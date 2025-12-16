local HttpService = game:GetService("HttpService")

local config = {}

config.Version = "v1.0.0.0a" -- Do not touch, this is used by updater.lua to autoupdate the script

config.Default = {
    autoupdate = true,
    controls = {
        sidescroll = Enum.KeyCode.LeftControl,
        groupselect = Enum.KeyCode.LeftShift,
        addselect = Enum.KeyCode.LeftControl
    },
    ui = {
        sizeratio = 1.3,
        animations = true
    }
}

config.Settings = HttpService:JSONDecode(HttpService:JSONEncode(config.Default))

config.FileName = "NOCT-xt/settings.json"

function config:Save()
    local json = HttpService:JSONEncode(config.Settings)
    
    if not isfolder("NOCT-xt") then makefolder("NOCT-xt") end
    
    writefile(self.FileName, json)
end

function config:Load()
    if isfile(self.FileName) then
        local content = readfile(self.FileName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
        
        if success and decoded then
            for key, value in pairs(decoded) do
                if config.Settings[key] ~= nil then
                    if type(value) == "table" and type(config.Settings[key]) == "table" then
                        for setting, val in pairs(value) do
                            config.Settings[key][setting] = val
                        end
                    else
                        config.Settings[key] = value
                    end
                end
            end
        else
            warn("Failed to decode config JSON")
        end
    else
        self:Save()
    end
end

config.dependencies = {
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

return config