--[[
	To counter AFK bots that never joins the game.
--]]

local TIMER = 600

-------
local safe = {}

game.Players.PlayerAdded:Connect(function(NewPly)
	print("Beginning Security Check")
	wait(TIMER)
	if safe[NewPly] then
		safe[NewPly] = nil
		print("Security Check passed")
	else
		NewPly:Kick("Unauthorized Security Check")
	end
end)

script.SecurityConfirm.Event:Connect(function(PlyrObj)
	safe[PlyrObj] = true
	print(PlyrObj.Name.. " has been Security Confirmed")
end)
