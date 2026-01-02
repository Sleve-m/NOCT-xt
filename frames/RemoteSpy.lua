RemoteSpy = {}

local createUI = modules.createUI

local sudpix, udpix, sUDim2 = createUI.sudpix, createUI.udpix, createUI.sUDim2

function RemoteSpy.createRemoteSpy()
    local newremspy = {
        scroller = createUI.createFrame(nil, sudpix(266,129), sudpix(0,15), true),
        exampleremote = createUI.createText(nil, "Example", sUDim2(1,-31,0,12), sudpix(12, 0), true, createUI.textStyles.selectable),
        sortbtn = createUI.createText(nil, "Recent", sudpix(40,15), sudpix(0,0), true)
    }
    createUI.createImage(newremspy.exampleremote, getimg("PlaceHolder.png"), sudpix(10,10), sudpix(-14,1), false)
    createUI.createText(newremspy.exampleremote, "1", sudpix(10,10), sUDim2(1, -12, 0, 1), false)
    Instance.modify(newremspy.exampleremote, {Visible = false, TextXAlignment = Enum.TextXAlignment.Left, TextSize = createUI.sNumber(8)})
    Instance.modify(newremspy.sortbtn, {BorderSizePixel = 1, BackgroundTransparency = 0, BorderColor3 = Color3.fromRGB(64,64,64), BorderMode = Enum.BorderMode.Inset, TextSize = createUI.sNumber(8)})

    return newremspy
end

return RemoteSpy