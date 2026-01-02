local RemoteSpy = {}

local RunService = game:GetService("RunService")

local createUI = modules.createUI

local udpix, sudpix, sUDim2 = createUI.udpix, createUI.sudpix, createUI.sUDim2

local ui = {}
local currentRemotes = {}
local remoteList = {}
local selectedInstances = {}

local function sortBy(t, sortType)
    table.sort(t, function(a, b)
        local dataA = currentRemotes[a]
        local dataB = currentRemotes[b]

        if sortType == "TimeStamp" then
            local timeA = (dataA and dataA.Logs and dataA.Logs[1]) and dataA.Logs[1].TimeStamp or 0
            local timeB = (dataB and dataB.Logs and dataB.Logs[1]) and dataB.Logs[1].TimeStamp or 0
            
            return tostring(timeA) > tostring(timeB)

        elseif sortType == "Calls" then
            local callsA = dataA and dataA.Calls or 0
            local callsB = dataB and dataB.Calls or 0
            
            return callsA > callsB

        elseif sortType == "Name" then
            return a.Name:lower() < b.Name:lower()
        end
        
        return false
    end)
    return t
end

local sortorders = {
    [1] = {sortBy, "TimeStamp", "Recent"},
    [2] = {sortBy, "Name",      "abc"},
    [3] = {sortBy, "Calls",     "Most"}
}

local currentsort = 1

