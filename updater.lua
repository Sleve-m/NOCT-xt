local HttpService = game:GetService("HttpService")

local updater = {}


function updater:updateNOCTxt(LoadingUI)
    morehttp.downloadrepo("Sleve-m", "NOCT-xt", "main", "NOCT-xt")
end

function updater:checkForUpdates(LoadingUI)
    local thisVersion = modules.config.Version
    
    local success, remoteConfig = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Sleve-m/NOCT-xt/refs/heads/main/config.lua"))()
    end)

    if success and remoteConfig then
        local currentVersion = remoteConfig.Version
        
        if thisVersion ~= currentVersion then
            print(thisVersion.." : "..currentVersion)
            LoadingUI.Text = ("Update "..currentVersion.. "available: Updating...")
            task.wait()
            return true
        end
    else
        warn("Failed to check for updates.")
    end
    
    return false
end

return updater