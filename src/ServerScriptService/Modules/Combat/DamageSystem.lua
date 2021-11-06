local module = {}

local SuspiciousPlyrs = {}

local PlayerStats = {}
local FirstHit = nil

---PVP
local FirstBlood = nil


local ListOfDodges					= {}
local ListOfBlocks 					= {}
local ListOfUlts					= {}
local ListOfLight					= {}
local ListOfHeavy					= {}
local ListOfKnockBacks				= {}
local ListOfKnockUps				= {}
local ListOfKnockDowns				= {}
local ListOfShooty					= {}
local BlacklistAnimations			= {}

local GlobalThings = {
	GlobalParryWindow				= .08, --.08
	GlobalParryCooldown				= 3,
	GlobalBlockSpeed				= 35,
	GlobalBlockModifier				= .1,
	GlobalComboAmount				= 1,
	GlobalComboCooldown				= 3,
	GlobalComboDamageModifier		= .002,
	GlobalFatigueAmount				= .4,
	GlobalUltimateCounter			= 0
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local BadgeService = game:GetService("BadgeService")
local TS = game:GetService("TweenService")

local Modules = script.Parent.Parent
local WeaponCraft = require(Modules.CharacterManagement["WeaponCrafting"])
local CacheAnimations = require(Modules.Utility["CacheAnimationList"])
local ClassInfo = require(Modules.CharacterManagement["ClassInfo"])
local PlayerManager = require(Modules.PlayerStatsObserver)
local EffectFinder = require(script.Parent.EffectFinder)
local Sockets = require(Modules.Utility["server"])
local PVPManager = require(Modules.Combat.PVPManager)
local FS = require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local Bezier = require(ReplicatedStorage.Scripts.Modules.Bezier)

ListOfDodges, ListOfBlocks, ListOfUlts, ListOfLight, ListOfHeavy, ListOfKnockBacks, ListOfKnockUps, ListOfKnockDowns, BlacklistAnimations = CacheAnimations:Cache()

local tbi = table.insert
local tbr = table.remove
local Rand = Random.new()
local Instancenew = Instance.new
local CFrameAngles = CFrame.Angles
local mathrad = math.rad
local abs = math.abs
local Floor = math.floor
local Vec3 = Vector3.new
local CF = CFrame.new

local function ObjectiveUpdate(Name)
	Modules.Parent.Server.Bindables.ObjectiveUpdate:Fire(Name)
end

local function AwardBadge(PlayerId, BadgeId)
	BadgeService:AwardBadge(PlayerId,BadgeId)
end

local function RewardAchievement(tbl, id)
	Modules.Parent.Server.Bindables.RewardAchievement:Fire(tbl, id)
end

local function GetTouchingParts(part)
	local connection = part.Touched:Connect(function() end)
	local results = part:GetTouchingParts()
	connection:Disconnect()
	connection = nil
	FS.spawn(function()
		wait(.5)
		if connection ~= nil then
			connection:Disconnect()
			connection = nil
		end
	end)
	return results
end

function module:GetGlobalThings(GlobalThangs)
	GlobalThings = GlobalThangs
end

---Enemy properties: (center, cf, size, IsProj, Targ, dScale, IsLaser)

function module:DamageMode(GameData, OwnerId, DamageOwner, Enemies, EnemyProperties, TargetDamaged, isBlowback, CU, Ckb, IsDeflected, ForceAnimation, DamageScale, FlatDamage, FlatDamageTrue)
	local CalcUlt = CU ~= nil and true or false
	if DamageOwner ~= TargetDamaged and TargetDamaged:FindFirstChildOfClass("Humanoid") then
		local id					= OwnerId or nil
		local PlayerStat			= id and PlayerManager:GetPlayerStat(id)
		local CombatState			= PlayerStat and PlayerManager:GetCombatState(id)
		local currentClass 			= PlayerStat and PlayerStat.CurrentClass
		local currentChar			= CombatState and PlayerStat.Characters[currentClass]
		local wep 					= PlayerStat and WeaponCraft:GetWeaponFromID(currentClass, currentChar.CurrentWeapon.ID)
		local currentDamage 		= PlayerStat and currentChar.Damage+(wep.Stats.ATK+(wep.StatsPerLevel.ATK*currentChar.CurrentWeapon.UpLvl))

		local PlayerOwner			= PlayerStat and Players:GetPlayerFromCharacter(DamageOwner) or {}
		local TargetPlayer			= Players:GetPlayerFromCharacter(TargetDamaged) or nil
		local TargetStats			= TargetPlayer and PlayerManager:GetPlayerStat(TargetPlayer.UserId)
		local TargetState			= TargetPlayer and PlayerManager:GetCombatState(TargetPlayer.UserId)
		local TargetClass			= TargetStats and TargetStats.Characters[TargetStats.CurrentClass]
		local TargetTrophy			= TargetClass and WeaponCraft:GetTrophyFromID(TargetClass.CurrentTrophy.Map, TargetClass.CurrentTrophy.ID)
		local Humanoid 				= id and DamageOwner.Humanoid
		local THumanoid				= CalcUlt and nil or TargetDamaged:FindFirstChildOfClass("Humanoid")
		local CanKnockBack			= Ckb and Ckb or false
		local CanDamage 			= true
		local WasDeflected			= IsDeflected and IsDeflected or false
		local CCType				= "None"
		local ParryWindow			= GlobalThings.GlobalParryWindow
		local ParryCooldown			= GlobalThings.GlobalParryCooldown
		local ComboAmount			= GlobalThings.GlobalComboAmount
		local ComboCooldown			= GlobalThings.GlobalComboCooldown
		local ComboDamageModifier	= GlobalThings.GlobalComboDamageModifier
		local Skills 				= PlayerStat and currentChar.Skills
		local Animation				= PlayerStat and (ForceAnimation or CombatState.LastAnim)
		local HeavyCritMod			= 1
		local PercentageBoost		= 1 --Multiplier
		local HPDmgMultiplier		= 0 --Multipler
		local DamageBoost			= FlatDamage and FlatDamage or 0 --Flat Added Damage
		local StamRecovery			= 0
		local BonusCriticalChance	= 0
		local SpecialAmnt 			= 0
		local HealingOnCrit			= 0 --Flat
		local IgnoresDefense		= FlatDamageTrue and true or false
		local HasSpear				= false
		local StartAtZeroSpecial	= false
		local IsLight				= false
		local AutoCrit				= false
		local HadSpecial			= false
		local RedsTurret			= false
		local LastSkillUsed			= {}
		if TargetPlayer and PlayerOwner then
			if TargetPlayer.TeamColor == PlayerOwner.TeamColor then
				return
			end
		end
		if Animation then
			local AnimTrack = Animation
			for _, v in ipairs(ListOfUlts) do
				if AnimTrack.Animation.AnimationId == v then
					for _, e in ipairs(Skills) do
						if e.Name == "Attack Speed Mastery" then
							PercentageBoost = PercentageBoost * (1+(ClassInfo:GetSkillInfo(e.Name).PercentageIncrease[e.Rank+1]))
						end
					end
					if CombatState.UltimateCounter >= 100 then
						CombatState.UltimateCounter = CombatState.UltimateCounter - 100
						ComboAmount = 3
						CombatState.LastAnim = nil
						PlayerManager:UpdateCombatState(id, CombatState)
					else				
						CanDamage = false
					end
					break
				end
			end
			if CCType == "None" then
				for _, v in ipairs(ListOfKnockBacks) do
					if AnimTrack.Animation.AnimationId == v then
						CCType = "Knockback"
						break
					end
				end
			end
			if CCType == "None" then
				for _, v in ipairs(ListOfKnockUps) do
					if AnimTrack.Animation.AnimationId == v then
						CCType = "Knockup"
						break
					end
				end
			end
			for _, v in ipairs(ListOfDodges) do
				if AnimTrack.Animation.AnimationId == v then
					for _, e in ipairs(Skills) do
						if e.Name == "Attack Speed Mastery" then
							PercentageBoost = PercentageBoost * (1+(ClassInfo:GetSkillInfo(e.Name).PercentageIncrease[e.Rank+1]))
						end
					end
					break
				end
			end
			for _, v in ipairs(ListOfUlts) do
				if AnimTrack.Animation.AnimationId == v then
					for _, e in ipairs(Skills) do
						if e.Name == "Attack Speed Mastery"then
							PercentageBoost = PercentageBoost * (1+(ClassInfo:GetSkillInfo(e.Name).PercentageIncrease[e.Rank+1]*(.2)))
						end
						if e.Name == "Skillful Mastery" then
							PercentageBoost = PercentageBoost * (1+(ClassInfo:GetSkillInfo(e.Name).PercentageIncrease[e.Rank+1]*(.35)))
						end
					end
				end
			end
			for _, v in ipairs(ListOfLight) do
				if AnimTrack.Animation.AnimationId == v then
					IsLight = true
					StamRecovery += 12
					for _, e in ipairs(Skills) do
						if e.Name == "Attack Speed Mastery" then
							PercentageBoost = PercentageBoost * (1+(ClassInfo:GetSkillInfo(e.Name).PercentageIncrease[e.Rank+1]))
						end
					end
					break
				end
			end
			for _, v in ipairs(ListOfHeavy) do
				if AnimTrack.Animation.AnimationId == v then
					for _, e in ipairs(Skills) do
						local Skil = ClassInfo:GetSkillInfo(e.Name)
						if Skil.AnimId == AnimTrack.Animation.AnimationId then
							if e.Unlocked == false then
								CanDamage = false --haxxxx????
							end
						end
						if e.Name == "Skillful Mastery" then
							PercentageBoost = PercentageBoost * (1+(Skil.PercentageIncrease[e.Rank+1]))
						end
						if e.Name == "Critical Mastery" and e.Unlocked then
							HeavyCritMod = HeavyCritMod * (1+(Skil.PercentageIncrease[e.Rank+1]))
							BonusCriticalChance = BonusCriticalChance + ((Skil.PercentageIncrease[e.Rank+1])*100)*.5
						end
					end
					break
				end
			end
			local DoNotIncrease = false
			for _, v in ipairs(Skills) do
				local Skil = ClassInfo:GetSkillInfo(v.Name)
				if v.Name == "Focus Mastery" then
					local am = ReplicatedStorage.PlayerValues[DamageOwner.Name].StaminaMax.Value * (Skil.PercentageIncrease[v.Rank+1])
					StamRecovery += IsLight and am or am*.5
				elseif v.Name == "One Versus Many" or v.Name == "One Versus All" then
					local EnemyCount = 0
					if TargetPlayer then
						EnemyCount = EnemyCount + 5
					else
						for _,Enemy in ipairs(Enemies) do
							if Enemy ~= nil then
								if Enemy.Torso ~= nil and (DamageOwner.HumanoidRootPart.Position-Enemy.Torso.Position).Magnitude <= 15 then
									EnemyCount = EnemyCount + (Enemy.Boss and 5 or 1)
								end
							end
						end
					end
					if EnemyCount > 0 then
						BonusCriticalChance = BonusCriticalChance + 3 * EnemyCount
						if GameData and GameData.TeamHP <= 250 then
							BonusCriticalChance = BonusCriticalChance + 10
						end
						if EnemyCount >= 5 then
							BonusCriticalChance = BonusCriticalChance * 2
							if v.Name == "One Versus Many" and EffectFinder:FindEffect("Fervor's Edge", id) == nil then
								local Effect = EffectFinder:CreateEffect("Fervor's Edge", 10, DamageOwner)
								tbi(CombatState.StatusEffects, Effect)
								PlayerManager:UpdateCombatState(id, CombatState)
							elseif v.Name == "One Versus All" and EffectFinder:FindEffect("Fervors Edge", id) == nil then
								local Effect = EffectFinder:CreateEffect("Fervors Edge", 10, DamageOwner)
								tbi(CombatState.StatusEffects, Effect)
								PlayerManager:UpdateCombatState(id, CombatState)
							end
						end
					end
				end
				if v.Name == "Critical Mercy" then
					StartAtZeroSpecial = true
					if CombatState.SpecialBar >= 100 then
						CombatState.SpecialBar = 0
						local Effect = EffectFinder:CreateEffect("Critical Mercy", 20, DamageOwner)
						tbi(CombatState.StatusEffects, Effect)
						PlayerManager:UpdateCombatState(id, CombatState)
						Sockets:GetSocket(PlayerOwner):Emit("SpecialBarReset")
					end
				end
				if v.Name == "Trident Berserker" then
					if CombatState.ComboCount >= 500 then
						AutoCrit = true
						IgnoresDefense = true
						local Count = 3
						CombatState.ComboCount = CombatState.ComboCount + Count
						PlayerManager:UpdateCombatState(id, CombatState)
						SpecialAmnt = SpecialAmnt + Count
						PercentageBoost = PercentageBoost * 4
						Humanoid.Health = Humanoid.Health + CombatState.ComboCount*.05
					end
				end
				if v.Name == "Powers United" then
					DamageBoost = DamageBoost + (DamageOwner.Humanoid.Health * .2)
				end
				if v.Name == "Demonic Presence" then
					if CombatState.ConsumedDamage >= 1 and CombatState.ConsumedDamage <= DamageOwner.Humanoid.Health then
						IgnoresDefense = true
					end
					DamageBoost = DamageBoost + CombatState.ConsumedDamage
					CombatState.ConsumedDamage = 0
					PlayerManager:UpdateCombatState(id, CombatState)
				end
				if AnimTrack.Animation.AnimationId ~= "rbxassetid://3964207339" then
					if v.Name == "Chaos Bulwark" and v.Unlocked then
						if AnimTrack.Animation.AnimationId == "rbxassetid://3917046117" then
							PercentageBoost = PercentageBoost * (4.75 + (.75 * v.Rank))
							DoNotIncrease = true
						end
					end
				end
				if v.Name == "Overwhelming Strength" then
					HealingOnCrit = DamageOwner.Humanoid.Health * .06
					local HPCrit = 100 - ((DamageOwner.Humanoid.Health / DamageOwner.Humanoid.MaxHealth) * 100)
					BonusCriticalChance = BonusCriticalChance + HPCrit*4
					if IsLight then
						table.insert(LastSkillUsed, v.Name)
					end
				end
				if v.Name == "Weakness Exploit" then
					BonusCriticalChance += (0.5 * CombatState.ComboCount)
					table.insert(LastSkillUsed, v.Name)
				end
				if v.Name == "Dented Blows" then
					table.insert(LastSkillUsed, v.Name)
				end
				if v.Name == "Iron Stance" then
					ReplicatedStorage.PlayerValues[DamageOwner.Name].Barrier.Value = math.min(DamageOwner.Humanoid.MaxHealth, ReplicatedStorage.PlayerValues[DamageOwner.Name].Barrier.Value + (DamageOwner.Humanoid.MaxHealth * 0.005))
				end
				if Skil.AnimId == AnimTrack.Animation.AnimationId and v.Unlocked then
					--- Veil of the Storm
					if Skil.AnimId == "rbxassetid://5786471874" then
						ReplicatedStorage.PlayerValues[DamageOwner.Name].Barrier.Value = math.min(DamageOwner.Humanoid.MaxHealth, ReplicatedStorage.PlayerValues[DamageOwner.Name].Barrier.Value + (DamageOwner.Humanoid.MaxHealth * 0.06))
					end

					--- Take Aim
					if Skil.AnimId == "rbxassetid://1539764838" then
						local ChgTime, MaxCharge = 0, 5
						for _, RedChg in ipairs(CombatState.StatusEffects) do
							if RedChg.Name == "RedChargeRifle" then
								ChgTime = tick()-RedChg.TimeStamp
								local CT = CombatState.AttackSpeed-1
								if CT < 0 then CT = 0 end
								MaxCharge = 5*(1-CT)
								PercentageBoost = PercentageBoost * (1+((Skil.PercentageIncrease[v.Rank+1])*(ChgTime < MaxCharge and ChgTime or MaxCharge)))
								AutoCrit = ( ChgTime >= MaxCharge and true or false)
								break
							end
						end
						PercentageBoost = PercentageBoost + 0.005 * (currentChar.Stamina * 0.15 >= 60 and 60 or currentChar.Stamina * 0.15)
						if CombatState.SpecialBar >= 100 then
							HadSpecial = true
							CombatState.SpecialBar = 0
							PercentageBoost *= 30
							Sockets:GetSocket(PlayerOwner):Emit("SpecialBarReset")
						end
						local Effect = EffectFinder:CreateEffect("Haste", 0.5 + (1.25 * ((ChgTime < MaxCharge and ChgTime or MaxCharge) / MaxCharge)), DamageOwner)
						tbi(CombatState.StatusEffects, Effect)
						PlayerManager:UpdateCombatState(id, CombatState)
					elseif Skil.AnimId == "rbxassetid://3505475719" or Skil.AnimId == "rbxassetid://5661676845" then
						RedsTurret = true
					else
						if not DoNotIncrease then
							PercentageBoost = PercentageBoost * (1+(Skil.PercentageIncrease[v.Rank+1]))
						end
					end
				end
			end
		end
		
		local PWGem = EffectFinder:FindGemstone(TargetPlayer and TargetPlayer.UserId or nil, "Parry Window Increase")
		if PWGem ~= nil then
			ParryWindow = ParryWindow * (1+(PWGem.Q*.01))
		end
		local PEGem = EffectFinder:FindGemstone(TargetPlayer and TargetPlayer.UserId or nil, "Parry Expert")
		if PEGem ~= nil then
			ParryCooldown = ParryCooldown * (1-(PEGem.Q*.01))
		end
		
		if TargetState then
			if TargetState.Ultimate then
				CanDamage = false
			end
			local PotentialParry = EffectFinder:FindEffect("Parrying", TargetPlayer and TargetPlayer.UserId, true)
			local PotentialBlock = EffectFinder:FindEffect("Blocking", TargetPlayer and TargetPlayer.UserId, true)
			if PotentialParry or PotentialBlock then
				CanDamage = false
				local Type = "TargetBlock"
				local hasLaser = EnemyProperties and EnemyProperties.IsLaser
				if PotentialParry and not hasLaser then
					Type = "TargetParry"
					TargetState.RecentlyParried = 0
					if OwnerId == nil and DamageOwner then
						DamageOwner.Configuration.Stunned = true
					end
					AwardBadge(TargetPlayer.UserId, 706675821)
					if OwnerId == nil and DamageOwner and DamageOwner.Auto and DamageOwner.Torso:FindFirstChildOfClass("BoolValue") == nil then
						RewardAchievement({38}, TargetPlayer.UserId)
			--			DamageOwner.Torso.Parent.Bindables.Parried:Fire(TargetDamaged.PrimaryPart, "Parried")
					end
					local Effect = EffectFinder:CreateEffect("Counter Attack", 1.25, TargetDamaged)
					tbi(TargetState.StatusEffects, Effect)
					ComboAmount += 20
					if tick() - TargetState.ComboTimer <= GlobalThings.GlobalComboCooldown then
						TargetState.ComboCount = TargetState.ComboCount + ComboAmount
						if TargetState.HighestCombo < TargetState.ComboCount then
							TargetState.HighestCombo = TargetState.ComboCount
						end
						if TargetStats.HighestCombo < TargetState.ComboCount then
							TargetStats.HighestCombo = TargetState.ComboCount
							if TargetState.ComboCount >= 1000 then
								AwardBadge(TargetPlayer.UserId, 706686040)
							end
						end
					else
						TargetState.ComboCount = 0
					end
					Sockets:GetSocket(TargetPlayer):Emit("AdjustAtt", 1, 1.25)
					Sockets:GetSocket(TargetPlayer):Emit("DamageIndicator", true, "PARRIED!", TargetDamaged.HumanoidRootPart)
				elseif PotentialBlock then
					local BlockStrength = 50
					local Coefficient = 15
					local Division = 2250
					local BlockDamage = (Coefficient * (OwnerId == nil and DamageOwner.Configuration.Atk or currentDamage) * (100 - BlockStrength)) / Division
					local StaGem = EffectFinder:FindGemstone(TargetPlayer.UserId, "Stamina Use Decrease")
					if StaGem ~= nil then
						BlockDamage = BlockDamage * (1-(StaGem.Q*.01))
					end
					if ReplicatedStorage.PlayerValues[TargetDamaged.Name].Stamina.Value >= BlockDamage then
						ReplicatedStorage.PlayerValues[TargetDamaged.Name].Stamina.Value -= BlockDamage
						if GameData.DungeonMsg == "Use your Block to withstand 5 attacks" then
							ObjectiveUpdate("Use your Block to withstand 5 attacks")
						end
						Sockets:GetSocket(TargetPlayer):Emit("DamageIndicator", true, "BLOCKED!", TargetDamaged.HumanoidRootPart)
					else
						THumanoid.WalkSpeed = 0
						TargetState.Dodging = false
						Sockets:GetSocket(TargetPlayer):Emit("Ragdoll", true, OwnerId == nil and DamageOwner.Torso.Position or DamageOwner.PrimaryPart.Position, 1)
						Sockets:GetSocket(TargetPlayer):Emit("DamageIndicator", true, "BLOCK BREAK!", TargetDamaged.HumanoidRootPart)
						wait(3)
						Sockets:GetSocket(TargetPlayer):Emit("Ragdoll", false, OwnerId == nil and DamageOwner.Torso.Position or DamageOwner.PrimaryPart.Position, 1)
					end
				end
				local relativeDirection = ((OwnerId == nil and DamageOwner.Torso.Position or DamageOwner.PrimaryPart.Position) - TargetDamaged.PrimaryPart.Position)
				local force = 100

				if DamageOwner.Torso:FindFirstChild("Minion") then
					force = 20
				end

				local y = Instance.new("BodyVelocity")
				y.Name = "BVKnockback"
				y.maxForce = Vector3.new(59999, 3, 59999)
				y.velocity = -relativeDirection.Unit * force
				local newPosition = Instance.new("Vector3Value")
				newPosition.Name = Type
				newPosition.Value = (OwnerId == nil and DamageOwner.Torso.Position or DamageOwner.PrimaryPart.Position)
				newPosition.Parent = TargetDamaged.PrimaryPart
				y.Parent = TargetDamaged.PrimaryPart
				Debris:AddItem(y, .15)
			end
			if TargetState.Dodging then
				CanDamage = false
				local ConsGem = EffectFinder:FindGemstone(TargetPlayer.UserId, "Counterattack")
				if ConsGem ~= nil then
					TargetState.ConsumedDamage = TargetState.ConsumedDamage + ((OwnerId == nil and DamageOwner.Configuration.Atk or currentDamage)*(ConsGem.Q*.01))
				end
				local Tact = EffectFinder:FindWeaponEffect(TargetPlayer.UserId, "Tactician")
				if Tact ~= nil then
					ReplicatedStorage.PlayerValues[TargetDamaged.Name].Stamina.Value += ReplicatedStorage.PlayerValues[TargetDamaged.Name].StaminaMax.Value * (Tact.V * .01)
				end
				TargetState.DodgedAttacks = TargetState.DodgedAttacks + 1
				if GameData.DungeonMsg == "Use your Dodge and evade 7 attacks" then
					ObjectiveUpdate("Use your Dodge and evade 7 attacks")
				end
				Sockets:GetSocket(TargetPlayer):Emit("DamageIndicator", true, "DODGED!!", TargetDamaged.HumanoidRootPart, OwnerId == nil and DamageOwner.Torso or DamageOwner.PrimaryPart)
			end
			if EffectFinder:FindEffect("Invincibility", TargetPlayer and TargetPlayer.UserId) then
				CanDamage = false
				if TargetStats and TargetStats.CurrentClass == "DarwinB" then
					local Effect = EffectFinder:CreateEffect("Focused Charge", 5, TargetDamaged)
					tbi(TargetState.StatusEffects, Effect)
					local Effect = EffectFinder:CreateEffect("Crescent Sweep", 5, TargetDamaged)
					tbi(TargetState.StatusEffects, Effect)
					Sockets:GetSocket(TargetPlayer):Emit("AdjustAtt", .3, 5)
				end
			end
			if EffectFinder:FindEffect("Counter Attack", TargetPlayer and TargetPlayer.UserId) then
				CanDamage = false
			end
			
			PlayerManager:UpdateCombatState(TargetPlayer.UserId, TargetState)
		end
		--[[
		for i = 1, #PlayersNeedReviving do
			local Ply = PlayersNeedReviving[i]
			if Ply ~= nil and Ply.Player == PotentialPlayer then
				CanDamage = false
			end
		end
		--]]
		if CanDamage then
			local EnemyAIProperties = {}
			local Found = false
			local Target = nil
			for _,targs in ipairs(Enemies) do
				if targs.Torso == TargetDamaged.PrimaryPart then
					Target = targs
					Found = true
					break
				end
			end
			if OwnerId == nil and DamageOwner then
			--	(center, cf, size, IsProj, Targ, dScale, IsLaser)
				EnemyAIProperties.IsProj = EnemyProperties.IsProj
				EnemyAIProperties.Targ = EnemyProperties.Targ
				EnemyAIProperties.dmgScale = EnemyProperties.dmgScale
				EnemyAIProperties.IsLaser = EnemyProperties.IsLaser
			end
			if Found then
				if Target.Ally then
					Found = false
				end
			end
			if TargetPlayer then
				Found = true
			end
			if Found  then
				local ComboCoGem = EffectFinder:FindGemstone(id, "Combo Score Time Increase")
				if ComboCoGem ~= nil then
					ComboCooldown = ComboCooldown * (1+(ComboCoGem.Q*.01))
				end
				if CombatState then
					local excess = currentChar.Stamina * 0.15 >= 40 and 1 + math.abs((40 - (currentChar.Stamina * 0.15))) * .01 or 1
					if tick() - CombatState.ComboTimer <= ComboCooldown then
						local Count = (ComboAmount * excess)
						CombatState.ComboCount += Count
						SpecialAmnt = SpecialAmnt + Count
						if CombatState.HighestCombo < CombatState.ComboCount then
							CombatState.HighestCombo = CombatState.ComboCount
						end
						if PlayerStat.HighestCombo < CombatState.ComboCount then
							PlayerStat.HighestCombo = CombatState.ComboCount
						end
					else
						CombatState.ComboCount = 0
					end
					CombatState.ComboTimer = tick()
				end
				local comboCountDamage = PlayerStat and math.min(1.75, 1 + (CombatState.ComboCount * ComboDamageModifier)) or 1
				local origDamage = PlayerStat and
					DamageBoost+Rand:NextNumber(currentDamage * ((40 + ((currentChar.CurrentLevel * 0.1) + (PlayerStat.WeaponLevel * 4))) * 0.01),currentDamage) * comboCountDamage
					or (OwnerId == nil and DamageOwner.Configuration.Atk * (EnemyAIProperties.dmgScale and EnemyAIProperties.dmgScale or 1))
				local newDamage = FlatDamageTrue and DamageBoost or origDamage

				if DamageScale then
					newDamage *= DamageScale
				end
				
				local CurrentCritAmnt 		= PlayerStat and currentChar.Crit+(wep.Stats.CRIT+(wep.StatsPerLevel.CRIT*currentChar.CurrentWeapon.UpLvl)) or 0
				local EnemyCritDef 			= TargetPlayer == nil and Target.Configuration.CritDef or 0
				local CritIgnore = EffectFinder:FindWeaponEffect(id, "Critical Up")
				if CritIgnore ~= nil then
					EnemyCritDef = EnemyCritDef * (1-(CritIgnore.V*.01))
				end
				local CritMod				= ((CurrentCritAmnt - EnemyCritDef) + BonusCriticalChance)
				local CritGem = EffectFinder:FindGemstone(id, "Critical Increase")
				if CritGem ~= nil then
					CritMod = CritMod + CritGem.Q
				end
				local Draw = EffectFinder:FindWeaponEffect(id, "Draw Attack")
				if Draw ~= nil and CombatState.ComboCount <= 0 then
					newDamage = newDamage * 2
				end
				local DB = EffectFinder:FindWeaponEffect(id, "Dented Blow")
				if DB ~= nil and CombatState.ComboCount <= 0 then
					AutoCrit = true
				end
				local CCGem = EffectFinder:FindGemstone(id, "Life Drain on Crit")
				if CCGem ~= nil then
					CritMod = CritMod + CCGem.Q*10
				end
				local MaxCrit 				= 50
				local CritAct = EffectFinder:FindWeaponEffect(id, "Critical Act")
				if CritAct ~= nil then
					MaxCrit = CritAct.V
				end
				
				local CanKnockback 			= true
				local Crit					= CritMod > MaxCrit and MaxCrit or CritMod
				local HasCrit				= false
				local TrophyValue			= TargetTrophy and -(TargetTrophy.Stats.DEF + (TargetTrophy.StatsPerLevel.DEF * TargetClass.CurrentTrophy.UpLvl)) or 0
				local EnemyDefenseMod		= (TargetClass and TrophyValue + TargetClass.Defense or (Target and Target.Configuration.Def))
				local Gem2 = EffectFinder:FindGemstone(TargetPlayer and TargetPlayer.UserId, "Reinforced Armor")
				if Gem2 ~= nil then
					EnemyDefenseMod = EnemyDefenseMod + Gem2.Q
				end
				if TargetClass then
					EnemyDefenseMod = EnemyDefenseMod * .01
					if EnemyDefenseMod >= .8 then
						EnemyDefenseMod = .8
					end
				end
				local Atk6Gem = EffectFinder:FindGemstone(TargetPlayer and TargetPlayer.UserId, "Primal Curse and Bloodlust")

				if IgnoresDefense then
					EnemyDefenseMod = 0
				end
				
				local ArmorPierce = EffectFinder:FindWeaponEffect(id, "Armor Piercer")
				if ArmorPierce ~= nil then
					EnemyDefenseMod = EnemyDefenseMod * (1-(ArmorPierce.V*.01))
				end
				local ArmorPenGem = EffectFinder:FindGemstone(id, "Armor Penetration")
				if ArmorPenGem ~= nil then
					EnemyDefenseMod = EnemyDefenseMod * (1-(ArmorPenGem.Q*.01))
				end

				local MinimumDmg = 1
				if PlayerStat and PlayerStat.WeaponLevel > 0 then
					if PlayerStat.WeaponLevel > 1 then
						EnemyDefenseMod = EnemyDefenseMod * 1-(
							(PlayerStat.WeaponLevel <= 11 and -0.03+PlayerStat.WeaponLevel*0.02) or
							(PlayerStat.WeaponLevel == 12 and 0.23) or
							(PlayerStat.WeaponLevel == 13 and 0.28) or
							(PlayerStat.WeaponLevel == 14 and 0.35) or
							(PlayerStat.WeaponLevel == 15 and 0.5)
						)
						if PlayerStat.WeaponLevel >= 9 then
							MinimumDmg = (
								(PlayerStat.WeaponLevel == 9 and 10) or
								(PlayerStat.WeaponLevel == 10 and 50) or
								(PlayerStat.WeaponLevel == 11 and 75) or
								(PlayerStat.WeaponLevel == 12 and 100) or
								(PlayerStat.WeaponLevel == 13 and 150) or
								(PlayerStat.WeaponLevel == 14 and 300) or
								(PlayerStat.WeaponLevel == 15 and 500)
							)
						end
					end
					newDamage = newDamage * 1 + (
						(PlayerStat.WeaponLevel == 1 and 0.02) or
						(PlayerStat.WeaponLevel == 2 and 0.03) or
						(PlayerStat.WeaponLevel <= 11 and -0.01+PlayerStat.WeaponLevel*0.02) or
						(PlayerStat.WeaponLevel == 12 and 0.25) or
						(PlayerStat.WeaponLevel == 13 and 0.3) or
						(PlayerStat.WeaponLevel == 14 and 0.4) or
						(PlayerStat.WeaponLevel == 15 and 0.5)
					)
					Humanoid.Health = Humanoid.Health + Humanoid.MaxHealth*(
						(PlayerStat.WeaponLevel == 12 and 0.005) or
						(PlayerStat.WeaponLevel == 13 and 0.01) or
						(PlayerStat.WeaponLevel == 14 and 0.015) or
						(PlayerStat.WeaponLevel == 15 and 0.03) or
						(0)
					)
				end

				local origDamage = 0
				if Atk6Gem ~= nil then
					if TargetClass then
						newDamage = 999999 * (1-EnemyDefenseMod)
					else
						newDamage = 999999 - EnemyDefenseMod
					end
				else
					origDamage = newDamage
					if TargetClass then
						newDamage = newDamage * (1-EnemyDefenseMod)
					else
						newDamage = newDamage - EnemyDefenseMod
					end
				end
				local Voracity = false
				if OwnerId == nil and DamageOwner then
					for _, Effect in ipairs(DamageOwner.Configuration.Effects) do
						if Effect == "Voracity" then
							local NewDmg = currentChar.HP * .6
							NewDmg = NewDmg + currentChar.Defense * 1.7
							newDamage = newDamage + NewDmg
							Voracity = true
						end
					end
				end
				local Resi = EffectFinder:FindWeaponEffect(TargetPlayer and TargetPlayer.UserId, "Resistant Fighter")
				if Resi ~= nil and THumanoid.Health >= THumanoid.MaxHealth then
					if Rand:NextNumber(1,100) <= Resi.V then
						newDamage = 1
					end
				end
				local dmgres = TargetStats and TargetStats.Characters[TargetStats.CurrentClass].CritDef*.03 or 0
				newDamage = newDamage * (dmgres < 30 and 1-(dmgres*.01) or .7)
				local DefenseUp = EffectFinder:FindWeaponEffect(TargetPlayer and TargetPlayer.UserId, "Defense Up")
				if DefenseUp ~= nil then
					newDamage = newDamage * (1-(DefenseUp.V*.01))
				end
				local Gem = EffectFinder:FindGemstone(TargetPlayer and TargetPlayer.UserId, "DEF Increase")
				if Gem ~= nil then
					newDamage = newDamage * (1-(Gem.Q*.01))
				end
				local GemF = EffectFinder:FindGemstone(TargetPlayer and TargetPlayer.UserId, "Fortitude")
				if GemF ~= nil then
					if EffectFinder:FindEffect("Fortitude", TargetPlayer and TargetPlayer.UserId) ~= nil then
						newDamage = newDamage * (1-(GemF.Q*.01))
					else
						local Effect = EffectFinder:CreateEffect("Fortitude", 1, TargetDamaged)
						tbi(TargetState.StatusEffects, Effect)
						PlayerManager:UpdateCombatState(TargetPlayer and TargetPlayer.UserId, TargetState)
					end
				end
				if EffectFinder:FindEffect("Fervors Edge", TargetPlayer and TargetPlayer.UserId) ~= nil  then
					CanKnockback = false
					if OwnerId == nil then
						if (DamageOwner.Torso.Position-TargetDamaged.HumanoidRootPart.Position).magnitude > 15 then
							newDamage = newDamage * .7
						else
							newDamage = newDamage * .9
						end
					end
				end
				if EffectFinder:FindEffect("Whirling Thunder", TargetPlayer and TargetPlayer.UserId) ~= nil or EffectFinder:FindEffect("Thousand Chaos", TargetPlayer and TargetPlayer.UserId) ~= nil then
					newDamage = newDamage * .25
				end
				if EffectFinder:FindEffect("Focused Charge", TargetPlayer and TargetPlayer.UserId) ~= nil then
					newDamage = newDamage * .9
				end
				if EffectFinder:FindEffect("Potion", TargetPlayer and TargetPlayer.UserId) ~= nil then
					newDamage = newDamage * .5
				end
				local Calamity = EffectFinder:FindEffect("Calamity Chaos", TargetPlayer and TargetPlayer.UserId)
				if Calamity ~= nil then
					newDamage = newDamage * Calamity.Misc
				end
				if EffectFinder:FindEffect("Haste", TargetPlayer and TargetPlayer.UserId) ~= nil then
					newDamage = newDamage * .01
					THumanoid.Health = THumanoid.Health + (((THumanoid.MaxHealth - THumanoid.Health)*.3) + (150+(TargetStats.Characters[TargetStats.CurrentClass].CurrentLevel*2)))
					TargetState.SpecialBar = TargetState.SpecialBar + 25
					if TargetState.SpecialBar >= 100 then
						TargetState.SpecialBar = 100
					end
					Sockets:GetSocket(TargetPlayer):Emit("SpecialBarReset", TargetState.SpecialBar)
					PlayerManager:UpdateCombatState(TargetPlayer.UserId, TargetState)
				end
				if EffectFinder:FindEffect("Elysian Counter", TargetPlayer and TargetPlayer.UserId) ~= nil then
					local Skills = TargetStats.Characters[TargetStats.CurrentClass].Skills
					local Rank =  0
					local HeavyRank = 0
					for _, e in ipairs(Skills) do
						local Skil = ClassInfo:GetSkillInfo(e.Name)
						if e.Name == "Elysian Counter" and e.Unlocked then
							ComboAmount = ComboAmount + 35
							TargetState.UltimateCounter = TargetState.UltimateCounter + 20
							Rank = e.Rank + 1
							newDamage = newDamage * (1+(Skil.PercentageIncrease[Rank]))
							if tick() - TargetState.ComboTimer <= GlobalThings.GlobalComboCooldown then
								TargetState.ComboCount = TargetState.ComboCount + ComboAmount
								if TargetStats.HighestCombo < TargetState.ComboCount then
									TargetStats.HighestCombo = TargetState.ComboCount
									if TargetState.ComboCount >= 1000 then
										AwardBadge(TargetPlayer.UserId, 706686040)
									end
								end
							else
								TargetState.ComboCount = 0
							end
							TargetState.ComboTimer = tick()
						elseif e.Name == "Skillful Mastery" and e.Unlocked then
							HeavyRank = e.Rank+1
						end
					end
					local Effect = EffectFinder:CreateEffect("Focused Charge", 5, TargetDamaged)
					tbi(TargetState.StatusEffects, Effect)
					ReplicatedStorage.PlayerValues[TargetDamaged.Name].Stamina.Value = ReplicatedStorage.PlayerValues[TargetDamaged.Name].StaminaMax.Value
					Sockets:GetSocket(TargetPlayer):Emit("AdjustAtt", .3, 5)
					if EffectFinder:FindEffect("Fervors Edge", TargetPlayer and TargetPlayer.UserId) ~= nil then
						local PlayerCounterDamage;
						if PlayerOwner or DamageOwner.Boss or (DamageOwner.Auto and DamageOwner.Torso:FindFirstChildOfClass("BoolValue") == nil) then
							PlayerCounterDamage = (TargetStats.Characters[TargetStats.CurrentClass].Damage + ((OwnerId == nil and DamageOwner.Configuration.MAXHP or DamageOwner.Humanoid.MaxHealth)*.0075))*(1+(.045+(.025*Rank)))
						else
							PlayerCounterDamage = TargetStats.Characters[TargetStats.CurrentClass].Damage+DamageOwner.Configuration.HP*(.045+(.025*Rank))
						end
						PlayerCounterDamage = PlayerCounterDamage * (1+(ClassInfo:GetSkillInfo("Skillful Mastery").PercentageIncrease[Rank]))
						PlayerCounterDamage = PlayerCounterDamage - (OwnerId == nil and DamageOwner.Configuration.Def or 0)
						if PlayerCounterDamage < 1 then
							PlayerCounterDamage = 1
						end
						if OwnerId == nil and DamageOwner then
							if DamageOwner.Configuration.HP > PlayerCounterDamage then
								DamageOwner.Configuration.HP = DamageOwner.Configuration.HP - PlayerCounterDamage
							else
								DamageOwner.Died(TargetPlayer.Name, PlayerCounterDamage - DamageOwner.Configuration.HP)
							end
							if DamageOwner.Boss or (DamageOwner.Auto and DamageOwner.Torso:FindFirstChildOfClass("BoolValue") == nil) then
								Sockets:Emit("EnemyStatus", DamageOwner, "BossHP", DamageOwner.Configuration.HP)
							end
						elseif OwnerId and DamageOwner then
							if DamageOwner.Humanoid.Health > PlayerCounterDamage then
								DamageOwner.Humanoid:TakeDamage(PlayerCounterDamage)
							end
						end
						Sockets:GetSocket(TargetPlayer):Emit("DamageIndicator", false, Floor(PlayerCounterDamage), OwnerId == nil and DamageOwner.Torso or DamageOwner.PrimaryPart, TargetState.ComboCount, TargetState.ComboTimer, TargetState.UltimateCounter)
						if TargetDamaged and TargetDamaged.PrimaryPart:FindFirstChild("StatusEffects") then
							local StringValue = Instance.new("StringValue")
							StringValue.Value = "Countered"
							local ObjectValue = Instance.new("ObjectValue")
							ObjectValue.Name = "Target"
							ObjectValue.Value = OwnerId == nil and DamageOwner.Torso or DamageOwner.PrimaryPart
							ObjectValue.Parent = StringValue
							StringValue.Parent = TargetDamaged.PrimaryPart.StatusEffects.Effects
							Debris:AddItem(StringValue, 1)
						end
						local Effect = EffectFinder:CreateEffect("Fervors Edge", 10*(1+abs(ClassInfo:GetSkillInfo("Elysian Counter").PercentageIncrease[Rank]*.5)), TargetDamaged)
						tbi(TargetState.StatusEffects, Effect)
					else
						local Effect = EffectFinder:CreateEffect("Fervors Edge", 10*(1+abs(ClassInfo:GetSkillInfo("Elysian Counter").PercentageIncrease[Rank]*.5)), TargetDamaged)
						tbi(TargetState.StatusEffects, Effect)
					end
					PlayerManager:UpdateCombatState(TargetPlayer.UserId, TargetState)
				end
				if Voracity then
					local Dmg = THumanoid and THumanoid.MaxHealth*.14 or 0
					if newDamage <= Dmg then
						newDamage = Dmg
					end
				end
				if EffectFinder:FindEffect("Invincibility", TargetPlayer and TargetPlayer.UserId) then
					newDamage = 0
				end
				
				local CritWounds = newDamage*.25
				local CanCritWound = true
				if TargetStats then
					local Skills = TargetStats and TargetStats.Characters[TargetStats.CurrentClass].Skills
					for _, e in ipairs(Skills) do
						local Skil = ClassInfo:GetSkillInfo(e.Name)
						if e.Name == "Spell Witch" then
							if EnemyAIProperties.IsProj ~= nil and EnemyAIProperties.IsProj then
								CanCritWound = false
								newDamage = newDamage * .7
							else
								CritWounds *= .25
							end
							break
						elseif e.Name == "Spear Breaker" then
							if THumanoid.Health > 1 and THumanoid.MoveDirection.Magnitude <= 0 then
								if #THumanoid:GetPlayingAnimationTracks() < 5 then
									if EnemyAIProperties.IsProj ~= nil and EnemyAIProperties.IsProj then
										module:DamageMode(GameData, TargetPlayer.UserId, TargetPlayer.Character, Enemies, nil, DamageOwner.Torso.Parent, nil)
										newDamage = 0
										for _, Bullet in ipairs(DamageOwner.Configuration.Animations) do
											if Bullet ~= nil and (TargetDamaged.PrimaryPart.Position-Bullet.CFrame.Position).Magnitude <= 10 then
												local ConsGem = EffectFinder:FindGemstone(TargetPlayer and TargetPlayer.UserId, "Counterattack")
												if ConsGem ~= nil then
													TargetState.ConsumedDamage = TargetState.ConsumedDamage + (DamageOwner.Configuration.Atk*(ConsGem.Q*.01))
												end
												Bullet.Tick = 9999
											end
										end
										Sockets:GetSocket(TargetPlayer):Emit("Deflect", DamageOwner.Torso, nil, "LingeringForce")
									elseif EnemyAIProperties.IsLaser ~= nil and EnemyAIProperties.IsLaser then
										local Effect = EffectFinder:CreateEffect("Invincibility", .25, TargetDamaged)
										tbi(TargetState.StatusEffects, Effect)
										local ConsGem = EffectFinder:FindGemstone(TargetPlayer and TargetPlayer.UserId, "Counterattack")
										if ConsGem ~= nil then
											TargetState.ConsumedDamage = TargetState.ConsumedDamage + (DamageOwner.Configuration.Atk*(ConsGem.Q*.01))
										end
										local Tact = EffectFinder:FindWeaponEffect(TargetPlayer and TargetPlayer.UserId, "Tactician")
										if Tact ~= nil then
											ReplicatedStorage.PlayerValues[TargetDamaged.Name].Stamina.Value += ReplicatedStorage.PlayerValues[TargetDamaged.Name].StaminaMax.Value * (Tact.V * .01)
										end
										TargetState.DodgedAttacks = TargetState.DodgedAttacks + 1
										Sockets:GetSocket(TargetPlayer):Emit("Deflect", DamageOwner.Torso, nil, "LingeringForceL")
									end
								end
							end
							break
						elseif e.Name == "Demonic Presence" then
							TargetState.ConsumedDamage = TargetState.ConsumedDamage + (origDamage*.35)
						elseif e.Name == "Powers United" and THumanoid.Health < THumanoid.MaxHealth * .5 then
							local MaxDmg = THumanoid.MaxHealth * .15
							if newDamage >= MaxDmg then
								newDamage = MaxDmg
							end
						end
					end
					local Bulwark = EffectFinder:FindEffect("Chaos Bulwark", TargetPlayer and TargetPlayer.UserId)
					if Bulwark ~= nil then
						CanKnockback = false
						local Angle = math.deg(math.acos(TargetPlayer.Character.PrimaryPart.CFrame.LookVector:Dot(((OwnerId == nil and DamageOwner.Torso.Position or DamageOwner.PrimaryPart.Position) - TargetDamaged.PrimaryPart.Position).unit)))
						if Angle <= 75 then
							newDamage = newDamage * (1 + Bulwark.Misc)
							if TargetPlayer.Character:FindFirstChild("Bulwark") then
								local RegionTargs = {}
								local parts = GetTouchingParts(TargetPlayer.Character.Bulwark.Region)
								for _, part in ipairs(parts) do
									local Targ = nil
									if part.Parent:FindFirstChild("HumanoidRootPart") then
										Targ = part.Parent
									elseif part.Parent.Parent:FindFirstChild("HumanoidRootPart") then
										Targ = part.Parent.Parent
									end
									if Targ and Targ ~= TargetPlayer.Character and not RegionTargs[Targ] then
										RegionTargs[Targ] = true
										local PlyTarg = Players:GetPlayerFromCharacter(Targ) 
										if PlyTarg then
											local Effect = EffectFinder:CreateEffect("Invincibility", 1.25, Targ)
											local TargPlyrState = PlayerManager:GetCombatState(PlyTarg.UserId)
											tbi(TargPlyrState.StatusEffects, Effect)
											PlayerManager:UpdateCombatState(PlyTarg.UserId, TargPlyrState)
										end
									end
								end
							end
						end
					end
					PlayerManager:UpdateCombatState(TargetPlayer and TargetPlayer.UserId, TargetState)
				end
				if EffectFinder:FindEffect("Spearlancer", TargetPlayer and TargetPlayer.UserId) ~= nil then
					newDamage = 0
					local Spr = Instance.new("Folder")
					Spr.Name = "CounterAnimation"
					Spr.Parent = TargetPlayer.Character.PrimaryPart
					Debris:AddItem(Spr, 1)
					TargetPlayer.Character:SetPrimaryPartCFrame(OwnerId == nil and DamageOwner.Torso.CFrame or DamageOwner.PrimaryPart.CFrame)
					if OwnerId == nil and not DamageOwner.Boss then
						DamageOwner.Died(TargetPlayer.Name, 9999999)
					end
					TargetState.SpecialBar = TargetState.SpecialBar + 75
					if TargetState.SpecialBar >= 100 then
						TargetState.SpecialBar = 100
					end
					Sockets:GetSocket(TargetPlayer):Emit("SpecialBarReset", TargetState.SpecialBar)
					ComboAmount = ComboAmount + 75
					if tick() - TargetState.ComboTimer <= GlobalThings.GlobalComboCooldown then
						TargetState.ComboCount = TargetState.ComboCount + ComboAmount
						if TargetStats.HighestCombo < TargetState.ComboCount then
							TargetStats.HighestCombo = TargetState.ComboCount
							if TargetState.ComboCount >= 1000 then
								AwardBadge(TargetPlayer.UserId, 706686040)
							end
						end
					else
						TargetState.ComboCount = 0
					end
					TargetState.ComboTimer = tick()
				end
				if EffectFinder:FindEffect("Critical Mercy", TargetPlayer and TargetPlayer.UserId) ~= nil then
					CanCritWound = false
				end
				if CanCritWound and TargetPlayer and newDamage/THumanoid.MaxHealth >= .25 then
					local MinusCrit = (TargetStats.Characters[TargetStats.CurrentClass].HP*0.003)
					CritWounds = CritWounds * (MinusCrit < 50 and 1-(MinusCrit*.01) or .5)
					local CritW = EffectFinder:FindWeaponEffect(TargetPlayer.UserId, "Wounds Resist")
					if CritW ~= nil then
						CritWounds = CritWounds * (1-(CritW.V*.01))
					end
					local Gem3 = EffectFinder:FindGemstone(TargetPlayer.UserId, "Critical Wounds Decrease")
					if Gem3 ~= nil then
						CritWounds = CritWounds * (1-(Gem3.Q*.01))
					end
					THumanoid.MaxHealth = THumanoid.MaxHealth - CritWounds
					if THumanoid.MaxHealth < 1 then
						THumanoid.MaxHealth = 1
					end
					TargetState.CriticalWounds = TargetState.CriticalWounds + CritWounds
					if TargetState.CriticalWounds >= TargetState.MAXHP*.9 then
						TargetState.CriticalWounds = Floor(TargetState.MAXHP*.9)
					end
					newDamage = newDamage - CritWounds
					if CanKnockback then
						local KnockbackChance = 100
						local Knockback = EffectFinder:FindWeaponEffect(TargetPlayer.UserId, "Tumble Master")
						if Knockback ~= nil then
							KnockbackChance = Rand:NextNumber(1, 100)
						end
						Sockets:GetSocket(TargetPlayer):Emit("Knockback", KnockbackChance > 50 and false or nil, TargetState.CriticalWounds)
					end
				end

				local Fatal = EffectFinder:FindWeaponEffect(id, "Fatal Strike")
				if Fatal ~= nil then
					if MinimumDmg < Fatal.V then
						MinimumDmg = Fatal.V
					end
				end
				if RedsTurret and (not Target.Boss and not Target.Auto and TargetPlayer == nil) then
					newDamage = newDamage + (Target.Configuration.MAXHP * .025)
					AutoCrit = true
				end
				if PlayerStat and DamageOwner and PlayerStat.CurrentClass == "Valeri" and FlatDamageTrue then
					if DamageOwner.PrimaryPart:FindFirstChild("ValeriTome") then
						local value = newDamage * 0.2
						local Values = ReplicatedStorage.PlayerValues[DamageOwner.Name]
						DamageOwner.Humanoid.Health += value
						Values.Barrier.Value = math.min(DamageOwner.Humanoid.MaxHealth, Values.Barrier.Value + value)
						Values.Stamina.Value = math.min(Values.StaminaMax.Value, Values.Stamina.Value + value)
					end
				end
				local VeilofTheStormBuff = EffectFinder:FindEffect("Veil of the Storm", id) 
				if VeilofTheStormBuff then
					newDamage *= VeilofTheStormBuff.Misc
				end
				if EffectFinder:FindEffect("Empowered", id) then
					if (TargetPlayer or Target.Boss or Target.Auto) then
						newDamage = newDamage * 1.25
					else
						HPDmgMultiplier = 0.05
					end
				end
				if EffectFinder:FindEffect("Focused Charge", id) or EffectFinder:FindEffect("Counter Attack", id) then
					AutoCrit = true
				end
				if EffectFinder:FindEffect("Searing Edge", id) then
					DamageOwner.Humanoid.Health = DamageOwner.Humanoid.Health + DamageOwner.Humanoid.MaxHealth*.01
				end
				if HPDmgMultiplier > 0 then
					newDamage = newDamage + ((TargetPlayer and THumanoid.MaxHealth or Target.Configuration.MAXHP) * HPDmgMultiplier)
				end
				if (Crit > 0 and Rand:NextNumber(1,100) <= Crit) or AutoCrit then
					HasCrit = true
					DamageOwner.Humanoid.Health = DamageOwner.Humanoid.Health + HealingOnCrit
					if IsLight and table.find(LastSkillUsed, "Overwhelming Strength") then
						newDamage = newDamage * 2
					end
					if table.find(LastSkillUsed, "Weakness Exploit") then
						CombatState.ComboCount += 1
					end
					if Target and table.find(LastSkillUsed, "Dented Blows") then
						Target.Configuration.Def -= Target.Configuration.Def * 0.0015
					end
					local CritDamage = 1.3+(currentDamage*0.00015)
					newDamage = newDamage * CritDamage
					newDamage = newDamage * HeavyCritMod
					local CritI = EffectFinder:FindWeaponEffect(id, "Critical Exploit")
					if CritI ~= nil then
						newDamage = newDamage * (1+(CritI.V*.01))
					end
				end
				if Animation ~= nil then
					if Animation.Animation.AnimationId == "rbxassetid://3087280788" then
						local Effect = EffectFinder:CreateEffect("Thousand Chaos", 1, DamageOwner)
						tbi(CombatState.StatusEffects, Effect)
						PlayerManager:UpdateCombatState(id, CombatState)
					end
				end
				if EffectFinder:FindEffect("Critical Mercy", id) then
					newDamage = newDamage * 1.75
					if (not Target.Boss and not Target.Auto) then						
						HPDmgMultiplier = .1
					end
					local Count = 1
					CombatState.ComboCount = CombatState.ComboCount + Count
					SpecialAmnt = SpecialAmnt + Count
					if HasCrit then
						if Target.Torso:FindFirstChild("LFSpear") == nil then
							for i = 1, 3 do
								local Spear = ReplicatedStorage.Models.Weapons.LFSpear:Clone()
								Spear.PrimaryPart = Spear.Handle
								Spear:SetPrimaryPartCFrame(Target.Torso.CFrame)
								local Weld = Instancenew("Weld")
								Weld.Part0 = Target.Torso
								Weld.Part1 = Spear.PrimaryPart
								Weld.C1 = CFrameAngles(mathrad(Rand:NextNumber(1, 360)), mathrad(Rand:NextNumber(1, 360)), mathrad(Rand:NextNumber(1, 360)))
								Weld.Parent = Spear.PrimaryPart
								Spear.Name = "LFSpear"
								Spear.Parent = Target.Torso
								Debris:AddItem(Spear, 10)
							end
						else
							HasSpear = true
							if Animation ~= nil then
								if Animation.Animation.AnimationId == "rbxassetid://3087280788" then
									PercentageBoost = PercentageBoost * 1.15
								elseif Animation.Animation.AnimationId == "rbxassetid://3115648751" then
									PercentageBoost = PercentageBoost * 2
									Humanoid.Health = Humanoid.Health + Humanoid.MaxHealth*.025
								end
							end
						end
					end
				end
				newDamage = newDamage * PercentageBoost
				local Atk2Gem = EffectFinder:FindGemstone(id, "Ranger")
				if Atk2Gem ~= nil then
					if (((TargetPlayer and TargetDamaged.PrimaryPart.Position or Target.Torso.Position) - DamageOwner.PrimaryPart.Position)).Magnitude >= 15 then
						newDamage = newDamage * (1+(Atk2Gem.Q*.01))
					end
				end
				local Atk3Gem = EffectFinder:FindGemstone(id, "Muscular Power")
				if Atk3Gem ~= nil then
					newDamage = newDamage + (Humanoid.MaxHealth*(Atk3Gem.Q*.01))
				end
				if PlayerStat and table.find(PlayerStat.Vestiges, 14) then
					if GameData.TeamHP < 100 then
						newDamage = newDamage * 1.5
					end
				end
				if not TargetPlayer and PlayerStat and table.find(PlayerStat.Vestiges, 16) then
					if Target.Configuration.HP >= Target.Configuration.MAXHP * .95 then
						newDamage = newDamage * 1.35
					end
				end
				local Atk4Gem = EffectFinder:FindGemstone(id, "Under Pressure")
				if GameData ~= nil and Atk4Gem ~= nil then
					local TeHP = (GameData.MAXTeamHP-GameData.TeamHP)/GameData.MAXTeamHP
					local increasedDmg = TeHP*(Atk4Gem.Q*.01)
					newDamage = newDamage * (1+increasedDmg)
				end
				local Atk5Gem = EffectFinder:FindGemstone(id, "Giant Slayer")
				if Atk5Gem ~= nil and ((Humanoid.Health < (TargetPlayer and THumanoid.Health or Target.Configuration.HP))) then
					newDamage = newDamage * (1+(Atk5Gem.Q*.01))
				end
				local Atk6Gem = EffectFinder:FindGemstone(id, "Primal Curse and Bloodlust")
				if Atk6Gem ~= nil then
					newDamage = newDamage * (1+(Atk6Gem.Q*.01))
				end
				local Atk7Gem = EffectFinder:FindGemstone(id, "Persistent")
				if Atk7Gem ~= nil then
					newDamage = newDamage + (CombatState.ComboCount*(Atk7Gem.Q*.01))
				end
				local Unf = EffectFinder:FindWeaponEffect(id, "Unfazed Resolve")
				if Unf ~= nil and Humanoid.Health < Humanoid.MaxHealth*.25 then
					newDamage = newDamage * (1+(Unf.V*.01))
				end
				if Animation and Animation.Animation.AnimationId == "rbxassetid://5255893101" then
					if EffectFinder:FindEffect("Crescent Sweep", id) then
						local Effect = EffectFinder:CreateEffect("Crescent Wind", 5, DamageOwner)
						tbi(CombatState.StatusEffects, Effect)
						local BonusDmg = 0.09 * (origDamage*.1)
						newDamage *= (6+BonusDmg)
						local HealMax = CombatState.CriticalWounds * 0.5
						DamageOwner.Humanoid.MaxHealth += HealMax
						CombatState.CriticalWounds = math.max(0, CombatState.CriticalWounds - HealMax)
					end
				end
				if Animation and Animation.Animation.AnimationId == "rbxassetid://5255912147" then
					if EffectFinder:FindEffect("Crescent Wind", id, true) then
						local BonusDmg = 0.09*(origDamage*.1)
						newDamage *= (3+BonusDmg)
						
						local Effect = EffectFinder:CreateEffect("Focused Charge", 5, DamageOwner)
						tbi(CombatState.StatusEffects, Effect)
						ReplicatedStorage.PlayerValues[DamageOwner.Name].Stamina.Value = ReplicatedStorage.PlayerValues[DamageOwner.Name].StaminaMax.Value
						Sockets:GetSocket(PlayerOwner):Emit("AdjustAtt", .2, 5)
						
						local BulletBarrages = 7
						local Segments = 70
						local Steps = 5
						local Cooldown = Random.new()
						for i = 1, BulletBarrages do
							local Bullet = ServerStorage.Models.Parts.BulletClone:Clone()
							local P0 = DamageOwner.PrimaryPart.Position
							local LastPosition = P0
							Bullet.Position = P0
							Bullet.Trail.Enabled = true
							Bullet.Parent = DamageOwner
							Debris:AddItem(Bullet, 2)
							local Targets = workspace.Enemies:GetChildren()
							FS.spawn(function()
								local PotentialTarget = Targets[Cooldown:NextInteger(1, #Targets)]
								if PotentialTarget ~= DamageOwner and PotentialTarget:IsA("Model") then
									local PlayerTorso = PotentialTarget.PrimaryPart
									local P1 = PlayerTorso.Position + (PlayerTorso.Velocity * .5)
									local Dist = (P1 - P0).Magnitude
									local P2 = CFrame.new(P0, P1) * CFrame.new(0, 20, -Dist * .5)
									local Positions = Bezier:NewQuadraticCurve(Segments, P0, P1, P2.Position + Vector3.new(Cooldown:NextNumber(-60, 60),Cooldown:NextNumber(-15, 15),Cooldown:NextNumber(-60, 60)))
									for v = 1, #Positions, Steps do
										Bullet.CFrame = CFrame.new(Bullet.Position, Positions[v])
										local Tween = TS:Create(Bullet, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Position = Positions[v]})
										local Speed = (Bullet.Position - LastPosition).Magnitude
										local Dir = Bullet.CFrame.LookVector*Speed
										local ray = Ray.new(Positions[v], Dir)
										local obj, pos = workspace:FindPartOnRayWithIgnoreList(ray, {DamageOwner, workspace.Players}, false, true)
										
										Tween:Play()
										
										if obj then
											local Targ
											if obj.Parent:FindFirstChildOfClass("Humanoid") then
												Targ = obj.Parent
											elseif obj.Parent.Parent:FindFirstChildOfClass("Humanoid") then
												Targ = obj.Parent.Parent
											end
											if Targ then
												module:DamageMode(GameData, id, DamageOwner, Enemies, nil, Targ, nil, nil, nil, nil, nil, 1.5)
											end
											local Impact = Bullet.Impact
											Impact.PitchShift.Octave = Random.new():NextNumber(0.5, 1.5)
											Impact:Play()
											Tween:Cancel()
											break
										end
										
										LastPosition = Positions[v < #Positions - (Steps + 1) and v + Steps or #Positions]
										wait()
									end
									TS:Create(Bullet, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
									wait(.1)
									Bullet:Destroy()
								end
							end)
							wait( Cooldown:NextNumber(0, 0.01) )
						end
					end
				end			
				
				if IsLight then
					if EffectFinder:FindEffect("Crescent Sweep", id, true) then
						newDamage *= 2
					end
					local Atk8Gem = EffectFinder:FindGemstone(id, "Swift Attacks")
					if Atk8Gem ~= nil then
						newDamage = newDamage * (1+(Atk8Gem.Q*.01))
					end
					if CombatState and CombatState.ConsumedDamage > 0 then
						newDamage = newDamage + CombatState.ConsumedDamage
						CombatState.ConsumedDamage = 0
						PlayerManager:UpdateCombatState(id, CombatState)
					end
					if not StartAtZeroSpecial then
						SpecialAmnt = 9
					end
				else
					if not StartAtZeroSpecial then
						SpecialAmnt = .7
					end
				end
				if EffectFinder:FindWeaponEffect(TargetPlayer and TargetPlayer.UserId, "Spiked Edges") then
					module:DamageMode(GameData, TargetPlayer.UserId, TargetPlayer.Character, Enemies, nil, DamageOwner.Torso.Parent, nil, nil, nil, nil, nil, nil, newDamage * .05)
				end
				local AttackUp = EffectFinder:FindWeaponEffect(id, "Attack Up")
				if AttackUp ~= nil then
					newDamage = newDamage * (1+(AttackUp.V*.01))
				end
				local AtkGem = EffectFinder:FindGemstone(id, "ATK Increase")
				if AtkGem ~= nil then
					newDamage = newDamage * (1+(AtkGem.Q*.01))
				end
				if StamRecovery > 0 then
					ReplicatedStorage.PlayerValues[DamageOwner.Name].Stamina.Value += StamRecovery
					if ReplicatedStorage.PlayerValues[DamageOwner.Name].Stamina.Value >= ReplicatedStorage.PlayerValues[DamageOwner.Name].StaminaMax.Value then
						ReplicatedStorage.PlayerValues[DamageOwner.Name].Stamina.Value = ReplicatedStorage.PlayerValues[DamageOwner.Name].StaminaMax.Value
					end
					PlayerManager:UpdateCombatState(id, CombatState)
				end
				local UltGem = EffectFinder:FindGemstone(id, "Ultimate Increase")
				if CombatState and CombatState.Ultimate and UltGem ~= nil then
					newDamage = newDamage * (1+(UltGem.Q*.01))
				end
				if Target then
					newDamage = newDamage - (CombatState.Ultimate and 0 or EnemyDefenseMod)
				else
					newDamage = newDamage * (1 - EnemyDefenseMod)
				end
				if newDamage < 1 then
					newDamage = MinimumDmg
				end
				if HasCrit then
					local Bandit = EffectFinder:FindWeaponEffect(id, "Bandit")
					if Bandit ~= nil then
						PlayerStat.Gold = PlayerStat.Gold + Bandit.V
					end
					if CCGem ~= nil then
						Humanoid.Health = Humanoid.Health + (newDamage*(CCGem.Q*.01))
					end
				end
				local HRGem = EffectFinder:FindGemstone(id, "HP Regen on Hit")
				if HRGem ~= nil then
					Humanoid.Health = Humanoid.Health + (newDamage*(HRGem.Q*.01))
				end
				if EffectFinder:FindEffect("Fervors Edge", id) ~= nil then
					Humanoid.Health += 10
					if IsLight and EffectFinder:FindEffect("Fervors Edge", id) ~= nil then
						local BonusDmg = 0.09 * (origDamage*.1)
						newDamage = newDamage * (1+BonusDmg) --(1.1+(BonusDmg < 1.3 and BonusDmg or 1.3))
					end
					local Executed = false
					local EXECUTIONAMNT = 0
					if (TargetPlayer or Target.Boss or Target.Auto) then 
						EXECUTIONAMNT = .05
					else
						EXECUTIONAMNT = .35
					end
					if (TargetPlayer and THumanoid.Health <= THumanoid.MaxHealth * EXECUTIONAMNT) or (Target and Target.Configuration.HP <= Target.Configuration.MAXHP * EXECUTIONAMNT) then
						Executed = true
					end
					if Executed then
						CombatState.ComboCount = CombatState.ComboCount + 25
						newDamage = newDamage + (abs(TargetPlayer and THumanoid.Health or Target.Configuration.HP) + 1)
						if EffectFinder:FindEffect("Fervors Edge", id) ~= nil then
							local Effect = EffectFinder:CreateEffect("Fervors Edge", 10, DamageOwner)
							tbi(CombatState.StatusEffects, Effect)
						end
						PlayerManager:UpdateCombatState(id, CombatState)
					end
				end
				local OldHP = (Target and Target.Configuration.HP or (TargetPlayer and THumanoid.Health))
				local ToBeHP = (Target and Target.Configuration.HP - newDamage or (TargetPlayer and THumanoid.Health - newDamage))
				if Target then
					if table.find(Target.Configuration.Effects, "Ranged Immune") then
						if (DamageOwner.PrimaryPart.Position - Target.Torso.Position).Magnitude > 10 then
							newDamage = 1
							Sockets:GetSocket(PlayerOwner):Emit("DamageIndicator", true, "RANGED IMMUNE!", Target.Torso)
						end
					end
					if table.find(Target.Configuration.Effects, "Indomitable Will") then
						local PtsToGain = 0.03
						Target.Configuration.Def = Target.Configuration.Def + PtsToGain
					end
					if WasDeflected and table.find(Target.Configuration.Effects, "Self Mitigated Armor") then
						newDamage = newDamage * .05
					end
					if table.find(Target.Configuration.Effects, "Undying") then
						local DamageCap = Target.Configuration.MAXHP*.03
						if newDamage >= DamageCap then
							newDamage = DamageCap
						end
					end
				end
				if CombatState and CombatState.ComboCount >= 1000 then
					AwardBadge(id, 706686040)
				end

				if CombatState then
					CombatState.DPS = CombatState.DPS + newDamage
				end
				if Animation then
					local StaleCount = PlayerManager:GetStaleCount(id, Animation.Animation.AnimationId)
					newDamage = newDamage * 1 - (StaleCount * 0.04)
					PlayerManager:UpdateStaleAttack(id, Animation.Animation.AnimationId)
				end
				if (Target and Target.Configuration.HP > newDamage) then
					if Target.Auto then
						if Target.Torso.Parent:FindFirstChild("Bindables") then
							if GameData.CurrentMap.MissionName == "High Vigils: Basic Combat Tutorial" then
								if Target.Configuration.HP <= Target.Configuration.MAXHP*.35 then
									Target.Configuration.HP = Target.Configuration.MAXHP
								end
								newDamage = Target.Configuration.MAXHP*.005
								if GameData.DungeonMsg == "Use your Light Attack on Lilah 25 times" then
									ObjectiveUpdate("Use your Light Attack on Lilah 25 times")
								end
							end
							local Perc = 1
							local KGem = EffectFinder:FindGemstone(id, "Knockout Master")
							if KGem ~= nil then
								Perc = 1+(KGem.Q*.01)
							end
							Target.Torso.Parent.Bindables.SelfDamage:Fire(Target.Configuration.HP, Perc, DamageOwner)
						end
					end
					if Target.Boss then
						Sockets:Emit("EnemyStatus", Target, "BossHP", Target.Configuration.HP)
					end
					Target.Configuration.HP = Target.Configuration.HP - newDamage
					if CombatState.UltimateCounter < 400 then
						local UltAmount = (.6+(CombatState.ComboCount*.0002))+GlobalThings.GlobalUltimateCounter
						if UltGem ~= nil then
							UltAmount = UltAmount * (1+(UltGem.Q*.01))
						end
						CombatState.UltimateCounter = CombatState.UltimateCounter + UltAmount
					else
						CombatState.UltimateCounter = 400
					end
					if CCType == "Knockup" then
						Target.Knockup()
					else
						if isBlowback == false then
							Target.Knockback(CCType == "Knockback" and 1 or 2)
						else
							if CanKnockBack then
								Target.Knockback(nil, (DamageOwner.PrimaryPart.Position - Target.Torso.Position))
							end
						end
					end
				elseif TargetState then
					TargetState.DamageTaken = TargetState.DamageTaken + newDamage
					PVPManager:Add(PlayerOwner, "DamageDealt", newDamage)
					local Barrier = ReplicatedStorage.PlayerValues[TargetDamaged.Name].Barrier
					if newDamage < Barrier.Value then
						Barrier.Value -= newDamage
						newDamage = 1
					else
						newDamage -= Barrier.Value
						Barrier.Value = 0
					end
					if THumanoid.Health > newDamage then
						THumanoid:TakeDamage(newDamage)
					else
						if PVPManager:IsPVP() then
							if THumanoid.Health > 0 then
								PVPManager:Add(PlayerOwner, "Kills", 1)
							end
							THumanoid.Health = 0
						else
							local CanDie = true
							if table.find(TargetStats.Vestiges, 13) then
								--- Prevents one shots
								if THumanoid.Health >= THumanoid.MaxHealth * .9 then
									THumanoid.Health = THumanoid.MaxHealth * .05
									CanDie = false
								end
							end
							if CanDie then
								THumanoid.Health = 1
								Sockets:GetSocket(TargetPlayer):Emit("Ragdoll", true, DamageOwner.Torso and DamageOwner.Torso.Position)
								Modules.Parent.Server.Bindables.PlayerDown:Fire(TargetPlayer)
							end
						end
					end
					local GemB = EffectFinder:FindGemstone(TargetPlayer.UserId, "Battle Scars")
					if GemB ~= nil then
						local Effect = EffectFinder:CreateEffect("Battle Scars", GemB.Q, TargetDamaged)
						tbi(TargetState.StatusEffects, Effect)
					end
					if OwnerId == nil and (GameData and (GameData.HeroMode or GameData.EveryoneMustDie)) then
						if Rand:NextNumber(1,100) <= 30 then
							if EffectFinder:FindEffect("Bleed", TargetPlayer.UserId) == nil then
								local BleedDuration = 30
								local BleedResist = EffectFinder:FindWeaponEffect(TargetPlayer.UserId, "Bleed Resist")
								if BleedResist ~= nil then
									BleedDuration = BleedDuration * (1-(BleedResist.V*.01))
								end
								local Debuff = EffectFinder:FindWeaponEffect(TargetPlayer.UserId, "Debuff Resist")
								if Debuff ~= nil then
									BleedDuration = BleedDuration * (1-(Debuff.V*.01))
								end
								local Effect = EffectFinder:CreateEffect("Bleed", BleedDuration, TargetDamaged)
								tbi(TargetState.StatusEffects, Effect)
							end
						end
					end
					PlayerManager:UpdateCombatState(TargetPlayer.UserId, TargetState)
				else
					if CombatState and CombatState.Ultimate and (TargetPlayer or Target.Boss or (Target.Auto and Target.Torso:FindFirstChildOfClass("BoolValue") == nil)) then
						AwardBadge(id, 706674697)
					end
					if Target then
						if not TargetPlayer then
							local Overkill = newDamage - Target.Configuration.HP
							Target.Died(DamageOwner.Name, Overkill)
						end
					end
					if HadSpecial then
						if Animation ~= nil and Animation.Animation.AnimationId == "rbxassetid://1539764838" then
							CombatState.SpecialBar = 100
						end
					end
				end

				if PlayerStat then
					if FirstHit == nil then
						FirstHit = PlayerOwner
						Sockets:Emit("Banner", "First to Strike" , PlayerStat.ProfileBackground, PlayerOwner.Name.. " - Lv" ..PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel)
					end
					if CombatState.IsSpecial then
						local CPGem = EffectFinder:FindGemstone(id, "CP Increase")
						if CPGem ~= nil then
							SpecialAmnt = SpecialAmnt * 1+(CPGem.Q*.01)
						end
						CombatState.SpecialBar = CombatState.SpecialBar + SpecialAmnt
						if CombatState.SpecialBar >= 100 then
							CombatState.SpecialBar = 100
						end
					end
					local EnemyStats = nil
					if not TargetPlayer then
						EnemyStats = Target.Configuration
					end
					Sockets:GetSocket(PlayerOwner):Emit("DamageIndicator", false, Floor(newDamage), TargetPlayer and TargetDamaged.PrimaryPart or Target.Torso, CombatState.ComboCount, CombatState.ComboTimer, CombatState.UltimateCounter, HasCrit, EnemyStats, Crit, CombatState.SpecialBar)
					if PlayerStat.HighestDamage < newDamage then
						PlayerStat.HighestDamage = Floor(newDamage+.5)
					end
				end

				PlayerManager:UpdateCombatState(id, CombatState)
				return 0
			end
		end
	end
end

return module
