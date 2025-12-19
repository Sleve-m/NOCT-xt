local MainFrame = {}

local createUI = import("ui/create.lua")
local UIsizing = import("ui/sizing.lua")
local udpix, sudpix, sUDim2 = UISizing.udpix, UISizing.sudpix, UISizing.sUDim2

function MainFrame.createMainFrame()
    local minimize = createUI.createText(nil, "Noct xt", sudpix(50,15), UDim2.new(0.5,-140,0.5,-80), true)
    createUI.createGrad(minimize, createUI.colorgrads[1], 0)
    minimize.ZIndex = 5
    minimize.FontFace.Weight = Enum.FontWeight.Bold
    local border = createUI.createFrame(minimize, sudpix(282,162), udpix(0,0), false)
    createUI.createGrad(border, createUI.colorgrads[2], 45)
    border.BackgroundColor3 = Color3.new(1,1,1)
    border.BackgroundTransparency = 0.5
    minimize.MouseButton1Click:Connect(function()
        border.Visible = not border.Visible
    end)
    local main = createUI.createFrame(border, sudpix(280,160), sudpix(1,1), false)
    createUI.makeDraggable(main, minimize)
    local titletext = createUI.createText(main, "Home", sudpix(50,15), UDim2.new(0.5,-25,0,0), false)
    createGrad(titletext, createUI.colorgrads[3], 0)
    local topline = createUI.createFrame(main, sudpix(280,1), sudpix(0,15), false)
    topline.BackgroundColor3 = Color3.fromRGB(100,100,100)
    createUI.createGrad(topline, createUI.colorgrads[3], 0)
    local kill = createUI.createText(main, "X", sudpix(15,15), sUDim2.new(1,-15,0,0), true)
    createUI.createGrad(kill, createUI.colorgrads[2], 45)
    kill.MouseEnter:Connect(function()
	    kill.UIGradient.Color = createUI.grad2(Color3.fromRGB(255,32,32),Color3.fromRGB(32,32,32))
    end)
    kill.MouseLeave:Connect(function()
	    kill.UIGradient.Color = createUI.grad2(Color3.fromRGB(255,255,255), Color3.fromRGB(32,32,32))
    end)
    local function createSubFrame(name, folder)
        local subframe = createUI.createFrame(folder, sudpix(265,144), sudpix(15,16), false)
        subframe.Name = name
    end
    local subframes = {
        "Closure Scanner",
        "Home",
        "Instance Explorer",
        "Log Viewer",
        "Remote Spy",
        "Script Searcher",
        "Script Viewer",
        "Settings",
        "Upvalue Scanner",
        "Value Editor"
    }
    local subframefolder = Instance.new("Folder", main)
    for _, subframe in pairs(subframes) do
        createSubFrame(subframe, subframefolder)
    end
    local frameswapbuttons = {
        "Instance Explorer",
        "Remote Spy",
        "Script Searcher",
        "Upvalue Scanner",
        "Closure Scanner",
        "Settings",
        "Home"
    }
    local frameswapbuttonfolder = Instance.new("Folder", main)
    for _, frameswapbutton in pairs(frameswapbuttons) do
        local img = getcustomasset("NOCT-xt/ui/images/"..frameswapbutton..".png")
        createUI.createFrameSwapButton(frameswapbuttonfolder, _, img, subframefolder[frameswapbutton])
    end
    return minimize
end

return MainFrame