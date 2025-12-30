local HttpService = game:GetService("HttpService")

local config = {}

config.Version = "v1.0.0.0a1" -- Do not touch, this is used by updater.lua to autoupdate the script

config.Default = {
    controls = {
        sidescroll = Enum.KeyCode.LeftControl,
        groupselect = Enum.KeyCode.LeftShift,
        addselect = Enum.KeyCode.LeftControl,
        fastscroll = Enum.KeyCode.LeftShift
    },
    ui = {
        sizeratio = 1.5,
        animate = true
    }
}

local FileName = "NOCT-xt/settings.json"

config.Settings = {}

function config:SaveSettings()
    io.writetabletofile(config.FileName, config.Settings)
end

function config:LoadSettings()
    config.Settings = isfile(config.FileName) and io.loadtablefromfile(config.FileName) or config.Default
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
    "methods/getimage.lua",
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
    "objects/LocalScript.lua",
    "objects/ModuleScript.lua",
    "objects/Remote.lua",
    "objects/Upvalue.lua",
    "ui/images/Auto-Scroll.png",
    "ui/images/Back.png",
    "ui/images/Class Icons.png",
    "ui/images/Closure Scanner.png",
    "ui/images/Home.png",
    "ui/images/Instance Explorer.png",
    "ui/images/Links.png",
    "ui/images/PlaceHolder.png",
    "ui/images/Remote Spy.png",
    "ui/images/Script Searcher.png",
    "ui/images/Scroll Bar.png",
    "ui/images/Settings.png",
    "ui/images/Snapshots.png",
    "ui/create.lua",
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