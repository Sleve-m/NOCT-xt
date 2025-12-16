local HttpService = game:GetService("HttpService")

local updater = {}
local config = import("NOCT-xt/config.lua")

local url = "https://raw.githubusercontent.com/Sleve-m/NOCT-xt/refs/heads/main/"

function updater:updateNOCTxt()
    local dependencies = config.dependencies 

    if not dependencies then 
        warn("Updater failed: Could not find dependencies list in config.")
        return 
    end

    print("Starting Update...")

    for index, fileRelPath in pairs(dependencies) do
        local cleanPath = fileRelPath:gsub("^/", "")
        local fileUrl = url .. cleanPath
        
        local success, content = pcall(function()
            return game:HttpGet(fileUrl)
        end)

        if success then
            local fullPath = "NOCT-xt/" .. cleanPath
            
            if fullPath:find("/") then
                local folderPath = fullPath:match("^(.*)/")
                if not isfolder(folderPath) then
                    makefolder(folderPath)
                end
            end

            writefile(fullPath, content)
            print("Updated: " .. cleanPath)
        else
            warn("Failed to download: " .. cleanPath)
        end
    end
    
    print("Update Complete! Please restart the script.")
end

function updater:checkForUpdates()
    local thisVersion = config.Version
    
    local success, remoteConfig = pcall(function()
        return loadstring(game:HttpGet(url .. "config.lua"))()
    end)

    if success and remoteConfig then
        local currentVersion = remoteConfig.Version
        
        if thisVersion ~= currentVersion then
            print("Update Available! Local: " .. thisVersion .. " | Remote: " .. currentVersion)
            return true
        end
    else
        warn("Failed to check for updates.")
    end
    
    return false
end

return updater