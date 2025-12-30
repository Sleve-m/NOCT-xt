local MainFrame = {}

local createUI = modules.createUI

local udpix, sudpix, sUDim2 = createUI.udpix, createUI.sudpix, createUI.sUDim2

function MainFrame.createMainFrame()
    local minimize = createUI.createText(nil, "NOCT xt", sudpix(50,15), sUDim2(0.5,-140,0.5,-80), true)
    Instance.modify(minimize, {ZIndex = 5, FontFace.Weight = Enum.FontWeight.Bold})
    createUI.createGrad(minimize, createUI.colorgrads[1], 0)

    local border = createUI.createFrame(minimize, sudpix(282,162), udpix(0,0), false)
    Instance.modify(border, {BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.5})
    createUI.createGrad(border, createUI.colorgrads[2], 45)

    minimize.MouseButton1Click:Connect(function()
        border.Visible = not border.Visible
        minimize.BackgroundTransparency = (minimize.BackgroundTransparency == 0 and 1 or 0)
    end)

    local main = createUI.createFrame(border, sudpix(282,162)-udpix(2,2), udpix(1,1), false)
    createUI.makeDraggable(main, minimize)

    local titletext = createUI.createText(main, "Home", sudpix(50,15), sUDim2(0.5,-25,0,0), false)
    titletext.TextSize = createUI.sNumber(8)
    createUI.createGrad(titletext, createUI.colorgrads[3], 0)

    local topline = createUI.createFrame(main, UDim2.new(1,0,0,1), sudpix(0,15), false)
    topline.BackgroundColor3 = Color3.fromRGB(100,100,100)
    createUI.createGrad(topline, createUI.colorgrads[3], 0)

    local kill = createUI.createText(main, "X", sudpix(15,15), sUDim2(1,-15,0,0), true)
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
        subframe.Visible = (name == "Home")
    end

    local subframeslist = {
        "Closure Scanner",
        "Constant Scanner",
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
    subframefolder.Name = "SubFrame Folder"
    subframes = subframefolder
    for _, subframe in pairs(subframeslist) do
        createSubFrame(subframe, subframefolder)
    end

    local frameswapbuttons = {
    "Instance Explorer",
    "Remote Spy",
    "Script Searcher",
    "Closure Scanner",
    "Settings",
    "Home"
    }

    local frameswapbuttonfolder = Instance.new("Folder", main)
    frameswapbuttonfolder.Name = "FrameSwap Button Folder"
    for _, frameswapbutton in pairs(frameswapbuttons) do
        createUI.createFrameSwapButton(
            frameswapbuttonfolder, 
            _, 
            getimg(frameswapbutton .. ".png"), 
            subframes[frameswapbutton], 
            titletext
        )
    end
    
    return main
end

return MainFrame