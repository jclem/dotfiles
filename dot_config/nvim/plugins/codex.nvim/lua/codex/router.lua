local ipc = require("codex.ipc")
local util = require("codex.util")

local M = {}

local Router = {}
Router.__index = Router

function Router.new(socket_path, opts)
  return setmetatable({
    socket_path = socket_path,
    opts = opts or {},
    server = nil,
    clients = {},
    clients_by_id = {},
    pending_requests = {},
    pending_discoveries = {},
  }, Router)
end

function Router:send(client, message)
  if client and client.pipe and not client.pipe:is_closing() then
    client.pipe:write(ipc.encode_frame(message))
  end
end

function Router:broadcast_client_status(client, status)
  local message = {
    type = "broadcast",
    method = "client-status-changed",
    sourceClientId = client.id,
    version = 1,
    params = {
      clientId = client.id,
      clientType = client.type,
      status = status,
    },
  }

  for _, other in pairs(self.clients) do
    if other ~= client then
      self:send(other, message)
    end
  end
end

function Router:register_client(client, request_id, params)
  if client.id then
    self:send(client, {
      type = "response",
      requestId = request_id,
      resultType = "success",
      method = "initialize",
      handledByClientId = client.id,
      result = { clientId = client.id },
    })
    return
  end

  client.id = util.uuid()
  client.type = params and params.clientType or "unknown"
  self.clients_by_id[client.id] = client
  self:broadcast_client_status(client, "connected")
  self:send(client, {
    type = "response",
    requestId = request_id,
    resultType = "success",
    method = "initialize",
    handledByClientId = client.id,
    result = { clientId = client.id },
  })
end

function Router:unregister_client(client)
  self.clients[client.pipe] = nil
  if client.id then
    self.clients_by_id[client.id] = nil
    self:broadcast_client_status(client, "disconnected")
  end

  for request_id, pending in pairs(self.pending_requests) do
    if pending.target == client or pending.source == client then
      pending.timer:stop()
      pending.timer:close()
      self.pending_requests[request_id] = nil
      if pending.source ~= client then
        self:send(pending.source, {
          type = "response",
          requestId = pending.original_request_id,
          resultType = "error",
          error = "client-disconnected",
        })
      end
    end
  end
end

function Router:forward_request(source, request, target)
  local request_id = request.requestId
  local timer = util.uv.new_timer()
  self.pending_requests[request_id] = {
    source = source,
    target = target,
    original_request_id = request.requestId,
    timer = timer,
  }

  timer:start(request.timeoutMs or 10000, 0, function()
    local pending = self.pending_requests[request_id]
    if pending then
      self.pending_requests[request_id] = nil
      self:send(pending.source, {
        type = "response",
        requestId = pending.original_request_id,
        resultType = "error",
        error = "request-timeout",
      })
    end
    timer:stop()
    timer:close()
  end)

  self:send(target, request)
end

function Router:no_client(source, request)
  self:send(source, {
    type = "response",
    requestId = request.requestId,
    resultType = "error",
    error = "no-client-found",
  })
end

function Router:discover_target(source, request)
  local candidates = {}
  if request.targetClientId then
    local target = self.clients_by_id[request.targetClientId]
    if target and target ~= source then
      table.insert(candidates, target)
    end
  else
    for _, client in pairs(self.clients) do
      if client ~= source then
        table.insert(candidates, client)
      end
    end
  end

  if #candidates == 0 then
    self:no_client(source, request)
    return
  end

  local group_id = util.uuid()
  local group = {
    source = source,
    request = request,
    remaining = #candidates,
    resolved = false,
    timer = util.uv.new_timer(),
    ids = {},
  }

  group.timer:start(10000, 0, function()
    if not group.resolved then
      group.resolved = true
      self:no_client(source, request)
    end
    for _, id in ipairs(group.ids) do
      self.pending_discoveries[id] = nil
    end
    group.timer:stop()
    group.timer:close()
  end)

  for _, candidate in ipairs(candidates) do
    local discovery_id = util.uuid()
    table.insert(group.ids, discovery_id)
    self.pending_discoveries[discovery_id] = {
      group_id = group_id,
      group = group,
      target = candidate,
    }
    self:send(candidate, {
      type = "client-discovery-request",
      requestId = discovery_id,
      request = request,
    })
  end
