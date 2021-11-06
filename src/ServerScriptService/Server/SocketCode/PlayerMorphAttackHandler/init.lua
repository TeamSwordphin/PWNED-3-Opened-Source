local RunService = game:GetService("RunService")
local CollectionService	= game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")

local SERVER_FOLDER = script.Parent.Parent
local MODULES = SERVER_FOLDER.Parent.Modules

local GameObjectHandler	= require(SERVER_FOLDER.SharedModules.GameObjectHandler)
local DamageSystem = require(MODULES.Combat["DamageSystem"])
local CacheAnimations = require(MODULES.Utility["CacheAnimationList"])
local Utilities	= require(ReplicatedStorage.Scripts.Modules.AIUtil)
local EffectFinder	= require(MODULES.Combat.EffectFinder)
local PlayerManager	= require(MODULES.PlayerStatsObserver)
local RegionModule = require(MODULES.Utility["RegionModule"])
local Hitbox = require(MODULES.Combat["Hitbox"])
local Morpher = require(ReplicatedStorage.Scripts.Modules.Morpher)
local WeaponCraft = require(MODULES.CharacterManagement["WeaponCrafting"])
local ClassInfo = require(MODULES.CharacterManagement["ClassInfo"])
local FS = require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local Sockets = require(MODULES.Utility["server"])
local RaycastModule	= require(MODULES.Combat.RaycastHitbox)
local PVPManager = require(MODULES.Combat.PVPManager)
local RagdollHandler = ReplicatedStorage.Scripts.Modules:WaitForChild("RagdollHandler")
local buildRagdoll = require(ReplicatedStorage.Scripts.Modules:WaitForChild("buildRagdoll"))


--<< Variables >>--

local logic = {}
local PVP = nil

local BindableEvent = Instance.new("BindableEvent", script)

local StamCosts						= {
	Light = 1,
	Heavy = 40,
	Dodge = 30,
	Ult = 3,
	Knockup = 8,
	Knockback = 8
}

local GlobalThings = {
	MaxGemDrops						= 2,
	MaxLootDrops					= 10,
	GlobalParryWindow				= .08,
	GlobalParryCooldown				= 3,
	GlobalBlockSpeed				= 35,
	GlobalBlockModifier				= .1,
	GlobalComboAmount				= 1,
	GlobalComboCooldown				= 3,
	GlobalComboDamageModifier		= .002,
	GlobalLobbyTimer				= 95,
	GlobalFatigueAmount				= .4,
	GlobalUltimateCounter			= 0
}

local ListOfDodges					= {}
local ListOfBlocks 					= {}
local ListOfUlts					= {}
local ListOfLight					= {}
local ListOfHeavy					= {}
local ListOfKnockBacks				= {}
local ListOfKnockUps				= {}
local ListOfKnockDowns				= {}
local BlacklistAnimations			= {}
local ListOfShooty					= {"rbxassetid://1539764838"}
ListOfDodges, ListOfBlocks, ListOfUlts, ListOfLight, ListOfHeavy, ListOfKnockBacks, ListOfKnockUps, ListOfKnockDowns, BlacklistAnimations = CacheAnimations:Cache()


local Vec3, CF = Vector3.new, CFrame.new
local tbi, tbr = table.insert, table.remove
local Rand = Random.new()
local Floor = math.floor

local CharacterKeyframeHandler = {}
for _, moduleKeyframe in ipairs(script:GetDescendants()) do
	if moduleKeyframe.Name == "Keyframe" then
		CharacterKeyframeHandler[string.format("Keyframe%s", moduleKeyframe.Parent.Parent.Name)] = require(moduleKeyframe)
	end
end



--<< Functions >>--
SERVER_FOLDER.Bindables.AddPVPTable.Event:Connect(function(PVPTable)
	PVP = PVPTable
end)

local function AwardBadge(PlayerId, BadgeId)
	BadgeService:AwardBadge(PlayerId,BadgeId)
end

function setCollisionGroupRecursive(object)
	if object:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(object, "Players")
	end
	for _, child in next, object:GetChildren() do
		setCollisionGroupRecursive(child)
	end
end


--<< Socket Init >>--

