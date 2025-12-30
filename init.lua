local HttpService = game:GetService("HttpService")
local environment = gettenv()

local LoadingUImod = loadstring(io.requirefileorget("NOCT-xt/frames/Loading.lua", "https://raw.githubusercontent.com/Sleve-m/NOCT-xt/main/frames/Loading.lua"))()

local noctxt = Instance.new("ScreenGui", gethui())
print("01")
noctxt.Name = "NOCTxt"
print("02")
local LoadingUI = LoadingUImod.createLoadingUI()
LoadingUI.Parent = noctxt

if not isfolder("NOCT-xt") then
    LoadingUI.TextLabel.Text = "Installing NOCT xt..."
    morehttp.downloadrepo("Sleve-m", "NOCT-xt", "main", "NOCT-xt")
end

local function useMethods(module)
    for name, method in pairs(module) do
        if method then
            environment[name] = method
        end
    end
end

environment.NOCT = {
    modules = {},
    UIS = {},
    CTRLS = {},
    subframefolder = {}
    settings = {}
}

useMethods({
    environment = environment,
    modules = NOCT.modules,
    uis = NOCT.UIS,
    controls = NOCT.CTRLS,
    subframes = NOCT.subframefolder,
    noctxt = noctxt,
    import = io.requirefile("NOCT-xt/methods/fileimport.lua").importfile
})

local Updater = import("updater.lua")
modules.config = import("config.lua")

local noctCanStart = true
LoadingUI.TextLabel.Text = "Checking dependencies..."
local missingDependencies = modules.config:checkDependencies()

if #missingDependencies > 0 then
    local warningMessage = "NOCT-xt is missing dependencies: "
    local function appendWarning(_, missingDependency)
        warningMessage = warningMessage .. missingDependency
        if _ ~= #missingDependencies then 
            warningMessage = warningMessage .. ", " 
        end
    end
    table.fordo(missingDependencies, appendWarning)
    warn(warningMessage)
else
    LoadingUI.TextLabel.Text = ("Starting...")
end

Updater:updateNOCTxt(LoadingUI.TextLabel)
modules.config = import("config.lua")
modules.config:LoadSettings()

useMethods(import("methods/string.lua"))
useMethods(import("methods/table.lua"))
useMethods(import("methods/userdata.lua"))
useMethods(import("methods/environment.lua"))
useMethods(import("methods/getimage.lua"))

loadstring(readfile("NOCT-xt/main.lua"))()

