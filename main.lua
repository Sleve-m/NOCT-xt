local RunService = game:GetService("RunService")
local ReflectionsService = game:GetService("ReflectionService")
local coregui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")

local LoadingUI = noctxt.TextLabel

local startupsound = Instance.new("Sound", SoundService)
startupsound.SoundId = getcustomasset("NOCT-xt/assets/sound/Start-Up.wav")
startupsound.Ended:Connect(function() startupsound:Destroy() end)

LoadingUI.TextLabel.Text = "Loading Modules..."
task.wait()
io.requirefile("NOCT-xt/modules/ModuleLoader.lua").loadModules()

LoadingUI.TextLabel.Text = "Setting up frames..."
task.wait()
local mainframe = modules.UIBuilder.buildUI()
getgenv()["mainframe"] = mainframe

LoadingUI.TextLabel.Text = "Setting up instance explorer..."
task.wait()
modules.iEModule.setup()
LoadingUI.TextLabel.Text = "Setting up script viewer..."
task.wait()
modules.sVModule.setup()
LoadingUI.TextLabel.Text = "Setting up remote spy..."
task.wait()
modules.rSModule.setup()
LoadingUI.TextLabel.Text = "Setting up function watcher..."
task.wait()
modules.fWModule.setup()

LoadingUI.TextLabel:Destroy()
startupsound:Play()
for i = 0, 90, 0.5 do
    task.wait()
    local progress = math.smoothstep(0, 90, i)
    LoadingUI.UIGradient.Rotation = math.lerp(-90, 0, progress)
    environment.LoadingUImod:CreateParticle(LoadingUI)
end

mainframe.Parent.Parent.Parent = noctxt

for i, v in pairs(LoadingUI:GetChildren()) do
    if v.ClassName == "Frame" then
        v.Parent = mainframe
    end
end

LoadingUI.BackgroundTransparency = 1
for i = 0, 100, 1 do
    task.wait()
	LoadingUI.TextTransparency = i/100
    local progress = math.smoothstep(0, 100, i)
    local keytime = math.clamp(math.lerp(0, 1, progress), 0.01, 0.99)
    mainframe.UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), 
        ColorSequenceKeypoint.new(keytime, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(keytime+0.005, Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
    })
end
mainframe.UIGradient:Destroy()
LoadingUI.Text = ""
wait(5)
LoadingUI:Remove()