-- << Services >>
local Players           = game:GetService("Players")
local Debris 			= game:GetService("Debris")
local TweenService 		= game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local RunService        = game:GetService("RunService")

-- << Constants >>
local SERVER_FOLDER     = script.Parent.Parent.Parent.Parent.Parent.Parent
local MODULES           = SERVER_FOLDER.Parent.Modules

-- << Modules >>
local Sockets           = require(MODULES.Utility["server"])
local PlayerManager	    = require(MODULES.PlayerStatsObserver)
local DamageSystem      = require(MODULES.Combat["DamageSystem"])
local RaycastModule	    = require(MODULES.Combat.RaycastHitbox)
local EffectFinder	    = require(MODULES.Combat.EffectFinder)
local GameObjectHandler	= require(SERVER_FOLDER.SharedModules.GameObjectHandler)
local Promise           = require(ReplicatedStorage.Scripts.Modules.Promise)


------------------------------------
return function (humanoid, model)

    local player = Players:GetPlayerFromCharacter(model)
    local userID = player and player.UserId

    local currentGrappledTarget
    local grapplingRunService

	humanoid.AnimationPlayed:Connect(function(animTrack)
        local id = animTrack.Animation.AnimationId
		
		animTrack.KeyframeReached:Connect(function(keyFrame)
            --- General Effects
            if keyFrame == "ConeDamage" or keyFrame == "ConeStart" or keyFrame == "ConeStrike" then
                local maxDistance = 8
                local coneAngle = 120
                local damageScale = 1.8
                
                for _, target in ipairs(workspace.Enemies:GetChildren()) do
                    if target.PrimaryPart and target ~= model then
                        local relative = (target.PrimaryPart.Position - model.PrimaryPart.Position)
                        local forward = model.PrimaryPart.CFrame.LookVector
                        local side = relative.Unit
                        local theta = math.deg(math.acos(forward:Dot(side)))
                        
                        if relative.Magnitude < maxDistance and theta <= coneAngle then
                            DamageSystem:DamageMode(GameObjectHandler:GameData(), userID, model, GameObjectHandler:GetEnemies(), nil, target, nil, nil, nil, nil, nil, damageScale)
                        end
                    end
                end
            end

            if keyFrame == "GrappleStart" then
                local CombatState = PlayerManager:GetCombatState(userID)
                local Effect = EffectFinder:CreateEffect("Invincibility", 2, model, nil, true)
                table.insert(CombatState.StatusEffects, Effect)
                PlayerManager:UpdateCombatState(userID, CombatState)
                model.PrimaryPart.Anchored = true
                currentGrappledTarget = nil

                local newHitbox = RaycastModule:Initialize(model.Weapon.Part, {workspace.Players, workspace.DeadEnemies})
                newHitbox.OnHit:Connect(function(hit, humanoid)
                    --- raycast?

                    currentGrappledTarget = humanoid.Parent
                    local primaryPart = currentGrappledTarget.PrimaryPart
                    local lastPosition = primaryPart.CFrame
                    if not primaryPart.Anchored then
                        primaryPart.Anchored = true

                        Promise.new(function(resolve)
                            grapplingRunService = RunService.Heartbeat:Connect(function()
                                if not currentGrappledTarget then
                                    grapplingRunService:Disconnect()
                                    humanoid.Parent:SetPrimaryPartCFrame(lastPosition)
                                    humanoid.Parent.PrimaryPart.Anchored = false
                                    model.PrimaryPart.Anchored = false
                                    resolve()
                                    return
                                end
                                primaryPart.CFrame = model.UpperTorso.CFrame * CFrame.new(0, 1, -1)
                            end)
                        end):timeout(2):andThen(function()
                           --- resolved within seconds.
                        end):catch(function(e)
                            model.PrimaryPart.Anchored = false
                            humanoid.Parent:SetPrimaryPartCFrame(lastPosition)
                            humanoid.Parent.PrimaryPart.Anchored = false
                            currentGrappledTarget = nil
                            RaycastModule:Deinitialize(model.Weapon.Part)
                        end)

                        RaycastModule:Deinitialize(model.Weapon.Part)
                    else
                        return
                    end
                end)

                Promise.delay(2):andThen(function()
                    if model.PrimaryPart.Anchored then
                        model.PrimaryPart.Anchored = false
                        currentGrappledTarget = nil
                        RaycastModule:Deinitialize(model.Weapon.Part)
                    end
                end)

                newHitbox:HitStart()
            elseif keyFrame == "GrappleStop" then
                RaycastModule:Deinitialize(model.Weapon.Part)
            elseif keyFrame == "Impact" then
                model.PrimaryPart.Anchored = false
                local range = 15
                local playerHP = (humanoid.MaxHealth * 0.5)
                local flatDamage = currentGrappledTarget and (currentGrappledTarget.Humanoid.MaxHealth * 0.2) + playerHP or playerHP
                for _, target in ipairs(workspace.Enemies:GetChildren()) do
                    if target.PrimaryPart and target ~= model and target ~= currentGrappledTarget then                        
                        if (target.PrimaryPart.Position - model.PrimaryPart.Position).Magnitude < range then
                            DamageSystem:DamageMode(GameObjectHandler:GameData(), userID, model, GameObjectHandler:GetEnemies(), nil, target, nil, nil, nil, nil, nil, 3, flatDamage)
                        end
                    end
                end

                if currentGrappledTarget then
                    local damageScale = 20
                    DamageSystem:DamageMode(GameObjectHandler:GameData(), userID, model, GameObjectHandler:GetEnemies(), nil, currentGrappledTarget, nil, nil, nil, nil, nil, damageScale)
                    wait(1)
                    currentGrappledTarget = nil
                end
            end
		end)
    end)

end