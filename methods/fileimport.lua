local fileImport = {}

funciton fileImport.importfile(path)
    loadstring(readfile(path))()
end

return fileImport