function logic:Init(Socket)
	local Player = Socket.Player
	local id = Player.UserId
	local GeneralHitbox

	
	local function CreateRangedHitBox(blowback, CFc, size, debrisTime, origin, ForceAnim)
		local p 		= Instance.new("Part")
		local bv 		= Instance.new("BodyVelocity")
		p.Transparency 	= 1
		p.CanCollide 	= false	
		p.CFrame 		= origin or Player.Character.HumanoidRootPart.CFrame*CF(0,0,-1)
		p.Size 			= size
		bv.velocity 	= CFc
		bv.maxForce 	= Vec3(1,1,1)*math.huge
		bv.Parent		= p
		local HitTargets = {}
		p.Touched:Connect(function(hit)
			local PartParent = nil
			if hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid") then
				PartParent = hit.Parent
			elseif hit and hit.Parent.Parent and hit.Parent.Parent:FindFirstChildOfClass("Humanoid") then
				PartParent = hit.Parent.Parent
			end
			local Target = PartParent
			if Target and Target.Parent and Target.Parent ~= workspace.Players and Target ~= Player.Character then
				if not HitTargets[Target] then
					HitTargets[Target] = true
					DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, GameObjectHandler:GetEnemies(), nil, Target, blowback, nil, nil, nil, ForceAnim)
				end
			end
		end)
		p.Parent 		= Player.Character
		wait(debrisTime)
		p:Destroy()
	end
	
	local function CreateHitBox(blowback, cf, siz, KF, Orig, AnimTrack, Deltime, BodyVeloc, BodyAng, BodyPos)
		local CF 			= cf or CF(0,0,-4)
		local size			= siz or Vec3(4,6,5)
		local X, Y, Z 		= size.X >= 100 and 100 or size.X, size.Y >= 100 and 100 or size.Y, size.Z >= 600 and 600 or size.Z
		local BoxSize 		= Vec3(X, Y, Z)
		local Origin		= Orig and Orig*CF or Player.Character.HumanoidRootPart.CFrame*CF
		local Region 		= RegionModule.new(Origin, BoxSize)

		local IgnoreList = {Player.Character.Parent == workspace.Enemies and Player.Character or workspace.Players, workspace.DeadEnemies}
		if PVP then
			for _,TeamMates in ipairs(CollectionService:GetTagged(table.find(PVP.RedTeam, Player.Name) and "RedTeam" or "BlueTeam")) do
				tbi(IgnoreList, TeamMates.Character)
			end
		end
		local parts 		= Region:Cast(IgnoreList)
		local CanDamage 	= true
		local HitTargets = {}
		local Enemies = GameObjectHandler:GetEnemies()
		for i = 1, #parts do
			local PartParent = nil
			if parts[i].Parent:FindFirstChildOfClass("Humanoid") then
				PartParent = parts[i].Parent
			elseif parts[i].Parent.Parent:FindFirstChildOfClass("Humanoid") then
				PartParent = parts[i].Parent.Parent
			end
			if PartParent and not HitTargets[PartParent] then
				if KF == "Grab" then
					CanDamage = false
					return PartParent
				end
				if CanDamage then
					HitTargets[PartParent] = true
					DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, Enemies, nil, PartParent, blowback)
				end
			end
		end
		if CanDamage then
			for _,Enemy in ipairs(Enemies) do
				if Enemy ~= nil then
					if HitTargets[Enemy.Torso.Parent] ~= nil then
						local Delt, BodyV, BodyA, BodyP = Deltime or nil, BodyVeloc or nil, BodyAng or nil, BodyPos or nil
						if Delt == nil or BodyV == nil then
							Delt, BodyV, BodyA, BodyP = Hitbox:CommitPhysics(AnimTrack, Player.Character, Enemy.Torso.Parent, KF)
						end
						if Delt ~= nil then
							Enemy.CommitPhysics(Player, Delt, BodyV, BodyA, BodyP)
						end
					end
					if Enemy.Configuration.Type == "Flying" then
						for v = 1, #Enemy.Configuration.Animations do
							local Bullet = Enemy.Configuration.Animations[v]
							if Bullet ~= nil and (Origin.p-Bullet.CFrame.p).magnitude <= (X+Y+Z)*.333 then
								local ConsGem = EffectFinder:FindGemstone(id, "Counterattack")
								if ConsGem ~= nil then
									local CombatState = PlayerManager:GetCombatState(id)
									CombatState.ConsumedDamage = CombatState.ConsumedDamage + (Enemy.Configuration.Atk*(ConsGem.Q*.01))
									PlayerManager:UpdateCombatState(id, CombatState)
								end
								Bullet.Tick = 9999
								DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, Enemies, nil, Enemy.Torso.Parent)
								Socket:Emit("Deflect", Enemy.Torso)
								break
							end
						end
					end
				end
			end
		end
	end
	
	Socket:Listen("A", function(aim) ---For characters that aim like Red. Useless otherwise.
		local CombatState = PlayerManager:GetCombatState(id)
		for _,Shooties in ipairs(ListOfShooty) do
			if CombatState.LastAnim ~= nil and Shooties == CombatState.LastAnim.Animation.AnimationId then
				CombatState.LastAim = aim
				if CombatState.LastAim ~= nil then
					local pos, dir = CombatState.LastAim, CombatState.LastAim.lookVector
					local HitEnemies = {}
					local Spd = 1 --Spread
					for i = 1, 9 do
						local x = (i == 1 and 0) or (i == 2 and 0) or (i == 3 and 0) or (i == 4 and Spd) or (i == 5 and -Spd) or (i == 6 and -Spd) or (i == 7 and Spd) or (i == 8 and -Spd) or (i == 9 and Spd)
						local y = (i == 1 and 0) or (i == 2 and Spd) or (i == 3 and -Spd) or (i == 4 and 0) or (i == 5 and 0) or (i == 6 and Spd) or (i == 7 and Spd) or (i == 8 and -Spd) or (i == 9 and -Spd)
						local NewP = pos*CF(x,y-1.2,0)
						local IgnoreList = {Player.Character.Parent == workspace.Enemies and Player.Character or workspace.Players, workspace.Terrain, workspace.DeadEnemies}
						if PVP then
							for _,TeamMates in ipairs(CollectionService:GetTagged(table.find(PVP.RedTeam, Player.Name) and "RedTeam" or "BlueTeam")) do
								tbi(IgnoreList, TeamMates.Character)
							end
						end
						local Hit = Utilities:Raycast(NewP.p, NewP.lookVector*5000, IgnoreList, false, 1 , false, true)
						if Hit ~= nil then
							local PartParent = nil
							if Hit.Parent:FindFirstChildOfClass("Humanoid") then
								PartParent = Hit.Parent
							elseif Hit.Parent.Parent:FindFirstChildOfClass("Humanoid") then
								PartParent = Hit.Parent.Parent
							end
							if PartParent and not HitEnemies[PartParent] then
								HitEnemies[PartParent] = true
								CreateHitBox(false,CF(0,0,0), Vec3(20,20,20), nil, Hit.CFrame, nil, .75, NewP.LookVector * 50 + Vector3.new(0, 25, 0),  Vector3.new(0, Rand:NextNumber(-25, 25), Rand:NextNumber(-160, 160))) 
							end
						end
					end
				end
				break
			end
		end
	end)

	local SpecialClasses = {"Red", "Valeri", "LingeringForce"}

	Socket:Listen("GetBattleModeInfo", function()
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local CombatState = PlayerManager:GetCombatState(id)
		local currentClass = PlayerStat.CurrentClass
		local currentLevel = PlayerStat.Characters[currentClass].CurrentLevel
		local currentStamina = PlayerStat.Characters[currentClass].Stamina
		local SkillLoadOut = PlayerStat.Characters[currentClass].SkillsLoadOut
		local classScript = ReplicatedStorage.Scripts.ClassAnimateScripts[currentClass]
		CombatState.AttackSpeed = (1 + ((currentStamina * 0.04) * .01)) > 1.4 and 1.4 or (1 + ((currentStamina * 0.04) * .01))
		CombatState.IsSpecial = table.find(SpecialClasses, currentClass) and true or false

		local Skills = PlayerStat.Characters[currentClass].Skills
		for _, v in ipairs(Skills) do
			if v.Name == "Attack Speed Mastery" and v.Unlocked then
				CombatState.AttackSpeed += (0.015 * v.Rank)
				break
			end
		end

		local ChainCooldowns = {
			C1 = 0,
			C2 = 0,
			C3 = 0,
			CD1 = 0,
			CD2 = 0,
			CD3 = 0,
			BonusAtk1 = 0,
			BonusAtk2 = 0,
			BonusAtk3 = 0
		}
		
		for i = 1, 3 do --- row
			local Counter = 1
			for b = 1, 3 do ---- column
				if SkillLoadOut["C"..i][b] ~= nil then
					local SkillInfo = ClassInfo:GetSkillInfo(SkillLoadOut["C"..i][b])
					if SkillInfo ~= nil then
						for _,Skills in ipairs(classScript.attackY:GetChildren()) do
							if Skills:IsA("Animation") then
								if Skills.AnimationId == SkillInfo.AnimId then
									if SkillInfo.Cooldown > 0 then
										ChainCooldowns["C" ..i] += SkillInfo.Cooldown
									end
									local NewSkill = Skills:Clone()
									NewSkill.Name = string.format("Y%s-%s", i, Counter)
									NewSkill.Parent = classScript.attackY
									Counter = Counter + 1
									break
								end
							end
						end
					end
				end
			end
			ChainCooldowns["BonusAtk" ..i] = i == 1 and (Counter <= 2 and 1*Counter or 5) or i == 2 and (Counter <= 2 and 4*Counter or 15) or (Counter <= 2 and 10*Counter or 40)
			ChainCooldowns["C" ..i] *= 1-((Counter-1) * (i * .05))
		end
		
		CombatState.ChainCooldowns = ChainCooldowns

		return currentClass, currentLevel, CombatState.AttackSpeed, CombatState.IsSpecial, ChainCooldowns
	end)
	
	local function BattleMode()
		--[[
			This function calls everytime a character loads on the battlefield (respawning counts too)
		--]]
		
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)

		local currentClass = PlayerStat.CurrentClass
		local currentLevel = PlayerStat.Characters[currentClass].CurrentLevel
		local currentStamina = PlayerStat.Characters[currentClass].Stamina
		local wep = WeaponCraft:GetWeaponFromID(currentClass, PlayerStat.Characters[currentClass].CurrentWeapon.ID)
		local classScript = ReplicatedStorage.Scripts.ClassAnimateScripts[currentClass]:Clone()

		if not wep.Model then return end

		local weapon = wep.Model:Clone()
		local Motor6D = weapon:FindFirstChild("WristToHandle")
		classScript.Name = "Animate"
		weapon.Name	= "Weapon"
		Motor6D.Part0 = Player.Character.RightHand
		if weapon:FindFirstChild("Handle") == nil then
			Motor6D.Part1 = weapon.Hand.Value
		else
			Motor6D.Part1 = weapon.Handle
		end
		if weapon:FindFirstChild("Offhand") then
			local Off = weapon.Offhand
			local Motor6D2 = Off:FindFirstChild("WristToHandle")
			Off.Name = "OffhandWeapon"
			Motor6D2.Part0 = Player.Character.LeftHand
			if Off:FindFirstChild("Handle") == nil then
				Motor6D2.Part1 = Off.Hand.Value
			else
				Motor6D2.Part1 = Off.Handle
			end
			Off.Parent = Player.Character
		end
		local CharacterSkills = PlayerStat.Characters[currentClass].Skills
		local SkillLoadOut = PlayerStat.Characters[currentClass].SkillsLoadOut		
		local ChainCooldowns = {
			C1 = 0,
			C2 = 0,
			C3 = 0,
			CD1 = 0,
			CD2 = 0,
			CD3 = 0,
			BonusAtk1 = 0,
			BonusAtk2 = 0,
			BonusAtk3 = 0
		}
		
		CombatState.AttackSpeed = 1
		PlayerStat.Characters[currentClass].Skills = ClassInfo:UpdateClassSkills(CharacterSkills, currentClass)
		
		for i = 1, 3 do --- row
			local Counter = 1
			for b = 1, 3 do ---- column
				if SkillLoadOut["C"..i][b] ~= nil then
					local SkillInfo = ClassInfo:GetSkillInfo(SkillLoadOut["C"..i][b])
					if SkillInfo ~= nil then
						for _,Skills in ipairs(classScript.attackY:GetChildren()) do
							if Skills:IsA("Animation") then
								if Skills.AnimationId == SkillInfo.AnimId then
									if SkillInfo.Cooldown > 0 then
										ChainCooldowns["C" ..i] += SkillInfo.Cooldown
									end
									local NewSkill = Skills:Clone()
									NewSkill.Name = string.format("Y%s-%s", i, Counter)
									NewSkill.Parent = classScript.attackY
									Counter = Counter + 1
									break
								end
							end
						end
					end
				end
			end
			ChainCooldowns["BonusAtk" ..i] = i == 1 and (Counter <= 2 and 1*Counter or 5) or i == 2 and (Counter <= 2 and 4*Counter or 15) or (Counter <= 2 and 10*Counter or 40)
			ChainCooldowns["C" ..i] *= 1-((Counter-1) * (i * .05))
		end
		
		CombatState.ChainCooldowns = ChainCooldowns

		local Skills = PlayerStat.Characters[currentClass].Skills
		for _,Anim in ipairs(classScript:GetDescendants()) do
			if Anim:IsA("Animation") then
				for _, Skill in ipairs(Skills) do
					local SkillInfo = ClassInfo:GetSkillInfo(Skill.Name)
					if SkillInfo.AnimId == Anim.AnimationId and Skill.Unlocked == false then
						Anim:Destroy()
					end
				end
			end
		end

		if Player.Character:FindFirstChild("Animate") then
			Player.Character.Animate:Destroy()
		end

		classScript.Parent = Player.Character
		weapon.Parent = Player.Character
		Motor6D.Parent = Player.Character.RightHand
		if not PVP then
			Player.TeamColor = Teams.InGame.TeamColor
		end
		
		local Trophy = WeaponCraft:GetTrophyFromID(PlayerStat.Characters[currentClass].CurrentTrophy.Map, PlayerStat.Characters[currentClass].CurrentTrophy.ID)
		
		local MaxHp = PlayerStat.Characters[currentClass].HP
		MaxHp = MaxHp + (Trophy.Stats.HP+(Trophy.StatsPerLevel.HP*PlayerStat.Characters[currentClass].CurrentTrophy.UpLvl))
		for _, v in ipairs(Skills) do
			local Skil = ClassInfo:GetSkillInfo(v.Name)
			if v.Name == "Powers United" then
				MaxHp = MaxHp + PlayerStat.Characters[currentClass].Damage * .2
				MaxHp = MaxHp + PlayerStat.Characters[currentClass].Defense * .2
				MaxHp = MaxHp + PlayerStat.Characters[currentClass].Stamina * .2
				MaxHp = MaxHp + PlayerStat.Characters[currentClass].Crit * .2
				MaxHp = MaxHp + PlayerStat.Characters[currentClass].CritDef * .2
			elseif v.Name == "Attack Speed Mastery" and v.Unlocked then
				CombatState.AttackSpeed += 0.015 * v.Rank
			end
		end
		local HPGem = EffectFinder:FindGemstone(id, "HP Increase")
		if HPGem ~= nil then
			MaxHp = MaxHp * (1+(HPGem.Q*.01))
		end
		
		if EffectFinder:FindWeaponEffect(id, "Mechanical Wings") then
			Player.Character.Humanoid.JumpPower = 60
		elseif EffectFinder:FindWeaponEffect(id, "Mechanical Wings II") then
			Player.Character.Humanoid.JumpPower = 65
		end
		
		classScript.Disabled = false

		CombatState.IsSpecial = false
		CombatState.CryPoints = 50
		CombatState.CryFormCD = 0
		CombatState.SpecialBar = 0
		CombatState.CryForm	= false
		CombatState.MaxBlockHP = currentStamina + (wep.Stats.STAM + (wep.StatsPerLevel.STAM * PlayerStat.Characters[currentClass].CurrentWeapon.UpLvl))
		CombatState.Dodging = false
		CombatState.CriticalWounds = 0
		CombatState.DPS = 0
		CombatState.HighestCombo = 0
		CombatState.DodgedAttacks = 0
		CombatState.DamageTaken	= 0
		CombatState.SupportSkills = 0
		CombatState.Revivals = 0
		CombatState.MAXHP = MaxHp
		CombatState.AttackSpeed += (((currentStamina * 0.04) * .01)) > 1.4 and 1.4 or (1 + ((currentStamina * 0.04) * .01))

		Player.Character.Humanoid.MaxHealth = Floor(MaxHp+.5)
		Player.Character.Humanoid.Health 	= Player.Character.Humanoid.MaxHealth

		ReplicatedStorage.PlayerValues[Player.Name].Stamina.Value = CombatState.MaxBlockHP
		ReplicatedStorage.PlayerValues[Player.Name].StaminaMax.Value = CombatState.MaxBlockHP
		ReplicatedStorage.PlayerValues[Player.Name].StaminaRecoveryRate.Value = 1.5

		ReplicatedStorage.PlayerValues[Player.Name].Barrier.Value = 0
		ReplicatedStorage.PlayerValues[Player.Name].BarrierDecayRate.Value = MaxHp * 0.0015

		local AtkSpd = EffectFinder:FindWeaponEffect(id, "Quick Hands")
		if AtkSpd ~= nil then
			CombatState.AttackSpeed = CombatState.AttackSpeed + (AtkSpd.V*.01)
		end
		
		CombatState.IsSpecial = table.find(SpecialClasses, currentClass) and true or false
		
		PlayerManager:UpdateCombatState(id, CombatState)
	end

	local NewConn = BindableEvent.Event:Connect(function(player)
		if player.TeamColor == Teams.InGame.TeamColor and player.UserId == id then
			BattleMode()
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		if player.UserId == id and NewConn then
			NewConn:Disconnect()
			NewConn = nil
		end
	end)
	
	local function EquipTrophy()
		if PVP then
			Socket:Emit("Hint", "You cannot change trophies in PVP!")
		else
			local PlayerStat = PlayerManager:GetPlayerStat(id)
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			local CurrentTrophy = CurrentClass.CurrentTrophy
			
			if Player.Character:FindFirstChild("Trophy") then
				Player.Character.Trophy:Destroy()
			end
			if CurrentTrophy.Map ~= "Null" then
				local FetchTrophy = WeaponCraft:GetTrophyFromID(CurrentTrophy.Map, CurrentTrophy.ID)
				Morpher:morphTrophy(FetchTrophy.Model, Player.Character)
			end
		end
	end
	
	Socket:Listen("EquipTrophy", function()
		EquipTrophy()
	end)
	Socket:Listen("EquipPiece", function(Limb, SkinName)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local currentClass = PlayerStat.Characters[PlayerStat.CurrentClass]

		if Limb and SkinName then
			for i,v in ipairs(Player.Character:GetChildren()) do
				if v:IsA("Model") and v.Name ~= "Trophy" then
					v:Destroy()
				end
			end

			for _, skin in ipairs(currentClass.Skins) do
				if skin.Name == SkinName then
					if currentClass.CurrentSkinPieces[Limb] then
						currentClass.CurrentSkinPieces[Limb] = {N = skin.Name, P = {}, S = {}, T = {}, Q = {}}
					end
					Morpher:morph(Player.Character, currentClass.CurrentSkinPieces)
				end
			end
		end
	end)
	Socket:Listen("EquipCostume", function(SkinObj)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local currentClass = PlayerStat.Characters[PlayerStat.CurrentClass]

		if typeof(SkinObj) == "table" and SkinObj.Name then
			for i,v in ipairs(Player.Character:GetChildren()) do
				if v:IsA("Model") and v.Name ~= "Trophy" then
					v:Destroy()
				end
			end

			for _, skin in ipairs(currentClass.Skins) do
				if skin.Name == SkinObj.Name then --- checks to see if they own it
					for name, _ in pairs(currentClass.CurrentSkinPieces) do
						if ReplicatedStorage.Models.Armor[skin.Name]:FindFirstChild(Morpher:GetLimbInfo()[name]) then
							currentClass.CurrentSkinPieces[name] = {N = skin.Name, P = {}, S = {}, T = {}, Q = {}}
						end
					end
					Morpher:morph(Player.Character, currentClass.CurrentSkinPieces)
					return currentClass
				end
			end
		end
		return nil
	end)

	Socket:Listen("PetChange", function(petName)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		Player.Character.Pets:ClearAllChildren()

		if petName == "Nothing" then
			PlayerStat.CurrentPet = "Nothing"
			return
		end

		if table.find(PlayerStat.Pets, petName) then
			PlayerStat.CurrentPet = petName
			local pPet = ReplicatedStorage.Models.Pets:FindFirstChild(PlayerStat.CurrentPet)
			if pPet then
				local newPet = pPet:Clone()
				newPet.PrimaryPart.AlignOrientation.Attachment1 = Player.Character.PrimaryPart.PetPosition
				newPet.PrimaryPart.AlignPosition.Attachment1 = Player.Character.PrimaryPart.PetPosition
				newPet.Parent = Player.Character.Pets
			end
		else
			PlayerStat.CurrentPet = "Nothing"
		end
	end)
	
	Socket:Listen("CryMorph", function() --- TBA
		--[[
			Nothing yet. We will revisit this a a much later date.
		--]]
		
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		if PlayerStat then
			local currentClass = PlayerStat.CurrentClass
			if CombatState.CryFormCD ~= 0 then
				CombatState.CryPoints = CombatState.CryPoints + Floor(tick() - CombatState.CryFormCD+.5)
				if CombatState.CryPoints > 50 then
					CombatState.CryPoints = 50
				end
			end
			if CombatState.CryForm == false and CombatState.CryPoints >= 5 then
				for i,v in ipairs(Player.Character:GetChildren()) do
					if v:IsA("Model") and v.Name ~= "Weapon" then
						v:Destroy()
					end
				end
				Morpher:morph(ServerStorage.Models.Armor:FindFirstChild(currentClass.."CrySuit"), Player.Character)
				Player.Character.Health:Destroy()
				ServerStorage.Scripts.Health:clone().Parent = Player.Character
				if Player.Character.Humanoid.Health <= (Player.Character.Humanoid.MaxHealth*.1) then
					AwardBadge(id, 706685135)
				end
				Player.Character.Humanoid.Health = Player.Character.Humanoid.MaxHealth
				CombatState.CryForm = true
				FS.spawn(function()
					while CombatState.CryForm do
						wait(1)
						CombatState.CryPoints = CombatState.CryPoints - 2.5
						print(CombatState.CryPoints)
						if CombatState.CryPoints <= 0 then
							CombatState.CryPoints = 0
							CombatState.CryForm = false
						end
					end
					for i,v in ipairs(Player.Character:GetChildren()) do
						if v:IsA("Model") and v.Name ~= "Weapon" then
							v:Destroy()
						end
					end
					local skin = PlayerStat.Characters[currentClass].CurrentSkin
					Morpher:morph(ReplicatedStorage.Models.Armor:FindFirstChild(skin.Name), Player.Character, skin)
					CombatState.CryFormCD = tick()
				end)
			elseif CombatState.CryForm then
				CombatState.CryForm = false
			end
		end
	end)

	Socket:Listen("ItemUse", function(item)
		local Changes = false
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local CombatState = PlayerManager:GetCombatState(id)

		print(PlayerStat.Potions, PlayerStat.PotionsStamina)

		if item == "Potion" then
			if PlayerStat.Potions >= 1 then
				PlayerStat.Potions -= 1
				local Effect = EffectFinder:CreateEffect("Potion", 10, Player.Character)
				tbi(CombatState.StatusEffects, Effect)
				PlayerManager:UpdateCombatState(id, CombatState)
				Changes = true
			end
		elseif item == "PotionStamina" then
			if PlayerStat.PotionsStamina >= 1 then
				PlayerStat.PotionsStamina -= 1
				EffectFinder:FindEffect("Stam Boost", id, true) 
				local Effect = EffectFinder:CreateEffect("Stam Boost", 60, Player.Character)
				tbi(CombatState.StatusEffects, Effect)
				PlayerManager:UpdateCombatState(id, CombatState)
				Changes = true
			end
		end
		if Changes then
			PlayerManager:UpdateCombatState(id, CombatState)
		end
	end)

	Socket:Listen("Blocking", function()
		if Player.TeamColor == Teams.InGame.TeamColor then
			local CombatState = PlayerManager:GetCombatState(id)

			--- Blocking
			EffectFinder:FindEffect("Blocking", id, true)
			local Effect = EffectFinder:CreateEffect("Blocking", 2, Player.Character, nil, true)
			tbi(CombatState.StatusEffects, Effect)

			--- Parrying
			if tick() - CombatState.RecentlyParried >= 3 then
				CombatState.RecentlyParried = 0
				CombatState.ParryAmount = 0
			end
			EffectFinder:FindEffect("Parrying", id, true)
			local Effect = EffectFinder:CreateEffect("Parrying", (0.3 - (CombatState.ParryAmount * 0.06)), Player.Character, nil, true)
			tbi(CombatState.StatusEffects, Effect)
			CombatState.ParryAmount = CombatState.ParryAmount >= 5 and 5 or CombatState.ParryAmount + 1
			CombatState.RecentlyParried = tick()
			PlayerManager:UpdateCombatState(id, CombatState)
		end
	end)

	Socket:Listen("StopBlocking", function()
		if Player.TeamColor == Teams.InGame.TeamColor then
			EffectFinder:FindEffect("Blocking", id, true)
			EffectFinder:FindEffect("Parrying", id, true)
		end
	end)

	local function createHitbox(char)
		local IgnoreList = {Player.Character.Parent == workspace.Enemies and Player.Character or workspace.Players, workspace.Terrain, workspace.DeadEnemies}
		if PVP then
			for _,TeamMates in ipairs(CollectionService:GetTagged(table.find(PVP.RedTeam, Player.Name) and "RedTeam" or "BlueTeam")) do
				tbi(IgnoreList, TeamMates.Character)
			end
		end

		GeneralHitbox = RaycastModule:Initialize(char, IgnoreList)
		GeneralHitbox.OnHit:Connect(function(hit, humanoid)
			DamageSystem:DamageMode(GameObjectHandler:GameData(), id, char, GameObjectHandler:GetEnemies(), nil, humanoid.Parent)
		end)

		GeneralHitbox.OnUpdate:Connect(function(pointPosition)
			local Enemies = GameObjectHandler:GetEnemies()
			for _, Enemy in ipairs(Enemies) do
				for i, bullet in ipairs(Enemy.Configuration.Animations) do
					if bullet and bullet.Tick < 9998 then 
						if (pointPosition - bullet.CFrame.Position).Magnitude <= 5 then
							local ConsGem = EffectFinder:FindGemstone(id, "Counterattack")
							if ConsGem ~= nil then
								local CombatState = PlayerManager:GetCombatState(id)
								CombatState.ConsumedDamage += (Enemy.Configuration.Atk * (ConsGem.Q * 0.01))
								PlayerManager:UpdateCombatState(id, CombatState)
							end
							DamageSystem:DamageMode(GameObjectHandler:GameData(), id, char, Enemies, nil, Enemy.Torso.Parent, nil, nil, nil, true)
							bullet.CFrame = bullet.CFrame * CFrame.new(0, 6000, 0)
							bullet.Tick = 9999
							Socket:Emit("Deflect", Enemy.Torso)
							break
						end
					end
				end
			end
		end)
	end

	Socket:Listen("ForceHitbox", function()
		if GeneralHitbox then return end

		createHitbox(Player.Character)
	end)

	Socket:Listen("ForceMorph", function()
		--[[
			Important function. Gives the player their character skins and observes the player's animations.
			Will play certain effects like buffs once Keyframe has been reached.
		--]]
		
		local SpawnMorph = {}
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		for _, model in ipairs(Player.Character:GetChildren()) do
			if model.Name ~= "Weapon" and model:IsA("Model") then
				model:Destroy()
			end
		end
		
		if PlayerStat then
			SpawnMorph.Create = function()
				
				local CombatState = PlayerManager:GetCombatState(id)
				local currentClass = PlayerStat.CurrentClass
				local skin = PlayerStat.Characters[currentClass].CurrentSkinPieces
				local Enemies = GameObjectHandler:GetEnemies()
				local values = ReplicatedStorage.PlayerValues:FindFirstChild(Player.Name)

				if not values then
					local newValues = ReplicatedStorage.PlayerValues["Default_CharacterValues"]:Clone()
					newValues.Name = Player.Name
					newValues.Parent = ReplicatedStorage.PlayerValues
				else
					for _, value in ipairs(values:GetChildren()) do
						value.Value = 0
					end
				end

				Morpher:morph(Player.Character, skin)
				EquipTrophy()

				if PlayerStat.CurrentPet ~= "" then
					local pPet = ReplicatedStorage.Models.Pets:FindFirstChild(PlayerStat.CurrentPet)
					if pPet then
						local newPet = pPet:Clone()
						newPet.PrimaryPart.AlignOrientation.Attachment1 = Player.Character.PrimaryPart.PetPosition
						newPet.PrimaryPart.AlignPosition.Attachment1 = Player.Character.PrimaryPart.PetPosition
						newPet.Parent = Player.Character.Pets
					end
				end

				setCollisionGroupRecursive(Player.Character)
				CombatState.Character = Player.Character
				Player.Character.Class.Value = currentClass
				
				buildRagdoll(Player.Character.Humanoid)

				local keyFrameHandler = CharacterKeyframeHandler[string.format("Keyframe%s", PlayerStat.CurrentClass)]
				if keyFrameHandler then
					keyFrameHandler(Player.Character.Humanoid, Player.Character)
				end
				
				Player.Character.Humanoid.AnimationPlayed:Connect(function(AnimTrack)
					CombatState = PlayerManager:GetCombatState(id)
					PlayerStat = PlayerManager:GetPlayerStat(id)
					
					if PlayerStat == nil then
						return
					end
					currentClass = PlayerStat.CurrentClass
					
					if Player.TeamColor ~= Teams.Lobby.TeamColor and EffectFinder:FindWeaponEffect(id, "Third Strike Fallacy") then
						if AnimTrack.Animation.AnimationId == Player.Character.Animate.attackX.X3.AnimationId then
							local Swords = ServerStorage.Models.Misc.ShadowSwordSpin:Clone()
							local Motor = Swords.CenterBrickMotor
							Motor.Part0 = Player.Character.PrimaryPart
							Motor.Part1 = Swords.PrimaryPart
							Motor.Parent = Player.Character.PrimaryPart
							Swords.Parent = Player.Character
							local SwordAnim = Player.Character.Humanoid:LoadAnimation(Swords.ShadowSpin)
							local Hitbox = RaycastModule:Initialize(Swords, Player.Character.Parent == workspace.Enemies and {Player.Character} or {workspace.Players})
							Hitbox.OnHit:Connect(function(hit, humanoid)
								DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, Enemies, nil, humanoid.Parent, nil, nil, nil, nil, nil, 0.5)
							end)
							SwordAnim.KeyframeReached:Connect(function(KF)
								if KF == "HitStart" then
									Hitbox:HitStart()
								elseif KF == "HitStop" then
									Hitbox:HitStop()
								end
							end)
							SwordAnim:Play()
							Debris:AddItem(Motor, 5)
							Debris:AddItem(Swords, 5)
							wait(4.5)
							SwordAnim:Destroy()
							Swords:Destroy()
						end
					end
					
					if currentClass == "DarwinB" or currentClass == "LingeringForce" or currentClass == "Alburn" then
						for i = 1, #CombatState.StatusEffects do
							local Effect = CombatState.StatusEffects[i]
							if Effect then
								if Effect.Name == "Elysian Counter" or Effect.Name == "Spearlancer" then
									if Player.Character.PrimaryPart:FindFirstChild("CounterAnimation") then
										Player.Character.PrimaryPart.CounterAnimation:Destroy()
									end
									if Effect.Object ~= nil then 
										Effect.Object:Destroy()
									end
									tbr(CombatState.StatusEffects, i)
									break
								end
								if currentClass == "Alburn" and Effect.Name == "Chaos Bulwark" then
									local AnimationTracks = Player.Character.Humanoid:GetPlayingAnimationTracks()
									local CanDel = true
									for i, track in pairs (AnimationTracks) do
										if track.Animation.AnimationId == "rbxassetid://3917046117" then
											CanDel = false
											break
										end
									end
									if CanDel then
										if Player.Character:FindFirstChild("Bulwark") then
											Player.Character.Bulwark:Destroy()
										end
										if Effect.Object ~= nil then 
											Effect.Object:Destroy()
										end
										tbr(CombatState.StatusEffects, i)
									end
								end
							end
						end
					end

					local Ain = AnimTrack.KeyframeReached:Connect(function(KF)
						if KF == "SlashBegin" or KF == "DamageStart" or KF == "Knockback" or KF == "Grab" or KF == "SlashPhysics" or KF == "SlashUp" or KF == "SlashBeginBig" then
							local CFc, Size, Type = Hitbox:CreateBox(AnimTrack, Player.Character, KF)
							if Type == nil then --- nil equals melee
								if Size == nil or CFc == nil then
									GeneralHitbox:HitStart()
								else
									CreateHitBox(KF == "Knockback" and true or false, CFc, Size, KF, nil, AnimTrack)
								end
							else
								CreateRangedHitBox(KF == "Knockback" and true or false,CFc,Size,Type) --CF is Velocity, and Type is the DebrisTime
							end
						elseif KF == "SlashE" or KF == "SlashEnd" or KF == "DamageStop" or KF == "AnimationEnd" then
							GeneralHitbox:HitStop()
						elseif KF == "Proj" and (currentClass == "Darwin" or currentClass == "DarwinB")then
							CreateRangedHitBox(KF == "Knockback" and true or false,Player.Character.PrimaryPart.CFrame.lookVector*400, Vector3.new(4,6,1), 3) --CF is Velocity, and Type is the DebrisTime
						elseif KF == "GrenadeThrow" and currentClass == "Red" then
							local CFc, Size, Type = Hitbox:CreateBox(AnimTrack, Player.Character)
							local Orig = Player.Character.HumanoidRootPart.CFrame
							FS.spawn(function()
								for i = 1, 40 do					
									CreateHitBox(false, CFc, Size, KF, Orig, AnimTrack)
									wait(.1)
								end
							end)
						elseif (KF == "SummonTurret" or KF == "SummonSniperTurret") and currentClass == "Red" then
							local TurretCount = 0
							local FirstTurr;
							for _, Turret in ipairs(script.Parent.Parent.Parent.BossScript:GetChildren()) do
								if Turret.Name == "TurretScript" then
									if Turret.OwnerPlayerId.Value == id then
										TurretCount += 1
										if FirstTurr == nil then
											FirstTurr = Turret
										end
										if TurretCount > 2 then
											if FirstTurr.Model.Value ~= nil and FirstTurr.Model.Value:FindFirstChild("Humanoid") then
												FirstTurr.Model.Value.Humanoid:TakeDamage(9999999999)
											end
										end
									end
								end
							end
							local NewTurret = ServerStorage.Models.Misc[KF == "SummonTurret" and "RedTurret" or "RedSniperTurret"]:Clone()
							local TurretScript = NewTurret.TurretScript
							TurretScript.Model.Value = NewTurret
							TurretScript.OwnerPlayerId.Value = id
							TurretScript.Parent = script.Parent.Parent.Parent.BossScript
							NewTurret.Parent = Player.Character.Parent == workspace.Enemies and workspace.Enemies or workspace.Players
							local Torso = Player.Character.PrimaryPart
							local Hit, Position, Surface = Utilities:Raycast(Torso.Position, Vec3(0, (-Torso.Size.Y * 100), 0), {workspace.Players, workspace.Enemies, workspace.DeadEnemies}, false, 1 , false, true)
							local TrueCF = CF(Position, Position + Surface) * CFrame.Angles(math.rad(-90),0,0)
							NewTurret:SetPrimaryPartCFrame(TrueCF * CF(0, 1, 0))
							NewTurret.Humanoid.MaxHealth = 300 + (42 * PlayerStat.Characters[currentClass].CurrentLevel)
							NewTurret.Humanoid.Health = NewTurret.Humanoid.MaxHealth
							NewTurret.Bindables.Stats.DEF.Value = -200 + (2 * PlayerStat.Characters[currentClass].CurrentLevel)
							NewTurret.Bindables.Damage.Event:Connect(function(targ)
								DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, Enemies, nil, targ, nil, nil, nil, nil, AnimTrack)
							end)
							NewTurret.Humanoid.HealthChanged:Connect(function()
								if NewTurret.Humanoid.Health < 1 then
									TurretScript:Destroy()
									NewTurret:Destroy()
								end
							end)
							TurretScript.Disabled = false
							local Time = KF == "SummonTurret" and 30 or 40
							for i=1, #PlayerStat.Characters[currentClass].Skills do
								local Skill = PlayerStat.Characters[currentClass].Skills[i]
								local ve = ClassInfo:GetSkillInfo(Skill.Name)
								if ve.AnimId == (KF == "SummonTurret" and "rbxassetid://3505475719" or "rbxassetid://5661676845") then
									Time = Time + (4*Skill.Rank)
								end
							end
							Debris:AddItem(TurretScript, Time)
							Debris:AddItem(NewTurret, Time)
						elseif KF == "Counter" and (currentClass == "DarwinB") then
							local Effect = EffectFinder:CreateEffect("Elysian Counter", 1, Player.Character)
							tbi(CombatState.StatusEffects, Effect)
							PlayerManager:UpdateCombatState(id, CombatState)
						elseif KF == "MarkedForPull" and (currentClass == "DarwinB") then
							if Player.Character.HumanoidRootPart:FindFirstChild("MarkedForPull") ~= nil then
								Player.Character.HumanoidRootPart.MarkedForPull:Destroy()
							end
							local Range = 25
							if EffectFinder:FindEffect("Fervors Edge", id) ~= nil then
								Range = 50
							end
							
							for _, Enemy in ipairs(workspace.Enemies:GetChildren()) do
								if Enemy ~= Player.Character and Enemy.PrimaryPart then
									if (Enemy.PrimaryPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= Range then
										local Folder = nil
										if Player.Character.HumanoidRootPart:FindFirstChild("MarkedForPull") == nil then
											Folder = Instance.new("Folder")
											Folder.Name = "MarkedForPull"
											Folder.Parent = Player.Character.HumanoidRootPart
											Debris:AddItem(Folder, 3)
										else
											Folder = Player.Character.HumanoidRootPart.MarkedForPull
										end
										local ObjectValue = Instance.new("ObjectValue")
										ObjectValue.Name = "Target"
										ObjectValue.Value = Enemy.PrimaryPart
										local EnemyIsBoss = false
										for _, EnemyTable in ipairs(Enemies) do
											if EnemyTable.Torso ~= nil and EnemyTable.Torso == EnemyTable.PrimaryPart then
												if EnemyTable.Boss then
													EnemyIsBoss = true
													break
												end
											end
										end
										if Players:GetPlayerFromCharacter(Enemy) or (EnemyIsBoss) then
											local BossObj = ObjectValue:Clone()
											BossObj.Name = "IsBoss"
											BossObj.Parent = ObjectValue
										end
										ObjectValue.Parent = Folder
									end
								end
							end

							local Effect = EffectFinder:CreateEffect("Whirling Thunder", AnimTrack.Length, Player.Character)
							tbi(CombatState.StatusEffects, Effect)
							PlayerManager:UpdateCombatState(id, CombatState)
						elseif KF == "Pull" and (currentClass == "DarwinB") then
							if Player.Character.HumanoidRootPart:FindFirstChild("MarkedForPull") ~= nil then
								for _, Torso in ipairs(Player.Character.HumanoidRootPart.MarkedForPull:GetChildren()) do
									if not Torso.Value:FindFirstChild("IsBoss") then
										FS.spawn(function()
											for i = 1,3 do
												Torso.Value.CFrame = Player.Character.HumanoidRootPart.CFrame
												wait(.1)
											end
										end)
									end
									DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, Enemies, nil, Torso.Value.Parent)
								end
								Player.Character.HumanoidRootPart.MarkedForPull:Destroy()
							end
						elseif KF == "GiveBuff" and (currentClass == "DarwinB") then
							local Effect = EffectFinder:CreateEffect("Fervors Edge", 10, Player.Character)
							tbi(CombatState.StatusEffects, Effect)
							local Effect2 = EffectFinder:CreateEffect("Focused Charge", 5, Player.Character)
							tbi(CombatState.StatusEffects, Effect2)
							Socket:Emit("AdjustAtt", .3, 5)
							PlayerManager:UpdateCombatState(id, CombatState)
						elseif KF == "WaitForSize" and (currentClass == "Valeri") then
							if Player.Character.HumanoidRootPart:FindFirstChild("Range") == nil then
								local Folder = Instance.new("IntValue")
								Folder.Name = "Range"
								for _, Skill in ipairs(PlayerStat.Characters[currentClass].Skills) do
									local ve = ClassInfo:GetSkillInfo(Skill.Name)
									if ve.AnimId == "rbxassetid://3330607396" then
										Folder.Value = Skill.Rank
										if CombatState.SpecialBar >= 100 then
											local Folderr = Instance.new("Folder")
											Folderr.Name = "Empowered"
											Folderr.Parent = Folder
											FS.spawn(function()
												wait(2)
												if CombatState.SpecialBar >= 100 then
													CombatState.SpecialBar = 0
													PlayerManager:UpdateCombatState(id, CombatState)
													Socket:Emit("SpecialBarReset")
												end
											end)
											for _, otherPlayer in ipairs(Players:GetPlayers()) do
												EffectFinder:FindEffect("Empowered", otherPlayer.UserId, true) 
												local otherState = PlayerManager:GetCombatState(otherPlayer.UserId)
												local Effect = EffectFinder:CreateEffect("Empowered", 15, otherPlayer.Character)
												tbi(otherState.StatusEffects, Effect)
												PlayerManager:UpdateCombatState(otherPlayer.UserId, otherState)
											end
										end
										break
									end
								end
								Folder.Parent = Player.Character.HumanoidRootPart
								Debris:AddItem(Folder,1)
							end
						elseif KF == "SummonCircle" and (currentClass == "Valeri") then
							local HadSpecial = false
							local Range = 3
							local OldRange = 3
							if CombatState.SpecialBar >= 100 then
								HadSpecial = true
								CombatState.SpecialBar = 0
								PlayerManager:UpdateCombatState(id, CombatState)
								Socket:Emit("SpecialBarReset")
							end
							if not HadSpecial then
								if Player.Character.HumanoidRootPart:FindFirstChild("Range") then
									Range = 3 + Player.Character.HumanoidRootPart.Range.Value
								end
							else
								local OldRange = 3 + Player.Character.HumanoidRootPart.Range.Value
								Range = 30
							end
							for _,Enemy in ipairs(Enemies) do
								if Enemy and Enemy.Torso ~= nil then
									if (Enemy.Torso.Position-Player.Character.HumanoidRootPart.Position).magnitude <= Range then
										DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, Enemies, nil, Enemy.Torso.Parent)
									end
								end
							end
							local TargetGroup = Player.Character.Parent == workspace.Enemies and {Player.Character} or workspace.Players:GetChildren()
							if PVP then
								for _,TeamMates in ipairs(CollectionService:GetTagged(table.find(PVP.RedTeam, Player.Name) and "RedTeam" or "BlueTeam")) do
									tbi(TargetGroup, TeamMates.Character)
								end
							end
							for _, Ally in ipairs(TargetGroup) do
								if Ally and Ally.PrimaryPart ~= nil and Player.Character:FindFirstChild("Humanoid") then
									if (Ally.PrimaryPart.Position-Player.Character.HumanoidRootPart.Position).magnitude <= Range then
										local AllyPlyr = Players:GetPlayerFromCharacter(Ally)
										if not HadSpecial then
											if AllyPlyr and EffectFinder:FindEffect("Disposition Heal", AllyPlyr.UserId) == nil then
												CombatState.SupportSkills = CombatState.SupportSkills + 1
												local Effect = EffectFinder:CreateEffect("Disposition Heal", 5, Ally, Player.Character.Humanoid.MaxHealth*ClassInfo:GetSkillInfo("Disposition").PercentageIncrease[Range - 2])
												local TargetCombatState = PlayerManager:GetCombatState(AllyPlyr.UserId)
												tbi(TargetCombatState.StatusEffects, Effect)
												PlayerManager:UpdateCombatState(AllyPlyr.UserId, TargetCombatState)
											end
										else
											if AllyPlyr and EffectFinder:FindEffect("Disposition Heal Empowered", AllyPlyr.UserId) == nil then
												CombatState.SupportSkills = CombatState.SupportSkills + 1
												local Effect = EffectFinder:CreateEffect("Disposition Heal Empowered", 1.5, Ally, Player.Character.Humanoid.MaxHealth*(ClassInfo:GetSkillInfo("Disposition").PercentageIncrease[OldRange - 2] * 7.5))
												local TargetCombatState = PlayerManager:GetCombatState(AllyPlyr.UserId)
												tbi(TargetCombatState.StatusEffects, Effect)
												PlayerManager:UpdateCombatState(AllyPlyr.UserId, TargetCombatState)
											end
										end
									end
								end
							end
						elseif KF == "ShootBeams" and (currentClass == "Valeri") then
							FS.spawn(function()
								local HadSpecial = false
								local RicochetBullets = {}
								local CFA, MRAD = CFrame.Angles, math.rad
								local function Shoot(StartFrom)
									for i = 1, 30 do
										local Bullet = {}
										Bullet.Position = StartFrom.Position+Vec3(0,10,0)
										Bullet.OldPos = StartFrom.Position
										Bullet.StartCF = StartFrom.CFrame
										local RandomNormal = Bullet.StartCF*CFA(MRAD(Rand:NextNumber(1,360)),MRAD(Rand:NextNumber(1,360)),MRAD(Rand:NextNumber(1,90)))
										Bullet.Normal = RandomNormal.lookVector
										Bullet.OverrideDistance = 0
										Bullet.CurrentDist = 0
										Bullet.BouncedTimes = 0
										Bullet.BouncedSpecial = false
										Bullet.ID = HttpService:GenerateGUID()
										tbi(RicochetBullets, Bullet)
									end
									Sockets:Emit("ValeriBeams", "Create", RicochetBullets)
								end
								if CombatState.SpecialBar >= 100 then
									HadSpecial = true
									CombatState.SpecialBar = 0
									PlayerManager:UpdateCombatState(id, CombatState)
									Socket:Emit("SpecialBarReset")
								end
								Shoot(Player.Character.PrimaryPart)
								local connection;
								local Anims = AnimTrack
								connection = RunService.Heartbeat:Connect(function()
									local FlightSpeed = 10
									for i = 1, #RicochetBullets do
										local Bullet = RicochetBullets[i]
										if Bullet then
											local overrideDistance = (Bullet.OverrideDistance > 0 and Bullet.OverrideDistance or nil)
											local ray = Ray.new(Bullet.Position, Bullet.Normal * (overrideDistance or FlightSpeed))
											local TeamMembers = PVP and CollectionService:GetTagged(table.find(PVP.RedTeam, Player.Name) and "RedTeam" or "BlueTeam")
											local IgnoreList = {Player.Character.Parent == workspace.Enemies and Player.Character or workspace.Players, workspace.DeadEnemies}
											if PVP then
												for _,TeamMates in ipairs(TeamMembers) do
													tbi(IgnoreList, TeamMates.Character)
												end
											end
											local hit, pos, norm = game.Workspace:FindPartOnRayWithIgnoreList(ray, IgnoreList)
											Bullet.OldPos = Bullet.Position
											Bullet.Position = pos
											if Bullet.OverrideDistance > 0 then
												Bullet.OverrideDistance = 0
											end
											if (hit) then
												local FoundTarget;
												if hit.Parent:FindFirstChildOfClass("Humanoid") then
													FoundTarget = hit.Parent
												elseif hit.Parent.Parent:FindFirstChildOfClass("Humanoid") then
													FoundTarget = hit.Parent.Parent
												end
												if FoundTarget then
													DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, Enemies, nil, FoundTarget, nil, nil, nil, nil, Anims, HadSpecial and 1.35 or 1, HadSpecial and Player.Character.Humanoid.MaxHealth * .1)
												end
												local reflect = (Bullet.Normal - (2 * Bullet.Normal:Dot(norm) * norm))
												Bullet.Normal = reflect
												Bullet.OverrideDistance = (FlightSpeed - (pos - Bullet.OldPos).Magnitude)
												if not HadSpecial then
													Bullet.BouncedTimes = Bullet.BouncedTimes + 1
												end
											end
											local ReqDist = 70
											if HadSpecial then
												ReqDist = 50
											end
											if Bullet.BouncedTimes == 0 and Bullet.CurrentDist >= ReqDist then
												Bullet.BouncedTimes = Bullet.BouncedTimes + 1
												if HadSpecial then
													if (Bullet.CurrentDist >= 50 and Bullet.BouncedSpecial == false) then
														Bullet.BouncedSpecial = true
													end
												end
												local FocusPoint = Bullet.Position
												local NearestTorso,Proximity = nil,1000
												for _,enemies in ipairs(workspace.Enemies:GetChildren()) do
													local CanTarget = true
													if PVP then
														for _, Members in ipairs(TeamMembers) do
															if Members.Character == enemies then
																CanTarget = false
																break
															end
														end
													end
													if CanTarget and Player.Character ~= enemies and enemies.PrimaryPart then
														local Distance = (enemies.PrimaryPart.Position - FocusPoint).Magnitude
														if Distance < Proximity then
															NearestTorso = enemies.PrimaryPart
															Proximity = Distance
														end
													end
												end
												if NearestTorso then
													local CF = CF(Bullet.Position, NearestTorso.Position)
													Bullet.Normal = CF.LookVector
												end
											end
											Bullet.CurrentDist = (Bullet.CurrentDist + (pos - Bullet.OldPos).Magnitude)
											if Bullet.CurrentDist >= 300 or Bullet.BouncedTimes >= 5 then
												Sockets:Emit("ValeriBeams", "DestroyBullet", Bullet)
												tbr(RicochetBullets,i)
											end
										end
									end
									if #RicochetBullets < 1 then
										connection:Disconnect()
										connection = nil
									else
										Sockets:Emit("ValeriBeams", "MoveBeams", RicochetBullets)
									end
								end)
							end)
						elseif KF == "DamageReduction" and (currentClass == "Valeri") then
							local Rank = 0
							for i=1, #PlayerStat.Characters[currentClass].Skills do
								local Skill = PlayerStat.Characters[currentClass].Skills[i]
								local ve = ClassInfo:GetSkillInfo(Skill.Name)
								if ve.AnimId == "rbxassetid://3399035928" then
									Rank = Skill.Rank
									break
								end
							end
							local TargetGroup = Player.Character.Parent == workspace.Enemies and {Player.Character} or workspace.Players:GetChildren()
							if PVP then
								for _,TeamMates in ipairs(CollectionService:GetTagged(table.find(PVP.RedTeam, Player.Name) and "RedTeam" or "BlueTeam")) do
									tbi(TargetGroup, TeamMates.Character)
								end
							end
							for _, Ally in ipairs(TargetGroup) do
								if Ally and Ally.PrimaryPart ~= nil and Player.Character:FindFirstChild("Humanoid") then
									if (Ally.PrimaryPart.Position-Player.Character.HumanoidRootPart.Position).magnitude <= 20 then
										local AllyPlyr = Players:GetPlayerFromCharacter(Ally)
										if AllyPlyr and EffectFinder:FindEffect("Calamity Chaos", AllyPlyr.UserId) == nil then
											local Effect = EffectFinder:CreateEffect("Calamity Chaos", 4, Ally, .5+(.01*Rank))
											local CombatStateID = PlayerManager:GetCombatState(AllyPlyr.UserId)
											tbi(CombatStateID.StatusEffects, Effect)
											PlayerManager:UpdateCombatState(AllyPlyr.UserId, CombatStateID)
										end
									end
								end
							end
						elseif KF == "Execution" and (currentClass == "Valeri") then
							if CombatState.SpecialBar >= 100 then
								CombatState.SpecialBar = 0
								PlayerManager:UpdateCombatState(id, CombatState)
								Socket:Emit("SpecialBarReset")
								for _,Enemy in ipairs(Enemies) do
									if Enemy and Enemy.Torso ~= nil then
										if (Enemy.Torso.Position-Player.Character.HumanoidRootPart.Position).magnitude <= 16 then
											local IsBoss = false
											if Enemy.Boss or Enemy.Auto then
												IsBoss = true
											end
											if (Enemy.Configuration.HP/Enemy.Configuration.MAXHP) <= (IsBoss and .05 or .5) then
												Enemy.Configuration.HP = 0
												Enemy.Died(Player.Name, 9999)
												local HPtoGive = 1+(IsBoss and .5 or .15)
												FS.spawn(function()
													if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
														Player.Character.Humanoid.MaxHealth = Player.Character.Humanoid.MaxHealth * HPtoGive
													end
												end)
											end
										end
									end
								end
							end
						elseif KF == "Counter" and (currentClass == "LingeringForce") then
							local Effect = EffectFinder:CreateEffect("Spearlancer", .5, Player.Character)
							tbi(CombatState.StatusEffects, Effect)
							PlayerManager:UpdateCombatState(id, CombatState)
						elseif KF == "BulwarkStart" and (currentClass == "Alburn") then
							local Percent = 0
							for i=1, #PlayerStat.Characters[currentClass].Skills do
								local Skill = PlayerStat.Characters[currentClass].Skills[i]
								local ve = ClassInfo:GetSkillInfo(Skill.Name)
								if ve.Name == "Chaos Bulwark" then
									Percent = ve.PercentageIncrease[Skill.Rank+1]
									break
								end
							end
							if EffectFinder:FindEffect("Chaos Bulwark", id) == nil then
								local Effect = EffectFinder:CreateEffect("Chaos Bulwark", 5, Player.Character, Percent and Percent or 0)
								tbi(CombatState.StatusEffects, Effect)
								PlayerManager:UpdateCombatState(id, CombatState)
							end
							local Bulwark = ReplicatedStorage.Models.Misc.Bulwark:Clone()
							Bulwark.Parent = Player.Character
							local Motor = Bulwark.BulwarkPartMotor
							Motor.Parent = Player.Character.PrimaryPart
							Motor.Part0 = Player.Character.PrimaryPart
							Motor.Part1 = Bulwark.BulwarkPart
							Debris:AddItem(Bulwark, 6)
							Debris:AddItem(Motor, 6)
							local Anime = Player.Character.Humanoid:LoadAnimation(Bulwark.Y1)
							Anime:Play()
							for _, Part in ipairs(Bulwark:GetChildren()) do
								if Part:IsA("BasePart") and Part.Name ~= "BulwarkPart" and Part.Name ~= "Region" then
									TweenService:Create(Part, TweenInfo.new(.25,Enum.EasingStyle.Linear), {Transparency = 0.4}):Play()
									FS.spawn(function()
										wait(4.5)
										TweenService:Create(Part, TweenInfo.new(.5,Enum.EasingStyle.Linear), {Transparency = 1}):Play()
									end)
								end
							end
						elseif KF == "BulwarkExplode" and (currentClass == "Alburn") then
							for i = 1, 3 do
								FS.spawn(function()
									local Origin = Player.Character.PrimaryPart.CFrame * CF(0, 0, -4) * CFrame.Angles(0, math.rad(i == 1 and 0 or i == 2 and 45 or -45), 0)
									CreateRangedHitBox(false, Origin.LookVector*200, Vec3(5, 14, 5.5), 2, Origin, AnimTrack) --CF is Velocity, and Type is the DebrisTime
								end)
							end
						elseif KF == "ShootArc" and (currentClass == "Alburn") then
							local Origin = Player.Character.PrimaryPart.CFrame * CF(0, 0, 0)
							CreateRangedHitBox(false, Origin.LookVector*200, Vec3(15, 1, 15), 2, Origin) --CF is Velocity, and Type is the DebrisTime
							local Effect = EffectFinder:CreateEffect("Searing Edge", 2, Player.Character)
							tbi(CombatState.StatusEffects, Effect)
							PlayerManager:UpdateCombatState(id, CombatState)
						elseif KF == "SwordSlam" and currentClass == "Alburn" then
							local SpawnPos = nil
							local Anims = AnimTrack
							local Hit, Position, Surface = Utilities:Raycast(Player.Character.PrimaryPart.Position, Player.Character.PrimaryPart.CFrame.LookVector * 40, {workspace.Players, workspace.Enemies, workspace.DeadEnemies, workspace.Terrain}, false, 0.11 , false, true)
							if Position then
								local Hit2, Position2, Surface2 = Utilities:Raycast(Position, Vec3(0, -10, 0), {workspace.Players, workspace.Enemies, workspace.DeadEnemies, workspace.Terrain}, false, 0.11 , false, true)
								if Position2 then
									SpawnPos = Position2
								end
							end
							wait(1)
							if SpawnPos then
								local CFSpawn = CF(SpawnPos)
								for v = 1, 10 do
									for _,Enemy in ipairs(workspace.Enemies:GetChildren()) do
										if Enemy ~= Player.Character and Enemy.PrimaryPart then
											if (Enemy.PrimaryPart.Position-SpawnPos).Magnitude <= 30 then
												for _, EnemyTable in ipairs(Enemies) do
													if EnemyTable.Torso == Enemy.PrimaryPart and not EnemyTable.Boss and not EnemyTable.Auto then
														Enemy.Torso.CFrame = CFSpawn
														break
													end
												end
												Player.Character.Humanoid.Health = Player.Character.Humanoid.Health + Player.Character.Humanoid.MaxHealth*.04
												DamageSystem:DamageMode(GameObjectHandler:GameData(), id, Player.Character, Enemies, nil, Enemy.PrimaryPart.Parent, nil, nil, nil, nil, Anims)
											end
										end
									end
									wait(.6)
								end
							end
						end
					end)


					---- Stamina Costs etc
					if AnimTrack.Animation.AnimationId == "rbxassetid://1539764838"  and (currentClass == "Red") then
						for i = 1, #CombatState.StatusEffects do
							local Effect = CombatState.StatusEffects[i]
							if Effect.Name == "RedChargeRifle" then
								tbr(CombatState.StatusEffects, i)
								PlayerManager:UpdateCombatState(id, CombatState)
								break
							end
						end
						local Effect = EffectFinder:CreateEffect("RedChargeRifle", nil, Player.Character)
						tbi(CombatState.StatusEffects, Effect)
						PlayerManager:UpdateCombatState(id, CombatState)
					end
					AnimTrack.Stopped:Connect(function()
						Ain:Disconnect()
						AnimTrack:Destroy()
					end)
					if CombatState.LastAnim ~= nil then
						CombatState.LastAnim = AnimTrack
					end
					CombatState.LastAnim = AnimTrack
					CombatState.Dodging = false
					CombatState.Ultimate = false
					PlayerManager:UpdateCombatState(id, CombatState)

					local CanAtkSped = false
					local DecreaseStam = false
					local DecreaseHP = true
					local DecreaseAmount = 0
					local Skills = PlayerStat.Characters[currentClass].Skills
					local AnimTrack = CombatState.LastAnim
					for i = 1, #ListOfLight do
						local v = ListOfLight[i]
						if AnimTrack.Animation.AnimationId == v then
							CanAtkSped = true
							DecreaseStam = true
							DecreaseAmount = .005
							break
						end
					end
					for i = 1, #ListOfHeavy do
						local v = ListOfHeavy[i]
						if AnimTrack.Animation.AnimationId == v then
							if ReplicatedStorage.PlayerValues[Player.Name].Stamina.Value < 1 then
								AnimTrack:Stop()
								AnimTrack:Destroy()
								Ain:Disconnect()
								return
							end
							DecreaseStam = true
						--	DecreaseAmount = StamCosts.Heavy
							CanAtkSped = true
							for i=1, #PlayerStat.Characters[currentClass].Skills do
								local Skill = PlayerStat.Characters[currentClass].Skills[i]
								local ve = ClassInfo:GetSkillInfo(Skill.Name)
								if ve.AnimId == AnimTrack.Animation.AnimationId then
									DecreaseAmount = ve.StaminaCost
								end
								if AnimTrack.Animation.AnimationId == "rbxassetid://3115648751" and DecreaseHP then
									DecreaseHP = false
									Player.Character.Humanoid.Health = Player.Character.Humanoid.Health * .8
								elseif AnimTrack.Animation.AnimationId == "rbxassetid://3964207339" and DecreaseHP then
									DecreaseHP = false
									Player.Character.Humanoid.Health = Player.Character.Humanoid.Health * .65
								elseif AnimTrack.Animation.AnimationId == "rbxassetid://3956957896" and DecreaseHP then
									DecreaseHP = false
									Player.Character.Humanoid.Health = Player.Character.Humanoid.Health * .85
								end
							end
							break
						end
					end
					for i = 1, #ListOfUlts do
						local v= ListOfUlts[i]
						if AnimTrack.Animation.AnimationId == v then
							DecreaseStam = true
							DecreaseAmount = StamCosts.Ult
							CanAtkSped = true
							CombatState.Ultimate = true
							local Effect = EffectFinder:CreateEffect("Invincibility", 5, Player.Character)
							--tbi(CombatState[Player.UserId].StatusEffects, Effect) -- causes bug
							tbi(CombatState.StatusEffects, Effect)
							PlayerManager:UpdateCombatState(id, CombatState)
							break
						end
					end
					for i =1, #ListOfKnockBacks do
						local v = ListOfKnockBacks[i]
						if AnimTrack.Animation.AnimationId == v then
							DecreaseStam = true
							DecreaseAmount = StamCosts.Knockback
							break
						end
					end
					for i=1, #ListOfKnockUps do
						local v = ListOfKnockUps[i]
						if AnimTrack.Animation.AnimationId == v then
							DecreaseStam = true
							DecreaseAmount = StamCosts.Knockup
							break
						end
					end
					for i = 1, #ListOfDodges do
						local v = ListOfDodges[i]
						if AnimTrack.Animation.AnimationId == v then
							if ReplicatedStorage.PlayerValues[Player.Name].Stamina.Value < 1 then
								AnimTrack:Stop()
								AnimTrack:Destroy()
								return
							end
							GeneralHitbox:HitStop()
							CombatState.Dodging = true
							FS.spawn(function()
								wait(1.5)
								if CombatState.Dodging then
									CombatState.Dodging = false
									PlayerManager:UpdateCombatState(id, CombatState)
								end
							end)
							DecreaseStam = true
							DecreaseAmount = StamCosts.Dodge
							local trop = WeaponCraft:GetTrophyFromID(PlayerStat.Characters[currentClass].CurrentTrophy.Map, PlayerStat.Characters[currentClass].CurrentTrophy.ID)
							local tropValue = trop and trop.Stats.CRITDEF+(trop.StatsPerLevel.CRITDEF*PlayerStat.Characters[currentClass].CurrentTrophy.UpLvl) or 0
							local Effect = EffectFinder:CreateEffect("Invincibility", 0.7 * (1+(tropValue)), Player.Character, nil, true)
							tbi(CombatState.StatusEffects, Effect)
							PlayerManager:UpdateCombatState(id, CombatState)
							break
						end
					end
					if not CombatState.Dodging then
						for i = 1, #ListOfBlocks do
							local v = ListOfBlocks[i]
							if AnimTrack.Animation.AnimationId == v then
								GeneralHitbox:HitStop()
								break
							end
						end
					end
					
					if DecreaseStam then
						local StaminaDe = EffectFinder:FindWeaponEffect(id, "StaminaDecrease")
						if StaminaDe ~= nil then
							DecreaseAmount = DecreaseAmount * (1-(StaminaDe.V*.01))
						end
						local StaGem = EffectFinder:FindGemstone(id, "Stamina Use Decrease")
						if StaGem ~= nil then
							DecreaseAmount = DecreaseAmount * (1-(StaGem.Q*.01))
						end
						for _, Stam in ipairs(Skills) do
							if Stam.Name == "Stamina Mastery" then
								DecreaseAmount = DecreaseAmount * (1+(ClassInfo:GetSkillInfo(Stam.Name).PercentageIncrease[Stam.Rank+1]))
								break
							end
						end
						if ReplicatedStorage.PlayerValues[Player.Name].Stamina.Value >= DecreaseAmount then
							ReplicatedStorage.PlayerValues[Player.Name].Stamina.Value -= DecreaseAmount
						else
							ReplicatedStorage.PlayerValues[Player.Name].Stamina.Value = 0
						end
						PlayerManager:UpdateCombatState(id, CombatState)
					end
				end)
				Socket:Emit("EffectEnabled", PlayerStat.CurrentClass, Player.Character)
				Player.Character.Parent = workspace.Players
				if PVP then
					if (Player.TeamColor == Teams.Team1.TeamColor or Player.TeamColor == Teams.Team2.TeamColor) then
						Player.Character.Parent = workspace.Enemies
						local FF = Instance.new("ForceField", Player.Character)
						Debris:AddItem(FF, 3)
						if table.find(PVP.RedTeam, Player.Name) then
							Player.Character:SetPrimaryPartCFrame(CFrame.new(workspace.Map.PVPSpawns.RedTeamSpawn.Position, workspace.Map.PVPSpawns.BlueTeamSpawn.Position))
						else
							Player.Character:SetPrimaryPartCFrame(CFrame.new(workspace.Map.PVPSpawns.BlueTeamSpawn.Position, workspace.Map.PVPSpawns.RedTeamSpawn.Position))
						end
						for _,OtherPlayers in ipairs(game.Players:GetPlayers()) do
							if OtherPlayers ~= Player then
								Sockets:GetSocket(OtherPlayers):Emit("EffectEnabled", PlayerStat.CurrentClass, Player.Character)
							end
						end
						local Humanoid = Player.Character:WaitForChild("Humanoid")
						Humanoid.Died:Connect(function()
							PVPManager:Add(Player, "Deaths", 1)
							Player.TeamColor = Teams.InGame.TeamColor
						end)
					else
						Player.Character:SetPrimaryPartCFrame(workspace.LobbySpawns.SpawnLocationLoot.CFrame)
					end
				end

				BindableEvent:Fire(Player)
			end

			


			Player.CharacterAdded:connect(function(char)
				print("RESPAWNED")
				
				if workspace.StreamingEnabled then
					local HRP = char:WaitForChild("HumanoidRootPart")
					HRP.Anchored = true
					Player:RequestStreamAroundAsync(workspace.SpawnLocationBattle.Position)
					HRP.Anchored = false
				end

				local bool = false
				if PVP then
					bool = true
				else
					if GameObjectHandler:GameData() ~= nil and Player.TeamColor == Teams.InGame.TeamColor then
						if GameObjectHandler:GameData().TeamHP >= 100 then
							GameObjectHandler:GameData().TeamHP -= 100
							bool = true
						else
							Player.TeamColor = Teams.Lobby.TeamColor
						end
					end
				end

				local CombatState = PlayerManager:GetCombatState(id)
				CombatState.GuildAccept = ""
				PlayerManager:UpdateCombatState(id, CombatState)
				local Humanoid = char:WaitForChild("Humanoid")
				wait(1)
				Socket:Emit("Respawned", char, bool, (PVP and nil or (GameObjectHandler:GameData()~=nil and GameObjectHandler:GameData().CurrentMap.MapName.."Music")))
				SpawnMorph.Create()

				createHitbox(char)
			end)
			--Player:LoadCharacter()
			SpawnMorph.Create()
		else
			print("Unable to morph due to nil data")
		end
	end)

	for _, socketModules in ipairs(script.ClassHandlers:GetDescendants()) do
		if socketModules.Name == "Socket" then
			local newSocket = require(socketModules)
			newSocket:Init(Socket)
		end
	end
	
end

require(RagdollHandler)

return logic
