local ScriptViewerBuilder = {}

local createUI = modules.createUI

local sudpix, udpix, sUDim2 = createUI.sudpix, createUI.udpix, createUI.sUDim2

function ScriptViewerBuilder.createScriptViewer()
    local scriptviewerUI = {
        textContentScroller = createUI.createFrame(nil, sudpix(200,129), sudpix(0,15), true),
        foundLinesScroller = createUI.createFrame(nil, sudpix(65,129), sudpix(200,15), true),
        scriptViewerSearchInputTextBox = createUI.createTextBox(nil, "Search in script", sudpix(150,15), sudpix(115,0)),
        foundLineExampleButton = createUI.createText(nil, "Example", UDim2.new(1,0,0,15), udpix(0,0), true),
        lineNumTemplate = createUI.createText(nil, "0", udpix(20, 0), udpix(0,0), false),
        scriptTextTemplate = createUI.createText(nil, "Script placeholder", udpix(175, 0), udpix(25, 0), false)
    }
    
    return scriptviewerUI
end

return ScriptViewerBuilder