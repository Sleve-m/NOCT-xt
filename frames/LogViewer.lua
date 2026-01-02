local LogViewer = {}

local createUI = modules.createUI

local sudpix, udpix, sUDim2 = createUI.sudpix, createUI.udpix, createUI.sUDim2

function LogViewer.createLogViewer()
    local newlogviewer = {
        logsscroller = createUI.createFrame(nil, sudpix(50, 129), udpix(0,0), true),
        argsscroller = createUI.createFrame(nil, sudpix(216, 144), sudpix(50, 0), true),
        examplelog = createUI.createText(nil, "Example", sudpix(50, 12), udpix(0,0), true, createUI.textStyles.selectable),
        examplearg = createUI.createText(nil, "Example", udpix(0,0), udpix(0,0), true)
    }
    newlogviewer.examplelog.Visible = false
    newlogviewer.examplelog.TextSize = createUI.sNumber(8)
    newlogviewer.examplearg.Visible = false
    newlogviewer.examplearg.TextXAlignment = Enum.TextXAlignment.Left
    newlogviewer.examplearg.TextSize = createUI.sNumber(8)


    return newlogviewer
end

return LogViewer