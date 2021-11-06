local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")

local EnemiesFolder = game.Workspace:WaitForChild("Enemies")
local Modules = script.Parent.Parent.Parent.Modules
local PlayerManager	= require(Modules.PlayerStatsObserver)
local Utilities	= require(ReplicatedStorage.Scripts.Modules.AIUtil)
local Sockets = require(Modules.Utility["server"])
local FS = require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local EffectFinder = require(Modules.Combat.EffectFinder)
local RegionModule = require(Modules.Utility["RegionModule"])
local DamageSystem = require(Modules.Combat["DamageSystem"])
local EnemyInfo = require(Modules.Combat.EnemyInfo)
local GameObjectHandler = require(script.Parent.GameObjectHandler)
local RewardAchievement	= require(script.Parent.RewardAchievement)

local tbi, tbr = table.insert, table.remove
local CF = CFrame.new
local Rand = Random.new()
local Floor = math.floor
local Vec3 = Vector3.new

local PlayerCollisionGroupName = "Players"



-------

function ObjectiveUpdate(Name)
	script.Parent.ServerData.ObjectiveUpdate:Fire(Name)
end

function FindPlayerTarget(tor)
	local NearestTorso,Proximity = nil, 1000
	
	for _, Plyr in ipairs(workspace.Players:GetChildren()) do
		if Plyr ~= nil and Plyr.PrimaryPart ~= nil and Plyr:FindFirstChild("Humanoid") and Plyr.Humanoid.Health > 1 then
			local Distance = (Plyr.PrimaryPart.Position - tor.Position).magnitude
			if Distance < Proximity and Plyr.Humanoid.Health > 0 then
				NearestTorso = Plyr.PrimaryPart
				Proximity = Distance
			end
		end
	end
	return NearestTorso
end

function setCollisionGroupRecursive(object)
	if object:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(object, PlayerCollisionGroupName)
	end
	for _, Part in ipairs(object:GetDescendants()) do
		if Part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(Part, PlayerCollisionGroupName)
		end
	end
end

