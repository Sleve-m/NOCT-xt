local fileImport = {}

funciton fileImport.importfile(path)
    return loadstring(readfile(path))()
end

return fileImport