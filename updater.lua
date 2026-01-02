local HttpService = game:GetService("HttpService")

local updater = {}

local url = "https://raw.githubusercontent.com/Sleve-m/NOCT-xt/refs/heads/main/"

function updater:Install(dependencies, LoadingUI)
    for _, dependency in pairs(dependencies) do
        local content = game:HttpGet(url .. dependency:gsub(" ", "%%20"))
        LoadingUI.Text = ("Installing: " .. dependency)
        LoadingUI.Parent.Frame.Size = UDim2.new((_/#dependencies),0,0,2)
        task.wait()
        if dependency:find("/") then
            local folder = "NOCT-xt/" .. dependency:match("^(.*)/")
            if not isfolder(folder) then makefolder(folder) end
        end
        writefile("NOCT-xt/" .. dependency, content)
    end
    LoadingUI.Parent.Frame:Destroy()
    LoadingUI.Text = ("Finished install")
    task.wait()
end

function updater:updateNOCTxt(LoadingUI)
    local dependencies = modules.config.dependencies 

    if not dependencies then 
        warn("Updater failed: Could not find dependencies list in config.")
        return 
    end

    LoadingUI.Text = ("Starting Update...")
    task.wait()

    for index, fileRelPath in pairs(dependencies) do
        LoadingUI.Text = ("Updating: " .. fileRelPath)
        LoadingUI.Parent.Frame.Size = UDim2.new((index/#dependencies),0,0,2)
        task.wait()
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
        else
            warn("Failed to download: " .. cleanPath)
        end
    end
    
    LoadingUI.Text = ("Update Complete!")
    task.wait()
end

function updater:checkForUpdates(LoadingUI)
    local thisVersion = modules.config.Version
    
    local success, remoteConfig = pcall(function()
        return loadstring(game:HttpGet(url .. "config.lua"))()
    end)

    if success and remoteConfig then
        local currentVersion = remoteConfig.Version
        
        if thisVersion ~= currentVersion then
            print(thisVersion.." : "..currentVersion)
            LoadingUI.Text = ("Update "..currentVersion.. "available")
            task.wait()
            return true
        end
    else
        warn("Failed to check for updates.")
    end
    
    return false
end

return updater