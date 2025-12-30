local ModuleLoader = {}

function ModuleLoader.loadModules()
    modules.createUI = import("ui/create.lua")
    modules.UIBuilder = import("ui/uibuilder.lua")
    modules.mFBuilder = import("frames/MainFrame.lua")
    modules.iEBuilder = import("frames/InstanceExplorer.lua")
    modules.sVBuilder = import("frames/ScriptViewer.lua")
    modules.sSBuilder = import("frames/ScriptSearch.lua")
    modules.rSBuilder = import("frames/RemoteSpy.lua")
    modules.cSBuilder = import("frames/Closure.lua")
    modules.sBuilder = import("frames/Settings.lua")
    modules.hBuilder = import("frames/Home.lua")
    modules.remoteObject = import("objects/Remote.lua")
    modules.upvalueObject = import("objects/Upvalue.lua")
    modules.iEModule = import("modules/InstanceExplorer.lua")
    modules.sVModule = import("modules/ScriptViewer.lua")
    modules.rSModule = import("modules/RemoteSpy.lua")
    modules.constantObject = import("objects/Constant.lua")
    modules.closureObject = import("objects/Closure.lua")
    modules.modulesScriptObject = import("objects/ModuleScript.lua")
    modules.localScriptObject = import("objects/LocalScript.lua")
end

return ModuleLoader