local RemoteSpy = {}

local RunService = game:GetService("RunService")

local remoteObj = modules.remoteObject

local remoteMethods = {
    FireServer = true,
    InvokeServer = true,
    Fire = true,
    Invoke = true
}

local remotesViewing = {
    RemoteEvent = true,
    RemoteFunction = true,
    BindableEvent = true,
    BindableFunction = true
}

local currentRemotes = {}

local newCalls = {}

local remoteDataEvent = Instance.new("BindableEvent")
local eventSet = false

local function connectEvent(callback)
    remoteDataEvent.Event:Connect(callback)

    if not eventSet then
        eventSet = true
    end
end

local processNeeded = false

function dumpTable(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dumpTable(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function processCalls()
    local cacheCalls = table.clone(newCalls)
    table.clear(newCalls)
    for _, call in pairs(cacheCalls) do
        local remote = currentRemotes[call.Instance]
        print("Remote called: "..call.Instance.Name)
        local validArgs = (type(call.Args) == "table") and call.Args or {}
        local vargs = {unpack(validArgs, 2)}
        if not remote then
            remote = remoteObj.new(call.Instance)
            currentRemotes[call.Instance] = remote
        end
        if eventSet then
            local scall = {
                script = call.Script,
                args = vargs,
                func = getinfo(3).func
            }
            remoteObj.IncrementCalls(remote, scall)
            remoteDataEvent.Fire(remoteDataEvent, instance, scall)
        end
    end
end

local alertprint = ""
local ACLogs = ""

local loggedChecks = {}

local loggedclocks = {}
local loggedclockchecks = {}

writefile("NOCT-xt/ACLogs.txt", "")

RunService.Heartbeat:Connect(function()
    if processNeeded then processCalls(); processNeeded = false end
    if alertprint ~= "" then 
        print("Alert: "..alertprint)
        appendfile("NOCT-xt/ACLogs.txt" ,"\n"..tostring(os.clock()).."\t : "..alertprint)
        alertprint = ""
    end
end)

local oldPcall = clonefunction(pcall)

local oldIsCClosure = clonefunction(iscclosure)
local oldIsLClosure = clonefunction(islclosure)
local oldDebugInfo = clonefunction(debug.info)
local oldTraceback = clonefunction(debug.traceback)
local oldGetCallStack = clonefunction(debug.getcallstack)
local oldGetStack = clonefunction(debug.getstack)
local oldGetUpvalues = clonefunction(debug.getupvalues)
local oldGetProtos = clonefunction(debug.getprotos)
local oldGetConstants = clonefunction(debug.getconstants)
local oldRawEqual = clonefunction(rawequal)
local oldIsFunctionHooked = clonefunction(isfunctionhooked)
local oldIsExecutorClosure = clonefunction(isexecutorclosure)
local oldCoroutineRunning = clonefunction(coroutine.running)
local oldCoroutineStatus = clonefunction(coroutine.status)
local oldOsClock = clonefunction(os.clock)

local protectedFunctions = {
    [islclosure] = clonefunction(islclosure),
    [iscclosure] = clonefunction(iscclosure),
    [debug.info] = clonefunction(debug.info),
    [debug.traceback] = clonefunction(debug.traceback),
    [debug.getcallstack] = clonefunction(debug.getcallstack),
    [debug.getstack] = clonefunction(debug.getstack),
    [debug.getupvalues] = clonefunction(debug.getupvalues),
    [debug.getprotos] = clonefunction(debug.getprotos),
    [debug.getconstants] = clonefunction(debug.getconstants),
    [rawequal] = clonefunction(rawequal),
    [isfunctionhooked] = clonefunction(isfunctionhooked),
    [isexecutorclosure] = clonefunction(isexecutorclosure),
    [coroutine.running] = clonefunction(coroutine.running),
    [coroutine.status] = clonefunction(coroutine.status),
    [os.clock] = clonefunction(os.clock)
}

local protectedFunctionsbare = {
    islclosure,
    iscclosure,
    debug.info,
    debug.traceback,
    debug.getcallstack,
    debug.getstack,
    debug.isvalidlevel,
    debug.getupvalues,
    debug.getprotos,
    debug.getconstants,
    rawequal,
    isfunctionhooked,
    isexecutorclosure,
    coroutine.running,
    coroutine.status,
    os.clock
}

local oldGetRawMetatable = clonefunction(getrawmetatable)
local mt = oldGetRawMetatable(game)
local oldNameCall = clonefunction(mt.__namecall)
local oldIndex = clonefunction(mt.__index)
local oldLt = mt.__lt
local oldSub = mt.__sub

setreadonly(mt, false)

hookfunction(getrawmetatable, newcclosure(function(obj)
    if not checkcaller() then
        if obj == game then
            alertprint = "AC called getrawmetatable(game)"
        end
    end
    return protectedFunctions[oldGetRawMetatable](obj)
end))

local clockcheckcachelength = 100

mt.__sub = newcclosure(function(op1, op2)
    if not checkcaller and type(op1) == "number" then
        if table.find(loggedclocks, op1) and table.find(loggedclocks, op2) then
            table.insert(loggedclockchecks, oldSub(op1, op2))
            if #loggedclockchecks>clockcheckcachelength then table.remove(loggedclockchecks, clockcheckcachelength+1) end
        end
    end
    return oldSub(op1, op2)
end)

mt.__lt = newcclosure(function(op1, op2)
    if not checkcaller() then
        if table.find(loggedclockchecks, op1) or table.find(loggedclockchecks, op2) then
            alertprint = "AC checked function time"
                if table.find(loggedclockchecks, op1) then return true else return false end
        end
    end
    return oldLt(op1, op2)
end)

local clockcachelength = 10

hookfunction(os.clock, newcclosure(function(time)
    if not checkcaller() then
        table.insert(loggedclocks, 1, time)
        if #loggedclocks>clockcachelength then table.remove(loggedclocks, clockcachelength+1) end
    end
    return oldOsClock(time)
end))

local protectionMap = {}

for func, clone in pairs(protectedFunctions) do
    protectionMap[func] = clone
end

--[[hookfunction(pcall, newcclosure(function(...)   -- comented out because it causes detection
    if not checkcaller() then
        local args = {...}
        local funcToCall = args[1]
        
        local safeClone = protectionMap[funcToCall]
        
        if safeClone then
            local cleanResults = { oldPcall(safeClone, select(2, ...)) }
            local success = cleanResults[1]

            if not success then
                alertprint = "AC attempted to fuzz a protected function: " .. tostring(funcToCall).."\t : "..tostring(getcallingscript())
                return unpack(cleanResults)
            end
            
        end
    end

    return oldPcall(...)
end))]]

hookfunction(coroutine.running, newcclosure(function(co)    --both commented out because causes lag in games where it is spammed
    if not checkcaller() then alertprint = "AC checked coroutine.status".."\t : "..tostring(getcallingscript()) end
    return protectedFunctions[oldCoroutineRunning](co)
end))

hookfunction(coroutine.status, newcclosure(function(co)
    if not checkcaller() then alertprint = "AC checked coroutine.status".."\t : "..tostring(getcallingscript()) end
    return oldCoroutineStatus(co)
end))

hookfunction(debug.isvalidlevel, newcclosure(function(...)
    if not checkcaller() then
        alertprint = "AC checked debug.isvalidlevel"
    end
    return oldIsValidLevel(...)
end))

hookfunction(debug.getstack, newcclosure(function(...)
    if not checkcaller() then
        alertprint = "AC checked debug.getstack"
    end
    return oldGetStack(...)
end))

hookfunction(debug.getcallstack, newcclosure(function(...)
    if not checkcaller() then
        alertprint = "AC checked debug.getcallstack"
    end
    return oldGetCallStack(...)
end))

hookfunction(isexecutorclosure, newcclosure(function(...)
    if not checkcaller() then
        alertprint = "AC checked if a function was native to your executor"
        return false
    end
    return oldIsExecutorClosure(...)
end))

hookfunction(isfunctionhooked, newcclosure(function(...)
    if not checkcaller() then
        alertprint = "AC checked if a function was hooked"
        return false
    end
    return oldIsFunctionHooked(...)
end))

hookfunction(debug.getconstants, newcclosure(function(...)
    if not checkcaller() then
        alertprint = "AC checked debug.getconstants"
    end
    return oldGetConstants(...)
end))

hookfunction(debug.getprotos, newcclosure(function(...)
    if not checkcaller() then
        alertprint = "AC checked debug.getprotos"
    end
    return oldGetProtos(...)
end))

hookfunction(debug.getupvalues, newcclosure(function(...)
    if not checkcaller() then
        alertprint = "AC checked debug.getupvalues"
    end
    return oldGetUpvalues(...)
end))

hookfunction(rawequal, newcclosure(function(...)
    local arg1, arg2 = ...
    if not checkcaller() then
        if protectedFunctionsbare[arg1] or protectedFunctionsbare[arg2] then
            alertprint = "AC checked integrity of "..arg1.." against "..arg2.." using rawequal"
            return true
        end
    end
    return oldRawEqual(...)
end))

hookfunction(debug.info, newcclosure(function(arg1, ...)
    if not checkcaller() then
        local logKey = ""
        
        if type(arg1) == "number" then
            local success, name, src = pcall(oldDebugInfo, arg1, "ns")
            
            if success then
                name = name or "anonymous"
                src = src or "unknown source"
                logKey = "Stack Level " .. tostring(arg1) .. " -> " .. name .. " (" .. src .. ")"
            else
                logKey = "Stack Level " .. tostring(arg1) .. " (Could not resolve)"
            end
            if not loggedChecks[logKey] then
                loggedChecks[logKey] = true
                alertprint = "AC Check: "..logKey.."\t : "..tostring(getcallingscript())
            end
            return oldDebugInfo(arg1+1, ...)

        elseif type(arg1) == "function" then
            if arg1 == mt.__namecall then
                logKey = "Function: __namecall"
            elseif arg1 == mt.__index then
                logKey = "Function: __index"
            elseif arg1 == print then
                logKey = "Function: print (Integrity Check)"
            else
                local success, src = pcall(oldDebugInfo, arg1, "s")
                local _, name = pcall(oldDebugInfo, arg1, "n")
                
                src = success and src or "unknown"
                name = name or "anonymous"
                
                logKey = "Function: " .. name .. " inside " .. src
            end
        else
            logKey = "Type: " .. typeof(arg1)
        end

        if not loggedChecks[logKey] then
            loggedChecks[logKey] = true
            alertprint = "AC Check: "..logKey.."\t : "..tostring(getcallingscript())
        end
    end

    return oldDebugInfo(arg1, ...)
end))

hookfunction(islclosure, newcclosure(function(func)
    if not checkcaller() then
        local logKey = tostring(func)
        if func == mt.__namecall then logKey = "__namecall" end
        if func == mt.__index then logKey = "__index" end
        
        if not loggedChecks["lclosure"..logKey] then
            loggedChecks["lclosure"..logKey] = true
            alertprint = "AC checked islclosure(" .. logKey .. ")"
        end
        if alertprint == "" then alertprint = "AC checked islclosure" end
    end
    return oldIsLClosure(func)
end))

hookfunction(iscclosure, newcclosure(function(func)
    if not checkcaller() then
        local logKey = tostring(func)
        if func == mt.__namecall then logKey = "__namecall" end
        if func == mt.__index then logKey = "__index" end
        
        if not loggedChecks["cclosure_"..logKey] then
            loggedChecks["cclosure_"..logKey] = true
            alertprint = "AC checked iscclosure(" .. logKey .. ")"
        end
        if alertprint == "" then alertprint = "AC checked iscclosure" end
    end
    return oldIsCClosure(func)
end))

function scrub(result)
    local cleanResult = ""
    for line in result:gmatch("[^\r\n]+") do
        if line:find("ReplicatedStorage") 
           or line:find("PlayerScripts") 
           or line:find("CoreGui") 
           or line:find("Players")
           or line:find("Workspace")
           or line:find("Starter")
           or line:find("Backpack")
        then
            cleanResult = cleanResult .. line .. "\n"
        end
    end
    
    if cleanResult == "" then 
        return result 
    else
        return cleanResult:sub(1, -2) 
    end
end

hookfunction(debug.traceback, newcclosure(function(...)
    local result = oldTraceback(...)
    if not checkcaller() then
        alertprint = "AC is checking debug.traceback".."\t : "..tostring(getcallingscript())
        return scrub(result)
    end
    return result
end))

setreadonly(mt, true)

local originalNC

local newNC
newNC = newcclosure(function(...)
    local instance = ...
    
    if typeof(instance) ~= "Instance" then
        return originalNC(...)
    end

    local method = getnamecallmethod()
    
    if method == "fireServer" then
        method = "FireServer"
    elseif method == "invokeServer" then
        method = "InvokeServer"
    end

    if remotesViewing[instance.ClassName] and instance ~= remoteDataEvent and remoteMethods[method] then
        local remote = currentRemotes[instance]
        local scriptCaller = getcallingscript() 
        
        table.insert(newCalls, {
            Args = {...}, 
            Instance = instance, 
            Script = success and scriptCaller or nil, 
            Time = os.clock()
        })
        
        processNeeded = true
        
        if remote and remote.Blocked then
            return
        end
    end
    return originalNC(...)
end)

setstackhidden(newNC, true)

originalNC = hookmetamethod(game, "__namecall", newNC)

local reRef = Instance.new("RemoteEvent")
local rfRef = Instance.new("RemoteFunction")
local beRef = Instance.new("BindableEvent")
local bfRef = Instance.new("BindableFunction")

local methodHooks = {
    RemoteEvent = reRef.FireServer,
    RemoteFunction = rfRef.InvokeServer,
    BindableEvent = beRef.Fire,
    BindableFunction = bfRef.Invoke
}

local function checkPermission(instance)
    if (instance.ClassName) then end
end

for _name, targetFunction in pairs(methodHooks) do
    local originalMethod
    local newMethodHook
    newMethodHook = newcclosure(function(...)
        local args = {...}
        local instance = args[1]
        if typeof(instance) ~= "Instance" then
            return originalMethod(...)
        end
        local success = pcall(checkPermission, instance)
        if (not success) then return originalMethod(...) end
        if instance.ClassName == _name and remotesViewing[instance.ClassName] and instance ~= remoteDataEvent then
            local remote = currentRemotes[instance]
            local scriptCaller = getcallingscript
            local cleanArgs = select(2, args)
            table.insert(newCalls, {
                Args = cleanArgs, 
                Instance = instance, 
                Script = scriptCaller, 
                Time = os.clock()
            })
            processNeeded = true
            if remote and remote.Blocked then
                return
            end
        end
        return originalMethod(...)
    end)
    setstackhidden(newMethodHook, true)
    originalMethod = hookfunction(targetFunction, newMethodHook)
end
reRef:Destroy()
rfRef:Destroy()
beRef:Destroy()
bfRef:Destroy()

print("Hooks initialized safely")

RemoteSpy.RemotesViewing = remotesViewing
RemoteSpy.CurrentRemotes = currentRemotes
RemoteSpy.ConnectEvent = connectEvent
return RemoteSpy