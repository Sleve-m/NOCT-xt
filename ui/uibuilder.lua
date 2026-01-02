local UIBuilder = {}

local function parentall(array, prnt)
    for _, value in pairs(array) do
        value.Parent = prnt
    end
end

function UIBuilder.buildUI()
    local mainframe = modules.mFBuilder.createMainFrame()
    local subframefolder = mainframe["SubFrame Folder"]
    local InstanceExplorerUI = modules.iEBuilder.createInstanceExplorer()
    parentall(InstanceExplorerUI, subframefolder["Instance Explorer"])
    local RemoteSpyUI = modules.rSBuilder.createRemoteSpy()
    parentall(RemoteSpyUI, subframefolder["Remote Spy"])
    local ScriptViewerUI = modules.sVBuilder.createScriptViewer()
    parentall(ScriptViewerUI, subframefolder["Script Viewer"])
    local LogViewerUI = modules.lVBuilder.createLogViewer()
    parentall(LogViewerUI, subframefolder["Log Viewer"])
    local ClosureScannerUI = modules.cSBuilder.createClosureScanner()

    local ScriptSearcherUI = modules.sSBuilder.createScriptSearcher()

    local SettingsUI = modules.sBuilder.createSettings()

    local HomeUI = modules.hBuilder.createHome()
    parentall(HomeUI, subframefolder["Home"])
    uis = {
        IEUI = InstanceExplorerUI,
        RSUI = RemoteSpyUI,
        SVUI = ScriptViewerUI,
        SSUI = ScriptSearcherUI,
        CSUI = ClosureScannerUI,
        SUI = SettingsUI,
        HUI = HomeUI,
        LVUI = LogViewerUI
    }
    
    return mainframe
end

function UIBuilder.destroyui()
    noctxt:Destroy()
end

return UIBuilder