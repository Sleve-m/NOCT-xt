local InstanceExplorer = {}

local ReflectionsService = game:GetService("ReflectionService")

local ui = {}

local createUI = modules.createUI
local scriptViewer = modules.sVModule

local udpix, sudpix, sUDim2 = createUI.udpix, createUI.sudpix, createUI.sUDim2

local currentPath = {game}
local selectedInstances = {}
local links = {}
local snapshots = Instance.new("Folder", nil)
snapshots.Name = "Snapshots"
local instClipboard = {}

local ui = environment.NOCTUIS.IEUI

local iconsmapping = { 
	["Instance"]        = Vector2.new(0,0), 
	["Part"]            = Vector2.new(1,0),  
	["Model"]           = Vector2.new(2,0),  
	["Script"]          = Vector2.new(6,0), 
	["Sound"]           = Vector2.new(11,0), 
	["Player"]          = Vector2.new(12,0),
	["LocalScript"]     = Vector2.new(18,0), 
	["Workspace"]       = Vector2.new(19,0), 
	["ScreenGui"]       = Vector2.new(47,0), 
	["TextLabel"]       = Vector2.new(0,1),
    ["RemoteFunction"]  = Vector2.new(24,1),
	["RemoteEvent"]     = Vector2.new(25,1), 
	["ModuleScript"]    = Vector2.new(26,1), 
	["Folder"]          = Vector2.new(27,1)

}
local iconsize = 16

local function getChilds(inst, deep)
    return typeof(inst) == "Instance" and (deep and inst:GetDescendants() or inst:GetChildren()) or inst
end

local iconsImg = getimg("Class Icons.png")

local function applyIcon(img, inst)
    local index = iconsmapping[inst.ClassName] or Vector2.new(0,0)
	img.Image = iconsImg
	img.ImageRectSize = Vector2.new(iconsize, iconsize)
	img.ImageRectOffset = Vector2.new(index.X*iconsize, index.Y*iconsize)
end

