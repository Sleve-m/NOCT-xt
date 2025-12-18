local UIFunctions = {}

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local sinkaction = "NOCT_SinkScroll"
local sideScrollDown = false
local groupSelectDown = false
local addSelectDown = false

local Config = import("config.lua")
local controls = Config:Load().controls

function UIFunctions.adaptivescroll(frame)
	frame.ScrollingEnabled = false
	local friction = 0.93
	local velocity = 0
	local velocityx = 0
	
	frame.MouseEnter:Connect(function()
		ContextActionService:BindAction(
			SINK_ACTION, 
			function() 
				return Enum.ContextActionResult.Sink
			end, 
			false, 
			Enum.UserInputType.MouseWheel
		)
	end)

	frame.MouseLeave:Connect(function()
		ContextActionService:UnbindAction(SINK_ACTION)
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if sideScrollDown then
				velocityx = velocityx + (input.Position.Z * -3)
			else
				velocity = velocity + (input.Position.Z * 3)
			end
		end
	end)

	RunService.RenderStepped:Connect(function()
		if math.abs(velocity) < 0.1 and math.abs(velocityx) < 0.1 then
			velocity = 0
			velocityx = 0
			return
		end
		if math.abs(velocity) < 0.1 or math.abs(velocityx) < 0.1 then
			if math.abs(velocity) < 0.1 then
				velocity = 0
			end
			if math.abs(velocityx) < 0.1 then
				velocityx = 0
			end
		end

		velocity = velocity * friction
		velocityx = velocityx * friction

		local newY = frame.CanvasPosition.Y - velocity
		local newX = frame.CanvasPosition.X - velocityx
		local maxScroll = frame.AbsoluteCanvasSize.Y - frame.AbsoluteWindowSize.Y
		local maxScrollx = frame.AbsoluteCanvasSize.X - frame.AbsoluteWindowSize.X

		if newY < 0 then
			newY = 0
			velocity = 0
		elseif newY > maxScroll then
			newY = maxScroll
			velocity = 0
		end
		if newX < 0 then
			newX = 0
			velocityx = 0
		elseif newX > maxScrollx then
			newX = maxScrollx
			velocityx = 0
		end
		frame.CanvasPosition = Vector2.new(newX, frame.CanvasPosition.Y)
		frame.CanvasPosition = Vector2.new(frame.CanvasPosition.X, newY)
	end)
end

function UIFunctions.animateframeswapbutton()

end

function UIFunctions.swaptoframe()
	local mousein = false
	btn.MouseEnter:Connect(function()
		mousein = true
		while wait(0.02) and mousein do
			btngrad.Rotation += 10
			if btngrad.Rotation > 360 then btngrad.Rotation -= 360 end
		end
	end)
	btn.MouseLeave:Connect(function()
		mousein = false
		while wait(0.02) and not mousein and not(btngrad.Rotation > 30 and btngrad.Rotation < 60) do
			btngrad.Rotation += 20
			if btngrad.Rotation > 360 then btngrad.Rotation -= 360 end
		end
		if not mousein then btngrad.Rotation = 45 end
	end)
end

return UIFunctions