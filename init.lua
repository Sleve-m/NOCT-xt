local HttpService = game:GetService("HttpService")
local environment = getgenv()

local url = "https://raw.githubusercontent.com/Sleve-m/NOCT-xt/refs/heads/main/"
if not isfile("NOCT-xt/config.lua") then
    print("NOCT-xt: Performing First-Time Install...")

    local success, remoteConfig = pcall(function()
        return loadstring(game:HttpGet(url .. "config.lua"))()
    end)

    if success and remoteConfig and remoteConfig.dependencies then
        writefile("NOCT-xt/config.lua", game:HttpGet(url .. "config.lua"))

        for _, dependency in pairs(remoteConfig.dependencies) do
            local content = game:HttpGet(url .. dependency)
            
            if dependency:find("/") then
                local folder = "NOCT-xt/" .. dependency:match("^(.*)/")
                if not isfolder(folder) then makefolder(folder) end
            end
            
            writefile("NOCT-xt/" .. dependency, content)
            print("Installed: " .. dependency)
        end
        print("Finished install")
    else
        return warn("NOCT-xt: Failed to fetch install list from GitHub.")
    end
end

local noctCanStart = true
local fimport = loadstring(readfile("NOCT-xt/methods/fileimport.lua"))().importfile 

local Updater = fimport("NOCT-xt/updater.lua")
local Config = loadstring(readfile("NOCT-xt/config.lua"))()

local function useMethods(module)
    for name, method in pairs(module) do
        if method then
            environment[name] = method
        end
    end
end

useMethods({ import = fimport })


if Config.Settings.autoupdate then 
    if Updater:checkForUpdates() then 
        Updater:updateNOCTxt()
        Config = fimport("NOCT-xt/config.lua")
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

useMethods(import("NOCT-xt/methods/string.lua"))
useMethods(import("NOCT-xt/methods/table.lua"))
useMethods(import("NOCT-xt/methods/userdata.lua"))
useMethods(import("NOCT-xt/methods/environment.lua"))

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

