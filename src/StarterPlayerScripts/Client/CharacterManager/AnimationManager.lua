-- << Services >> --
local Players = game:GetService("Players")

-- << Constants >> -- 
local CLIENT = script.Parent.Parent
local PLAYER = Players.LocalPlayer

-- << Modules >> --
local DataValues = require(CLIENT.DataValues)

-- << Variables >> --
local Numbers	= DataValues.Numbers
local Objs		= DataValues.Objs
local Ticks		= DataValues.Ticks
local Character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid 	= Character:WaitForChild("Humanoid")


---------------------
local handler = {}

function OnRespawn(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
end

PLAYER.CharacterAdded:Connect(OnRespawn)

function handler:StopAllAnimations()
	Humanoid.PlatformStand = true
	Character.Animate.Disabled = true
	Humanoid.PlatformStand = false
	for i, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
    	track:Stop()
	end
end

function handler:RestoreAnimations(bool)
	local Restart = bool or nil
	Character.Animate.Disabled = false
	Humanoid.AutoRotate = true
	if Restart == nil then
		Numbers.Combo = 1
		Numbers.SkillCounter = 1
		Ticks.Last_Combo = tick() + 1
	end
	if Objs.AnimTrack then
		Objs.AnimTrack:Destroy()
	end
end

return handler