local getimage = {}

function getimage.getimg(name)
	local basePath = "NOCT-xt/ui/images/"
	local originalPath = basePath .. name
	
	local success, assetId = pcall(function()
		if not isfile(originalPath) then error("File missing") end
		local data = readfile(originalPath)
		
		local tempName = "temp_" .. tostring(math.floor(tick())) .. "_" .. name
		local tempPath = basePath .. tempName
		
		writefile(tempPath, data)
		
		local newimg = getcustomasset(tempPath)
		wait()
		delfile(tempPath)
		return newimg
	end)

	if success then
		return assetId
	else
		warn("Image failure for ["..name.."]: using placeholder")
		return getcustomasset("NOCT-xt/ui/images/PlaceHolder.png")
	end
end

return getimage