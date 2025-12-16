local fileImport = {}

function fileImport.importfile(path) 
    return loadstring(readfile(path))()
end

return fileImport