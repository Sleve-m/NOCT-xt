local FunctionWatcher = {}

local createUI = modules.createUI

local sudpix, udpix, sUDim2 = createUI.sudpix, createUI.udpix, createUI.sUDim2

function FunctionWatcher.createFunctionWatcher()
    local newfunctionwatcher = {
        scroller = createUI.createFrame(nil, sudpix(266,129), sudpix(0,15), true),
        examplefunc = createUI.createText(nil, "Example", sUDim2(1,-31,0,12), sudpix(12, 0), true, createUI.textStyles.selectable)
    }
    
    createUI.createText(newfunctionwatcher.examplefunc, "1", sudpix(10,10), sUDim2(1, -12, 0, 1), false)
    Instance.modify(newfunctionwatcher.examplefunc, {Visible = false, TextXAlignment = Enum.TextXAlignment.Left, TextSize = createUI.sNumber(8)})
    
    return newfunctionwatcher
end

return FunctionWatcher