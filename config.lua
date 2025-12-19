local HttpService = game:GetService("HttpService")

local config = {}

config.Version = "v1.0.0.0b" -- Do not touch, this is used by updater.lua to autoupdate the script

config.Default = {
    autoupdate = true,
    controls = {
        sidescroll = Enum.KeyCode.LeftControl,
        groupselect = Enum.KeyCode.LeftShift,
        addselect = Enum.KeyCode.LeftControl
    },
    ui = {
        sizeratio = 1.3,
        animate = true
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
    "init.lua",
    "config.lua",
    "updater.lua",
    "main.lua",
    "frames/Closure.lua",
    "frames/InstanceExplorer.lua",
    "frames/Loading.lua",
    "frames/LogViewer.lua",
    "frames/MainFrame.lua",
    "frames/RemoteSpy.lua",
    "frames/ScriptSearch.lua",
    "frames/ScriptViewer.lua",
    "frames/Settings.lua",
    "frames/Upvalue.lua",
    "frames/ValueEditor.lua",
    "methods/environment.lua",
    "methods/fileimport.lua",
    "methods/string.lua",
    "methods/table.lua",
    "methods/userdata.lua",
    "modules/ClosureSpy.lua",
    "modules/ConstantScanner.lua",
    "modules/InstanceExplorer.lua",
    "modules/ModuleScanner.lua",
    "modules/RemoteSpy.lua",
    "modules/ScriptScanner.lua",
    "modules/UpvalueScanner.lua",
    "objects/Closure.lua",
    "objects/Constant.lua",
    "objects/Instance.lua",
    "objects/LocalScript.lua",
    "objects/ModuleScript.lua",
    "objects/Remote.lua",
    "objects/Remote.lua",
    "objects/Upvalue.lua",
    "ui/images/Home.png",
    "ui/images/Instance Explorer.png",
    "ui/images/Remote Spy.png",
    "ui/images/Scroll Bar.png",
    "ui/images/Settings.png",
    "ui/create.lua",
    "ui/sizing.lua",
    "ui/uibuilder.lua"
}

function config:checkDependencies()
    local missingDependencies = {}
    local header = "NOCT-xt/"
    for index, dependency in pairs(self.dependencies) do
        if not isfile(header..dependency) then
            table.insert(missingDependencies, dependency)
        end
    end
    return missingDependencies
end

return config