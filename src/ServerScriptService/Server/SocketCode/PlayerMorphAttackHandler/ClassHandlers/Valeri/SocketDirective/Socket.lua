
-- << Services >>
local Debris 			= game:GetService("Debris")
local TweenService 		= game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- << Constants >>
local SERVER_FOLDER = script.Parent.Parent.Parent.Parent.Parent.Parent
local MODULES       = SERVER_FOLDER.Parent.Modules

-- << Modules >>
local Sockets           = require(MODULES.Utility["server"])
local PlayerManager 	= require(MODULES.PlayerStatsObserver)
local ClassInfo         = require(MODULES.CharacterManagement["ClassInfo"])
local EffectFinder	    = require(MODULES.Combat.EffectFinder)
local DamageSystem      = require(MODULES.Combat["DamageSystem"])
local GameObjectHandler	= require(SERVER_FOLDER.SharedModules.GameObjectHandler)

-- << Variables >>
local PVP = nil


------------------------------------
SERVER_FOLDER.Bindables.AddPVPTable.Event:Connect(function(PVPTable)
	PVP = PVPTable
end)

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

    Socket:Listen("SummonTome", function()
        local values = ReplicatedStorage.PlayerValues[Player.Name]
        local model = Player.Character
        local playerStat = checkIs()
        local damageValue = 0

        if not playerStat or not model or values.Stamina.Value < 1 then return end

        local CombatState = PlayerManager:GetCombatState(id)
        local HasSpecial = false
        if CombatState.SpecialBar >= 100 then
            HadSpecial = true
            CombatState.SpecialBar = 0
            PlayerManager:UpdateCombatState(id, CombatState)
            Socket:Emit("SpecialBarReset")
        end

        if model:FindFirstChild("ValeriTome") then
            model.ValeriTome:Destroy()
        end

        for _, TomeSkill in ipairs(playerStat.Characters[playerStat.CurrentClass].Skills) do
            if TomeSkill.Name == "Soul Siphon" then
                if TomeSkill.Unlocked then
                    damageValue = ((ClassInfo:GetSkillInfo(TomeSkill.Name).PercentageIncrease[TomeSkill.Rank + 1]) * 100)
                    break
                else
                    return
                end
            end
        end

        local tome = ServerStorage.Models.Misc.ValeriTome:Clone()
        local attachment = Instance.new("Attachment", model.PrimaryPart)
        attachment.Position = Vector3.new(2, 4, 5)
        tome.PrimaryPart.Position = model.PrimaryPart.Position
        tome.PrimaryPart.AlignOrientation.Attachment1 = attachment
        tome.PrimaryPart.AlignPosition.Attachment1 = attachment
        tome.Parent = model.PrimaryPart
        Debris:AddItem(tome, 30)
        Debris:AddItem(attachment, 30)

        --- Target damage
        local targetsSiphoned = {}
        local tic = 0
        local seekTarget = 0
        local conn = RunService.Heartbeat:Connect(function()
            if not tome or not model then
                return
            end

            if tick() - tic >= 0.25 then
                tic = tick()
                for _, target in ipairs(targetsSiphoned) do
                    DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, GameObjectHandler:GetEnemies(), nil, target, nil, nil, nil, nil, Anims, 1, damageValue, true)
                end
            end
            if tick() - seekTarget >= 5 then
                seekTarget = tick()
                targetsSiphoned = {} --- Resets target pool
                tome.Beams:ClearAllChildren()
                local TeamMembers = PVP and CollectionService:GetTagged(table.find(PVP.RedTeam, Player.Name) and "RedTeam" or "BlueTeam") or {}
                for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
                    if enemy and enemy.PrimaryPart then
                        if not table.find(TeamMembers, enemy.Name) and enemy ~= model then
                            local distance = (enemy.PrimaryPart.Position - model.PrimaryPart.Position).Magnitude
                            if distance <= (HasSpecial and 100 or 50) then
                                local newBeam = tome.PrimaryPart.Beam:Clone()
                                local newTargetAttachment = tome.PrimaryPart.BeamPoint:Clone()
                                newBeam.Attachment0 = tome.PrimaryPart.BeamPoint
                                newBeam.Attachment1 = newTargetAttachment
                                newBeam.Enabled = true
                                newBeam.Parent = tome.Beams
                                newTargetAttachment.Parent = enemy.PrimaryPart
                                Debris:AddItem(newTargetAttachment, 5)
                                table.insert(targetsSiphoned, enemy)
                            end
                        end
                    end
                end
            end
        end)
        wait(30)
        conn:Disconnect()
        conn = nil
    end)

end

return logic