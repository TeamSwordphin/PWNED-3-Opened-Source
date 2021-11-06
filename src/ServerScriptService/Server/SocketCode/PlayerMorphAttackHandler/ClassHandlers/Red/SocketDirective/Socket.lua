
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
local ClassInfo     = require(MODULES.CharacterManagement["ClassInfo"])
local EffectFinder	= require(MODULES.Combat.EffectFinder)


------------------------------------
local logic = {}

function logic:Init(Socket)
	local Player = Socket.Player
    local id = Player.UserId
    
    local function checkIs()
        local PlayerStat = PlayerManager:GetPlayerStat(id)
        if PlayerStat.CurrentClass == script.Parent.Parent.Name then
            return PlayerStat
        end
    end

    Socket:Listen("DropPortal", function()
        local values = ReplicatedStorage.PlayerValues[Player.Name]
        local model = Player.Character
        local playerStat = checkIs()
        local attackSpeedValue = 0
        local teleportRaycastParams = RaycastParams.new()
        teleportRaycastParams.FilterDescendantsInstances = {workspace.Players, workspace.Enemies, workspace.DeadEnemies}
        teleportRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        if not playerStat or not model or values.Stamina.Value < 1 then return end

        for _, Drop in ipairs(playerStat.Characters[playerStat.CurrentClass].Skills) do
            if Drop.Name == "Drop Portal" then
                if Drop.Unlocked then
                    attackSpeedValue = (ClassInfo:GetSkillInfo(Drop.Name).PercentageIncrease[Drop.Rank+1])
                    break
                else
                    return
                end
            end
        end
        
        if model:FindFirstChild("TeleportFolder") then
            model.TeleportFolder:Destroy()
        end

        local teleportFolder = Instance.new("Folder", model)
        teleportFolder.Name = "TeleportFolder"
        Debris:AddItem(teleportFolder, 35)

        local teleporterCooldown = 0

        for i = 1, 2 do
            local rayOrigin = model.PrimaryPart.Position
            local rayDirection = Vector3.new(0, -100, 0)
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection, teleportRaycastParams)
            if raycastResult and teleportFolder then
                local newTeleporter = ServerStorage.Models.Misc.RedTeleporter:Clone()
                newTeleporter.Name = string.format("Teleporter%s", i)
                newTeleporter.Parent = teleportFolder
                local newAnim = newTeleporter.AnimationController:LoadAnimation(newTeleporter.Open)
                newAnim:AdjustSpeed(0)
                newAnim:Play()
                newTeleporter:SetPrimaryPartCFrame(CFrame.new(raycastResult.Position + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, math.rad(Random.new():NextNumber(0, 360)), 0))
                if i >= 2 then
                    local beam = newTeleporter.RightDoor.PivotRight.Beam
                    beam.Attachment0 = teleportFolder["Teleporter1"].RightDoor.PivotRight.Attachment
                    beam.Attachment1 = newTeleporter.RightDoor.PivotRight.Attachment
                    beam.Enabled = true

                    teleportFolder["Teleporter1"].Base.Beam.Enabled = true
                    newTeleporter.Base.Beam.Enabled = true
                end
                newAnim.KeyframeReached:Connect(function(KF)
                    if KF == "Stop" then
                        newAnim:AdjustSpeed(0)
                    end
                end)
                newTeleporter.RightDoor.PivotRight.Touched:Connect(function(hit)
                    local chosenTeleporter = string.format("Teleporter%s", i == 1 and 2 or 1)
                    local foundTeleporter = teleportFolder:FindFirstChild(chosenTeleporter)
                    if foundTeleporter and tick() - teleporterCooldown >= 3 then
                        local hitTarget = hit.Parent
                        local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
                        if hitTarget and hitPlayer then
                            local CombatState = PlayerManager:GetCombatState(hitPlayer.UserId)
                            local Effect = EffectFinder:CreateEffect("Attack Speed Increase", 7, Player.Character)
                            table.insert(CombatState.StatusEffects, Effect)
                            Sockets:GetSocket(hitPlayer):Emit("AdjustAtt", attackSpeedValue, 7)
                            PlayerManager:UpdateCombatState(hitPlayer.UserId, CombatState)
                            
                            teleporterCooldown = tick()
                            local goal = foundTeleporter.RightDoor.PivotRight.CFrame
                            hitTarget.PrimaryPart.CFrame = goal
                            foundTeleporter.Base.Beam.Enabled = false
                            newTeleporter.Base.Beam.Enabled = false
                            wait(3)
                            foundTeleporter.Base.Beam.Enabled = true
                            newTeleporter.Base.Beam.Enabled = true
                        end
                    end
                end)
                newAnim:AdjustSpeed(1)
            end
            wait(5)
        end
    end)

end

return logic