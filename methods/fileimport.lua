local fileImport = {}

function fileImport.importfile(path)
    local success, file = pcall(function()
    return loadstring(readfile("NOCT-xt/"..path))()
    end)
    if success then
        return file
    else
        print("File not found: ", "NOCT-xt/"..path)
        return nil
    end
end

return fileImport