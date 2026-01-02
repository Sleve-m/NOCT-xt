local FunctionWatcher = {}

local RunService = game:GetService("RunService")

local funcs = {"firesignal", "makefolder", "rconsolehide", "clonefunction", "clear_teleport_queue", "cansignalreplicate", "isscriptable", "debug.dumpheap", "debug.getconstants", "debug.getproto", "debug.setmemorycategory", "debug.profilebegin", "debug.isvalidlevel", "debug.traceback", "debug.getstack", "debug.getcallstack", "debug.loadmodule", "debug.getupvalues", "debug.getupvalue", "debug.getmemorycategory", "debug.resetmemorycategory", "debug.setmetatable", "debug.getinfo", "debug.setupvalue", "debug.dumpcodesize", "debug.setstack", "debug.getconstant", "debug.profileend", "debug.dumprefs", "debug.validlevel", "debug.getprotos", "debug.setconstant", "debug.getmetatable", "debug.info", "getfflag", "consolecreate", "isnewcclosure", "getexecutorname", "lz4decompress", "consoledestroy", "isgameactive", "keytap", "setfflag", "crypt.base64_decode", "crypt.lz4compress", "crypt.base64.encode", "crypt.base64.decode", "crypt.hmac", "crypt.generatekey", "crypt.lz4decompress", "crypt.base64decode", "crypt.encrypt", "crypt.base64encode", "crypt.generatebytes", "crypt.decrypt", "crypt.hash", "crypt.base64_encode", "crypt.random", "setthreadcontext", "getrenv", "toclipboard", "newcclosure", "gethiddenproperties", "isparallel", "get_signal_cons", "isfunctionhooked", "getsignalarguments", "cloneref", "get_process_identifier", "getmodules", "http_request", "getprotos", "isourclosure", "getrendersteppedlist", "isfile", "getproto", "saveplace", "isrbxactive", "rconsoleinfo", "queueonteleport", "rconsolename", "getupvalue", "consolesettitle", "mousemoveabs", "mouse1click", "setupvalue", "isfolder", "queueteleport", "isrenderobj", "identifyexecutor", "get_comm_channel", "getscripts", "getnilinstances", "isvalidlevel", "gettenv", "restorefunction", "getproperties", "getupvalues", "get_hidden_gui", "rconsoleclear", "rconsoleprint", "create_comm_channel", "bit.band", "bit.arshift", "bit.rshift", "bit.ror", "bit.bor", "bit.bnot", "bit.badd", "bit.bsub", "bit.bxor", "bit.tobit", "bit.bswap", "bit.rol", "bit.lshift", "bit.tohex", "bit.bdiv", "bit.bmul", "VoltSignal.new", "getfunctionhash", "isreadonly", "messagebox", "mouse2click", "getinfo", "sethiddenproperty", "writefile", "base64_encode", "loadfile", "setrbxclipboard", "getconstant", "setclipboard", "filtergc", "WebSocket.connect", "getcallbackmember", "dumpstring", "getnamecallmethod", "getactors", "getrawmetatable", "makewritable", "getconnections", "checkcaller", "makereadonly", "rconsoledestroy", "isexecutorclosure", "lift_closure", "setrawmetatable", "setreadonly", "rconsoletop", "getscriptfromthread", "setsimulationradius", "rconsolehidden", "getloadedmodules", "setrenderproperty", "getrunningscripts", "lift_and_load_closure", "setconstant", "set_thread_identity", "saveinstance", "getinstances", "getconstants", "firetouchinterest", "cache.replace", "cache.iscached", "cache.invalidate", "keypress", "getsignalwhitelist", "isnetworkowner", "compareinstances", "Drawing.new", "getsignalargumentsinfo", "delfile", "rconsoletoggle", "getrenderproperty", "readfile", "getscriptclosure", "gethui", "setnamecallmethod", "consoleprint", "hookmetamethod", "getsenv", "runfile", "iscclosure", "cleardrawcache", "hookfunction", "loadstring", "getcallingscript", "validlevel", "replaceclosure", "hookfunc", "setscriptable", "rconsoleerr", "gethiddenproperty", "get_thread_identity", "getidentity", "delfolder", "getgenv", "keyrelease", "getthreadcontext", "getthreadidentity", "consoleinput", "getscripthash", "setidentity", "setthreadidentity", "getcallstack", "getinstancecache", "mousemoverel", "mousescroll", "base64_decode", "mouse2release", "request", "mouse1release", "fireproximityprompt", "mouse1press", "keyclick", "getscriptfunction", "islclosure", "rconsolewarn", "http.request", "mouse2press", "replicatesignal", "listfiles", "getfpscap", "run_on_actor", "get_current_actor", "lz4compress", "rconsolesettitle", "appendfile", "getscriptbytecode", "consoleclear", "queue_on_teleport", "gethwid", "getgc", "getcustomasset", "restorefunc", "checkclosure", "setfpscap", "setstackhidden", "on_actor_added.__index", "newlclosure", "getregistry", "iswriteble", "fireclickdetector", "iscustomcclosure", "rconsoleinput", "rconsolecreate", "getreg", "setstack", "getstack", "rconsoleshow", "dofile", "iswindowactive", "clonereference", "clearteleportqueue", "getcallbackvalue"}

