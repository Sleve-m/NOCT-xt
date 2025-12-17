local CreateUI = {}

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

function CreateUI.creategrad(prnt, colorgrad, rot)
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

function CreateUI.text(prnt, txt, size, pos, isbutton, style)
    local newtxt
    if isbutton then
        newtxt = Instance.new("TextButton", prnt)
    else
        newtxt = Instance.new("TextLabel", prnt)
    end
    newtxt.Text = txt
    newtxt.Size = size
    newtxt.Position = pos
    if not style then style = self.textStyles end
    stylize(newtxt, style)
end

return CreateUI