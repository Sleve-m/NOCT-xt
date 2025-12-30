RemoteSpy = {}

local createUI = modules.createUI

local sudpix, udpix, sUDim2 = createUI.sudpix, createUI.udpix, createUI.sUDim2

function RemoteSpy.createRemoteSpy()
    local newremspy = {
        main = createUI.createFrame(nil, sudpix(100,100), udpix(0,0), true)
    }
    newremspy.main.CanvasSize = sudpix(1000,1000)
    return newremspy
end

return RemoteSpy