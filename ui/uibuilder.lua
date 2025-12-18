local UIBuilder = {}

local mainFrameBuilder = import("ui/MainFrame.lua")

function UIBuilder.buildUI(prnt)
    local mainframe = mainFrameBuilder.createMainFrame(prnt)
end

return UIBuilder