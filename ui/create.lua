local CreateUI = {}

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local SINK_ACTION = "NOCT_SinkScroll"
controls.sideScrollDown = false
controls.groupSelectDown = false
controls.addSelectDown = false
controls.fastScrollDown = false

local Config = modules.config
local setcontrols = Config.Default.controls
local uisettings = Config.Default.ui

function CreateUI.sudpix(x, y)
	local uiscale = uisettings.sizeratio
	return(UDim2.new(0,(x*uiscale),0,(y*uiscale)))
end

function CreateUI.udpix(x, y)
	return (UDim2.new(0,x,0,y))
end

function CreateUI.sUDim2(sx, ox, sy, oy)
	local uiscale = uisettings.sizeratio
	return(UDim2.new(sx, (ox*uiscale), sy, (oy*uiscale)))
end

function CreateUI.resizeImage(image, ratio)
	local originalTextureSize = Vector2.new(64,64)
	local newRectSize = originalTextureSize / ratio
	local newRectOffset = (originalTextureSize - newRectSize) / 2
	image.ImageRectSize = newRectSize
	image.ImageRectOffset = newRectOffset
end

local udpix, sudpix, sUDim2 = CreateUI.udpix, CreateUI.sudpix, CreateUI.sUDim2

local asIcon = nil
local as = false
local asFrame = nil

function CreateUI.adaptivescroll(frame)
	frame.ScrollingEnabled = false
	local friction = 0.93
	local velocity = 0
	local velocityx = 0
	
	frame.MouseEnter:Connect(function()
		wait()
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
				velocityx = velocityx + (input.Position.Z * -(controls.fastScrollDown and 8 or 3))
			else
				velocity = velocity + (input.Position.Z * (controls.fastScrollDown and 8 or 3))
			end
		end
	end)

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton3 then
			as = not as
			asFrame = as and frame or nil
			asIcon.Position = UDim2.fromOffset(input.Position.X-(asIcon.Size.X.Offset/2), input.Position.Y-(asIcon.Size.Y.Offset/2))
			asIcon.Visible = as
		end
	end)

	RunService.RenderStepped:Connect(function()
		if as and asFrame == frame then
			local asX = -(UserInputService:GetMouseLocation().X-(asIcon.Position.X.Offset+(asIcon.Size.X.Offset/2)))/10
			local asY = -(UserInputService:GetMouseLocation().Y-55-(asIcon.Position.Y.Offset+(asIcon.Size.Y.Offset/2)))/10
			velocity = math.abs(asY) > .5 and asY or 0
			velocityx = math.abs(asX) > .5 and asX or 0
		end
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

function CreateUI.animateframeswapbutton(btn)
	local mousein = false
	local btngrad = btn.UIGradient
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

function CreateUI.makeDraggable(a, b)
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
			CreateUI.deleteSelectionOptionFrame()
            dragging = true
            dragStart = typeof(input.Position) == "Vector3"
                and Vector2.new(input.Position.X, input.Position.Y)
                or input.Position
            startPos = b.Position
		end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            CreateUI.deleteSelectionOptionFrame()
        end
        if input.KeyCode == setcontrols.sidescroll then controls.sideScrollDown = true end
        if input.KeyCode == setcontrols.addselect then controls.addSelectDown = true end
        if input.KeyCode == setcontrols.groupselect then controls.groupSelectDown = true end
		if input.KeyCode == setcontrols.fastscroll then controls.fastScrollDown = true end
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
        if input.KeyCode == setcontrols.sidescroll then controls.sideScrollDown = false end
        if input.KeyCode == setcontrols.addselect then controls.addSelectDown = false end
        if input.KeyCode == setcontrols.groupselect then controls.groupSelectDown = false end
		if input.KeyCode == setcontrols.fastscroll then controls.fastScrollDown = false end
	end)
end

function CreateUI.swaptoframe(frame)
	frame.Parent.Parent.TextLabel.Text = frame.Name
	for _, currFrame in pairs(subframes:GetChildren()) do
		currFrame.Visible = currFrame == frame and true or false
	end
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
        Font = Enum.Font.Ubuntu,
        TextSize = 10,
        TextColor3 = colors.white
    },
    selectable = {
        BackgroundColor3 = colors.selected,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.Ubuntu,
        TextSize = 10,
        TextColor3 = colors.white
    },
    searchbar = {
        BackgroundColor3 = colors.darkgrey,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Font = Enum.Font.Ubuntu,
        TextSize = 8,
        TextColor3 = colors.white,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderColor3 = Color3.fromRGB(0,64,128)
    }
}

function CreateUI.sNumber(num)
	return uisettings.sizeratio*num
end

function CreateUI.grad2(c1,c2)
	return ColorSequence.new({ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)})
end

