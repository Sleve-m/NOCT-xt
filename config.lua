local HttpService = game:GetService("HttpService")

local config = {}

config.Version = "v1.0.0.0a" -- Do not touch, this is used by updater.lua to autoupdate the script

config.Default = {
    autoupdate = true,
    controls = {
        sidescroll = Enum.LeftControl,
        groupselect = Enum.LeftShift,
        addselect = Enum.LeftControl
    },
    ui = {
        sizeratio = 1.3,
        animations = true
    }
}

config.Settings = HttpService:JSONDecode(HttpService:JSONEncode(config.default))

function config:Save()
    local json = HttpService:JSONEncode(config.Settings)
    writefile(self.FileName, json)
end

function config:Load()
    if isfile(self.FileName) then
        local content = readfile(self.FileName)
        local decoded = HttpService:JSONDecode(content)
        for category, values in pairs(decoded) do
            if config.Settings[category] then
                for setting, value in pairs(values) do
                    config.Settings[category][setting] = value
                end
            end
        end
    else
        self:Save()
    end
end

local dependencies = {
    "updater.lua",
    "methods/environment.lua",
    "methods/string.lua",
    "methods/table.lua",
    "methods/userdata.lua",
    "modules/RemoteSpy.lua",
    "objects/Remote.lua",
    "ui/create.lua",
    "ui/functions.lua",
    "ui/sizing.lua"
}

function config:checkDependencies()
    local missingDependencies = {}
    local header = "NOCT-xt/"
    for index, dependency in pairs(dependencies) do
        if not isfile(header..dependency) then
            table.insert(missingDependencies, dependency)
        end
    end
    return missingDependencies
end

--[[
local Library = loadstring(game:HttpGet("..."))() -- Assuming you use a UI Library
local Config = require(path_to_config_above)

-- Initialize Config
Config:Load()

local Window = Library:CreateWindow("My Script")
local Tab = Window:CreateTab("Main")

-- Create the Toggle
local AimToggle = Tab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = Config.Settings.Aimbot.Enabled, -- Set initial state from config
    Callback = function(Value)
        -- 1. Update the table in memory
        Config.Settings.Aimbot.Enabled = Value
        
        -- 2. Save immediately (or use a Save Button)
        Config:Save() 
    end
})
]]

return config