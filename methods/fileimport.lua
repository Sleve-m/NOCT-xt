local fileImport = {}

function fileImport.importfile(path) 
    return loadstring(readfile("NOCT-xt/"..path))()
end

return fileImport