local Developers = {20118200, 93929075, 22864719, 9976947, 1871401}

local MarketplaceService = game:GetService("MarketplaceService")
local Modules = script.Parent.Parent.Parent.Modules
local Sockets = require(Modules.Utility["server"])

return function (player, GamePassID)
	local hasPass = false
	
	if table.find(Developers, player.UserId) then
		return true
	end
	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, GamePassID)
	end)
	if not success then
		Sockets:Emit("SendMessage", nil, nil, "Error in checking Game Pass of User " ..player.UserId.. ": " ..message, true)
	end
	return hasPass
end

