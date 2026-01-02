if not isfile("MoreLibrary/init.lua") then
    local function download_repo(owner, repo, branch, target_folder)
        local branch = branch or "main"
        local target_folder = target_folder or repo
        local tree_url = "https://api.github.com/repos/"..owner.."/"..repo.."/git/trees/"..branch.."?recursive=1"
        local headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
            ["Accept"] = "application/json"
        }
        local response = http_request({
            Url = tree_url,
            Method = "GET",
            Headers = headers
        })
        if not response then
            return warn("morehttp.downloadrepo: Request failed because response was nil")
        end
        if response.StatusCode ~= 200 then
            warn("morehttp.downloadrepo: GitHub API Failed")
            warn("    Status: " .. tostring(response.StatusCode))
            warn("    Body: " .. tostring(response.Body))
            return
        end
        local data = HttpService:JSONDecode(response.Body)
        if not data.tree then 
            return warn("http.downloadrepo: No file tree found in response.") 
        end
        if not isfolder(target_folder) then 
            makefolder(target_folder) 
        end
        local file_count = 0
        for _, item in pairs(data.tree) do
            local path = target_folder .. "/" .. item.path
            if item.type == "tree" then
                if not isfolder(path) then
                    makefolder(path)
                end
            elseif item.type == "blob" then
                local raw_url = "https://raw.githubusercontent.com/"..owner.."/"..repo.."/"..branch.."/"..item.path
                task.spawn(function()
                    local success, content = pcall(function() 
                        return game:HttpGet(raw_url) 
                    end)
                    if success then
                        writefile(path, content)
                        file_count = file_count + 1
                    else
                        warn("http.downloadrepo: Failed to download file: " .. item.path)
                    end
                end)
            end
        end
    end
    download_repo("Sleve-m", "More-Library", "main", "MoreLibrary")
end
local MoreLibrary = loadstring(readfile("MoreLibrary/init.lua"))
local success, libraryChunk = pcall(MoreLibrary)
print("Starting NOCT-xt")
if success then
print("Successfully loaded More Library")
libraryChunk.loadmodules()
local HttpService = game:GetService("HttpService")
local environment = gettenv(coroutine.running())

environment["LoadingUImod"] = io.requirefileorget("NOCT-xt/frames/Loading.lua", "https://raw.githubusercontent.com/Sleve-m/NOCT-xt/main/frames/Loading.lua")

local noctxt = Instance.new("ScreenGui", gethui())
noctxt.Name = "NOCTxt"
local LoadingUI = LoadingUImod.createLoadingUI()
environment["LoadingUI"] = LoadingUI
LoadingUI.Parent = noctxt

if not isfolder("NOCT-xt") then
    LoadingUI.TextLabel.Text = "Installing NOCT xt..."
    task.wait()
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

local Updater = io.requirefile("NOCT-xt/updater.lua")
modules.config = io.requirefile("NOCT-xt/config.lua")

local noctCanStart = true
LoadingUI.TextLabel.Text = "Checking dependencies..."
task.wait()
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
    task.wait()
end

if Updater:checkForUpdates(LoadingUI.TextLabel) then Updater:updateNOCTxt(LoadingUI.TextLabel) end
modules.config = io.requirefile("NOCT-xt/config.lua")
modules.config:LoadSettings()

useMethods(io.requirefile("NOCT-xt/methods/string.lua"))
useMethods(io.requirefile("NOCT-xt/methods/table.lua"))
useMethods(io.requirefile("NOCT-xt/methods/userdata.lua"))
useMethods(io.requirefile("NOCT-xt/methods/environment.lua"))
useMethods(io.requirefile("NOCT-xt/methods/getimage.lua"))

loadstring(readfile("NOCT-xt/main.lua"))()
else
    print("Could not load More Library")
end