CreateUI.colorgrads = {
	ColorSequence.new({ColorSequenceKeypoint.new(0, colors.purewhite), ColorSequenceKeypoint.new(0.68, Color3.fromRGB(143,143,143)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200,0,0)), ColorSequenceKeypoint.new(0.82, Color3.fromRGB(56,110,225)), ColorSequenceKeypoint.new(1, Color3.fromRGB(246,179,255))}),
	CreateUI.grad2(colors.purewhite, Color3.fromRGB(64,64,64)),
	ColorSequence.new({ColorSequenceKeypoint.new(0, colors.white), ColorSequenceKeypoint.new(0.66, colors.purewhite), ColorSequenceKeypoint.new(1, colors.white)})
}

function CreateUI.createGrad(prnt, colorgrad, rot)
    local newgrad = Instance.new("UIGradient", prnt)
	newgrad.Color = colorgrad
	newgrad.Rotation = rot
	return newgrad
end

function stylize(ui, style)
	for property, value in pairs(style) do
		ui[property] = typeof(value) == "number" and value*uisettings.sizeratio or value
	end
end

function CreateUI.createText(prnt, txt, size, pos, isbutton, style)
    local newtxt = Instance.new("Text"..(isbutton and "Button" or "Label"), prnt)
    newtxt.Text = txt
    newtxt.Size = size
    newtxt.Position = pos
    if not style then style = CreateUI.textStyles.deftext end
    stylize(newtxt, style)
    return newtxt
end

function CreateUI.createTextBox(prnt, txt, size, pos)
	local newtxt = Instance.new("TextBox", prnt)
	newtxt.Text = ""
	newtxt.PlaceholderText = txt
	newtxt.Size = size
	newtxt.Position = pos
	newtxt.ClearTextOnFocus = false
	newtxt.BorderMode = Enum.BorderMode.Inset
	newtxt.Focused:Connect(function() newtxt.BorderSizePixel = 1 end)
	newtxt.FocusLost:Connect(function() newtxt.BorderSizePixel = 0 end)
	stylize(newtxt, CreateUI.textStyles.searchbar)
	return newtxt
end

function CreateUI.createImage(prnt, img, size, pos, isbutton)
    local newimg = Instance.new("Image"..(isbutton and "Button" or "Label"), prnt)
    newimg.Size = size
    newimg.Position = pos
    newimg.Image = img
	newimg.BackgroundTransparency = 1
	newimg.BorderSizePixel = 0
    return newimg
end

asIcon = CreateUI.createImage(noctxt, getimg("Auto-Scroll.png"), sudpix(15,15), udpix(0,0), false)
asIcon.Visible = false; asIcon.ZIndex = 10

function CreateUI.createFrame(prnt, size, pos, isscrolling)
    local newframe = Instance.new((isscrolling and "Scrolling" or "").."Frame", prnt)
    newframe.Size = size
    newframe.Position = pos
    newframe.BorderSizePixel = 0
    newframe.BackgroundColor3 = colors.black
    if isscrolling then
		local setimg = getimg("PlaceHolder.png")
        newframe.MidImage, newframe.TopImage, newframe.BottomImage = setimg, setimg, setimg
        newframe.ScrollBarThickness = 2
        CreateUI.adaptivescroll(newframe)
    end
    return newframe
end

function CreateUI.createFrameSwapButton(prnt, y, img, frame)
    local newbtn = CreateUI.createImage(prnt, img, sudpix(15,15), sudpix(0,((y-1)*15)+16), true)
	newbtn.ImageColor3 = frame.Name == "Home" and colors.purewhite or Color3.fromRGB(200,200,200)
	newbtn.BackgroundColor3 = colors.darkgrey
	newbtn.BackgroundTransparency = frame.Name == "Home" and 0 or 1
	CreateUI.createGrad(newbtn, CreateUI.colorgrads[2], 45)
    if Config.Settings.ui.animate then
        CreateUI.animateframeswapbutton(newbtn)
    end
    newbtn.MouseButton1Click:Connect(function()
        CreateUI.swaptoframe(frame)
		for _, btn in pairs(prnt:GetChildren()) do
			btn.ImageColor3 = btn == newbtn and Color3.fromRGB(200,200,200) or colors.purewhite
			btn.BackgroundTransparency = btn == newbtn and 0 or 1
		end
    end)
end

function CreateUI.createSelectionOptionFrame(pos)
	CreateUI.deleteSelectionOptionFrame()
	local newseloptsframe = CreateUI.createFrame(noctxt, sudpix(55,0), pos, false)
	currentSelectionOptionsFrame = newseloptsframe
	newseloptsframe.BorderSizePixel = 1
	return newseloptsframe
end

function CreateUI.deleteSelectionOptionFrame()
    if currentSelectionOptionsFrame then currentSelectionOptionsFrame:Destroy() end
end

function CreateUI.createSelectionOption(txt, func)
    local newSelOpt = CreateUI.createText(currentSelectionOptionsFrame, txt, sudpix(55,12), sudpix(0,(#currentSelectionOptionsFrame:GetChildren())*12), true)
	currentSelectionOptionsFrame.Size = sudpix(55,(#currentSelectionOptionsFrame:GetChildren())*12)
	newSelOpt.TextSize = CreateUI.sNumber(8)
    newSelOpt.MouseButton1Click:Connect(function()
        func()
        CreateUI.deleteSelectionOptionFrame()
    end)
end

return CreateUI