local function newSelectionOptions(pos, isSelected)
    createUI.createSelectionOptionFrame(pos)
    local object = #selectedInstances == 1 and selectedInstances[1] or nil

    --Singulars
    local function deleteInst(obj) cobj = obj or object; cobj:Destroy() end
    local function breakInst(obj) cobj = obj or object; currentRemotes[cobj].Blocked = true end
    local function path(obj) cobj = obj or object; toclipboard(obj:GetFullName()) end
    local function genref() local rstr = string.random(8); getgenv()[rstr] = object; print(rstr); toclipboard(rstr) end
    function viewLogs(obj) cobj = obj or object; createUI.swaptoframe(subframes["Log Viewer"]); local logs = currentRemotes[cobj].Logs; modules.lVModule.viewlogs(logs) end

    function forAll(func)
        for _, inst in pairs(selectedInstances) do
            func(inst)
        end
    end

    --Plurals
    local function deleteInsts() forAll(deleteInst); drawRemotes() end
    local function breakInsts() forAll(breakInst) end

    if #selectedInstances == 0 or not isSelected then
        createUI.deleteSelectionOptionFrame()
    elseif #selectedInstances == 1 then
        createUI.createSelectionOption("View Logs", viewLogs)
        createUI.createSelectionOption("Break", breakInst)
        createUI.createSelectionOption("Path", path)
        createUI.createSelectionOption("Gen ref", genref)
        createUI.createSelectionOption("Delete", deleteInsts)
    else
        createUI.createSelectionOption("Break("..#selectedInstances..")", breakInsts)
        createUI.createSelectionOption("Delete("..#selectedInstances..")", deleteInsts)
    end
end

local iconsmapping = { 
    ["RemoteFunction"]  = Vector2.new(24,1),
	["RemoteEvent"]     = Vector2.new(25,1)

}

local iconsize = 16

local iconsImg = getimg("Class Icons.png")

local function applyIcon(img, inst)
    local index = iconsmapping[inst.ClassName] or Vector2.new(0,0)
	img.Image = iconsImg
	img.ImageRectSize = Vector2.new(iconsize, iconsize)
	img.ImageRectOffset = Vector2.new(index.X*iconsize, index.Y*iconsize)
end

local instDataMap = {}

function drawRemotes()
    local scrollY = ui.scroller.CanvasPosition.Y
    local windowHeight = ui.scroller.AbsoluteWindowSize.Y
    local rowHeight = createUI.sNumber(12)
    ui.scroller.CanvasSize = sudpix(0, 12 * #remoteList)
    local first = math.floor(scrollY / rowHeight) + 1
    local last = math.ceil((scrollY + windowHeight)/ rowHeight)
    if last > #remoteList then
        last = #remoteList
    end
    local currentlyVisible = {}
    for _, inst in pairs(ui.scroller:GetChildren()) do
        local index = tonumber(inst.Name)
        if index then
            if (index < first or index > last) or not (instDataMap[inst] == currentRemotes[tonumber(inst.Name)]) then
                instDataMap[inst] = nil
                inst:Destroy()
            else
                currentlyVisible[index] = true
                inst.BackgroundTransparency = table.find(selectedInstances, remoteList[index]) and 0.7 or 1
                inst.TextLabel.Text = currentRemotes[remoteList[index]].Calls
                inst.TextColor3 = currentRemotes[remoteList[index]].Blocked and Color3.new(200,64,64) or Color3.new(200,200,200)
            end
        end
    end
    for i = first, last do
        if not currentlyVisible[i] and remoteList[i] then
            local instObj = remoteList[i]
            local newinst = ui.exampleremote:Clone()
            instDataMap[newinst] = instObj
            newinst.Name = tostring(i)
            newinst.Text = instObj.Name
            newinst.TextLabel.Text = currentRemotes[instObj].Calls
            newinst.TextColor3 = currentRemotes[instObj].Blocked and Color3.new(200,64,64) or Color3.new(200,200,200)
            newinst.TextTruncate = Enum.TextTruncate.SplitWord
            newinst.Parent = ui.scroller
            newinst.Position = sudpix(17, (i-1) * 12)
            newinst.Visible = true
            newinst.BackgroundTransparency = table.find(selectedInstances, instObj) and 0.7 or 1
            applyIcon(newinst.ImageLabel, instObj)
            newinst.MouseButton1Click:Connect(function()
                createUI.deleteSelectionOptionFrame()
                if not controls.addSelectDown and not controls.groupSelectDown then
                    if #selectedInstances == 0 or not table.find(selectedInstances, instObj) then
                        selectedInstances = {instObj}
                    elseif table.find(selectedInstances, instObj) then
                        createUI.swaptoframe(subframes["Log Viewer"]); local logs = currentRemotes[instObj].Logs; modules.lVModule.viewlogs(logs)
                    end
                elseif controls.groupSelectDown then
                    if #selectedInstances > 0 then
                        local top = nil
                        local bottom = nil
                        local instindex = table.find(remoteList, instObj)
                        for n, m in pairs(selectedInstances) do
                            local mindex = table.find(remoteList, m)
                            if not top or not bottom then top, bottom = mindex, mindex end
                            bottom = mindex < bottom and mindex or bottom
                            top = mindex > top and mindex or top
                        end
                        if instindex < bottom then
                            for n = instindex, bottom-1 do
                                table.insert(selectedInstances, remoteList[n])
                            end
                        elseif instindex > top then
                            for n = top+1, instindex do
                                table.insert(selectedInstances, remoteList[n])
                            end
                        else
                            table.insert(selectedInstances, instObj)
                        end
                    else
                        selectedInstances = {instObj}
                    end
                elseif controls.addSelectDown then
                    table.insert(selectedInstances, instObj)
                end
                drawRemotes()
            end)
            newinst.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    newSelectionOptions(udpix(input.Position.X, input.Position.Y), table.find(selectedInstances, instObj))
                end
            end)
        end
    end
end

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--Setup-------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

function RemoteSpy.setup()
    ui = uis.RSUI

    ui.scroller.Changed:Connect(function(prop)
        if prop == "CanvasPosition" or prop == "AbsoluteWindowSize" then
            drawRemotes()
        end
    end)

    ui.sortbtn.MouseButton1Click:Connect(function()
        currentsort = (currentsort % #sortorders) + 1
        sortorders[currentsort][1](remoteList, sortorders[currentsort][2])
        ui.sortbtn.Text = sortorders[currentsort][3]
        drawRemotes()
    end)

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

    local newCalls = {}

    local processNeeded = false

    local function dumpTable(o)
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

    local function processCalls()
        local cacheCalls = table.clone(newCalls)
        table.clear(newCalls)
        for _, call in pairs(cacheCalls) do
            local remote = currentRemotes[call.Instance]
            local validArgs = (type(call.Args) == "table") and call.Args or {}
            local vargs = {unpack(validArgs, 2)}
            local timestamp = call.TimeStamp
            if not remote then
                remote = remoteObj.new(call.Instance)
                currentRemotes[call.Instance] = remote
                table.insert(remoteList, 1, call.Instance)
                drawRemotes()
            end
            remoteObj.incrementCalls(remote, vargs, timestamp)
            sortorders[currentsort][1](remoteList, sortorders[currentsort][2])
        end
        drawRemotes()
    end

    RunService.Heartbeat:Connect(function()
        if processNeeded then processCalls(); processNeeded = false end
    end)

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

        if remotesViewing[instance.ClassName] and remoteMethods[method] then
            local remote = currentRemotes[instance]
            local scriptCaller = getcallingscript() 
            
            table.insert(newCalls, {
                Args = {...}, 
                Instance = instance, 
                Script = success and scriptCaller or nil, 
                TimeStamp = os.date("[%H:%M:%S]")
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
            if instance.ClassName == _name and remotesViewing[instance.ClassName] then
                local remote = currentRemotes[instance]
                local scriptCaller = getcallingscript
                local cleanArgs = select(2, args)
                table.insert(newCalls, {
                    Args = cleanArgs, 
                    Instance = instance, 
                    Script = scriptCaller, 
                    TimeStamp = os.date("[%H:%M:%S]")
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
end

return RemoteSpy