InstanceExplorer = {}

local createUI = modules.createUI

local sudpix, udpix, sUDim2 = createUI.sudpix, createUI.udpix, createUI.sUDim2

function InstanceExplorer.createInstanceExplorer()
    local newinstexpl = {
        instscroller = createUI.createFrame(nil, sudpix(166,114), sudpix(0,30), true),
        propscroller = createUI.createFrame(nil, sudpix(100,114),sudpix(130,30), true),
        pathframe = createUI.createFrame(nil, sudpix(266,15),sudpix(0,15), true),
        back = createUI.createImage(nil, getimg("Back.png"), sudpix(15,15), sudpix(0,0), true),
        tougc = createUI.createImage(nil, getimg("Instance Explorer.png"), sudpix(15,15), sudpix(15,0), true),
        tolinks = createUI.createImage(nil, getimg("Links.png"), sudpix(15,15), sudpix(30,0), true),
        tosnapshots = createUI.createImage(nil, getimg("Snapshots.png"), sudpix(15,15), sudpix(45,0), true),
        nilinstances = createUI.createText(nil, "nil", sudpix(15,15), sudpix(60,0), true),
        searchbar = createUI.createTextBox(nil, "Search instances", sudpix(150,15), sudpix(115,0)),
        exampleinst = createUI.createText(nil, "Example", sUDim2(1,-19,0,12), sudpix(0,0), true, createUI.textStyles.selectable),
        exampleprop = createUI.createText(nil, "Example", sUDim2(1,0,0,12), sudpix(0,0), false),
        examplevalue = createUI.createText(nil, "Example", sUDim2(1,0,0,12), sudpix(0,0), true),
        examplepathitem = createUI.createText(nil, "/Example", sUDim2(0,40,1,0), sudpix(0,0), true)
    }
    
    createUI.createImage(newinstexpl.exampleinst, getimg("PlaceHolder.png"), sudpix(10,10), sudpix(-14,1), false)
    Instance.modify(newinstexpl.pathframe, {CanvasSize = udpix(0,0), AutomaticCanvasSize = Enum.AutomaticSize.X})
    Instance.modify(newinstexpl.examplepathitem, {TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.SplitWord, Visible = false, TextSize = createUI.sNumber(8)})
    newinstexpl.nilinstances.TextSize = createUI.sNumber(8)
    Instance.modify(newinstexpl.exampleinst, {Visible = false, TextXAlignment = Enum.TextXAlignment.Left, TextSize = createUI.sNumber(8)})
    Instance.modify(newinstexpl.exampleprop, {Visible = false, TextSize = createUI.sNumber(8), TextTruncate = Enum.TextTruncate.SplitWord, TextXAlignment = Enum.TextXAlignment.Left})
    Instance.modify(newinstexpl.examplevalue, {Visible = false, TextSize = createUI.sNumber(8), TextTruncate = Enum.TextTruncate.SplitWord, TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = Color3.fromRGB(16,16,16), BackgroundTransparency = 0})

    return newinstexpl
end

return InstanceExplorer