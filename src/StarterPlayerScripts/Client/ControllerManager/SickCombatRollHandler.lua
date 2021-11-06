local Players = game:GetService("Players")

-- << Services >> --
local ReplicatedStorage 	= game:GetService("ReplicatedStorage")

-- << Constants >> -- 
local CLIENT = script.Parent.Parent
local PLAYER = Players.LocalPlayer

-- << Modules >> --
local DataValues 	= require(CLIENT.DataValues)
local FS 		  	= require(ReplicatedStorage.Scripts.Modules.FastSpawn)

-- << Variables >> --
local Fall_Dist_Begin 	= 15
local bools 			= DataValues.bools


-- << Main Function >> --
function OnRespawned(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	Humanoid.FreeFalling:Connect(function(active)
		if (active) then
			DataValues.Last_Y = Character.PrimaryPart.Position.Y
		else
			if Character:FindFirstChild("Animate") and Character.Animate:FindFirstChild("fallintoroll") then
				local y_diff = DataValues.Last_Y - Character.PrimaryPart.Position.Y --the difference between the fall start position and the fall end position
				if (y_diff >= Fall_Dist_Begin) and bools.IsDodging == false and bools.IsBlocking == false and bools.Stunned == false then
					bools.Stunned = true
					bools.TPS = false
					local FallAnim = Humanoid:LoadAnimation(Character.Animate.fallintoroll.Roll)
		            FallAnim:Play()
					local function ResetRoll()
						wait(FallAnim.Length)
						bools.Stunned = false
						bools.Debounce = false
						bools.IsBlocking = false
						bools.IsDodging = false
						y_diff = 0
					end
					FS.spawn(function()
						ResetRoll()
					end)
					ResetRoll()
		        end
			end
	    end
	end)
end

PLAYER.CharacterAdded:Connect(OnRespawned)

return nil