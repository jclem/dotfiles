# Reads log lines from Fly.io, omits the Fly.io prefix ()
function flylog
    fly logs --json | jq -r '.message | fromjson?'
end