local ui = {}

function FunctionWatcher.setup()
    ui = uis.FWUI
    local alertprint = ""
    local ACLogs = ""

    local loggedChecks = {}

    writefile("NOCT-xt/ACLogs.txt", "")
    RunService.Heartbeat:Connect(function()
        if alertprint ~= "" then 
            --print("Alert: "..alertprint)
            appendfile("NOCT-xt/ACLogs.txt" ,"\n"..tostring(os.clock()).."\t : "..alertprint)
            alertprint = ""
        end
    end)
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
        [coroutine.status] = clonefunction(coroutine.status)
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
        coroutine.status
    }
    local oldGetRawMetatable = clonefunction(getrawmetatable)
    local mt = oldGetRawMetatable(game)
    local oldNameCall = clonefunction(mt.__namecall)
    local oldIndex = clonefunction(mt.__index)

    setreadonly(mt, false)
    hookfunction(getrawmetatable, newcclosure(function(obj)
        if not checkcaller() then
            if obj == game then
                alertprint = "AC called getrawmetatable(game)"
            end
        end
        return protectedFunctions[oldGetRawMetatable](obj)
    end))

    local protectionMap = {}

    for func, clone in pairs(protectedFunctions) do
        protectionMap[func] = clone
    end

    hookfunction(coroutine.running, newcclosure(function(co)
        if not checkcaller() then alertprint = "AC checked coroutine.status".."\t : "..tostring(getcallingscript()) end
        return oldCoroutineRunning(co)
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

    hookfunction(debug.info, newcclosure(function(arg1, arg2, ...)
        if not checkcaller() then
            if type(arg1) == "number" then
                local _, name, src = pcall(oldDebugInfo, arg1, "ns")
                name = name or "anonymous"
                src = src or "unknown"
                
                local logKey = `Stack(Num) {arg1} -> {name} ({src})`
                if not loggedChecks[logKey] then
                    loggedChecks[logKey] = true
                    alertprint = "AC Check:"..logKey
                end

                return oldDebugInfo(arg1 + 1, arg2, ...)

            elseif type(arg1) == "thread" and type(arg2) == "number" then
                local _, name, src = pcall(oldDebugInfo, arg1, arg2, "ns")
                name = name or "anonymous"
                src = src or "unknown"
                
                local logKey = `Stack(Thr) {arg2} -> {name} ({src})`
                if not loggedChecks[logKey] then
                    loggedChecks[logKey] = true
                    alertpring = "AC Check:"..logKey
                end

                return oldDebugInfo(arg1, arg2 + 1, ...)

            elseif type(arg1) == "function" then
            end
        end

        return oldDebugInfo(arg1, arg2, ...)
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
end

return FunctionWatcher