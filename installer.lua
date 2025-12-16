local success, remoteConfig = pcall(function()
    return loadstring(game:HttpGet(url .. "config.lua"))()
end)

if success and remoteConfig and remoteConfig.dependencies then
    writefile("NOCT-xt/config.lua", game:HttpGet(url .. "config.lua"))

    for _, dependency in pairs(remoteConfig.dependencies) do
        local content = game:HttpGet(url .. dependency)
            
        if dependency:find("/") then
            local folder = "NOCT-xt/" .. dependency:match("^(.*)/")
            if not isfolder(folder) then makefolder(folder) end
        end
            
        writefile("NOCT-xt/" .. dependency, content)
        print("Installed: " .. dependency)
    end
    print("Finished install")
else
    return warn("NOCT-xt: Failed to fetch install list from GitHub.")
end