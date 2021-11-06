local Players = game:GetService("Players")

local Modules = script.Parent.Parent.Parent.Modules
local PlayerManager	= require(Modules.PlayerStatsObserver)
local Sockets = require(Modules.Utility["server"])
local Achievements = require(Modules.Systems["Achievements"])
local Vestiges = require(Modules.Systems.Vestiges)

local tbi, tbr = table.insert, table.remove

return function(tbl, id, dontIncrement, value)
	local Stats = PlayerManager:GetPlayerStat(id)
	
	if Stats then
		local Rewards, NewAchievementList = Achievements:UpdateAchievements(Stats.Achievements, tbl, dontIncrement, value)
		if NewAchievementList ~= nil then
			local Ply = Players:GetPlayerByUserId(id)
			Stats.Achievements = NewAchievementList --- Overwrite old achievement list with the newly returned one
			if #Rewards > 0 then
				for _, Achievement in ipairs(Rewards) do
					for Index, Value in pairs(Achievement.Reward) do
						if Stats.UnclaimedAchievements[Index] == nil then
							if Index == "Tears" or Index == "Gold" then
								Stats.UnclaimedAchievements[Index] = 0
							else
								Stats.UnclaimedAchievements[Index] = {}
							end
						end
						if Index == "Tears" or Index == "Gold" then
							Stats.UnclaimedAchievements[Index] += Value
						else
							if not table.find(Stats[Index], Value) then
								tbi(Stats.UnclaimedAchievements[Index], Value)
								if Index == "Vestiges" then
									local Vestige = Vestiges:GetVestigeFromID(Value)
									Sockets:GetSocket(Ply):Emit("Hint", Vestige.Name.. " Obtained")
								end
							end
						end
						print("Gave " ..Index)
					end
				end
			end
		end
	end
end
