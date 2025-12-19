local fileImport = {}

function fileImport.importfile(path)
    if string.sub(path, 1, 8) == "NOCT-xt/" then
        path = string.sub(path, 9)
    end
    local fullPath = "NOCT-xt/" .. path

    if not isfile(fullPath) then
        warn("CRITICAL: File does not exist: " .. fullPath)
        return nil
    end

    local content = readfile(fullPath)

    local func, syntaxErr = loadstring(content)
    if not func then
        warn("SYNTAX ERROR in " .. fullPath .. ": " .. tostring(syntaxErr))
        return nil
    end

    local success, result = pcall(func)
    if not success then
        warn("RUNTIME ERROR inside " .. fullPath .. ": " .. tostring(result))
        return nil
    end

    return result
end

return fileImport