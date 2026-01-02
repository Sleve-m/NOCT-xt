local ModuleLoader = {}

function ModuleLoader.loadModules()
    modules.createUI = io.requirefile("NOCT-xt/ui/create.lua")
    modules.UIBuilder = io.requirefile("NOCT-xt/ui/uibuilder.lua")
    modules.mFBuilder = io.requirefile("NOCT-xt/frames/MainFrame.lua")
    modules.iEBuilder = io.requirefile("NOCT-xt/frames/InstanceExplorer.lua")
    modules.lVBuilder = io.requirefile("NOCT-xt/frames/LogViewer.lua")
    modules.sVBuilder = io.requirefile("NOCT-xt/frames/ScriptViewer.lua")
    modules.sSBuilder = io.requirefile("NOCT-xt/frames/ScriptSearch.lua")
    modules.rSBuilder = io.requirefile("NOCT-xt/frames/RemoteSpy.lua")
    modules.cSBuilder = io.requirefile("NOCT-xt/frames/Closure.lua")
    modules.sBuilder = io.requirefile("NOCT-xt/frames/Settings.lua")
    modules.hBuilder = io.requirefile("NOCT-xt/frames/Home.lua")
    modules.remoteObject = io.requirefile("NOCT-xt/objects/Remote.lua")
    modules.upvalueObject = io.requirefile("NOCT-xt/objects/Upvalue.lua")
    modules.iEModule = io.requirefile("NOCT-xt/modules/InstanceExplorer.lua")
    modules.sVModule = io.requirefile("NOCT-xt/modules/ScriptViewer.lua")
    modules.rSModule = io.requirefile("NOCT-xt/modules/RemoteSpy.lua")
    modules.lVModule = io.requirefile("NOCT-xt/modules/LogViewer.lua")
    modules.constantObject = io.requirefile("NOCT-xt/objects/Constant.lua")
    modules.closureObject = io.requirefile("NOCT-xt/objects/Closure.lua")
    modules.modulesScriptObject = io.requirefile("NOCT-xt/objects/ModuleScript.lua")
    modules.localScriptObject = io.requirefile("NOCT-xt/objects/LocalScript.lua")
end

return ModuleLoader