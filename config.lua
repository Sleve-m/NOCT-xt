local HttpService = game:GetService("HttpService")

local config = {}

config.Version = "v1.0.0.0a4" -- Do not touch, this is used by updater.lua to autoupdate the script

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
    io.writetabletofile(FileName, config.Settings)
end

function config:LoadSettings()
    if isfile(FileName) then
        config.Settings = io.loadtablefromfile(FileName)
    else 
        config.Settings = table.clone(config.Default)
        config:SaveSettings()
    end
end

config.dependencies = {
    "init.lua",
    "config.lua",
    "updater.lua",
    "main.lua",
    "assets/sound/Start-Up.wav",
    "frames/Closure.lua",
    "frames/FunctionWatcher.lua",
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
    "modules/FunctionWatcher.lua",
    "modules/InstanceExplorer.lua",
    "modules/LogViewer.lua",
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
    "ui/images/Function Watcher.png",
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