return function (LVL, HPP, ATK, DEF, CRIT, CRITDEF, Armor, Weapon, Type, boss, BossModel)
	local Enemies = GameObjectHandler:GetEnemies()
	local GameData = GameObjectHandler:GameData()
	local Data = {}
	local IsBoss = boss or false
	local SpawnPoints;
	local En;
	local Torso;
	local Humanoid;
	local MainScript;
	Data.AgentRadius = 4
	Data.Height = nil
	
	if workspace.Map:FindFirstChild("Spawners") then
		SpawnPoints = workspace.Map.Spawners:GetChildren()
	else
		SpawnPoints = {}
		local FindRando = Players:GetPlayers() 
		for i = 1, #FindRando do
			if FindRando[i].TeamColor == Teams.InGame.TeamColor then
				if FindRando[i].Character and FindRando[i].Character.PrimaryPart then
					local NewPoint = {}
					NewPoint.CFrame = FindRando[i].Character.PrimaryPart.CFrame
					tbi(SpawnPoints, NewPoint)
				end
			end
		end
	end
	
	local Spawn = SpawnPoints[Rand:NextInteger(1,#SpawnPoints)]
	if BossModel == nil then
		En = game.ReplicatedStorage.EnemyType.EnemyMobPlaceholder:Clone()
		En.Parent = EnemiesFolder
		En:SetPrimaryPartCFrame(Type == "Melee" and Spawn.CFrame or Spawn.CFrame * CF(0,20,0))
		Torso = En.Torso
		Humanoid = Instance.new("Humanoid"); 
		Humanoid.Parent = En
		local HP = script.PlayerHP:Clone(); 
		HP.Parent = Torso
	else
		En = BossModel:Clone()
		MainScript = En["_Main"]
		MainScript["_CHARACTEROBJ(DONOTTOUCH)"].Value = En
		MainScript.Parent = game.ServerScriptService.BossScript
		local BehaviorTree = En:FindFirstChild("BehaviorTree")
		if BehaviorTree then
			BehaviorTree.Parent = MainScript
		end
		Torso = En.PrimaryPart
		Humanoid = En.Humanoid
		if Torso:FindFirstChildOfClass("BoolValue") == nil then
			IsBoss = true
		else
			En:SetPrimaryPartCFrame(Spawn.CFrame * CF(0,5,0))
			local HP = script.PlayerHP:Clone(); 
			HP.Parent = Torso
		end
	end
	
	if boss and BossModel == nil then ---legacy support for BossMan, keep only for him.
		IsBoss = true
		Data.AgentRadius = 9
		Data.AgentHeight = 15
		local Torso2 = Instance.new("Part"); Torso2.Name = "Torso"; Torso2.FrontSurface = "Hinge"; Torso2.Anchored = false; Torso2.CanCollide = false;
		Torso2.Transparency = 1
		Torso2.CollisionGroupId = 1
		Torso2.Size = game.ReplicatedStorage.EnemyType[Armor]:GetExtentsSize()
		Torso2.CFrame = Torso.CFrame*CF(0,game.ReplicatedStorage.EnemyType[Armor].PrimaryPart.Offset.Value.Y,0)
		Torso2.Parent = Torso
		local weld = Instance.new("Motor6D")
		weld.C0 = Torso.CFrame:inverse() * Torso2.CFrame
		weld.Part0 = Torso
		weld.Part1 = Torso2
		weld.Parent = Torso
	end

	if BossModel then
		if not table.find(GameData.EnemiesFound, BossModel.Name) then
			table.insert(GameData.EnemiesFound, BossModel.Name)
			local enemyInfo = EnemyInfo:GetEnemy(BossModel.Name)
			if enemyInfo then
				Sockets:Emit("EnemyUpdate", enemyInfo)
			end
		end
	end
	
	Data.Grabbed = nil
	Data.Dead = false
	Data.Torso = Torso
	Data.Model = Torso.Parent
	local WS = boss and 40 or 20
	Data.WalkspeedPerSecond = GameData.HeroMode and WS*1.25 or WS
	Data.Jump = false
	Data.IsMovingIndirect = false
	Data.IndirectMoveStart = tick()
	Data.AutoKill = tick()
	Data.Hand = "Left"
	local dice = Rand:NextNumber(1,5)
	if dice >= 4 then
		Data.Hand = "Right"
	end
	Data.CreatedPath = false
	Data.LastPositionTimeOut = 0
	Data.PathObject = nil ---used for new Pathfinding
	Data.Path = nil
	Data.BlockedConnection = nil
	Data.WayPointStep = 2
	Data.WayPointTimeOut = 0
	Data.Target = nil
	Data.Animation = "Standing"
	
	Data.Direction = ((Data.Torso.Size.Z*.5) + (Data.WalkspeedPerSecond/30))
	
	Data.Ally = false
	Data.Boss = IsBoss
	Data.Auto = BossModel and true or false
	Data.Configuration = {}
	Data.Configuration.ArmorModel = nil
	Data.Configuration.Name = nil
	if Data.Auto == false then
		Data.Configuration.ArmorModel = Armor.."Suit"
		Data.Configuration.Name = Armor
	else
		Data.Configuration.Name = En.Name
	end
	Data.Configuration.WeaponModel = nil
	Data.Configuration.Type = Type
	Data.Configuration.Effects = {}
	Data.Configuration.Atk = ATK
	Data.Configuration.Def = DEF
	Data.Configuration.Crit = CRIT
	Data.Configuration.CritDef = CRITDEF
	local Health = HPP
	local PlayerInGame = game.Players:GetPlayers()
	if GameData.EveryoneMustDie then
		local TotalHP = 0
		local PlayerStats = PlayerManager:FetchPlayerStats()
		for _, PlayerStat in pairs(PlayerStats) do
			TotalHP = TotalHP + Floor((PlayerStat.Characters[PlayerStat.CurrentClass].Damage*1.4)^2)
		end
		if TotalHP > 0 then
			if IsBoss then
				Health = Health + TotalHP
				tbi(Data.Configuration.Effects, "Undying")
			else
				Health = Health + TotalHP*.03
			end
		end
		tbi(Data.Configuration.Effects, "Voracity") ---Struck enemies take 60% of their MAX HP as bonus damage. Damage against these units deals a minimum of 14% of their MAX HP.
	end
	local Healthamnt = Health*#PlayerInGame
	if GameData.HeroMode then
		Healthamnt *= 1.25
	end
	Data.Configuration.MAXHP = IsBoss and Healthamnt  or Health
	Data.Configuration.HP = IsBoss and Healthamnt or Health
	Data.Configuration.Level = LVL
	Data.Configuration.Stunned = false
	Data.Configuration.CanAttack = tick()
	Data.Configuration.AttackCD = 0
	Data.Configuration.CurrentlyAttacking = false
	Data.Configuration.Hitboxing = false
	Data.Configuration.Animations = {}
	Data.Configuration.AnimationsLoaded = false
	
	if Type ~= "Flying" and IsBoss == false and BossModel == nil then 
		Data.Configuration.WeaponModel = Weapon.."Weapon"
	end
	if Data.Configuration.Type == "Melee" then
		for _, Animations in ipairs(ReplicatedStorage.Scripts.EnemyAnimations[Armor]:GetChildren()) do
			for _, Anims in ipairs(Animations:GetChildren()) do
				if Anims:IsA("Animation") then
					local Ani = script.AnimationController:LoadAnimation(Anims)
					local Anim = {}
					Anim.Name = Anims.Name
					Anim.Animation = Ani
					Anim.NextCombo = nil
					Data.Configuration.Animations[Anims.Name] = Anim
				end
			end
		end
	end
	
	if En:FindFirstChild("xSIXxAnimationSaves") then
		En["xSIXxAnimationSaves"]:Destroy()
	end
	
	if En:FindFirstChild("Ally") then
		Data.Ally = true
	end
	
	if En:FindFirstChild("Bindables") then
		FS.spawn(function()
			wait(3)
			if En:FindFirstChild("Bindables") then
				En.Bindables.Initialize:Fire(Data.Configuration.MAXHP)
			end
		end)
		if En.Bindables:FindFirstChild("Dialogue") then
			En.Bindables.Dialogue.Event:Connect(function(Msg, CharacterName)
				Sockets:Emit("Dialogue", Msg, CharacterName)
			end)
		end
		if En.Bindables:FindFirstChild("ObjectiveUpdate") then
			En.Bindables.ObjectiveCheck.OnInvoke = function()
				return GameData.DungeonMsg
			end
			En.Bindables.ObjectiveUpdate.Event:Connect(function(ObjectiveName, Options)
				if ObjectiveName == "ALLYCHANGE" then
					if Data.Ally then
						Data.Ally = false
					else
						Data.Ally = true
					end
				elseif ObjectiveName == "WARNINGLABEL" then
					Sockets:Emit("EnemyStatus", Data, "Spawn")
					Sockets:Emit("Warning", Options[1], Options[2])
				else
					ObjectiveUpdate(ObjectiveName)
				end
			end)
		end
		En.Humanoid.Died:Connect(function()
			Data.Died("None", 9999)
		end)
		En.Bindables.Heal.Event:Connect(function(amnt)
			Data.Configuration.HP = Data.Configuration.HP + amnt
			if Data.Configuration.HP >= Data.Configuration.MAXHP then
				Data.Configuration.HP = Data.Configuration.MAXHP
			end
			Sockets:Emit("EnemyStatus", Data, "BossHP", Data.Configuration.HP)
		end)
		local onSuccessFulDamage = En.Bindables:FindFirstChild("OnSuccessfulDamage")
		En.Bindables.Damage.Event:Connect(function(Target, damageScale, IsLaser)
			local result = Data.Damage(nil, nil, nil, nil, Target, damageScale, IsLaser)
			if result == 0 and onSuccessFulDamage then
				onSuccessFulDamage:Fire(result, Target)
			end
		end)
		En.Bindables.ShootBullet.Event:Connect(function(OrigPos, TargPos, OrigCF, MaxTick, Speed, damageScale)
			Data.ShootBullet(OrigPos, TargPos, OrigCF, MaxTick, Speed, damageScale)
		end)
		En.Bindables.Effect.Event:Connect(function(Nam, Desc, Mode)
			local Remove = Mode and Mode or false
			if Remove then
				for i = 1, #Data.Configuration.Effects do
					if Data.Configuration.Effects[i] == Nam then
						tbr(Data.Configuration.Effects, i)
					end
				end
			else
				tbi(Data.Configuration.Effects, Nam)
			end
		end)
		En.Bindables.MusicChange.Event:Connect(function(Nam, Settings)
			local FDO = Settings and Settings.FDO
			local FDI = Settings and Settings.FDI
			Sockets:Emit("MusicChange", "Play", Nam, FDO, FDI)
		end)
		En.Bindables.Parried.PlayerParry.Event:Connect(function(PlyTarg, AnimObj)
			local NewAnimObj = AnimObj:Clone()
			NewAnimObj.Parent = ReplicatedStorage
			Debris:AddItem(NewAnimObj, 15)
			local Effect = EffectFinder:CreateEffect("Invincibility", 7, PlyTarg.Character)
			local CombatState = PlayerManager:GetCombatState(PlyTarg.UserId)
			tbi(CombatState.StatusEffects, Effect)
			PlayerManager:UpdateCombatState(PlyTarg.UserId, CombatState)
			Sockets:GetSocket(PlyTarg):Emit("ParryAnimation", En, NewAnimObj)
		end)
		En.Bindables.DamageSelf.Event:Connect(function(HPAmnt)
			local Damage = Data.Configuration.MAXHP * HPAmnt
			if Data.Configuration.HP > Damage then
				Data.Configuration.HP = Data.Configuration.HP - Damage
			else
				Data.Configuration.HP = 1
			end
			Sockets:Emit("EnemyStatus", Data, "BossHP", Data.Configuration.HP)
		end)
		En.Bindables.GetEffects.OnInvoke = function()
			return Data.Configuration.Effects
		end
	end
	
	Data.KnockupTimer = 0
	Data.KnockbackTimer = 0
	Data.OrigCFrame = nil
	
	Data.Damage = function(center, cf, size, IsProj, Targ, dScale, IsLaser)
		local Region, parts, HitTargets;
		local center 		= center or Data.Torso.CFrame
		local CF 			= cf or CF(0, 0.2, -4)
		local BoxSize 		= size or Vec3(4, 6, 5)
		if Targ == nil then
			Region 		= RegionModule.new(center*CF, BoxSize)
			parts 		= Region:Cast({workspace.Enemies, workspace.DeadEnemies})
		else
			parts = {}
			tbi(parts, Targ.PrimaryPart)
		end
		HitTargets 	= {}
		local dmgScale = dScale or 1
		for i = 1, #parts do
			local Target = nil
			if parts[i]:FindFirstChild("Humanoid") then
				Target = parts[i]
			else
				Target = parts[i].Parent
			end
			if Target and Target:FindFirstChild("Humanoid") and Target:FindFirstChild("Torso") == nil then
				local FoundHumanoid = false
				for c = 1,#HitTargets do
					if HitTargets[c] == Target then
						FoundHumanoid = true
						break
					end
				end
				if not FoundHumanoid then
					tbi(HitTargets,Target)
					local dmg = Data.Configuration.Atk
					local PotentialPlayer = Players:GetPlayerFromCharacter(Target)
					if PotentialPlayer then
						
						local EnemyProperties = {
							IsProj = IsProj,
							Targ = Target,
							dmgScale = dmgScale,
							IsLaser = IsLaser
						}
					
						local result = DamageSystem:DamageMode(GameData, nil, Data, Enemies, EnemyProperties, Target)
						return result
					else
						if Target.Bindables:FindFirstChild("Stats") then
							local Def = Target.Bindables.Stats.DEF.Value
							local newdamage = Data.Configuration.Atk - Def
							if newdamage < 1 then
								newdamage = 1
							end
							if Target.Bindables.Stats:FindFirstChild("GotDamaged") then
								Target.Bindables.Stats.GotDamaged:Fire(newdamage)
							else
								Target.Humanoid:TakeDamage(newdamage)
							end
						end
					end
				end
			end
		end
	end	
	
	Data.ShootBullet = function(RootPartPosition, TargetPosition, ReservedCF, MaxTick, Speed, damageScale)
		if Data.Dead == false then
			local Bullet = {}
			Bullet.Size = Vec3(2,2,2)
			Bullet.CFrame = ReservedCF and ReservedCF or CF(RootPartPosition, TargetPosition) * CF(0, 0, -5)
			Bullet.Tick = 0
			Bullet.MaxTick = MaxTick and MaxTick or 300
			Bullet.ID = HttpService:GenerateGUID()
			Bullet.Speed = Speed and -Speed or -0.4
			Bullet.DamageScale = damageScale and damageScale or 1
			tbi(Data.Configuration.Animations, Bullet)
			Sockets:Emit("EnemyAnimate", Data, "MakeBullet", Bullet)
		end
	end
	
	Data.Animate = function(Animation, cf, size)
		if Data.Auto == false then
			if Data.Animation ~= Animation and Data.Configuration.Stunned == false then
				if Animation ~= "Shoot" then
					Data.Animation = Animation
				end
				Sockets:Emit("EnemyAnimate", Data, Animation)
			end
			if Animation == "Attack" then
				if Data.Configuration.Type == "Melee" then
					if not Data.Configuration.CurrentlyAttacking and Data.Configuration.AttackCD < 1 then
						Data.Animation = Animation
						Data.Configuration.Stunned = true
						Sockets:Emit("EnemyAnimate", Data, Animation, tick())
						Data.Configuration.AttackCD = 200
						Data.Configuration.CanAttack = tick()
						Data.Configuration.Hitboxing = true
					end
					
					local PotentialMoves = Data.Configuration.Animations
					local Slash = Data.Configuration.Animations["X1"]
					local SlashBegin;
					FS.spawn(function()
						SlashBegin = Slash.Animation.Length*Slash.Animation:GetTimeOfKeyframe("SlashBegin1")
						if tick()-Data.Configuration.CanAttack >= SlashBegin and not Data.Configuration.CurrentlyAttacking then
							Data.Configuration.CurrentlyAttacking = true
							Data.Damage(nil, cf, Data.Boss and Vec3(13,10,13) or size )
							Data.Configuration.Hitboxing = false
						end
						if tick()-Data.Configuration.CanAttack >= Slash.Animation.Length then
							Data.Configuration.CanAttack = tick()+3
							Data.Configuration.Stunned = false
						end
					end)
				else
					if not Data.Configuration.CurrentlyAttacking and Data.Configuration.AttackCD < 1 then
						Data.Animation = Animation
						Data.Configuration.Stunned = true
						Data.Configuration.CanAttack = tick()
						Data.Configuration.CurrentlyAttacking = true
						if #Data.Configuration.Animations < 10 then
							Data.Configuration.AttackCD = 60
							Data.ShootBullet(Torso.Position, Data.Target.Position)
						else
							Data.Configuration.AttackCD = 750
							Data.Configuration.Stunned = true
						end
					end
					if tick()-Data.Configuration.CanAttack >= 2 then
						Data.Configuration.CanAttack = tick()+3
						Data.Configuration.Stunned = false
					end
				end
			end
		end
	end
	Data.getStat = function(stat)
		return Data.Configuration[stat]
	end
	Data.Died = function(Name, OK)
		if Data.Dead == false then
			for i = 1, #Enemies do
				if Enemies[i].Torso == Data.Torso then
					if Data.Auto and Name and OK then
						if Players:FindFirstChild(Name) and Players[Name].Character then
							local Enemy = Data.Torso.Parent
							local KilledByChar = Players[Name].Character
							local KnockbackDist = (200*(1+(OK/Data.Configuration.MAXHP))) < 4500 and 200*(1+(OK/Data.Configuration.MAXHP)) or 4500
							local CoEfficient = KnockbackDist * 0.3
							Enemy.HumanoidRootPart.Velocity = -(KilledByChar.HumanoidRootPart.Position - Enemy.HumanoidRootPart.Position).Unit * CoEfficient + Vector3.new(0,3,0)
						end
					end
					Sockets:Emit("EnemyStatus", Data, "Died", Name, OK)
					Data.Dead = true
					Data.Grabbed = nil
					local PlayerAmnt = #Players:GetPlayers()
					local EXPAmount = 0
					if GameData.HeroMode or GameData.EveryoneMustDie then 
						EXPAmount = Data.Configuration.Level*(.05+(PlayerAmnt*((Data.Auto and Data.Torso:FindFirstChildOfClass("BoolValue") == nil) and .05 or .01)))
					else
						EXPAmount = 5
						if Data.Configuration.Level >= 50 then
							EXPAmount = EXPAmount + Data.Configuration.Level * .01
						end
					end
					if ((Data.Auto and Data.Torso:FindFirstChildOfClass("BoolValue") == nil) or Data.Boss) and GameData.TeamHP >= 10 then
						for _, plyr in ipairs(Players:GetPlayers()) do
							local id = plyr.UserId
							local PlayerStat = PlayerManager:GetPlayerStat(id)
							RewardAchievement({29, 30, 31, 32, 33, 34, 35, 36, 37}, id)
							PlayerStat.BossesKilled = PlayerStat.BossesKilled + 1
						end
						if GameData.HeroMode or GameData.EveryoneMustDie then 
							EXPAmount = EXPAmount * 10
						else
							EXPAmount = EXPAmount * 3
						end
						GameData.TeamHP = GameData.TeamHP + 50
						script.Parent.Parent.Bindables.AddLobbyTime:Fire(220)
						local NotFound = true
						for _,Other in ipairs(Enemies) do
							if Other.Torso and ((Other.Auto and Other.Torso:FindFirstChildOfClass("BoolValue") == nil) or Other.Boss) then
								if Other.Torso ~= Data.Torso then
									NotFound = false
									break
								end
							end
						end
						if NotFound then
							Sockets:Emit("MusicChange", "Play", GameData~=nil and GameData.CurrentMap.MapName .. "Music")
						end
					end
					GameData.BaseXP = GameData.BaseXP + EXPAmount
					GameData.TeamHP = GameData.TeamHP + 1
					if GameData.TeamHP >= GameData.MAXTeamHP then
						GameData.TeamHP = GameData.MAXTeamHP
					end
					script.Parent.Parent.Bindables.AddLobbyTime:Fire(10)
					local Found = nil
					if Data.Torso then
						Found = Data.Torso:FindFirstChildOfClass("BoolValue")
						if Data.Torso:FindFirstChild("TriggerRemote") then
							Data.Torso.TriggerRemote:Fire()
						end
					end
					if (Data.Auto == false or Found ~= nil) then
						Data.Torso.PlayerHP:Destroy()
						if Found == nil then
							Data.Torso.Parent.Humanoid:Destroy()
						else
							FS.spawn(function()
								if Data.Torso ~= nil and Data.Torso.Parent then
									if Data.Torso.Parent:FindFirstChild("Bindables") then
										Data.Torso.Parent.Bindables.Died:Fire()
									end
								end
							end)
						end
						if Data.PathObject then
							Data.PathObject:Destroy()
							Data.PathObject = nil
						end
						Data.Path = nil
						if Data.BlockedConnection ~= nil then
							Data.BlockedConnection:Disconnect()
							Data.BlockedConnection = nil
						end
					else
						FS.spawn(function()
							if Data.Model ~= nil then
								if Data.Model:FindFirstChild("Bindables") then
									Data.Model.Bindables.Died:Fire()
								end
							end
						end)
					end
					if Data.Configuration.Type == "Flying" or Data.Configuration.Type == "Shooting" or Data.Auto then
						local bulls = {}
						for v= 1, #Data.Configuration.Animations do
							local Bullet = Data.Configuration.Animations[v]
							tbi(bulls, Bullet)
						end
						Sockets:Emit("EnemyAnimate", nil, "RemoveBullets", bulls)
					end
					if Data.Torso and Data.Torso.Parent then
						Data.Torso.Parent.Parent = workspace.DeadEnemies
						Debris:AddItem(Data.Torso.Parent, 30)
					end
					tbr(Enemies, i)
					break
				end
			end
		end
	end
	Data.Blowback = false
	Data.ThrowAngle = math.rad(45)
	Data.grav = 150
	Data.Target_Dist = 0
	Data.Proj_Vel = 0
	Data.Vx = 0
	Data.Vy = 0
	Data.FlightDur = 0
	Data.elapsed = 0
	Data.Lander = Vector3.new()
	Data.Knockback = function(val, blowback)
		if Data.Boss == false and Data.Auto == false then
			if blowback == nil then
				if tick()-Data.KnockupTimer <=2 then
					if val == 1 then
						Data.KnockupTimer = tick()+2.1
						
						Torso.Parent:SetPrimaryPartCFrame(Data.OrigCFrame)
						Data.OrigCFrame = nil
					else
						Data.KnockupTimer = tick()
						local Hit, Position, Surface = Utilities:Raycast(Torso.Position, Vec3(0, (Torso.Size.Y * .2), 0), {EnemiesFolder}, false, 1 , false, true)
						if Hit == nil then
							Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CF(0, .2, 0))
						end
					end
				end
				if tick()-Data.KnockupTimer > 2 or val == 1 then
					local Distance = (val == 1 and 20 or 6)
					local D = ((Torso.Size.Z*.5) + (Distance))
					local Hit, Position, Surface = Utilities:Raycast(Torso.Position, -(Torso.CFrame.lookVector * D), {EnemiesFolder}, false, 1 , false, true)
					if Hit == nil then
						Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CF(0, 0, Distance*.5))
					end
					Sockets:Emit("EnemyAnimate", Data, "KnockedBack", val)
					Data.Configuration.AttackCD = 200
					Data.Configuration.CanAttack = tick()+1
				end
			else
				--Torso.CFrame = Initial.CFrame
				if Data.Configuration.Type ~= "Flying" then
					local DirectionProjectedY = blowback:Dot(Vec3(0,1,0))
					local NewDirection = (blowback-(Vec3(0,1,0)*DirectionProjectedY)).unit
					Data.Lander = Torso.Position + -(NewDirection)*50
					Data.Target_Dist = (Torso.Position - Data.Lander).magnitude
					Data.Proj_Vel = Data.Target_Dist / (math.sin(2 * Data.ThrowAngle) / Data.grav)
					Data.Vx = math.sqrt(Data.Proj_Vel) * math.cos(Data.ThrowAngle)
					Data.Vy = math.sqrt(Data.Proj_Vel) * math.sin(Data.ThrowAngle)
					Data.FlightDur = Data.Target_Dist / Data.Vx
					local Dir = CF(Torso.Position, Data.Lander)
					Torso.Parent:SetPrimaryPartCFrame(Dir)
					Data.elapsed = 0
					Data.Configuration.AttackCD = 200
					Data.Configuration.CanAttack = tick()+1
					Data.Blowback = true
					local Dir2 = CF(Torso.Position, Data.Lander)
					Torso.Parent:SetPrimaryPartCFrame(Dir2)
				end
			end
		end
	end
	Data.Knockup = function()
		if Data.Auto == false then
			if Data.Configuration.Type == "Melee" then
				Data.KnockupTimer = tick()
				Data.OrigCFrame = Torso.CFrame
				local Hit, Position, Surface = Utilities:Raycast(Torso.Position, Vec3(0, (Torso.Size.Y * 7), 0), {EnemiesFolder}, false, 1 , false, true)
				if Hit == nil then
					Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CF(0, 6.5, 0))
				end
			end
		end
	end
	Data.CommitPhysics = function(ply, delTime, bodyVelocityDirection, bodyAngular, bodyPosition)
		if Data.Torso and Data.Auto == false and Data.Torso.Parent.Hurtbox and Data.Boss == false then
			if tick()-Data.KnockupTimer < 5 then
				Data.KnockupTimer = Data.KnockupTimer + delTime
			else
				Data.KnockupTimer = tick()+(delTime+5.2)
			end
			Data.Torso.Anchored = false
			Data.Torso.Parent.Hurtbox.Anchored = false
			Data.Torso:SetNetworkOwner(ply)
			Data.Torso.Parent.Hurtbox:SetNetworkOwner(ply)
			FS.spawn(function()
				while not Data.Dead and Data.Torso.Parent ~= nil and Data.Torso.Anchored == false do
					delay(delTime+5, function()
						if not Data.Dead and Data.Torso ~= nil and tick()-Data.KnockupTimer > 5 then
							if Data.Torso.Anchored == false and Data.Torso.Parent.Hurtbox.Anchored == false then
								Data.Torso:SetNetworkOwner(nil)
								Data.Torso.Parent.Hurtbox:SetNetworkOwner(nil)
							end
							Data.Torso.Anchored = true
							Data.Torso.Parent.Hurtbox.Anchored = true
							local Pos = CF(Torso.Position)
							Data.Torso.Parent:SetPrimaryPartCFrame(CF(Torso.CFrame.X, Pos.Y, Torso.CFrame.Z))
						end
					end)
					wait(delTime)
				end
			end)	
			if bodyVelocityDirection then
				local OldBV = Data.Torso:FindFirstChildOfClass("BodyVelocity")
				if OldBV then
					OldBV:Destroy()
				end
				local bV = Instance.new("BodyVelocity")
				bV.MaxForce = Vector3.new(9999999999999, 9999999999999, 9999999999999)
				bV.P = 9999999999
				bV.Velocity = bodyVelocityDirection
				bV.Parent = Data.Torso
				Debris:AddItem(bV, delTime)
			end
			if bodyAngular then
				local OldBV = Data.Torso:FindFirstChildOfClass("BodyAngularVelocity")
				if OldBV then
					OldBV:Destroy()
				end
				local bAV = Instance.new("BodyAngularVelocity")
				bAV.MaxTorque = Vector3.new(999999, 999999, 999999)
				bAV.P = math.huge
				bAV.AngularVelocity = bodyAngular
				bAV.Parent = Data.Torso
				Debris:AddItem(bAV, delTime)
			end
			if bodyPosition then
				local OldBV = Data.Torso:FindFirstChildOfClass("BodyPosition")
				if OldBV then
					OldBV:Destroy()
				end
				local bP = Instance.new("BodyPosition")
				bP.MaxForce = Vector3.new(9999999999999, 9999999999999, 9999999999999)
				bP.D = 99999
				bP.P = 9999999999
				bP.Position = bodyPosition
				bP.Parent = Data.Torso
				game.Debris:AddItem(bP, delTime)
			end
		end
	end
	Data.FindNewTarget = function(Ran)
		if Data.Auto == false and Data.Dead == false then
			Data.Jump = false
			Data.Target = FindPlayerTarget(Torso)
			Data.CreatedPath = false
			if Data.Target then
				if Data.PathObject == nil then
					if Data.AgentRadius ~= nil or Data.AgentHeight ~= nil then
						Data.PathObject = PathfindingService:CreatePath({AgentRadius = (Data.AgentRadius and Data.AgentRadius or 2), AgentHeight = (Data.AgentHeight and Data.AgentHeight or 5)})
					else
						Data.PathObject = PathfindingService:CreatePath()
					end
				end
				FS.spawn(function()
					if Data.PathObject and Data.Torso and Data.Target then
						Data.PathObject:ComputeAsync(Data.Torso.Position, Data.Target.Position)
						if Data.PathObject and Data.PathObject.Status == Enum.PathStatus.Success then
							Data.Path = Data.PathObject:GetWaypoints()
							Data.WayPointStep = 1
							if Data.BlockedConnection == nil then
								Data.BlockedConnection = Data.PathObject.Blocked:Connect(function(BlockedIndex)
									if BlockedIndex > Data.WayPointStep then
										Data.CreatedPath = false
										Data.Path = nil
										Data.WayPointStep = 1
										if Data.BlockedConnection then
											Data.BlockedConnection:Disconnect()
											Data.BlockedConnection = nil
										end
										Data.FindNewTarget()
									end
								end)
							end
							Data.CreatedPath = true
						else
							Data.Path = nil
							Data.CreatedPath = false
						end
					end
				end)
			end
		end
	end
	
	if BossModel then
		En.PrimaryPart.Anchored = true
		En:SetPrimaryPartCFrame(En.PrimaryPart.CFrame * CFrame.new(0, -500, 0))
		En.Parent = EnemiesFolder
		setCollisionGroupRecursive(En)
		MainScript.Disabled = false
	end
	
	return Data
end
