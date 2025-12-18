local CreateUI = {}

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local sinkaction = "NOCT_SinkScroll"
local sideScrollDown = false
local groupSelectDown = false
local addSelectDown = false

local UISizing = import("ui/sizing.lua")
local udpix, sudpix, sUDim2 = UISizing.udpix, UISizing.sudpix, UISizing.sUDim2
local Config = import("config.lua")
local controls = Config:Load().controls

function createUI.adaptivescroll(frame)
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

function createUI.animateframeswapbutton()

end

function createUI.makeDraggable(a, b)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	local function updateDrag(input)
		if not dragging then return end
		local pos = input.Position
		if typeof(pos) == "Vector3" then
			pos = Vector2.new(pos.X, pos.Y)
		elseif typeof(pos) ~= "Vector2" then
			return
		end
		if typeof(pos) ~= "Vector2" then return end
		local delta = pos - dragStart
		b.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
	a.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.deleteSelectionOptionFrame()
            dragging = true
            dragStart = typeof(input.Position) == "Vector3"
                and Vector2.new(input.Position.X, input.Position.Y)
                or input.Position
            startPos = b.Position
		end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            self.deleteSelectionOptionFrame()
        end
        if input.KeyCode == Config.controls.sidescroll then sideScrollDown = true end
        if input.KeyCode == Config.controls.addselect then addSelectDown = true end
        if input.KeyCode == Config.controls.groupselect then groupSelectDown = true end
	end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
        if input.KeyCode == Config.controls.sidescroll then sideScrollDown = false end
        if input.KeyCode == Config.controls.addselect then addSelectDown = false end
        if input.KeyCode == Config.controls.groupselect then groupSelectDown = false end
	end)
end

function createUI.swaptoframe()
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

local currentSelectionOptionsFrame = nil

local colors = {
    black = Color3.fromRGB(0,0,0),
    white = Color3.fromRGB(200,200,200),
    purewhite = Color3.fromRGB(255,255,255),
    darkgrey = Color3.fromRGB(16,16,16),
    selected = Color3.fromRGB(64,64,200)
}

CreateUI.textStyles = {
    deftext = {
        BackgroundColor3 = colors.black,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.Unbuntu,
        TextSize = 10
        TextColor3 = colors.white
    },
    selectable = {
        BackgroundColor3 = colors.selected,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.Unbuntu,
        TextSize = 10
        TextColor3 = colors.white
    },
    searchbar = {
        BackgroundColor3 = colors.darkgrey,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.Unbuntu,
        TextSize = 10
        TextColor3 = colors.white
    }
}

function CreateUI.grad2(c1,c2)
	return ColorSequence.new({ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)})
end

CreateUI.colorgrads = {
	ColorSequence.new({ColorSequenceKeypoint.new(0, colors.purewhite), ColorSequenceKeypoint.new(0.68, Color3.fromRGB(143,143,143)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200,0,0)), ColorSequenceKeypoint.new(0.82, Color3.fromRGB(56,110,225)), ColorSequenceKeypoint.new(1, Color3.fromRGB(246,179,255))}),
	grad2(colors.purewhite, Color3.fromRGB(16,16,16)),
	ColorSequence.new({ColorSequenceKeypoint.new(0, colors.white), ColorSequenceKeypoint.new(0.66, colors.purewhite), ColorSequenceKeypoint.new(1, colors.white)})
}

function CreateUI.createGrad(prnt, colorgrad, rot)
    local newgrad = Instance.new("UIGradient", prnt)
	newgrad.Color = colorgrad
	newgrad.Rotation = rot
	return newgrad
end

function stylize(ui, style)
    ui.BackgroundColor3 = style.BackgroundColor3
    ui.BackgroundTransparency = style.BackgroundTransparency
    ui.BorderSizePixel = style.BorderSizePixel
    ui.Font = style.Font
    ui.TextSize = style.TextSize
    ui.TextColor3 = style.TextColor3
end

function CreateUI.createText(prnt, txt, size, pos, isbutton, style)
    local typ = isbutton and "Button" or "Label"
    local newtxt = Instance.new("Text"..typ, prnt)
    newtxt.Text = txt
    newtxt.Size = size
    newtxt.Position = pos
    if not style then style = self.textStyles end
    stylize(newtxt, style)
    return newtxt
end

function CreateUI.createImage(prnt, img, size, pos, isbutton)
    local newimg = Instance.new("Image"..(isbutton and "Button" or "Label"), prnt)
    newimg.Size = size
    newimg.Position = pos
    newimg.Image = img
    return newimg
end

local scrollBarImage = getcustomasset("NOCT-xt/ui/images/ScrollBar.png")

function CreateUI.createFrame(prnt, size, pos, isscrolling)
    local newframe = Instance.new((isscrolling and "Scrolling" or "").."Frame", prnt)
    newframe.Size = size
    newframe.Position = pos
    newframe.BorderSizePixel = 0
    newframe.BackgroundColor3 = colors.black
    if isscrolling then
        newframe.MidImage, newframe.TopImage, newframe.BottomImage = scrollBarImage
        newframe.ScrollBarThickness = 2
        self.adaptivescroll(newframe)
    end
    return newframe
end

function CreateUI.createFrameSwapButton(prnt, y, img, frame)
    local newbtn = self.createImage(prnt, img, sudpix(15,15), sudpix(0,(y*15)+16), true)
    if Config.Settings.ui.animate then
        self.animateframeswapbutton(newbtn)
    end
    newbtn.MouseButton1Click:Connect(function()
        self.swaptoframe(frame)
    end)
end

function CreateUI.deleteSelectionOptionFrame()
    if currentSelectionOptionsFrame then currentSelectionOptionsFrame:Destroy() end
end

function CreateUI.createSelectionOption(y, txt, func)
    local newSelOpt = self.createText(currentSelectionOptionsFrame, txt, sudpix(55,15), sudpix(0,y*15), true)
    newSelOpt.MouseButton1Click:Connect(Function()
        func()
        self.deleteSelectionOptionFrame()
    end)
end

return CreateUI