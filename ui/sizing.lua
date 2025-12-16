local Sizing = {}

function Sizing.sudpix(x, y)
	local uiscale = noctsettings["uiscale"]
	return(UDim2.new(0,x*uiscale,0,y*uiscale))
end

function Sizing.udpix(x, y)
	return (UDim2.new(0,x,0,y))
end

function Sizing.sUDim2(sx, ox, sy, oy)
	local uiscale = noctsettings["uiscale"]
	return(UDim2.new(sx, ox*uiscale, sy, oy*uiscale))
end

return Sizing