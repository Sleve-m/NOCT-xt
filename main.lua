local RunService = game:GetService("RunService")
local ReflectionsService = game:GetService("ReflectionService")
local coregui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = import("Config.lua")
local UIBuilder = import("ui/UIBuilder.lua")

local noctxt = gethui().NOCTxt
local LoadingUI = noctxt.TextLabel

LoadingUI.Text = "Drawing UI..."
local MainFrame = UIBuilder.buildUI()

LoadingUI.TextLabel:Destroy()
while wait(0.015) and LoadingUI.UIGradient.Rotation < 0 do
	LoadingUI.UIGradient.Rotation += 1
end

LoadingUI.BackgroundTransparency = 1
while wait(0.02) and LoadingUI.TextTransparency < 1 do
	LoadingUI.TextTransparency += 0.02
end
LoadingUI:Remove()