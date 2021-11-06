-- << Services >>
local Debris 			= game:GetService("Debris")
local TweenService 		= game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local Players           = game:GetService("Players")

-- << Constants >>
local SERVER_FOLDER = script.Parent.Parent.Parent.Parent.Parent.Parent
local MODULES       = SERVER_FOLDER.Parent.Modules

-- << Modules >>
local Sockets       = require(MODULES.Utility["server"])
local PlayerManager	= require(MODULES.PlayerStatsObserver)
local EffectFinder	= require(MODULES.Combat.EffectFinder)


------------------------------------
return function (humanoid, model)
    local Player = Players:GetPlayerFromCharacter(model)
    if not Player then return end

	humanoid.AnimationPlayed:Connect(function(animTrack)
        local id = Player.UserId
        local CombatState = PlayerManager:GetCombatState(id)
		
		animTrack.KeyframeReached:Connect(function(keyFrame)
            --- General Effects
            if keyFrame == "Charge" then
                local Effect = EffectFinder:CreateEffect("Charging", 4.5, model)
                table.insert(CombatState.StatusEffects, Effect)
                PlayerManager:UpdateCombatState(id, CombatState)
            elseif keyFrame == "ChargeRemove" then
                local Charging = EffectFinder:FindEffect("Charging", id, true)
                if not Charging then return end

                local ChgTime = tick() - Charging.TimeStamp
                local DamageIncrease = math.min(1.8, 1 + (ChgTime * 0.2))

                local Effect = EffectFinder:CreateEffect("Veil of the Storm", 7, model, DamageIncrease)
                table.insert(CombatState.StatusEffects, Effect)
                PlayerManager:UpdateCombatState(id, CombatState)
            end
		end)
    end)

end