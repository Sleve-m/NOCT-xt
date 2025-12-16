local url = "https://github.com/Sleve-m/"
if not isfile("NOCT-xt/config.lua") then

end

local noctCanStart = true

local Config = import("NOCT-xt/config")

if Config.autoupdate and Config:checkForUpdates() then Config:updateNOCTxt() end

local checkedDependencies = Config:checkDependencies()

if #checkedDependencies ~= 0 then
    local warningMessage = "NOCT xt is missing dependencies: "
    for index, missingDependency in pairs(checkDependencies) do
        warningMessage = warningMessage..missingDependency
        if not index == #missingDependencies then warningMessage = warningMessage..", " end
    end
    warn(warningMessage)
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local sinkaction = "NOCT_SinkScroll"
local ReflectionsService = game:GetService("ReflectionService")
local coregui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

