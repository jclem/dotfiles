local util = require("codex.util")

local M = {}

M.MAX_FRAME_BYTES = 256 * 1024 * 1024

local function uint32_le(value)
  local b1 = value % 256
  local b2 = math.floor(value / 256) % 256
  local b3 = math.floor(value / 65536) % 256
  local b4 = math.floor(value / 16777216) % 256
  return string.char(b1, b2, b3, b4)
end

local function read_uint32_le(value)
  local b1, b2, b3, b4 = string.byte(value, 1, 4)
  return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

function M.encode_frame(message)
  local payload = type(message) == "string" and message or util.json_encode(message)
  return uint32_le(#payload) .. payload
end

M.FrameReader = {}
M.FrameReader.__index = M.FrameReader

function M.FrameReader.new(on_message, on_error)
  return setmetatable({
    buffer = "",
    on_message = on_message,
    on_error = on_error,
  }, M.FrameReader)
end

function M.FrameReader:fail(message)
  self.buffer = ""
  if self.on_error then
    self.on_error(message)
  end
end

function M.FrameReader:feed(chunk)
  if not chunk or chunk == "" then
    return
  end

  self.buffer = self.buffer .. chunk

  while #self.buffer >= 4 do
    local length = read_uint32_le(self.buffer)
    if length == 0 or length > M.MAX_FRAME_BYTES then
      self:fail("invalid frame length: " .. tostring(length))
      return
    end

    if #self.buffer < 4 + length then
      return
    end

    local payload = self.buffer:sub(5, 4 + length)
    self.buffer = self.buffer:sub(5 + length)

    local ok, message = pcall(util.json_decode, payload)
    if not ok then
      self:fail("invalid JSON frame")
      return
    end

    self.on_message(message)
  end
end

local Client = {}
Client.__index = Client

function Client.new(opts)
  return setmetatable({
    socket_path = opts.socket_path,
    client_type = opts.client_type or "neovim",
    handlers = opts.handlers or {},
    request_timeout_ms = opts.request_timeout_ms or 5000,
    pipe = nil,
    reader = nil,
    connected = false,
    client_id = nil,
    pending = {},
  }, Client)
end

function Client:send(message)
  if not self.pipe or self.pipe:is_closing() then
    return false
  end
  self.pipe:write(M.encode_frame(message))
  return true
end

function Client:send_request(method, params, callback)
  local request_id = util.uuid()
  local timer = util.uv.new_timer()
  self.pending[request_id] = { callback = callback, timer = timer }
  timer:start(self.request_timeout_ms, 0, function()
    local pending = self.pending[request_id]
    if pending then
      self.pending[request_id] = nil
      pending.callback(nil, "timeout")
    end
    timer:stop()
    timer:close()
  end)
  self:send({
    type = "request",
    requestId = request_id,
    sourceClientId = self.client_id or "initializing-client",
    version = 1,
    method = method,
    params = params or {},
  })
end

function Client:handle_response(message)
  local pending = self.pending[message.requestId]
  if pending then
    self.pending[message.requestId] = nil
    pending.timer:stop()
    pending.timer:close()
    vim.schedule(function()
      pending.callback(message)
    end)
  end

  if message.resultType == "success" and message.method == "initialize" then
    self.client_id = message.result and message.result.clientId or self.client_id
    self.connected = true
  end
end

function Client:handle_discovery(message)
  vim.schedule(function()
    local request = message.request or {}
    local handler = self.handlers[request.method]
    local can_handle = false
    if handler then
      local ok, result = pcall(handler.can_handle or function()
        return true
      end, request.params or {})
      can_handle = ok and result == true
    end

    self:send({
      type = "client-discovery-response",
      requestId = message.requestId,
      response = { canHandle = can_handle },
    })
  end)
end

function Client:handle_request(message)
  vim.schedule(function()
    local handler = self.handlers[message.method]
    if not handler then
      self:send({
        type = "response",
        requestId = message.requestId,
        resultType = "error",
        error = "no-handler-for-request",
      })
      return
    end

    local ok, result = pcall(handler.handle, message.params or {}, message)
    if not ok then
      self:send({
        type = "response",
        requestId = message.requestId,
        resultType = "error",
        error = tostring(result),
      })
      return
    end

    self:send({
      type = "response",
      requestId = message.requestId,
      resultType = "success",
      method = message.method,
      handledByClientId = self.client_id,
      result = result,
    })
  end)
end

function Client:handle_message(message)
  if message.type == "response" then
    self:handle_response(message)
  elseif message.type == "client-discovery-request" then
    self:handle_discovery(message)
  elseif message.type == "request" then
    self:handle_request(message)
  end
end

function Client:connect(callback)
  self.pipe = util.uv.new_pipe(false)
  self.reader = M.FrameReader.new(function(message)
    self:handle_message(message)
  end, function(err)
    util.notify("Codex IPC parse error: " .. tostring(err), vim.log.levels.WARN)
  end)

  self.pipe:connect(self.socket_path, function(err)
    if err then
      if callback then
        vim.schedule(function()
          callback(err)
        end)
      end
      return
    end

    self.pipe:read_start(function(read_err, chunk)
      if read_err then
        util.notify("Codex IPC read error: " .. tostring(read_err), vim.log.levels.WARN)
        return
      end
      if chunk then
        self.reader:feed(chunk)
      end
    end)

    self:send_request("initialize", { clientType = self.client_type }, function(_, init_err)
      if callback then
        callback(init_err)
      end
    end)
  end)
end

function Client:close()
  for id, pending in pairs(self.pending) do
    pending.timer:stop()
    pending.timer:close()
    self.pending[id] = nil
  end

  if self.pipe and not self.pipe:is_closing() then
    self.pipe:read_stop()
    self.pipe:close()
  end
  self.pipe = nil
  self.connected = false
  self.client_id = nil
end

M.Client = Client

return M
