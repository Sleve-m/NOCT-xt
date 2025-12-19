local UIBuilder = {}

local mainFrameBuilder = import("ui/MainFrame.lua")

function UIBuilder.buildUI()
    local mainframe = mainFrameBuilder.createMainFrame()

    return mainframe
end

return UIBuilder