function newSelectionOptions(pos, isSelected)
    local seloptsframe = createUI.createSelectionOptionFrame(pos)
    local object = #selectedInstances == 1 and selectedInstances[1] or nil

    --Singulars
    function createLink(obj) table.insert(links, obj) end
    function deleteInst(obj) obj:Destroy() end
    function createSnapshot(obj) obj:Clone().Parent = snapshots end
    function copy(obj) table.insert(instClipboard, obj:Clone()) end
    function cut(obj) copy(obj); deleteInst(obj) end
    function pasteHere(obj) obj:Clone().Parent = currPath[#currPath] end
    function decompileScript() createUI.swaptoframe(subframes["Script Viewer"]); modules.sVModule.viewScript(object) end
    function viewLogs(object)                                          end
    function pasteInto(obj)
        for _, inst in pairs(selectedInstances) do
            obj:Clone().Parent = inst
        end
    end

    function forAll(func)
        for _, inst in pairs(selectedInstances) do
            func(inst)
        end
    end

    function forAllinClipboard(func)
        for _, inst in pairs(instClipboard) do
            func(inst)
        end
    end

    --Plurals
    function createLinks() forAll(createLink) end
    function deleteInsts() forAll(deleteInst); refreshInstList() end
    function createSnapshots() forAll(createSnapshot) end
    function copys() table.clear(instClipboard); forAll(copy) end
    function cuts() table.clear(instClipboard); forAll(cut); refreshInstList() end
    function pasteHeres() forAllinClipboard(pasteHere); refreshInstList() end
    function pasteIntos() forAllinClipboard(pasteInto) end
    if #selectedInstances == 0 or not isSelected then
        createUI.createSelectionOption("Paste Here", pasteHere)
    elseif #selectedInstances == 1 then
        createUI.createSelectionOption("Delete", deleteInsts)
        createUI.createSelectionOption("Copy", copys)
        createUI.createSelectionOption("Cut", cuts)
        createUI.createSelectionOption("Paste Into", pasteIntos)
        createUI.createSelectionOption("Create Link", createLinks)
        createUI.createSelectionOption("Snapshot", createSnapshots)
        if object:IsA("LocalScript") or object:IsA("ModuleScript") then
            createUI.createSelectionOption("View Script", decompileScript)
        end
        if object:IsA("RemoteEvent") or object:IsA("RemoteFunction") then
            createUI.createSelectionOption("View Logs", viewLogs)
        end
    else
        createUI.createSelectionOption("Delete("..#selectedInstances..")", deleteInsts)
        createUI.createSelectionOption("Copy("..#selectedInstances..")", copys)
        createUI.createSelectionOption("Cut("..#selectedInstances..")", cuts)
        createUI.createSelectionOption("Paste Into("..#selectedInstances..")", pasteIntos)
        createUI.createSelectionOption("Create Link("..#selectedInstances..")", createLinks)
        createUI.createSelectionOption("Snapshot("..#selectedInstances..")", createSnapshots)
    end
    
end

function drawInstances(children)
    local scrollY = ui.instscroller.CanvasPosition.Y
    local windowHeight = ui.instscroller.AbsoluteWindowSize.Y
    local rowHeight = createUI.sNumber(12)
    local first = math.floor(scrollY / rowHeight) + 1
    local last = math.ceil((scrollY + windowHeight)/ rowHeight)
    if last > #children then
        last = #children
    end
    local currentlyVisible = {}
    for _, inst in pairs(getChilds(ui.instscroller, false)) do
        local index = tonumber(inst.Name)
        if index then
            if index < first or index > last then
                inst:Destroy()
            else
                currentlyVisible[index] = true
                inst.BackgroundTransparency = table.find(selectedInstances, children[index]) and 0.7 or 1
            end
        end
    end
    for i = first, last do
        if not currentlyVisible[i] and children[i] then
            local instObj = children[i]
            local newinst = ui.exampleinst:Clone()
            newinst.Name = tostring(i)
            newinst.Text = instObj.Name
            newinst.TextTruncate = Enum.TextTruncate.SplitWord
            newinst.Parent = ui.instscroller
            newinst.Position = sudpix(17, (i-1) * 12)
            newinst.Visible = true
            newinst.BackgroundTransparency = table.find(selectedInstances, instObj) and 0.7 or 1
            applyIcon(newinst.ImageLabel, instObj)
            newinst.MouseButton1Click:Connect(function()
                createUI.deleteSelectionOptionFrame()
                if not controls.addSelectDown and not controls.groupSelectDown then
                    if #selectedInstances == 1 and table.find(selectedInstances, instObj) then
                        table.insert(currentPath, instObj)
                        table.clear(selectedInstances)
                        refreshInstList(true)
                    else
                        selectedInstances = {instObj}
                    end
                elseif controls.groupSelectDown then
                    if #selectedInstances > 0 then
                        local top = nil
                        local bottom = nil
                        local instindex = table.find(children, instObj)
                        for n, m in pairs(selectedInstances) do
                            local mindex = table.find(children, m)
                            if not top or not bottom then top, bottom = mindex, mindex end
                            bottom = mindex < bottom and mindex or bottom
                            top = mindex > top and mindex or top
                        end
                        if instindex < bottom then
                            for n = instindex, bottom-1 do
                                table.insert(selectedInstances, children[n])
                            end
                        elseif instindex > top then
                            for n = top+1, instindex do
                                table.insert(selectedInstances, children[n])
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
                drawInstances(getChilds(currentPath[#currentPath]))
                refreshProperties()
            end)
            newinst.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    newSelectionOptions(udpix(input.Position.X, input.Position.Y), table.find(selectedInstances, instObj))
                end
            end)
        end
    end
end

function getAllProperties(inst)
	local results = {}
	local classprops = ReflectionsService:GetPropertiesOfClass(inst.ClassName)
	return classprops or results
end

function refreshProperties()
    for i, v in pairs(getChilds(ui.propscroller, false)) do
        v:Destroy()
    end
    ui.propscroller.CanvasPosition = Vector2.new(0,0)
    if #selectedInstances == 1 and selectedInstances[1] ~= nil then
        local props = getAllProperties(selectedInstances[1])
        local iter = 0
        for i, propInfo in pairs(props) do
            local propName = propInfo.Name
            local success, value = pcall(function()
                return selectedInstances[1][propName]
            end)
            if success then
                local newprop = ui.exampleprop:Clone()
                newprop.Parent = ui.propscroller
                newprop.Position = sudpix(0, (iter)*24)
                newprop.Text = propName..":"
                newprop.Visible = true
                local newvalue = ui.examplevalue:Clone()
                newvalue.Parent = ui.propscroller
                newvalue.Position = sudpix(0, (iter)*24+12)
                newvalue.Text = tostring(value)
                newvalue.Visible = true
                iter += 1
            end
        end
    end
end

function refreshInstList(totop)
    -- 1. Clear Lists
    for i, v in pairs(getChilds(ui.instscroller, false)) do
        v:Destroy()
    end
    for i, v in pairs(getChilds(ui.pathframe, false)) do
        v:Destroy()
    end

    -- 2. RESET SCROLL
    ui.instscroller.CanvasPosition = totop and Vector2.new(0,0) or ui.instscroller.CanvasPosition

    -- 3. ENSURE LAYOUT (The fix for "weird" positioning)
    -- This replaces your manual 'newx' calculation loops. 
    -- It automatically stacks buttons horizontally.
    if not ui.pathframe:FindFirstChildOfClass("UIListLayout") then
        local layout = Instance.new("UIListLayout")
        layout.Parent = ui.pathframe
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5) -- Optional padding between buttons
    end

    local children = getChilds(currentPath[#currentPath], false)

    -- 4. CREATE BREADCRUMBS
    for i, v in pairs(currentPath) do
        local newpathbtn = ui.examplepathitem:Clone()
        
        -- Set Text
        local instName = (typeof(v) == "Instance" and v.Name or "Search")
        newpathbtn.Text = instName .. "/"
        
        -- Sizing Logic
        -- We parent it first so AutomaticSize calculates correctly relative to the container
        newpathbtn.Parent = ui.pathframe
        newpathbtn.LayoutOrder = i -- Ensures they stay in order
        newpathbtn.Visible = true

        newpathbtn.AutomaticSize = Enum.AutomaticSize.X
        
        -- Optional: Cap the size if it gets too big (requires manual check after frame update)
        -- A better way is using a UISizeConstraint inside the button prefab, 
        -- but this keeps your logic simple:
        if newpathbtn.TextBounds.X > 80 then
             newpathbtn.AutomaticSize = Enum.AutomaticSize.None
             newpathbtn.Size = sudpix(80, 15)
        end

        -- Click Logic
        newpathbtn.MouseButton1Click:Connect(function()
            -- FIX: Iterate BACKWARDS when removing to avoid skipping shifting indices
            for n = #currentPath, i + 1, -1 do
                table.remove(currentPath, n)
            end
            refreshInstList()
        end)
    end

    refreshProperties()
    
    -- Update Canvas Size
    ui.instscroller.CanvasSize = sudpix(0, 12 * #children)
    
    -- Back Button Logic
    ui.back.ImageColor3 = #currentPath > 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,100,100)
    ui.back.Interactable = #currentPath > 1
    
    drawInstances(children)
end

function searchInstances(term)
    local currParent = currentPath[#currentPath-1]
    local searchResults = {}
    local isClassSearch = string.sub(term, 1, 1) == "*"
    local targetString = isClassSearch and string.lower(string.sub(term, 2)) or string.lower(term)

    local function checkAndAdd(inst)
        if isClassSearch then
            if string.find(string.lower(inst.ClassName), string.lower(targetString)) then
                table.insert(searchResults, inst)
            end
        else
            if string.find(string.lower(inst.Name), targetString, 1, true) then
                table.insert(searchResults, inst)
            end
        end
    end

    for _, child in pairs(getChilds(currentPath[#currentPath], true)) do
        checkAndAdd(child)
    end
    return searchResults
end

function InstanceExplorer.setup()
    ui = uis.IEUI
    ui.back.MouseButton1Click:Connect(function()
        currentPath[#currentPath] = nil
        refreshInstList(true)
    end)

    ui.tougc.MouseButton1Click:Connect(function()
        currentPath = {game}
        refreshInstList(true)
    end)

    ui.tolinks.MouseButton1Click:Connect(function()
        currentPath = {links}
        refreshInstList(true)
    end)

    ui.tosnapshots.MouseButton1Click:Connect(function()
        currentPath = {snapshots}
        refreshInstList(true)
    end)

    ui.nilinstances.MouseButton1Click:Connect(function()
        currentPath = {getnilinstances()}
        refreshInstList(true)
    end)

    ui.instscroller.Changed:Connect(function(prop)
        if prop == "CanvasPosition" or prop == "AbsoluteWindowSize" then
            drawInstances(getChilds(currentPath[#currentPath], false))
        end
    end)

    ui.searchbar.FocusLost:Connect(function(enterPressed)
        if enterPressed then table.insert(currentPath, searchInstances(ui.searchbar.Text)) end
        refreshInstList()
    end)

    refreshInstList(true)
end

return InstanceExplorer