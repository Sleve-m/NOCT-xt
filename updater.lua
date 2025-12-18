local HttpService = game:GetService("HttpService")

local updater = {}
local config = loadstring(readfile("NOCT-xt/config.lua"))()

local url = "https://raw.githubusercontent.com/Sleve-m/NOCT-xt/refs/heads/main/"

function updater:Install(dependencies, LoadingUI)
    for _, dependency in pairs(dependencies) do
        local content = game:HttpGet(url .. dependency)
        LoadingUI.Text = ("Installing: " .. dependency)
        LoadingUI.Parent.Frame.Size = UDim2.new((_/#dependencies),0,0,2)
        if dependency:find("/") then
            local folder = "NOCT-xt/" .. dependency:match("^(.*)/")
            if not isfolder(folder) then makefolder(folder) end
        end
        writefile("NOCT-xt/" .. dependency, content)
    end
    LoadingUI.Text = ("Finished install")
end

function updater:updateNOCTxt(LoadingUI)
    local dependencies = config.dependencies 

    if not dependencies then 
        warn("Updater failed: Could not find dependencies list in config.")
        return 
    end

    LoadingUI = ("Starting Update...")

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
            LoadingUI = ("Updated: " .. cleanPath)
        else
            warn("Failed to download: " .. cleanPath)
        end
    end
    
    LoadingUI = ("Update Complete! Please restart the script.")
end

function updater:checkForUpdates(LoadingUI)
    local thisVersion = config.Version
    
    local success, remoteConfig = pcall(function()
        return loadstring(game:HttpGet(url .. "config.lua"))()
    end)

    if success and remoteConfig then
        local currentVersion = remoteConfig.Version
        
        if thisVersion ~= currentVersion then
            LoadingUI = ("Update Available! Local: " .. thisVersion .. " | Remote: " .. currentVersion)
            return true
        end
    else
        warn("Failed to check for updates.")
    end
    
    return false
end

return updater