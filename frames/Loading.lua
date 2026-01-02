local Loading = {}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

function Loading.createLoadingUI()
    local loadingui = Instance.new("TextLabel")
    loadingui.Text = "NOCT xt"
    loadingui.Font = Enum.Font.Ubuntu
    loadingui.Size = UDim2.new(0,150,0,45)
    loadingui.Position = UDim2.new(0.5,-75,0.5,-22)
    loadingui.BorderSizePixel = 0
    loadingui.BackgroundColor3 = Color3.new(0,0,0)
    loadingui.TextColor3 = Color3.fromRGB(200,200,200)
    loadingui.ZIndex = 10
    loadingui.BackgroundTransparency = 0
    loadingui.TextSize = 28
    local loadinggrad = Instance.new("UIGradient", loadingui)
    loadinggrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(0.68, Color3.fromRGB(143,143,143)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200,0,0)), ColorSequenceKeypoint.new(0.82, Color3.fromRGB(56,110,225)), ColorSequenceKeypoint.new(1, Color3.fromRGB(246,179,255))})
    loadinggrad.Rotation = -90
    local tinfo = Instance.new("TextLabel", loadingui)
    tinfo.ZIndex = 11
    tinfo.Text = "Checking if installed"
    tinfo.TextSize = 6
    tinfo.TextColor3 = Color3.fromRGB(200,200,200)
    tinfo.Size = UDim2.new(1,0,0,10)
    tinfo.Position = UDim2.new(0,0,1,-10)
    tinfo.BackgroundTransparency = 1
    tinfo.TextXAlignment = Enum.TextXAlignment.Left
    local loadbar = Instance.new("Frame", loadingui)
    loadbar.Size = UDim2.new(0,0,0,2)
    loadbar.Position = UDim2.new(0,0,1,0)
    loadbar.BackgroundColor3 = Color3.fromRGB(200,200,200)
    loadbar.BorderSizePixel = 0

    return loadingui
end

Loading.Config = {
	FloatSpeed = 25,    -- Pixels per second upward
	SwayIntensity = 300, -- Horizontal sway amount
	SwaySpeed = 1,      -- How fast they sway left/right
	Colors = {
		Color3.fromRGB(0, 0, 0),
        Color3.fromRGB(255,255,255),
        Color3.fromRGB(41, 0, 80),
        Color3.fromRGB(0, 0, 0),
        Color3.fromRGB(0, 0, 0)
	}
}

function Loading:CreateParticle(parent, startPos)
	if not parent then return end
    local myfs = self.Config.FloatSpeed*((math.random(0,1)*2)-1)
	
	startPos = startPos or UDim2.new(0.5, 0, 0.5, 0)
	
	-- Create the particle instance
	local p = Instance.new("Frame")
	p.Name = "DaintyParticle"
	p.BackgroundColor3 = self.Config.Colors[math.random(1, #self.Config.Colors)]
	p.BorderSizePixel = 0
    p.ZIndex = 0
	
	-- Random small dainty size
	local size = math.random(1, 4)
	p.Size = UDim2.new(0, size, 0, size)
	p.AnchorPoint = Vector2.new(0.5, 0.5) -- Center anchor for smoother positioning
	p.Position = startPos
	
	-- Make it a circle
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = p
	
	p.Parent = parent
	
	-- Animation Variables
	local lifeTime = math.random(3, 6)
	local startTime = tick()
	local seed = math.random(0, 100) -- Random offset for sine wave so they don't all move identically
	
	-- Render Loop for this specific particle
	local connection
	connection = RunService.RenderStepped:Connect(function()
		-- Calculate time alive
		local now = tick()
		local elapsed = now - startTime
		
		-- Kill particle if lifetime over
		if elapsed >= lifeTime or not p.Parent then
			if connection then connection:Disconnect() end
			p:Destroy()
			return
		end
		
		-- 1. Linear Upward Movement
		local yOffset = -elapsed * myfs
		
		-- 2. Sine Wave Sway
		local xSway = math.sin((elapsed * self.Config.SwaySpeed) + seed) * self.Config.SwayIntensity
		
		-- Apply Position (Relative to where it started)
		p.Position = (startPos + UDim2.new(0, xSway, 0, yOffset)) + mainframe.Position
		
		-- 3. Fade Logic (Fade In -> Wait -> Fade Out)
		local transparency = 0
		if elapsed < 0.5 then
			transparency = 1 - (elapsed / 0.5) -- Fade in
		elseif elapsed > (lifeTime - 1.5) then
			transparency = (elapsed - (lifeTime - 1.5)) / 1.5 -- Fade out
		end
		p.BackgroundTransparency = transparency
	end)
end

return Loading