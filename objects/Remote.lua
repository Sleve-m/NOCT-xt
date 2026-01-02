local Remote = {}

function Remote.new(instance)
    local remote = {}

    remote.Instance = instance
    remote.Logs = {}
    remote.Calls = 0
    remote.Blocked = false
    remote.Ignored = false
    remote.Intercepted = false
    remote.Clear = Remote.clear
    remote.Block = Remote.block
    remote.BlockedArgs = {}
    remote.IgnoredArgs = {}
    remote.Intercept = Remote.intercept

    return remote
end

function Remote.clear(remote)
    remote.Calls = 0
    remote.Logs = {}
end

function Remote.block(remote)
    remote.Blocked = not remote.Blocked
end

function Remote.incrementCalls(remote, vargs, timestamp)
    remote.Calls += 1
    table.insert(remote.Logs, 1, {Args = vargs, TimeStamp = timestamp})
end

function Remote.intercept(remote, args)
    if remote.Blocked then
        return true
    end

    if remote.AreArgsBlocked(remote, args) then
        return true
    end

    if not remote.Ignored and not remote.AreArgsIgnored(remote, args) then
        remote.IncrementCalls(remote, args)
    end

    return false
end

return Remote