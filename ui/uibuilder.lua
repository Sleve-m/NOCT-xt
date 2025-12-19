local UIBuilder = {}

local mainFrameBuilder = import("frames/MainFrame.lua")

function UIBuilder.buildUI()
    local mainframe = mainFrameBuilder.createMainFrame()

    return mainframe
end

return UIBuilder