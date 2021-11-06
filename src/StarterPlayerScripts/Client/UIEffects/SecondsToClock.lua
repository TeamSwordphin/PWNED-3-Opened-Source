return function(seconds, bol)
	if seconds <= 0 then
		return "00:00"
	else
		local hours = string.format("%02.f", math.floor(seconds/3600))
		local mins 	= string.format("%02.f", math.floor(seconds/60 - (hours*60)))
		local secs 	= string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		if bol then
			return mins.. ":" .. secs
		end
		return hours..":"..mins
	end
end
