local HttpService = game:GetService("HttpService")
local environment = getgenv()

local url = "https://raw.githubusercontent.com/Sleve-m/NOCT-xt/refs/heads/main/"

local LoadingUImod = loadstring(isfile("NOCT-xt/frames/Loading.lua") and readfile("NOCT-xt/frames/Loading.lua") or game:HttpGet("https://raw.githubusercontent.com/Sleve-m/NOCT-xt/main/frames/Loading.lua"))()

local noctxt = Instance.new("ScreenGui", gethui())
noctxt.Name = "NOCTxt"
local LoadingUI = LoadingUImod.createLoadingUI()
LoadingUI.Parent = noctxt

if not isfile("NOCT-xt/config.lua") then
    LoadingUI.TextLabel.Text = "Installing NOCT xt..."
    if not isfolder("NOCT-xt") then
        makefolder("NOCT-xt")
    end
    local success, remoteConfigGet = pcall(function()
        return game:HttpGet(url .. "config.lua")
    end)
    local successs, remoteUpdaterGet = pcall(function()
        return game:HttpGet(url .. "updater.lua")
    end)
    if success and successs then
        writefile("NOCT-xt/config.lua", remoteConfigGet)
        local dependencies = loadstring(remoteConfigGet)().dependencies
        local remoteUpdater = loadstring(remoteUpdaterGet)()
        remoteUpdater:Install(dependencies, LoadingUI.TextLabel)
    else
        return warn("NOCT-xt: Failed to fetch install list from GitHub.")
    end
end

local fimport = loadstring(readfile("NOCT-xt/methods/fileimport.lua"))().importfile

local function useMethods(module)
    for name, method in pairs(module) do
        if method then
            environment[name] = method
        end
    end
end

useMethods({ import = fimport })

local Updater = import("updater.lua")
local Config = import("config.lua")

local noctCanStart = true
LoadingUI.TextLabel.Text = "Checking dependencies..."
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
    LoadingUI.TextLabel.Text = ("Starting...")
end

if Config.Settings.autoupdate then 
    if Updater:checkForUpdates() then 
        Updater:updateNOCTxt()
        Config = import("config.lua")
    end 
end

useMethods(import("methods/string.lua"))
useMethods(import("methods/table.lua"))
useMethods(import("methods/userdata.lua"))
useMethods(import("methods/environment.lua"))

loadstring(readfile("NOCT-xt/main.lua"))()

