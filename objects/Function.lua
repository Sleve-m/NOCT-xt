local Function = {}

function Function.new(newfunc, funcfile)
    local func = {}

    func.Function = newfunc
    func.Logs = {}
    func.Calls = 0
    func.File = funcfile
    
    return func
end

function Function.clear(func)
    func.Calls = 0
    func.Logs = {}
end

function Function.incrementCalls(func, vargs, timestamp)
    func.Calls += 1
    table.insert(func.Logs, 1, {Args = vargs, TimeStamp = timestamp})
end

return Function