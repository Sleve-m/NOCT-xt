local fileImport = {}

function fileImport.importfile(path)
    if string.sub(path, 1, 8) == "NOCT-xt/" then
        path = string.sub(path, 9)
    end
    local fullPath = "NOCT-xt/" .. path

    io.requirefile(fullPath)

    return result
end

return fileImport