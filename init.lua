local HttpService = game:GetService("HttpService")
local url = "https://raw.githubusercontent.com/Sleve-m/NOCT-xt/refs/heads/main/"
if not isfile("NOCT-xt/config.lua") then
    print("NOCT-xt: Performing First-Time Install...")

    local success, remoteConfig = pcall(function()
        return loadstring(game:HttpGet(url .. "config.lua"))()
    end)

    if success and remoteConfig and remoteConfig.Dependencies then
        writefile("NOCT-xt/config.lua", game:HttpGet(url .. "config.lua"))

        for _, dependency in pairs(remoteConfig.Dependencies) do
            local content = game:HttpGet(url .. dependency)
            
            if dependency:find("/") then
                local folder = "NOCT-xt/" .. dependency:match("^(.*)/")
                if not isfolder(folder) then makefolder(folder) end
            end
            
            writefile("NOCT-xt/" .. dependency, content)
            print("Installed: " .. dependency)
        end
    else
        return warn("NOCT-xt: Failed to fetch install list from GitHub.")
    end
end

local noctCanStart = true
local Updater = import("NOCT-xt/updater")
local Config = import("NOCT-xt/config")

if Config.Settings.autoupdate then 
    if Updater:checkForUpdates() then 
        Updater:updateNOCTxt()
        Config = import("NOCT-xt/config.lua")
    end 
end

local checkedDependencies = Config:checkDependencies()

if #checkedDependencies > 0 then
    local warningMessage = "NOCT-xt is missing dependencies: "
    
    for index, missingDependency in pairs(checkedDependencies) do
        warningMessage = warningMessage .. missingDependency
        
        if index ~= #checkedDependencies then 
            warningMessage = warningMessage .. ", " 
        end
    end
    warn(warningMessage)
    
else
    print("NOCT-xt: All dependencies loaded. Starting...")
end

--[[
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local sinkaction = "NOCT_SinkScroll"
local ReflectionsService = game:GetService("ReflectionService")
local coregui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")
]]

