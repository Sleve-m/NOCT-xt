local Sizing = {}

local function roundup(x)
	return math.floor(x)+1
end

function Sizing.sudpix(x, y)
	local uiscale = noctsettings["uiscale"]
	return(UDim2.new(0,roundup(x*uiscale),0,roundup(y*uiscale)))
end

function Sizing.udpix(x, y)
	return (UDim2.new(0,x,0,y))
end

function Sizing.sUDim2(sx, ox, sy, oy)
	local uiscale = noctsettings["uiscale"]
	return(UDim2.new(sx, roundup(ox*uiscale), sy, roundup(oy*uiscale)))
end

return Sizing