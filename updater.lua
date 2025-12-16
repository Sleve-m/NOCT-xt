local HttpService = game:GetService("HttpService")

local updater = {}

local url = "https://github.com/Sleve-m/NOCT-xt"

function updater:updateNOCTxt()

end

function updater:checkForUpdates()
    local thisVersion = import("NOCT-xt/config").Version
    local currentVersion = import(loadstring(game:HttpGet(url.."/config.lua"))()).Version
    if thisVersion ~= currentVersion then
        return true
    end
end

return updater