end

function Router:handle_discovery_response(message)
  local pending = self.pending_discoveries[message.requestId]
  if not pending then
    return
  end

  self.pending_discoveries[message.requestId] = nil
  local group = pending.group
  if group.resolved then
    return
  end

  if message.response and message.response.canHandle then
    group.resolved = true
    group.timer:stop()
    group.timer:close()
    for _, id in ipairs(group.ids) do
      self.pending_discoveries[id] = nil
    end
    self:forward_request(group.source, group.request, pending.target)
    return
  end

  group.remaining = group.remaining - 1
  if group.remaining <= 0 then
    group.resolved = true
    group.timer:stop()
    group.timer:close()
    self:no_client(group.source, group.request)
  end
end

function Router:handle_request(client, message)
  if message.method == "initialize" then
    self:register_client(client, message.requestId, message.params or {})
    return
  end
  self:discover_target(client, message)
end

function Router:handle_response(message)
  local pending = self.pending_requests[message.requestId]
  if not pending then
    return
  end

  pending.timer:stop()
  pending.timer:close()
  self.pending_requests[message.requestId] = nil
  self:send(pending.source, message)
end

function Router:handle_message(client, message)
  if message.type == "request" then
    self:handle_request(client, message)
  elseif message.type == "response" then
    self:handle_response(message)
  elseif message.type == "client-discovery-response" then
    self:handle_discovery_response(message)
  elseif message.type == "broadcast" then
    for _, other in pairs(self.clients) do
      if other ~= client then
        self:send(other, message)
      end
    end
  end
end

function Router:add_client(pipe)
  local client = { pipe = pipe, id = nil, type = nil }
  self.clients[pipe] = client
  local reader = ipc.FrameReader.new(function(message)
    self:handle_message(client, message)
  end, function(err)
    util.notify("Codex IPC router parse error: " .. tostring(err), vim.log.levels.WARN)
  end)

  pipe:read_start(function(err, chunk)
    if err or not chunk then
      self:unregister_client(client)
      if not pipe:is_closing() then
        pipe:close()
      end
      return
    end
    reader:feed(chunk)
  end)
end

function Router:start(callback)
  if util.is_windows() then
    if callback then
      callback("router is not implemented for Windows named pipes")
    end
    return
  end

  vim.fn.mkdir(util.dirname(self.socket_path), "p")
  pcall(util.uv.fs_unlink, self.socket_path)
  self.server = util.uv.new_pipe(false)

  local ok, bind_result, bind_err = pcall(function()
    return self.server:bind(self.socket_path)
  end)
  if not ok or bind_err or (bind_result ~= nil and bind_result ~= 0) then
    if callback then
      callback(bind_err or (ok and bind_result) or "failed to bind IPC socket")
    end
    return
  end

  self.server:listen(128, function(err)
    if err then
      util.notify("Codex IPC router listen error: " .. tostring(err), vim.log.levels.WARN)
      return
    end
    local pipe = util.uv.new_pipe(false)
    self.server:accept(pipe)
    self:add_client(pipe)
  end)

  if callback then
    callback(nil, self)
  end
end

function Router:close()
  for _, client in pairs(self.clients) do
    if client.pipe and not client.pipe:is_closing() then
      client.pipe:read_stop()
      client.pipe:close()
    end
  end
  self.clients = {}
  self.clients_by_id = {}

  if self.server and not self.server:is_closing() then
    self.server:close()
  end
  self.server = nil
  pcall(util.uv.fs_unlink, self.socket_path)
end

local function can_connect(socket_path, callback)
  local pipe = util.uv.new_pipe(false)
  pipe:connect(socket_path, function(err)
    if not err and not pipe:is_closing() then
      pipe:close()
    end
    callback(err == nil)
  end)
end

function M.ensure(socket_path, callback)
  can_connect(socket_path, function(connected)
    vim.schedule(function()
      if connected then
        callback(nil, nil)
        return
      end

      local router = Router.new(socket_path)
      router:start(callback)
    end)
  end)
end

M.Router = Router

return M
