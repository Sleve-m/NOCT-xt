local Loading = {}

function Loading.createLoadingUI()
    local loadingui = Instance.new("TextLabel")
    loadingui.Text = "NOCT xt"
    loadingui.Size = UDim2.new(0,220,0,65)
    loadingui.Position = UDim2.new(0.5,-110,0.5,-32)
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
    tinfo.TextSize = 8
    tinfo.TextColor3 = Color3.fromRGB(200,200,200)
    tinfo.Size = UDim2.new(1,0,0,10)
    tinfo.Position = UDim2.new(0,0,1,-10)
    tinfo.BackgroundTransparency = 1
    tinfo.TextXAlignment = Enum.TextXAlignment.Left
    return loadingui
end

return Loading