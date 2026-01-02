local LogViewer = {}

local createUI = modules.createUI

local sudpix, udpix, sUDim2 = createUI.sudpix, createUI.udpix, createUI.sUDim2

function LogViewer.viewlogs(t)
    local ui = uis.LVUI
    for i, v in pairs(ui.argsscroller:GetChildren()) do 
        v:Destroy()
    end

    local function getArgString(data)
        if typeof(data) == "table" then
            return " : table"
        elseif typeof(data) == "Instance" then
            return data:GetFullName().." : Instance"
        elseif typeof(data) == "string" then
            return '"' .. data .. '" : String'
        elseif typeof(data) == "Vector3" then 
            return string.format("Vec3(%g, %g, %g)", data.X, data.Y, data.Z)
        else
            return tostring(data)
        end
    end

    local function listarg(index, arg, t, stk)
        local stack = stk or 0
        local newarg = ui.examplearg:Clone()
        newarg.Visible = true
        local myY = 0
        for n, m in pairs(ui.argsscroller:GetChildren()) do 
            myY = myY + m.Size.Y.Offset 
        end
        
        newarg.Parent = ui.argsscroller
        newarg.Position = sudpix(myY, stack*20)
        newarg.Size = UDim2.new(1, 0, 0, 0)

        newarg.AutomaticSize = Enum.AutomaticSize.Y
        newarg.TextWrapped = true
        
        newarg.Text = string.format("Arg #%d: %s", index, getArgString(arg))
        if typeof(arg) == "table" then for n, m in pairs(arg) do listarg(n, m, arg, stack + 1) end end
    end

    local function listlog(index, log)
        local newlog = ui.examplelog:Clone()
        newlog.Parent = ui.logsscroller
        newlog.Position = sudpix(0, (index-1)*12)
        newlog.Visible = true
        newlog.Text = log.TimeStamp
        newlog.MouseButton1Click:Connect(function()
            for i, v in pairs(ui.logsscroller:GetChildren()) do v.BackgroundTransparency = (v == newlog) and 0.7 or 1 end
            for i, v in pairs(ui.argsscroller:GetChildren()) do v:Destroy() end
            table.fordo(log.Args, listarg)
        end)
    end

    table.fordo(t, listlog)
end

return LogViewer