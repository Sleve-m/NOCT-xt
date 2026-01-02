local Home = {}

local createUI = modules.createUI

local sudpix, udpix, sUDim2 = createUI.sudpix, createUI.udpix, createUI.sUDim2

function Home.createHome()
    local homeUI = {
        title = createUI.createText(nil, "NOCT-xt "..tostring(modules.config.Version), sudpix(150, 12), sUDim2(0.5,-75,0,4), false),
        creators = createUI.createText(nil, "By sleve and tainted", sudpix(150, 12), sUDim2(0.5,-75,0,18), false)
    }
    Instance.modify(homeUI.creators, {TextSize = createUI.sNumber(8), TextXAlignment = Enum.TextXAlignment.Center})
    homeUI.title.TextXAlignment = Enum.TextXAlignment.Center
    return homeUI
end

return Home