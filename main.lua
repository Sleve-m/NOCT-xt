local RunService = game:GetService("RunService")
local ReflectionsService = game:GetService("ReflectionService")
local coregui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")

local LoadingUI = noctxt.TextLabel

LoadingUI.TextLabel.Text = "Loading Modules..."
io.requirefile("NOCT-xt/modules/ModuleLoader.lua").loadModules()

LoadingUI.TextLabel.Text = "Drawing UI..."
local mainframe = nil
mainframe = modules.UIBuilder.buildUI()

LoadingUI.TextLabel:Destroy()
for i = -90, 0 do
	task.wait()
	LoadingUI.UIGradient.Rotation = math.lerp(-90, 0, math.smoothstep(math.clamp((i+90)/(90), 0, 1)))
end
modules.iEModule.setup()
modules.sVModule.setup()
mainframe.Parent.Parent.Parent = noctxt

LoadingUI.BackgroundTransparency = 1
while wait(0.02) and LoadingUI.TextTransparency < 1 do
	LoadingUI.TextTransparency += 0.02
end
LoadingUI:Remove()