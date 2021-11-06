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

local SoloTest = script.Parent.Values.DEBUG_VARIABLES.SoloTest.Value
local IsPVPTest	= script.Parent.Values.DEBUG_VARIABLES.IsPVPTest.Value
local CanSave = script.Parent.Values.DEBUG_VARIABLES.CanSave.Value

local Visualize = false
local ReservedServer = false
local StormStarted = false
local SoloPlace = false --- Not to be confused with SoloTest
local Difficulty = nil
local PVP = nil --- Is a table if not nil
local Map = nil
local FirstReady = nil
local LobbyTimer = GlobalThings.GlobalLobbyTimer

local PlayerCollisionGroupName = "Players"

----- START OF GAME LOGIC LOOP

local BadgeService					= game:GetService("BadgeService")
local CollectionService				= game:GetService("CollectionService")
local DataStoreService 				= game:GetService("DataStoreService")
local Debris						= game:GetService("Debris")
local GamePassService				= game:GetService("GamePassService")
local HttpService 					= game:GetService("HttpService")
local MessagingService				= game:GetService("MessagingService")
local Players 						= game:GetService("Players")
local PathfindingService 			= game:GetService("PathfindingService")
local PhysicsService 				= game:GetService("PhysicsService")
local ReplicatedStorage 			= game:GetService("ReplicatedStorage")
local ScriptContext					= game:GetService("ScriptContext")
local ServerStorage 				= game:GetService("ServerStorage")
local Teams 						= game:GetService("Teams")
local TeleportService				= game:GetService("TeleportService")
local TextService					= game:GetService("TextService")
local TweenService					= game:GetService("TweenService")
local RunService 					= game:GetService("RunService")
local StarterGui 					= game:GetService("StarterGui")
local ServerScriptService 			= game:GetService("ServerScriptService")

local Modules 						= script.Parent.Parent.Modules
local FS							= require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local PlayerManager					= require(Modules.PlayerStatsObserver)
local PVPManager					= require(Modules.Combat.PVPManager)
local Sockets 						= require(Modules.Utility["server"])
local MatchMaking					= require(Modules.Systems["Matchmaking"])
local TerrainSaveLoad				= require(Modules.Utility["TerrainSaveLoad"])
local Utilities						= require(ReplicatedStorage.Scripts.Modules.AIUtil)
local EffectFinder					= require(Modules.Combat.EffectFinder)
local LootInfo 						= require(Modules.CharacterManagement["LootInfo"])
local Achievements					= require(Modules.Systems["Achievements"])
local Vestiges						= require(Modules.Systems.Vestiges)
local WeaponCraft					= require(Modules.CharacterManagement["WeaponCrafting"])
local CheckGamePass					= require(script.Parent.SharedModules.CheckGamePass)
local RegionModule					= require(Modules.Utility["RegionModule"])
local DamageSystem					= require(Modules.Combat["DamageSystem"])
local GameObjectHandler				= require(script.Parent.SharedModules.GameObjectHandler)
local RewardAchievement				= require(script.Parent.SharedModules.RewardAchievement)
local CreateEnemy					= require(script.Parent.SharedModules.CreateEnemy)
local zonePlus 						= require(4664437268)
local zoneService 					= require(zonePlus.ZoneService)
local ChatService 					= require(ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)

local EnemiesFolder 				= game.Workspace:WaitForChild("Enemies"); EnemiesFolder:ClearAllChildren()

local Enemies						= GameObjectHandler:GetEnemies()
local Bullets						= {}
local TeleportQueues				= {}
local PlayersNeedReviving			= {}

local tbi, tbr = table.insert, table.remove
local Rad = math.rad
local UDi = UDim2.new
local CFA = CFrame.Angles
local CF = CFrame.new
local Vec3 = Vector3.new
local Floor = math.floor
local Rand = Random.new()

----- FUNCTIONS

local function format_int(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

local function setCollisionGroupRecursive(object)
	if object:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(object, PlayerCollisionGroupName)
	end
	for _, Part in ipairs(object:GetDescendants()) do
		if Part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(Part, PlayerCollisionGroupName)
		end
	end
end

local function toClock(seconds, bol)
	if seconds <= 0 then
		return "00:00"
	else
		--local days = seconds/86400
		local hours 	= string.format("%02.f", Floor(seconds/3600))
		local mins 		= string.format("%02.f", Floor(seconds/60 - (hours*60)))
		local secs 		= string.format("%02.f", Floor(seconds - hours*3600 - mins *60));
		if bol then
			return mins.. ":" .. secs
		end
		return hours..":"..mins
	end
end

local function NewCostume(name)
	local Suit = {}
	Suit.Name = name
	return Suit
end

local function forceSaveAll() 
	script.Parent.Bindables.ForceSaveAll:Fire()
end

local function saveData(id, Player)
	return script.Parent.Bindables.SaveDataOfPlayer:Invoke(id, Player)
end

function ObjectiveUpdate(ObjectiveName)
	local GameData = GameObjectHandler:GameData()
	if GameData then
		local Found = false
		for v = 1, #GameData.Objectives do
			for i = 1, #GameData.CurrentMap.TypeProperties.Objectives do
				if ObjectiveName == GameData.Objectives[v][1] and GameData.Objectives[v][1] == GameData.CurrentMap.TypeProperties.Objectives[i][1] then
					if GameData.Objectives[v][2] < GameData.CurrentMap.TypeProperties.Objectives[i][2] then
						GameData.Objectives[v][2] = GameData.Objectives[v][2] + 1
						Found = true
						break
					end
				end
			end
			if Found then break end
		end
	end
end

script.Parent.Bindables.ObjectiveUpdate.Event:Connect(function(Name)
	ObjectiveUpdate(Name)
end)

script.Parent.Bindables.AddPVPTable.Event:Connect(function(PVPTable)
	PVP = PVPTable
end)

script.Parent.Bindables.SelectMapPrefix.Event:Connect(function(Mapper)
	Map = Mapper
end)

script.Parent.Bindables.PlayerDown.Event:Connect(function(PlayerObject)
	for _, PlyrsDown in ipairs(PlayersNeedReviving) do
		if PlyrsDown.Player == PlayerObject then
			return
		end
	end
	local Plyr = {}
	Plyr.HP = 100
	Plyr.Player = PlayerObject
	tbi(PlayersNeedReviving, Plyr)
end)

script.Parent.Bindables.AddLobbyTime.Event:Connect(function(Time)
	LobbyTimer = LobbyTimer + Time
end)





-----

if (game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0) or SoloTest then
	ReservedServer = true
	ReplicatedStorage.SERVER_STATS.IsPrivateServer.Value = true
	if SoloTest then
		TerrainSaveLoad:Load(ReplicatedStorage.Environments.Terrains.TrainStation)
		if IsPVPTest then
			PVP = {RedTeam = {"Player1", "Player3"}, BlueTeam = {"Player2"}}
		end
	end
end

if game.PlaceId == 785484984 or game.PlaceId == 563493615 then
	ReservedServer = true
end

local GameLogic = {}

function GameLogic:Difficulty_Change(Diffic)
	Difficulty = Diffic
end

function GameLogic:Game_Start()	
	if ReservedServer and (Map ~= nil or SoloTest) then	
		
		--[[ Gameplay Init ]]--
	
		while wait(1) do
			local AmountAvailable = 0
			for _,ply in ipairs(Players:GetPlayers()) do
				local PlayerStat = PlayerManager:GetPlayerStat(ply.UserId)
				if PlayerStat then
					AmountAvailable = AmountAvailable + 1
				end
			end
			
			local GameData = nil
			while AmountAvailable > 0 and not SoloPlace do
				--[[
					Intermission Sequence
				--]]
				
				local ReadyButton = ServerStorage.Models.Misc.ReadyButton:Clone()
				local canUse = true
				ReadyButton.Parent = workspace
				ReadyButton.Touch.Touched:Connect(function(hit)
					if not canUse then return end

					local Plyr = game.Players:GetPlayerFromCharacter(hit.Parent)
					if hit.Parent and Plyr then
						if not workspace:FindFirstChild("Map") then
							local CombatState = PlayerManager:GetCombatState(Plyr.UserId)
							local PlayerStat = PlayerManager:GetPlayerStat(Plyr.UserId)
							CombatState.Ready = true
							PlayerManager:UpdateCombatState(Plyr.UserId, CombatState)
							if ReadyButton.Billboard.Menu.Frame1.Frame:FindFirstChild(hit.Parent.Name) == nil then
								local Namer = ReadyButton.Billboard.Menu.Frame1.Namer:Clone()
								Namer.Name = hit.Parent.Name
								Namer.Text = hit.Parent.Name
								Namer.Visible = true
								Namer.Parent = ReadyButton.Billboard.Menu.Frame1.Frame
							end
							if FirstReady == nil then
								FirstReady = Plyr
								Sockets:Emit("Banner", "First to Ready" , PlayerStat.ProfileBackground, Plyr.Name.. " - Lv" ..PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel)
							end
						else
							if GameData.TeamHP >= 100 then
								canUse = false
								Plyr.TeamColor = Teams.InGame.TeamColor
								Plyr:LoadCharacter()
								wait(1)
								canUse = true
							else
								Sockets:GetSocket(Plyr):Emit("Hint", string.format("Unable to spawn: requires %s more Life Force to spawn.", 100 - GameData.TeamHP))
								Sockets:GetSocket(Plyr):Emit("Hint", "Life Force regenerates over time and when enemies are defeated.")
							end
						end
					end
				end)
				
				LobbyTimer = GlobalThings.GlobalLobbyTimer
				while LobbyTimer > 0 do
					LobbyTimer = LobbyTimer - 1
					local Ready = 0
					local CombatStates = PlayerManager:FetchCombatStates()
					for _,states in pairs(CombatStates) do
						if states.Ready then
							Ready = Ready + 1
						end
					end
					if (Ready == #Players:GetPlayers() and LobbyTimer > 5) then
						LobbyTimer = 5
						Sockets:Emit("SendMessage", nil, nil, "The match is starting soon!", true)
					end
					if Ready > 0 then
						ReadyButton.Billboard.Menu.Frame1.Subtitle1.Text = "STARTING IN " ..LobbyTimer
					else
						ReadyButton.Billboard.Menu.Frame1.Subtitle1.Text = "TOUCH TO READY UP"
						LobbyTimer = GlobalThings.GlobalLobbyTimer
						FirstReady = nil
					end
					wait(1)
				end
				canUse = false
				ReadyButton.Billboard.Menu.Frame1.Subtitle1.Text = "TOUCH TO SPAWN IN"
				
				GameObjectHandler:CreateGameData()
				GameData = GameObjectHandler:GameData()
				if Difficulty == "EveryoneMustDie" then
					GameData.HeroMode = true
					GameData.EveryoneMustDie = true
					GameData.MAXTeamHP = 100
					GameData.TeamHP = 100
				else
					GameData.HeroMode = Difficulty
					GameData.EveryoneMustDie = false
					if GameData.HeroMode then
						GameData.MAXTeamHP = 300
						GameData.TeamHP = 300
					end
				end
				
				if SoloTest then
					if IsPVPTest then
						Map = MatchMaking:GetMap("Arena: Colosseum")
					else
						----"The Heart of Atlas: Compendium" ---"City Roads: The Streets are Silent" ----"High Vigils: Mysterious Distress Signal", "Riukaya-Hara: A Journey's Start"
						Map = MatchMaking:GetMap("High Vigils: Mysterious Distress Signal") 
						GameData.HeroMode = false
						GameData.EveryoneMustDie = false
					end
				end
				
				local psuedoMap = MatchMaking:GetMap(Map.MissionName)
				GameData.CurrentMap = psuedoMap
				GameData.CurrentRunLogic = psuedoMap.runLogic and require(psuedoMap.runLogic)

				if not PVP and GameData.CurrentMap.TypeProperties.Type == "Dungeon" then
					for _, Objective in ipairs(GameData.CurrentMap.TypeProperties.Objectives) do
						local NewValue = {}
						tbi(NewValue, Objective[1])
						tbi(NewValue, 0)
						tbi(GameData.Objectives, NewValue)
					end
				end
				local Map = workspace:FindFirstChild(GameData.CurrentMap.MapName) or ServerStorage.Environments.Maps[GameData.CurrentMap.MapName]:Clone()
				Map.Name = "Map"
				local function GetUnCancollide(Model)
					for _, Part in ipairs(Model:GetChildren()) do
						if Part:IsA("BasePart") and not Part.CanCollide then
							Part.Parent = workspace.DeadEnemies
						elseif Part:IsA("Model") and Part.Name ~= "Spawners" and Part.Name ~= "Ragdoll" and string.find(string.lower(Part.Name), "entrance") == nil then
							GetUnCancollide(Part)
						end
					end
				end

				if Map.Terrain:FindFirstChild("Terrain") then
					TerrainSaveLoad:Load(Map.Terrain.Terrain)
				end
				Map.Parent = workspace
				
				--[[
					Round Setup Sequence
				--]]
				LobbyTimer = PVP and 150 or 600
				
				if PVP then
					PVPManager:CreatePVPTags()
					Sockets:Emit("Warning", true)
				end
				
				print("Starting Game")
				
				wait(2)

				for _,ply in ipairs(Players:GetPlayers()) do
					if PVP then
						if table.find(PVP.RedTeam, ply.Name) then
							CollectionService:AddTag(ply, "RedTeam")
							ply.TeamColor = Teams.Team1.TeamColor
						else
							CollectionService:AddTag(ply, "BlueTeam")
							ply.TeamColor = Teams.Team2.TeamColor
						end
						ply:LoadCharacter()
					else
						local CombatState = PlayerManager:GetCombatState(ply.UserId)
						if CombatState then
							if CombatState.Ready then
								ply.TeamColor = Teams.InGame.TeamColor
								FS.spawn(function()
									--Sockets:GetSocket(ply):Emit("BattleModeON", GameData.CurrentMap.MapName.."Music")
									if game.PlaceId ~= 785484984 and game.PlaceId ~= 563493615 then ---- Main Places
										ply:LoadCharacter()
									else
										LobbyTimer = 99999
									end
								end)
								CombatState.Ready = false
								PlayerManager:UpdateCombatState(ply.UserId, CombatState)
							end
						end
					end
				end
				local AvgLevel 	= 99999
				AmountAvailable = 0
				for _,ply in ipairs(Players:GetPlayers()) do
					local PlayerStat = PlayerManager:GetPlayerStat(ply.UserId)
					if PlayerStat then
						local id = ply.UserId
						local currentLvl = PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel
						if ply.Character:FindFirstChild("Level") then
							ply.Character.Level.Value = currentLvl
						end
						if currentLvl < AvgLevel then
							AvgLevel = currentLvl
						end
						AmountAvailable = AmountAvailable + 1
					end
				end
				if not PVP then
					GameData.DungeonLevel = AvgLevel --Floor((AvgLevel/AmountAvailable)+.5)
					GameData.MaxEnemies = AmountAvailable*GameData.CurrentMap.TypeProperties.StartingEnemies
					GameData.EnemiesToSpawn = GameData.MaxEnemies
					GameData.CurrentWave = 1
				end				
				
				canUse = true
				local SpectateButton = ServerStorage.Models.Misc.SpectateButton:Clone()
				SpectateButton.Parent = workspace
				SpectateButton.Touch.Touched:Connect(function(hit)
					local Plyr = game.Players:GetPlayerFromCharacter(hit.Parent)
					if hit.Parent and Plyr then
						Plyr.TeamColor = Teams.Lobby.TeamColor
						Plyr:LoadCharacter()
						Sockets:GetSocket(Plyr):Emit("SpectateOn")
					end
				end)
				--[[
					Main Gameplay Sequence Loop
				--]]			
				FS.spawn(function()
					local SynchronizeBulletTime = 0
					local BulInfo = {}
					
					while GameData ~= nil do
						if not GameData.InUltimate then
							local Frame = RunService.Heartbeat:Wait()
							local CurrentEnemy = 0
							
							for _, Enemy in ipairs(Enemies) do
								CurrentEnemy = CurrentEnemy + 1
								if Enemy then
									local Torso = Enemy.Torso
									if Enemy.getStat("HP") > 0 and (Enemy.Auto == false or Enemy.Torso:FindFirstChildOfClass("BoolValue") ~= nil) then
										Torso.PlayerHP.Frame.HealthBar.Bar.Size = UDi(.96*(Enemy.getStat("HP")/Enemy.getStat("MAXHP")),0,.5,0)
									end
									local Time = 10
									if Enemy.Configuration.Type == "Melee" and Enemy.Auto == false then
										Time = 5
									end
									if tick()-Enemy.WayPointTimeOut >= Time and Enemy.Auto == false then
										Enemy.WayPointTimeOut = tick()
										Enemy.FindNewTarget()
									end
									if Enemy.Configuration.AttackCD > 0 and Enemy.Auto == false then
										Enemy.Configuration.AttackCD = Enemy.Configuration.AttackCD - 1
										if Enemy.Configuration.AttackCD <= (Enemy.Configuration.Type == "Melee" and 5 or 20) then
											Enemy.Configuration.Stunned = false
										end
									elseif Enemy.Auto == false then
										Enemy.Configuration.CurrentlyAttacking = false
									end
									if Torso.Position.Y < 400 and Enemy.Auto == false then
										warn("Fell off world!", Torso.Position.Y)
										if Enemy.Path then
											local WP;
											if Enemy.WayPointStep < #Enemy.Path then
												WP = Enemy.Path[Enemy.WayPointStep]
											else
												WP = Enemy.Path[Enemy.WayPointStep-1]
											end
											Torso.CFrame = CF(WP.Position.X, WP.Position.Y, WP.Position.Z)
										else
											Enemy.Died()
										end
									end
									local CanAction = true
									if Enemy.Torso.Anchored == false and Enemy.Auto == false then
										CanAction = false
									end
									if CanAction then
										if Enemy.Auto then
											for i, Bullet in ipairs(Enemy.Configuration.Animations) do
												if Bullet ~= nil then
													local LASTCF = Bullet.CFrame
													Bullet.Tick = Bullet.Tick + 1
													Bullet.CFrame = Bullet.CFrame * CF(0, 0, Bullet.Speed)
													if os.time() - SynchronizeBulletTime >= 5 then
														SynchronizeBulletTime = os.time()
														tbi(BulInfo, {Bullet.CFrame, Bullet.ID, Bullet.Tick})
													elseif #BulInfo > 0 then
														table.clear(BulInfo)
													end
													local obj = Utilities:Raycast(LASTCF.Position, Bullet.CFrame.Position - LASTCF.Position, {EnemiesFolder, workspace.DeadEnemies}, false, 1 , false, true)
													if obj then
														local targ = nil
														if obj then
															if obj.Parent:FindFirstChildOfClass("Humanoid") then
																targ = obj.Parent
															elseif obj.Parent.Parent:FindFirstChildOfClass("Humanoid") then
																targ = obj.Parent.Parent
															end
														end
														if targ then
															Bullet.Tick = 9999
															Bullet.MaxTick = 1
															Enemy.Damage(nil, nil, nil, true, targ, Bullet.DamageScale)
														end
													end

													if Bullet.Tick >= Bullet.MaxTick then
														Sockets:Emit("EnemyAnimate", nil, "RemoveBullets", {Bullet})
														tbr(Enemy.Configuration.Animations, i)
													end
												else
													tbr(Enemy.Configuration.Animations, i)
												end
											end
										end
										if Enemy.Blowback and Enemy.Auto == false then
											local Velocity = CF(0, (Enemy.Vy - (Enemy.grav * Enemy.elapsed)) * Frame, -(Enemy.Vx * Frame))
											local dir = Torso.CFrame * Velocity
											local D = (Torso.Size.Z*.5)+5
											local Hit, Position, Surface = Utilities:Raycast(Torso.Position, -(Torso.Position-dir.p)*D, {EnemiesFolder, workspace.DeadEnemies}, false, 1 , false, true)
											if Hit ~= nil then
												Enemy.Blowback = false
											else
												Torso.Parent:SetPrimaryPartCFrame(dir)
												Enemy.elapsed = Enemy.elapsed + Frame
												if Torso.Position.Y < -25 then 
													print("Fell off world! V2")
													Enemy.Died()
												end
											end
										elseif Enemy.Grabbed == nil and Enemy.Configuration.CurrentlyAttacking == false and Enemy.Auto == false then --1.625
											local Hit, Position, Surface = Utilities:Raycast(Torso.Position, Vec3(0, (-Torso.Size.Y * (Enemy.Configuration.Type == "Melee" and 1.625 or 15.625)), 0), {EnemiesFolder, workspace.Players, workspace.Terrain, workspace.DeadEnemies}, false, .1 , false, true)
											local Y = (Torso.Position.Y - Position.Y) -- ; print(Y)
											if tick()-Enemy.AutoKill >= 180 and Enemy.Boss == false and Enemy.Auto == false then
												Enemy.Died()
											end
											if Hit == nil and (Enemy.Jump == false or tick()-Enemy.KnockupTimer <= 2 or Enemy.Blowback) then
												if tick()-Enemy.KnockupTimer > 2 and Enemy.Blowback == false then
													Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CF(0, -.8, 0))
												end
												Enemy.Animate("Standing")
											else -- Ray has hit the ground
												if Enemy.Target then
													local Di = 1
													if (Enemy.Configuration.Type == "Melee" and Y > 0 and Y < 2.5) or (Enemy.Configuration.Type == "Flying" and Y > 5 and Y < 6.5) then --To keep the HRP off the ground
														Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CF(0, 0.1, 0))
													end
													if Enemy.Configuration.Stunned then
														Di = 0
													elseif tick()-Enemy.KnockbackTimer >= .35 then
														Di = 1
														Enemy.Direction = ((Torso.Size.Z*.5) + (Enemy.WalkspeedPerSecond/30))
													end
													local WayPoint;
													if Enemy.Path and Enemy.WayPointStep < #Enemy.Path then
														WayPoint = Enemy.Path[Enemy.WayPointStep]
														if Torso.Position.Y < WayPoint.Position.Y then
															Enemy.Jump = true
														else
															Enemy.Jump = false
														end
														if (WayPoint.Position-Torso.Position).Magnitude <= 5 then
															Enemy.WayPointTimeOut = tick()
															Enemy.WayPointStep = Enemy.WayPointStep + 1
														end
													end
													if WayPoint == nil then
														Enemy.WayPointTimeOut = 0
													end
													if Enemy.Configuration.Type ~= "Melee" then
														if WayPoint == nil or (Enemy.Target.Position-Torso.Position).magnitude <= 10 then
															WayPoint = Enemy.Target
														end
													end
													if WayPoint then
														local D = Enemy.Direction
														local Hit, Position, Surface = Utilities:Raycast(Torso.Position, Torso.CFrame.lookVector *  D, {workspace.DeadEnemies}, Visualize, 0.11 , false, true)
														if Hit == nil then
															Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CF(0, 0, (-(Enemy.WalkspeedPerSecond/30)*.5)*Di))
															if not Enemy.Configuration.Stunned then
																Enemy.Animate("Running")
																Enemy.Configuration.CanAttack = tick()+1
															end
															if not Enemy.IsMovingIndirect then
																if Enemy.Configuration.Type ~= "Melee" then
																	if (Torso.Position-Enemy.Target.Position).magnitude <= 50 then
																		Enemy.Animate("Attack", Bullets)
																	elseif (Torso.Position-Enemy.Target.Position).magnitude > 50 then
																		Enemy.Configuration.CanAttack = tick()+1
																		Enemy.Configuration.CurrentlyAttacking = false
																	end
																else
																	if (Torso.Position-Enemy.Target.Position).magnitude < 5 or Enemy.Configuration.Hitboxing then
																		Enemy.Animate("Attack")
																	elseif (Torso.Position-Enemy.Target.Position).magnitude > 5 then
																		Enemy.Configuration.CanAttack = tick()+1
																		Enemy.Configuration.CurrentlyAttacking = false
																	end
																end
																if not Enemy.Configuration.Stunned then
																	local V = Vec3(WayPoint.Position.X, Torso.Position.Y, WayPoint.Position.Z)
																	local LookCF = CF(Torso.CFrame.Position, V)
																	Torso.Parent:SetPrimaryPartCFrame(LookCF)
															--		Torso.Parent:SetPrimaryPartCFrame(CF(Torso.Position, Vec3(WayPoint.Position.X, Enemy.Configuration.Type == "Melee" and Torso.Position.Y or WayPoint.Position.Y, WayPoint.Position.Z))) --Pointing towards Target
																end
															elseif tick() - Enemy.IndirectMoveStart >= 0.3 then
																Enemy.IsMovingIndirect = false					
															end	
														elseif Hit ~= nil and Hit.Parent ~= nil then
															if Hit:IsDescendantOf(EnemiesFolder) then
																-- Moving left or right of the enemy
																Enemy.Animate("Running")
																local Hit, Position, Surface
																if Enemy.Hand == "Left" then
																	Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CFA(0, Rad(3), 0))
																	if not Enemy.IsMovingIndirect then
																		Enemy.IndirectMoveStart = tick()
																		Enemy.IsMovingIndirect = true
																	end
																elseif Enemy.Hand == "Right" then
																	Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CFA(0, Rad(-3), 0))
																	if not Enemy.IsMovingIndirect then
																		Enemy.IndirectMoveStart = tick()
																		Enemy.IsMovingIndirect = true
																	end 
																end
															else
																Enemy.Animate("Standing")
																if (Enemy.Jump and (Enemy.Target.Position-Torso.Position).magnitude > 5) then
																	Torso.Parent:SetPrimaryPartCFrame(Torso.CFrame * CF(0, .8, 0))
																end
																if tick() - Enemy.IndirectMoveStart >= 0.3 then
																	Enemy.IsMovingIndirect = false
																end
												    			if not Enemy.IsMovingIndirect and not Enemy.Configuration.Stunned then
																	local V = Vec3(WayPoint.Position.X, Torso.Position.Y, WayPoint.Position.Z)
																	local LookCF = CF(Torso.CFrame.Position, V)
																	Torso.Parent:SetPrimaryPartCFrame(LookCF)
																end		
															end
														end
													end
												end
											end
										elseif Enemy.Grabbed ~= nil and Enemy.Auto == false then
											Torso.Parent:SetPrimaryPartCFrame(Enemy.Grabbed.HumanoidRootPart.CFrame*CF(0,0,-3))						
										end
									end
								end
							end
							if #BulInfo > 0 then
					--			Synchronize the bullets every few seconds
								ReplicatedStorage.Sockets.Bullets:FireAllClients(BulInfo)
							end
						end
					end
				end)
				
				local SpawnTimer = tick()
				local TeamHPRegen = tick()
				local AlreadyBoss = false
				while LobbyTimer > (PVP and -1 or 0) and (PVP or #Teams.InGame:GetPlayers() > 0) do
					if not GameData.InUltimate then
						ReadyButton.Billboard.Menu.Frame1.Subtitle1.Text = string.format("SPAWN (L. Force: %s)", GameData.TeamHP)
						for _,p in ipairs(Players:GetPlayers()) do
							local CombatStat = PlayerManager:GetCombatState(p.UserId)
							if CombatStat ~= nil and #CombatStat.StatusEffects > 0 then
								for e = 1, #CombatStat.StatusEffects do
									local Effect = CombatStat.StatusEffects[e]
									if Effect ~= nil then
										if tick()-Effect.TimeStamp >= Effect.Duration and Effect.Name ~= "RedChargeRifle" then
											tbr(CombatStat.StatusEffects, e)
											PlayerManager:UpdateCombatState(p.UserId, CombatStat)
										else
											if Effect.Name == "Bleed" then
												if CombatStat.Character ~= nil then
													local bledDmg = (CombatStat.Character.Humanoid.MaxHealth * 0.005)
													if CombatStat.Character.Humanoid.Health > bledDmg then
														CombatStat.DamageTaken = CombatStat.DamageTaken + bledDmg
														CombatStat.Character.Humanoid:TakeDamage(bledDmg)
													else
														CombatStat.Character.Humanoid.Health = 1
													end
													PlayerManager:UpdateCombatState(p.UserId, CombatStat)
												end
											end
											if Effect.Name == "Potion" then
												if CombatStat.Character ~= nil then
													local perc = (CombatStat.Character.Humanoid.MaxHealth * 0.02)
													CombatStat.Character.Humanoid.Health = CombatStat.Character.Humanoid.Health + perc
													PlayerManager:UpdateCombatState(p.UserId, CombatStat)
												end
											end
											if Effect.Name == "Stam Boost" then
												if CombatStat.Character ~= nil then
													ReplicatedStorage.PlayerValues[p.Name].Stamina.Value += 25
													PlayerManager:UpdateCombatState(p.UserId, CombatStat)
												end
											end
											if Effect.Name == "Battle Scars" then
												if CombatStat.Character ~= nil then
													local perc = (CombatStat.Character.Humanoid.MaxHealth * 0.01)
													CombatStat.Character.Humanoid.Health = CombatStat.Character.Humanoid.Health + perc
													PlayerManager:UpdateCombatState(p.UserId, CombatStat)
												end
											end
											if Effect.Name == "Disposition Heal" or Effect.Name == "Disposition Heal Empowered" then
												if CombatStat.Character ~= nil then
													local perc = Effect.Misc
													CombatStat.Character.Humanoid.Health = CombatStat.Character.Humanoid.Health + perc
													PlayerManager:UpdateCombatState(p.UserId, CombatStat)
												end
											end
										end
									end
								end
							end
						end
						if #PlayersNeedReviving > 0 and GameData ~= nil then
							for i = 1, #PlayersNeedReviving do
								local Plyr = PlayersNeedReviving[i]
								if GameData.TeamHP > 0 then
									if Plyr ~= nil then
										if Plyr.HP > 0 then
											Plyr.HP = Plyr.HP - 25
											for _,  Ply in ipairs(Players:GetPlayers()) do
												if Ply.Character and Plyr.Player.Character and Ply.Character ~= Plyr.Player.Character then
													if (Plyr.Player.Character.HumanoidRootPart.Position-Ply.Character.HumanoidRootPart.Position).magnitude <= 10 then
														local MedGem = EffectFinder:FindGemstone(Ply.UserId, "Medic")
														if MedGem ~= nil then
															GameData.TeamHP = GameData.TeamHP + MedGem.Q
														end
														local CombatState = PlayerManager:GetCombatState(Ply.UserId)
														local PlayerStat = PlayerManager:GetPlayerStat(Ply.UserId)
														CombatState.Revivals = CombatState.Revivals + 1
														Sockets:Emit("Banner", "Savior" , PlayerStat.ProfileBackground, Ply.Name.. " - Lv" ..PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel)
														Sockets:GetSocket(Plyr.Player):Emit("Ragdoll", false)
														script.Parent.SocketCode.PlayerMorphAttackHandler.Event:Fire(Plyr.Player)
														if Plyr.Player.Character:FindFirstChildOfClass("Humanoid") then
															if not table.find(PlayerStat.StoryProgression, "DiedOnce") then
																local Effect = EffectFinder:CreateEffect("Invincibility", 23, Plyr.Player.Character)
																tbi(CombatState.StatusEffects, Effect)
																tbi(PlayerStat.StoryProgression, "DiedOnce")
															else
																local Effect = EffectFinder:CreateEffect("Invincibility", 3, Plyr.Player.Character)
																tbi(CombatState.StatusEffects, Effect)
															end
															PlayerManager:UpdateCombatState(Ply.UserId, CombatState)
															Plyr.Player.Character.Humanoid.Health = Plyr.Player.Character.Humanoid.MaxHealth
														end
														tbr(PlayersNeedReviving, i)
														break
													end
												end
											end
											if Plyr.Player.Character and Plyr.Player.Character:FindFirstChildOfClass("Humanoid") then
												Plyr.Player.Character.Humanoid.Health = 1
											end
											local LossAmount = 25
											local Resi = EffectFinder:FindWeaponEffect(Plyr.UserId, "Indecisive Preparation")
											if Resi ~= nil then
												LossAmount = LossAmount * (1-(Resi.V*.01))
											end
											GameData.TeamHP = GameData.TeamHP - Floor(LossAmount)
										else
											Sockets:GetSocket(Plyr.Player):Emit("Ragdoll", false)
											script.Parent.SocketCode.PlayerMorphAttackHandler.Event:Fire(Plyr.Player)
											if Plyr.Player.Character and Plyr.Player.Character:FindFirstChildOfClass("Humanoid") then
												local CombatState = PlayerManager:GetCombatState(Plyr.Player.UserId)
												local PlayerStat = PlayerManager:GetPlayerStat(Plyr.Player.UserId)
												if not table.find(PlayerStat.StoryProgression, "DiedOnce") then
													local Effect = EffectFinder:CreateEffect("Invincibility", 23, Plyr.Player.Character)
													tbi(CombatState.StatusEffects, Effect)
													tbi(PlayerStat.StoryProgression, "DiedOnce")
												else
													local Effect = EffectFinder:CreateEffect("Invincibility", 3, Plyr.Player.Character)
													tbi(CombatState.StatusEffects, Effect)
												end
												PlayerManager:UpdateCombatState(Plyr.Player.UserId, CombatState)
												Plyr.Player.Character.Humanoid.Health = Plyr.Player.Character.Humanoid.MaxHealth
											end
											tbr(PlayersNeedReviving, i)
										end
									else
										tbr(PlayersNeedReviving, i)
									end
								else
									GameData.TeamHP = 0
									if Plyr ~= nil then
										Plyr.Player.TeamColor = Teams.Lobby.TeamColor
										if Plyr.Player.Character and Plyr.Player.Character:FindFirstChild("Humanoid") then
											Plyr.Player.Character.Humanoid.Health = 0
										end
									end
									tbr(PlayersNeedReviving, i)
								end
							end
						end		
						
						local AddText = ""
					
						if not PVP then
							local Lvl = GameData.DungeonLevel < 1 and 1 or GameData.DungeonLevel
							if GameData.HeroMode then
								if Lvl < GameData.CurrentMap.MinLevelHero then
									Lvl = GameData.CurrentMap.MinLevelHero
								elseif Lvl > GameData.CurrentMap.MaxLevelHero then
									Lvl = GameData.CurrentMap.MaxLevelHero
								end
							else
								if Lvl < GameData.CurrentMap.MinLevel then
									Lvl = GameData.CurrentMap.MinLevel
								elseif Lvl > GameData.CurrentMap.MaxLevel then
									Lvl = GameData.CurrentMap.MaxLevel
								end
							end
							
							if GameData.CurrentMap.TypeProperties.Type == "Wave" then
								
								if (GameData.EnemiesToSpawn == 0 and #Enemies < 1) then
									LobbyTimer = LobbyTimer + ((15 + (5 * GameData.CurrentWave))) * Floor(#Teams.InGame:GetPlayers() * 0.5)
									GameData.CurrentWave += 1
									if GameData.MaxEnemies < GameData.MaxEnemiesCAP then
										GameData.MaxEnemies += 2
									end
									GameData.BaseXP += 25
									GameData.BaseGold += 50
									GameData.EnemiesToSpawn = GameData.MaxEnemies
									GameData.TeamHP += 100
									if GameData.TeamHP >= GameData.MAXTeamHP then
										GameData.TeamHP = GameData.MAXTeamHP
									end

									local systemSpeaker = ChatService:GetSpeaker("SYSTEM")
									systemSpeaker:SayMessage(string.format("Potential XP: %s, Potential Gold: %s", GameData.BaseXP, GameData.BaseGold), "All")
									
									local amnt = 0
									local max_val, name = -math.huge, ""
									local CombatStates = PlayerManager:FetchCombatStates()
									for k, v in pairs(CombatStates) do
										amnt += v.DPS
									    if v.DPS > max_val then
									        max_val, name = v.DPS, v.Name
									    end
									end

									systemSpeaker:SayMessage(
										string.format("%s is in the lead: %s damage dealt (%s Damage Participation)",
											name,
											format_int(Floor(max_val+.5)), 
											Floor((max_val/amnt)*100).. "%"
										),
										"All"
									)
								end

								if table.find(GameData.CurrentMap.TypeProperties.Objectives, "Defend") then
									if workspace.Map.Defending.DefendBlock.Humanoid.Health <= 0 then
										LobbyTimer = -1000
									end
								end
								
								if tick() - TeamHPRegen >= 2 and GameData.TeamHP < GameData.MAXTeamHP then
									GameData.TeamHP += 1
									TeamHPRegen = tick()
								end
								if tick() - SpawnTimer >= Rand:NextNumber(.1,2) then
									SpawnTimer = tick()
									
									if GameData.CurrentWave > GameData.CurrentMap.TypeProperties.Wave then
										GameData.MapCompleted = true
										LobbyTimer = 0
										break
									end
									
									for i = 1, Rand:NextInteger(1, 3) do
										FS.spawn(function()
											wait(Rand:NextNumber(0, .75))
											if GameData.EnemiesToSpawn > 0 and #Enemies < GameData.MaxEnemies then
												
												------------------------------------------------------------------------------------------------------------------------------------------------
												------------------------------------------------------------------------------------------------------------------------------------------------
												------------------------------------------------------------------------------------------------------------------------------------------------
												------------------------------------------------------------------------------------------------------------------------------------------------

												--LVL, HP, ATK, DEF, CRIT, CRITDEF
												local EnemyData;
												if GameData.CurrentMap.MissionName == "Riukaya-Hara: A Journey's Start" then
													if GameData.CurrentWave == 5 and GameData.EnemiesToSpawn == 1 then
														Sockets:Emit("Warning")
														local BossData
														if GameData.HeroMode then
															BossData = CreateEnemy(Lvl, 
																37000 + (400 * Lvl), 
																50 + (4 * Lvl), 
																Lvl, 
																0, 
																0, 
																"BossMan", nil, "Melee", true)
														else
															BossData = CreateEnemy(Lvl, 
																2700 + (50 * Lvl), 
																15 + (3 * Lvl), 
																1, 
																0, 
																0, 
																"BossMan", nil, "Melee", true)
														end
														local Num = #Enemies+1
														Enemies[Num] = BossData
														Sockets:Emit("EnemyStatus", BossData, "Spawn")
													end
													if Rand:NextInteger(1,5) >= 4 then
														EnemyData = CreateEnemy(Lvl, 120 + (10 * Lvl), 10 + (2 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.RiukayaHara.HaraFlightMob)
													else
														EnemyData = CreateEnemy(Lvl, 140 + (10 * Lvl), 15 + (2 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.RiukayaHara.HaraMob)
													end
												
												elseif GameData.CurrentMap.MissionName == "Simulated Battle I" then
													if GameData.CurrentWave >= 3 and Rand:NextNumber(1, 100) <= 40 then
														EnemyData = CreateEnemy(Lvl, 1350 + (20 * Lvl), 35 + (2 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.SimulatedBattles.SimulatedBattle1.ShieldMob)
													else
														EnemyData = CreateEnemy(Lvl, 840 + (15 * Lvl), 40 + (3 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.SimulatedBattles.SimulatedBattle1.HaraMob)
													end
												elseif GameData.CurrentMap.MissionName == "Simulated Battle II" then
													if GameData.CurrentWave >= 3 and Rand:NextNumber(1, 100) <= 30 then
														EnemyData = CreateEnemy(Lvl, 1700 + (25 * Lvl), 45 + (2 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.SimulatedBattles.SimulatedBattle1.ShieldMob)
													elseif GameData.CurrentWave >= 5 and Rand:NextNumber(1, 100) <= 30 then
														EnemyData = CreateEnemy(Lvl, 800 + (15 * Lvl), 40 + (2 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.SimulatedBattles.SimulatedBattle2.SpeedBrute)
													else
														EnemyData = CreateEnemy(Lvl, 1100 + (20 * Lvl), 55 + (3 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.SimulatedBattles.SimulatedBattle1.HaraMob)
													end
												elseif GameData.CurrentMap.MissionName == "Simulated Battle III" then
													local BossSpawned = false
													if GameData.CurrentWave == 8 and GameData.EnemiesToSpawn == 1 then
														EnemyData = CreateEnemy(Lvl, 
															72000 + (2650 * Lvl), 
															80 + (3 * Lvl), 
															4 * Lvl, 
															0, 
															Lvl * 0.5, 
															nil, nil, nil, false, 
															ServerStorage.Bosses.SimulatedBattles.Phantom
														)
													elseif not BossSpawned then
														if GameData.CurrentWave >= 2 and Rand:NextNumber(1, 100) <= 10 then
															EnemyData = CreateEnemy(Lvl, 3400 + (35 * Lvl), 70 + (2 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.SimulatedBattles.SimulatedBattle1.ShieldMob)
														elseif GameData.CurrentWave >= 4 and Rand:NextNumber(1, 100) <= 20 then
															EnemyData = CreateEnemy(Lvl, 1800 + (25 * Lvl), 65 + (2 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.SimulatedBattles.SimulatedBattle2.SpeedBrute)
														else
															EnemyData = CreateEnemy(Lvl, 2100 + (30 * Lvl), 75 + (3 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.SimulatedBattles.SimulatedBattle1.HaraMob)
														end
													end
												end

												if GameData.CurrentRunLogic then
													EnemyData = GameData.CurrentRunLogic(Lvl)
												end
												
												------------------------------------------------------------------------------------------------------------------------------------------------
												------------------------------------------------------------------------------------------------------------------------------------------------
												------------------------------------------------------------------------------------------------------------------------------------------------
												------------------------------------------------------------------------------------------------------------------------------------------------
												
												if EnemyData then
													local Num = #Enemies + 1
													Enemies[Num] = EnemyData
													Sockets:Emit("EnemyStatus", EnemyData, "Spawn")
													GameData.EnemiesToSpawn = GameData.EnemiesToSpawn - 1
												end
											end
										end)
									end
								end
								
								
							elseif GameData.CurrentMap.TypeProperties.Type == "Dungeon" then
							
								local Found = false
								for v = 1, #GameData.Objectives do
									for i = 1, #GameData.CurrentMap.TypeProperties.Objectives do
										if GameData.Objectives[v][1] == GameData.CurrentMap.TypeProperties.Objectives[i][1] then
											if GameData.Objectives[v][2] < GameData.CurrentMap.TypeProperties.Objectives[i][2] then
												GameData.DungeonMsg = GameData.Objectives[v][1]
												if GameData.CurrentMap.TypeProperties.Objectives[i][2] > 1 then
													AddText = " ("..GameData.Objectives[v][2].."/"..GameData.CurrentMap.TypeProperties.Objectives[i][2]..")"
												end
												Found = true
												break
											end
										end
									end
									if Found then break end
								end
								
								if not Found then
									GameData.MapCompleted = true
									LobbyTimer = 0
									break
								end
								
								if GameData.CurrentMap.MissionName == "Introduction" then
									if GameData.CurrentWave < 5 then
										GameData.CurrentWave = GameData.CurrentWave + 1
									end
									if GameData.CurrentWave == 5 then
										GameData.CurrentWave = GameData.CurrentWave + 1
										
										SoloPlace = true
										local Althea = ServerStorage.Bosses.Introduction.Althea:Clone()
										local AltheaScript = Althea["_Main"]
										AltheaScript["_CHARACTEROBJ(DONOTTOUCH)"].Value = Althea
										Althea.BehaviorTree.Parent = AltheaScript
										AltheaScript.Parent = script.Parent.Parent.BossScript
										Althea.Parent = workspace.Players
										
										Althea:SetPrimaryPartCFrame(ReplicatedStorage.Models.Misc.CameraGuy2.PrimaryPart.CFrame*CFrame.new(0, 0.8, 0))
										
										Althea.Bindables.Damage.Event:Connect(function(targ)
											for _,enemies in ipairs(Enemies) do
												if enemies.Torso.Parent == targ then
													local newDamage = 100
													enemies.Configuration.HP = math.max(1, enemies.Configuration.HP - newDamage)
													if enemies.Configuration.HP > newDamage then
														enemies.Configuration.HP = enemies.Configuration.HP - newDamage
													else
														enemies.Configuration.HP = 1
													end
													if enemies.Boss or (enemies.Auto and enemies.Torso:FindFirstChildOfClass("BoolValue") == nil) then
														Sockets:Emit("EnemyStatus", enemies, "BossHP", enemies.Configuration.HP)
													end
													break
												end
											end
										end)
										
										AltheaScript.Disabled = false
										setCollisionGroupRecursive(Althea)
										
										local BossData;
										local Lvl = 1
										BossData = CreateEnemy(Lvl, 
											2800, 
											70, 
											.025, 
											0, 
											0, 
											nil, nil, nil, false, 
											ServerStorage.Bosses.Introduction["The Researcher"]
										)
										local Num = #Enemies+1
										Enemies[Num] = BossData
										
									end
								
								elseif GameData.CurrentMap.MissionName == "High Vigils: Basic Combat Tutorial" then
									if GameData.CurrentWave < 5 then
										GameData.CurrentWave = GameData.CurrentWave + 1
									end
									if GameData.CurrentWave == 5 then
										GameData.CurrentWave = GameData.CurrentWave + 1
										local BossData;
										local Lvl = 1
										if GameData.HeroMode then
											BossData = CreateEnemy(Lvl, 
												31200*Lvl^1.5+5*Lvl-5, 
												(100+(8*Lvl))*1.3, 
												(13*Lvl)*1.2, 
												((7+(2*Lvl))*1.3)^1.1, 
												(14+(2*Lvl))*1.3, 
												nil, nil, nil, false, 
												ServerStorage.Bosses.HighVigils["Lilah"]
											)
										else
											BossData = CreateEnemy(Lvl, 
												14950*Lvl^1.3+5*Lvl-5, 
												(12+(3*Lvl))*1.3, 
												(30*Lvl)*1.2, 
												(7+(2*Lvl))*1.3, 
												(14+(2*Lvl))*1.3, 
												nil, nil, nil, false, 
												ServerStorage.Bosses.HighVigils["Lilah"]
											)
										end
										local Num = #Enemies + 1
										Enemies[Num] = BossData
									--	Sockets:Emit("EnemyStatus", BossData, "Spawn")
									end
									
								elseif GameData.CurrentMap.MissionName == "The Heart of Atlas: Compendium" then
									if GameData.CurrentWave == 1 then
										for _, Triggers in ipairs(workspace.Map.SpawnTriggers:GetChildren()) do
											local TriggerRequired = Triggers.TriggerRequired
											local EnemyTypes = Triggers.EnemyTypes:GetChildren()
											local EnemiesDied = 0
											local EnemiesToSpawn = Triggers.MaxEnemiesToSpawn.Value
											local Connection = nil
											local PlayersAmnt = #Teams.InGame:GetPlayers()
											Connection = Triggers.Trigger.Touched:Connect(function(hit)
												local PotentialPlayer = Players:GetPlayerFromCharacter(hit.Parent)
												if PotentialPlayer and hit == hit.Parent.PrimaryPart then
													if (TriggerRequired.Value == nil or TriggerRequired.Value.Transparency < 1) then
														Connection:Disconnect()
														Triggers.Trigger.Sound:Play()
														workspace.Map.Spawners:ClearAllChildren()
														for _, Spawners in ipairs(Triggers.EnemySpawns:GetChildren()) do
															Spawners.Parent = workspace.Map.Spawners
														end
														for _, Door in ipairs(Triggers.Doors:GetDescendants()) do
															if Door:IsA("BasePart") then
																Door.Mesh.Scale = Door.Size
																TweenService:Create(Door, TweenInfo.new(3), {Transparency = -1.25}):Play()
															end
														end
														
														for i = 1, EnemiesToSpawn do
															local EnemyData;
															
															if Triggers:FindFirstChild("BossSpawn") then
																if EnemyTypes[1].Name == "Valkyrie" then
																	FS.spawn(function()
																		Sockets:Emit("Warning", true)
																		Sockets:Emit("MusicChange", "Play", "HeartOfAtlas_ValkyrieTheme")
																	end)
																	if GameData.HeroMode then
																		EnemyData = CreateEnemy(Lvl, 
																			78000 + (2850 * Lvl), 
																			100 + (3 * Lvl),
																			4 * Lvl, 
																			0, 
																			Lvl * 0.5, 
																			nil, nil, nil, false, 
																			ServerStorage.Bosses.HeartOfAtlas["Valkyrie (Hero)"]
																		)
																	else
																		EnemyData = CreateEnemy(Lvl, 
																			78000 + (2850 * Lvl), 
																			100 + (3 * Lvl),
																			3 * Lvl, 
																			0, 
																			Lvl * 0.5, 
																			nil, nil, nil, false, 
																			ServerStorage.Bosses.HeartOfAtlas["Valkyrie"]
																		)
																	end
																elseif EnemyTypes[1].Name == "Atlas" then
																	FS.spawn(function()
																		Sockets:Emit("Warning", true)
																		Sockets:Emit("MusicChange", "Play", "HeartOfAtlas_ValkyrieTheme")
																	end)
																	if GameData.HeroMode then
																		EnemyData = CreateEnemy(Lvl, 
																			78000 + (2850 * Lvl), 
																			100 + (3 * Lvl),
																			4 * Lvl, 
																			0, 
																			Lvl * 0.5, 
																			nil, nil, nil, false, 
																			ServerStorage.Bosses.HeartOfAtlas["Atlas (Hero)"]
																		)
																	else
																		EnemyData = CreateEnemy(Lvl, 
																			100000 + (3200 * Lvl), 
																			100 + (3 * Lvl),
																			4 * Lvl, 
																			0, 
																			Lvl * 0.5, 	
																			nil, nil, nil, false, 
																			ServerStorage.Bosses.HeartOfAtlas["Atlas"]
																		)
																	end
																end
																Sockets:Emit("EnemyStatus", EnemyData, "Spawn")
															else
																local chosen = EnemyTypes[Rand:NextInteger(1, #EnemyTypes)].Name
																if chosen == "BallTurret" then
																	EnemyData = CreateEnemy(Lvl, (6200 + (150 * Lvl)) * PlayersAmnt, 60 + (3 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.HeartOfAtlas[chosen])
																elseif chosen == "Brute" then
																	EnemyData = CreateEnemy(Lvl, (8500 + (325 * Lvl)) * PlayersAmnt, 95 + (3 * Lvl), 1, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.HeartOfAtlas[chosen])
																end
															end
															
															local Bindable = Instance.new("BindableEvent")
															Bindable.Name = "TriggerRemote"
															Bindable.Event:Connect(function()
																EnemiesDied += 1
																if EnemiesDied >= EnemiesToSpawn then
																	Triggers.Trigger.Transparency = 0.99
																	for _, Door in ipairs(Triggers.Doors:GetDescendants()) do
																		if Door:IsA("BasePart") then
																			Door.CanCollide = false
																			TweenService:Create(Door, TweenInfo.new(2), {Transparency = 1}):Play()
																		end
																	end
																end
															end)
															Bindable.Parent = EnemyData.Torso
															
															local Num = #Enemies+1
															Enemies[Num] = EnemyData
															wait(Rand:NextNumber(0.2, 1))
														end
													end
												end
											end)
										end
										GameData.CurrentWave = GameData.CurrentWave + 1
									end
								end

								if GameData.CurrentRunLogic then
									GameData.CurrentRunLogic(Lvl)
								end
							end
						end
						
						LobbyTimer = LobbyTimer - 1
						GameData.TimeElapsed += 1

						if GameData.TimeElapsed <= 5 then
							GameData.TeamHP = GameData.MAXTeamHP
						end
						
						if PVP then
							local StormSphere = workspace.Map.PVPSpawns.StormSphere
							local OriginalRadius = StormSphere.Mesh.Scale
							
							if LobbyTimer < 0 and not StormStarted then
								StormStarted = true
								LobbyTimer = 0
								Sockets:Emit("SuddenDeath")
								FS.spawn(function()
									wait(2)
									Sockets:Emit("Hint", "Arena has begun shrinking! Stay in the zone!")
								end)
								
								local Center = Vector3.new(StormSphere.Position.X, 0, StormSphere.Position.Z)
								TweenService:Create(StormSphere, TweenInfo.new(1,Enum.EasingStyle.Linear), {Transparency = -1}):Play()
								TweenService:Create(StormSphere.Mesh, TweenInfo.new(30,Enum.EasingStyle.Linear), {Scale = Vector3.new(0, 500, 0)}):Play()
								
								local TimeElapsed = 1
								
								while #Teams.Team1:GetPlayers() >= 1 and #Teams.Team2:GetPlayers() >= 1 do						
									for _, Entities in ipairs(workspace.Enemies:GetChildren()) do
										local Humanoid = Entities:FindFirstChildOfClass("Humanoid")
										if Humanoid and Humanoid.Health > 0 then
											local RootPart = Entities.PrimaryPart
											if RootPart then
												local Dist = (Center - Vector3.new(RootPart.Position.X, 0, RootPart.Position.Z)).Magnitude
												if Dist > StormSphere.Mesh.Scale.X then
													Humanoid:TakeDamage(Humanoid.MaxHealth * ((1.015 ^ TimeElapsed) - 1))
													TimeElapsed += 1
												end
											end
										end
									end
									wait(.5)
								end
							end
							
							---When everyone is killed
							local Team1 = #Teams.Team1:GetPlayers()
							local Team2 = #Teams.Team2:GetPlayers()
							if Team1 < 1 or Team2 < 1 then
								PVPManager:AddScore(Team1 > Team2 and "Red" or "Blue")
								LobbyTimer = 150
								StormStarted = false
								StormSphere.Transparency = 1
								StormSphere.Mesh.Scale = OriginalRadius
								local RedScore, BlueScore = PVPManager:GetScores()
								Sockets:Emit("TeamScores", RedScore, BlueScore)
								wait(2)
								if RedScore >= 5 or BlueScore >= 5 then
									LobbyTimer = -1
								else
									for _,ply in ipairs(Players:GetPlayers()) do
										if table.find(PVP.RedTeam, ply.Name) then
											ply.TeamColor = Teams.Team1.TeamColor
										else
											ply.TeamColor = Teams.Team2.TeamColor
										end
										ply:LoadCharacter()
									end
								end
							end
						end
						
						Sockets:Emit("InfoUpdate", GameData, PVP and (LobbyTimer == 0 and "OVERTIME" or toClock(LobbyTimer,true)) or toClock(LobbyTimer,true), #Enemies, GameData.DungeonMsg, AddText)
							
					end
					wait(1)
				end
				
				--[[
					Main Gameplay Round Ending Sequence
				--]]
				local WasInGame = {}
				Sockets:Emit("ResetAnim")
				for _,ply in ipairs(Players:GetPlayers()) do
					local CombatState = PlayerManager:GetCombatState(ply.UserId)
					if CombatState then
						if ply.TeamColor == Teams.InGame.TeamColor or PVP then
							ply.TeamColor = Teams.Lobby.TeamColor
							ply:LoadCharacter()
							tbi(WasInGame, ply)
							CombatState.Ready = false
							PlayerManager:UpdateCombatState(ply.UserId, CombatState)
						end
					end
				end
				game.ServerScriptService.BossScript:ClearAllChildren()
				workspace.Terrain:ClearAllChildren()
				workspace.DeadEnemies:ClearAllChildren()
				workspace.Enemies:ClearAllChildren()
				
				if ReadyButton then
					ReadyButton:Destroy()
				end

				if SpectateButton then
					SpectateButton:Destroy()
				end
				
	--			FS.spawn(function()
			--		wait(8)
			--		Sockets:Emit("MusicChange", "Play", "LobbyMusic")
	--	end)
				if PVP then
					local RedScore, BlueScore = PVPManager:GetScores()
					Sockets:Emit("SuddenDeath", RedScore > BlueScore and "Red Wins!" or "Blue Wins!")
					wait(2)
					local PlayerBanners = {}
					local TopScores = {}
					TopScores.DamageDealt = {}
					TopScores.HighestCombo = {}
					TopScores.DodgedAttacks = {}
					TopScores.DamageTaken = {}
					TopScores.SupportSkills = {}
					TopScores.Revivals = {}
					for _,ply in ipairs(game.Players:GetPlayers()) do
						local PlayerStat = PlayerManager:GetPlayerStat(ply.UserId)
						if ply ~= nil and PlayerStat then
							local currentClass	= PlayerStat.Characters[PlayerStat.CurrentClass]
							local CombatState = PlayerManager:GetCombatState(ply.UserId)
							local KDA = PVPManager:ReturnPlayerTable(ply)
							local NewBanner = {}
							NewBanner.User = ply.Name
							NewBanner.Banner = PlayerStat.ProfileBackground
							tbi(PlayerBanners, NewBanner)
							local id = ply.UserId
							if KDA.DamageDealt > 0 then
								tbi(TopScores.DamageDealt, {ply.Name, Floor(KDA.DamageDealt)})
							end
							if CombatState.HighestCombo > 0 then
								tbi(TopScores.HighestCombo, {ply.Name, Floor(CombatState.HighestCombo)})
							end
							if CombatState.DodgedAttacks > 0 then
								tbi(TopScores.DodgedAttacks, {ply.Name, Floor(CombatState.DodgedAttacks)})
							end
							if CombatState.DamageTaken > 0 then
								tbi(TopScores.DamageTaken, {ply.Name, Floor(CombatState.DamageTaken)})
							end
							if KDA.Kills > 0 then
								tbi(TopScores.SupportSkills, {ply.Name, KDA.Kills, 1})
							end
							if KDA.Deaths > 0 then
								tbi(TopScores.Revivals, {ply.Name, KDA.Deaths, 1})
							end
							PlayerStat.DungeonPVPCompleted = PlayerStat.DungeonPVPCompleted + 1
						end
					end
					for _,ply in ipairs(game.Players:GetPlayers()) do
						Sockets:GetSocket(ply):Emit("LootFound", {}, PlayerBanners, TopScores, GameData.TimeElapsed, {})
					end
					PVPManager:Reset()
				elseif GameData.CurrentMap.MissionName ~= "Introduction" then
					if GameData.MapCompleted == false then
						Sockets:Emit("Intermission", "All Operators perished! Mission failed!")
						GameData.BaseXP = GameData.BaseXP + (100 + (GameData.DungeonLevel * 100)) 
					elseif GameData.MapCompleted == true then
						Sockets:Emit("Intermission", "Mission Completed! Congratulations!")
						GameData.BaseXP = GameData.BaseXP + (1500 + ((250 * GameData.DungeonLevel) ^ 1.0425))
					end
					GameData.BaseGold = GameData.BaseGold + Floor(GameData.BaseXP*.05)
					local PlayerBanners = {}
					local TopScores = {}
					TopScores.DamageDealt = {}
					TopScores.HighestCombo = {}
					TopScores.DodgedAttacks = {}
					TopScores.DamageTaken = {}
					TopScores.SupportSkills = {}
					TopScores.Revivals = {}
					for _,ply in ipairs(game.Players:GetPlayers()) do
						local PlayerStat = PlayerManager:GetPlayerStat(ply.UserId)
						if ply ~= nil and PlayerStat then
							local currentClass	= PlayerStat.Characters[PlayerStat.CurrentClass]
							local CombatState = PlayerManager:GetCombatState(ply.UserId)
							local NewBanner = {}
							NewBanner.User = ply.Name
							NewBanner.Banner = PlayerStat.ProfileBackground
							tbi(PlayerBanners, NewBanner)
							local id = ply.UserId
							if CombatState.DPS > 0 then
								tbi(TopScores.DamageDealt, {ply.Name, Floor(CombatState.DPS)})
							end
							if CombatState.HighestCombo > 0 then
								tbi(TopScores.HighestCombo, {ply.Name, Floor(CombatState.HighestCombo)})
							end
							if CombatState.DodgedAttacks > 0 then
								tbi(TopScores.DodgedAttacks, {ply.Name, Floor(CombatState.DodgedAttacks)})
							end
							if CombatState.DamageTaken > 0 then
								tbi(TopScores.DamageTaken, {ply.Name, Floor(CombatState.DamageTaken)})
							end
							if CombatState.SupportSkills > 0 then
								tbi(TopScores.SupportSkills, {ply.Name, Floor(CombatState.SupportSkills)})
							end
							if CombatState.Revivals > 0 then
								tbi(TopScores.Revivals, {ply.Name, Floor(CombatState.Revivals)})
							end
						end
					end
					for _,ply in ipairs(game.Players:GetPlayers()) do
						local PlayerStat = PlayerManager:GetPlayerStat(ply.UserId)
						if ply ~= nil and PlayerStat then
							local currentClass	= PlayerStat.Characters[PlayerStat.CurrentClass]
							local BaseXP = GameData.BaseXP
							local BaseGold = GameData.BaseGold
							local TotalInventorySpace = 0
							for i = 1, #currentClass.GemInventory do
								local Item = currentClass.GemInventory[i]
								if Item ~= nil then
									TotalInventorySpace = TotalInventorySpace + 1
								end
							end
							for i = 1, #currentClass.WeaponInventory do
								local Item = currentClass.WeaponInventory[i]
								if Item ~= nil and Item.ID ~= 1 then
									TotalInventorySpace = TotalInventorySpace + 1
								end
							end
							for i = 1, #currentClass.TrophyInventory do
								local Item = currentClass.TrophyInventory[i]
								if Item ~= nil and Item.ID ~= 1 then
									TotalInventorySpace = TotalInventorySpace + 1
								end
							end
							local StuffAwarded = {}
							if GameData.MapCompleted then
								local NewMapData = MatchMaking:GetMap(GameData.CurrentMap.MissionName) 
								for i = 1, Rand:NextNumber(GameData.CurrentMap.Type == "Event" and 8 or 2, GlobalThings.MaxLootDrops) do
									local Loot = LootInfo:DropRandomLoot(999, PlayerStat.Inventory, NewMapData.MaterialDrops)
									if Loot then
										local NotFound = true
										for v = 1, #PlayerStat.Inventory do
											local Item = PlayerStat.Inventory[v]
											if Item.IG == false and Item.ID == Loot.ID and Item.Q < 99 then
												Item.Q = Item.Q + 1
												NotFound = false
												break
											end
										end
										if NotFound then
											tbi(PlayerStat.Inventory, Loot)
										end
										tbi(StuffAwarded, LootInfo:GetItemInfoFromID(Loot.ID, Loot.IG, Loot.R))
									end
								end
								for i = 1, Rand:NextNumber(1, (GameData.HeroMode and GlobalThings.MaxGemDrops*2 or GlobalThings.MaxGemDrops)) do
									if TotalInventorySpace < PlayerStat.InventorySpace then
										local GemDrop = LootInfo:DropRandomGem(PlayerStat.InventorySpace, currentClass.GemInventory, currentClass, GameData.HeroMode, NewMapData.GemDrops)
										if GemDrop ~= "Nothing" then
											local iterationDupe = 1
											local GemScav = EffectFinder:FindGemstone(ply.UserId, "Gemstone Scavenger")
											if GemScav ~= nil then
												if Random.new():NextNumber(1, 100) <= GemScav.Q then
													iterationDupe += 1
												end
											end
											for i = 1, iterationDupe do
												local Loot = GemDrop
												if Loot.R == 0 then
													RewardAchievement({39}, ply.UserId)
												elseif Loot.R == 1 then
													RewardAchievement({40}, ply.UserId)
												elseif Loot.R == 2 then
													RewardAchievement({41}, ply.UserId)
												elseif Loot.R == 3 then
													RewardAchievement({42}, ply.UserId)
												elseif Loot.R == 4 then
													RewardAchievement({43}, ply.UserId)
												elseif Loot.R == 5 then
													RewardAchievement({44}, ply.UserId)
												end
												tbi(currentClass.GemInventory, GemDrop)
												tbi(StuffAwarded, LootInfo:GetItemInfoFromID(GemDrop.ID, GemDrop.IG, GemDrop.R))
											end
										end
									else
										break
									end
								end
							end
							local SpecialRewards = {}
							if GameData.MapCompleted then
								RewardAchievement({25}, ply.UserId)
								if table.find(GameData.CurrentMap.TypeProperties.Objectives, "Simulated") then
									RewardAchievement({71, 72}, ply.UserId)
								end
								if PlayerStat.CharacterPlayCount[PlayerStat.CurrentClass] then
									PlayerStat.CharacterPlayCount[PlayerStat.CurrentClass] = PlayerStat.CharacterPlayCount[PlayerStat.CurrentClass] + 1
								else
									PlayerStat.CharacterPlayCount[PlayerStat.CurrentClass] = 1
								end
								if GameData.EveryoneMustDie then
									PlayerStat.DungeonHMDCompleted = PlayerStat.DungeonHMDCompleted + 1
								elseif GameData.HeroMode then
									PlayerStat.DungeonHeroCompleted = PlayerStat.DungeonHeroCompleted + 1
								else
									PlayerStat.DungeonNormalCompleted = PlayerStat.DungeonNormalCompleted + 1
								end
								local SpecialLootDrops = GameData.HeroMode and 3 or 2
								if CheckGamePass(ply, 6845594) then
									SpecialLootDrops = GameData.HeroMode and 5 or 3
								end
								for i = 1, SpecialLootDrops do
									if TotalInventorySpace < PlayerStat.InventorySpace then
										local Diffu = GameData.HeroMode and "Hero" or "Normal"
										if GameData.EveryoneMustDie then
											Diffu = "HeroesMustDie"
										end
										local LootDrop;
										if i ~= SpecialLootDrops then
											LootDrop = WeaponCraft:DropRandomWeapon(PlayerStat.CurrentClass, GameData.CurrentMap.MissionName, Diffu, currentClass.WeaponInventory)
										else
											LootDrop = WeaponCraft:DropRandomTrophy(GameData.CurrentMap.MissionName, Diffu, currentClass.TrophyInventory)
										end
										if LootDrop then
											if LootDrop.Name == "Gold" then
												BaseGold = BaseGold + 50
											elseif LootDrop.Name == "LesserGold" then
												BaseGold = BaseGold + 20
											elseif LootDrop.WeaponObj ~= nil or LootDrop.IsSkin then
												local Rare = LootDrop.Object.Rarity
												if Rare == 1 then
													RewardAchievement({52}, ply.UserId)
												elseif Rare == 2 then
													RewardAchievement({53}, ply.UserId)
												elseif Rare == 3 then
													RewardAchievement({54}, ply.UserId)
												elseif Rare == 4 then
													RewardAchievement({55}, ply.UserId)
												elseif Rare == 5 then
													RewardAchievement({56}, ply.UserId)
												elseif Rare == 6 then
													RewardAchievement({57}, ply.UserId)
												elseif Rare == 7 then
													RewardAchievement({58}, ply.UserId)
												end
												if i ~= SpecialLootDrops then
													tbi(currentClass.WeaponInventory, LootDrop.WeaponObj)
												else
													if LootDrop.IsSkin then
														local Found = false
														for _, Skins in ipairs(currentClass.Skins) do
															if Skins.Name == LootDrop.Object.Model.Name then
																Found = true
																BaseGold = BaseGold + 100
																break
															end
														end
														if not Found then
															local Costume = NewCostume(LootDrop.Object.Model.Name)
															tbi(currentClass.Skins, Costume)
														end
													else
														tbi(currentClass.TrophyInventory, LootDrop.WeaponObj)
													end
												end
											end
											tbi(SpecialRewards, LootDrop)
										end
									end
								end
							end
							Sockets:GetSocket(ply):Emit("LootFound", StuffAwarded, PlayerBanners, TopScores, GameData.TimeElapsed, SpecialRewards)
							local G2Gem = EffectFinder:FindGemstone(ply.UserId, "Gold Digger")
							if G2Gem ~= nil then
								BaseGold = BaseGold + G2Gem.Q
							end
							local GGem = EffectFinder:FindGemstone(ply.UserId, "Gold Increase")
							if GGem ~= nil then
								BaseGold = BaseGold * (1+(GGem.Q*.01))
							end
							local EGem = EffectFinder:FindGemstone(ply.UserId, "EXP Increase")
							if EGem ~= nil then
								BaseXP = BaseXP * (1+(EGem.Q*.01))
							end
							local E2Gem = EffectFinder:FindGemstone(ply.UserId, "Friendship Charm")
							if E2Gem ~= nil then
								local Friends = 0
								for _,potentialFriends in next, Players:GetPlayers() do
									if potentialFriends ~= ply and ply:IsFriendsWith(potentialFriends.UserId) then
										Friends = Friends + 1
									end
								end
								BaseXP = BaseXP * (1+((E2Gem.Q*.01)*Friends))
							end
							if CheckGamePass(ply, 2057535) then
								if CheckGamePass(ply, 2229858) then
									BaseXP = BaseXP * 1.2
									BaseGold = BaseGold * 1.2
									Sockets:GetSocket(ply):Emit("SendMessage", nil, nil, "VIP and Unlock All Class gamepasses found. EXP and Gold earnings are increased by 20%.", nil, true)
								else
									BaseXP = BaseXP * 1.1
									BaseGold = BaseGold * 1.1
									Sockets:GetSocket(ply):Emit("SendMessage", nil, nil, "VIP gamepass found. EXP and Gold earnings are increased by 10%.", nil, true)
								end
							end
							local CharCount = 0
							for _,chars in next, PlayerStat.Characters do
								CharCount = CharCount + 1
							end
				--			if PlayerStats[ply.UserId].WeaponLevel > 1 then
				--				BaseXP = BaseXP * 1.2
				--			end
							if CharCount >= 2 then
								Sockets:GetSocket(ply):Emit("SendMessage", nil, nil, "You own " ..CharCount.. " character(s), increasing your EXP gains by " ..CharCount*3 .. "%", nil, true)
							else
								CharCount = 0
							end
							pcall(function()
								if ply:IsInGroup(3451727) or ply:IsInGroup(448936) then
									BaseXP = BaseXP * 1.10
									BaseGold = BaseGold * 1.10
									Sockets:GetSocket(ply):Emit("SendMessage", nil, nil, "Thanks for joining the official Team Swordphin group! You earned 10% bonus EXP and gold, with a total of " ..Floor(BaseXP+.5).. " EXP and " ..Floor(BaseGold+.5).. " Gold this round.", nil, true)
								else
									Sockets:GetSocket(ply):Emit("SendMessage", nil, nil, "You earned a total of " ..Floor(BaseXP+.5).. " EXP and " ..Floor(BaseGold+.5).. " Gold this round.", nil, true)
								end
							end)
							PlayerStat.LastReserveCode = "Returning"
							PlayerStat.LastReserveTime = os.time()
							PlayerStat.Gold = PlayerStat.Gold + Floor(BaseGold+.5)
							if GameData.MapCompleted then
								local mapCompleted = GameData.HeroMode and GameData.CurrentMap.MissionName.."H" or GameData.CurrentMap.MissionName
								if not table.find(PlayerStat.StoryProgression, mapCompleted) then
									tbi(PlayerStat.StoryProgression, mapCompleted)
								end
							end
							local EXPCount = Floor((BaseXP*(1+(.03*CharCount)))+.5)
							if PlayerStat.Guild ~= "" then
								local GuildXP = EXPCount*.025
								PlayerStat.GuildXP = PlayerStat.GuildXP + GuildXP
							end
							
							if currentClass.CurrentLevel < PlayerManager.PLAYER_LEVEL_CAP then
								currentClass.EXP = currentClass.EXP + EXPCount
							else
								currentClass.EXP = 0
							end
						end
					end
					forceSaveAll()
					
					for _, Enemy in ipairs(Enemies) do
						Enemy.Died()
					end
				end	
				
				if not SoloPlace then
					local rateOfDown = 1
					local PlayersMoveButtons = ServerStorage.Models.Misc.PlayersMoveMode:Clone()
					local PlayersMoveMode = {}
					PlayersMoveMode.Replay = true
					PlayersMoveMode.PlayersStaying = {}
					PlayersMoveMode.PlayersQueuedToLeave = {}
					
					for _, Player in ipairs(game.Players:GetPlayers()) do
						if #game.Players:GetPlayers() == 1 and not SoloTest and GameData.TimeElapsed > 10 and GameData.MapCompleted then
							local id = Player.UserId
							local HeroMode = "Normal"
							if GameData.HeroMode then
								HeroMode = "Hero"
							end
							if GameData.EveryoneMustDie then
								HeroMode = "EMD"
							end
							local PlayerStat = PlayerManager:GetPlayerStat(id)
							MatchMaking:PostToHighScore(GameData.CurrentMap, id, PlayerStat.CurrentClass, GameData.TimeElapsed, HeroMode)
						end
						PlayersMoveMode.PlayersQueuedToLeave[Player.Name] = true
						local Namer = PlayersMoveButtons.ReturnButton.Billboard.Menu.Frame1.Namer:Clone()
						Namer.Text = Player.Name
						Namer.Visible = true
						Namer.Parent = PlayersMoveButtons.ReturnButton.Billboard.Menu.Frame1.Frame
					end
					
					PlayersMoveButtons.ReturnButton.Touch.Touched:Connect(function(hit)
						if hit.Parent and game.Players:GetPlayerFromCharacter(hit.Parent) and PlayersMoveMode.PlayersQueuedToLeave[hit.Parent.Name] == nil then
							PlayersMoveMode.PlayersQueuedToLeave[hit.Parent.Name] = true
							PlayersMoveMode.PlayersStaying[hit.Parent.Name] = nil
							local Namer = PlayersMoveButtons.ReturnButton.Billboard.Menu.Frame1.Namer:Clone()
							Namer.Text = hit.Parent.Name
							Namer.Visible = true
							Namer.Parent = PlayersMoveButtons.ReturnButton.Billboard.Menu.Frame1.Frame
							for _, OtherButton in ipairs(PlayersMoveButtons.StayButton.Billboard.Menu.Frame1.Frame:GetChildren()) do
								if OtherButton:IsA("TextLabel") and OtherButton.Text == hit.Parent.Name then
									OtherButton:Destroy()
									break
								end
							end
						end
					end)
					
					local zone = zoneService:createZone("ReturnButton", PlayersMoveButtons.ReturnButton, 15)
					zone:initLoop(0.1)
					zone.requiredPlayers = #game.Players:GetPlayers()
					zone.count = 0
					zone.playerAdded:Connect(function(player)
						zone.count += 1
						if zone.count == zone.requiredPlayers then
							rateOfDown = .05
						end
					end)
					zone.playerRemoving:Connect(function(player)
						zone.count -= 1
						if zone.count ~= zone.requiredPlayers then
							rateOfDown = 1
						end
					end)
					
					if GameData.CurrentMap.Available and GameData.CurrentMap.Replayable then
						PlayersMoveButtons.StayButton.Touch.Touched:Connect(function(hit)
							if hit.Parent and game.Players:GetPlayerFromCharacter(hit.Parent) and PlayersMoveMode.PlayersStaying[hit.Parent.Name] == nil then
								PlayersMoveMode.PlayersQueuedToLeave[hit.Parent.Name] = nil
								PlayersMoveMode.PlayersStaying[hit.Parent.Name] = true
								local Namer = PlayersMoveButtons.StayButton.Billboard.Menu.Frame1.Namer:Clone()
								Namer.Text = hit.Parent.Name
								Namer.Visible = true
								Namer.Parent = PlayersMoveButtons.StayButton.Billboard.Menu.Frame1.Frame
								for _, OtherButton in ipairs(PlayersMoveButtons.ReturnButton.Billboard.Menu.Frame1.Frame:GetChildren()) do
									if OtherButton:IsA("TextLabel") and OtherButton.Text == hit.Parent.Name then
										OtherButton:Destroy()
										break
									end
								end
							end
						end)
					else
						PlayersMoveMode.Replay = false
						if MatchMaking:GetMap(GameData.CurrentMap.MissionName).Available == false then
							PlayersMoveButtons.StayButton.Billboard.Unavailable.Frame1.Subtitle1.Text = "THIS MISSION IS NO LONGER AVAILABLE"
						elseif GameData.CurrentMap.Replayable == false then
							PlayersMoveButtons.StayButton.Billboard.Unavailable.Frame1.Subtitle1.Text = "THIS MISSION CANNOT BE QUICK-REPLAYED"
						end
						PlayersMoveButtons.StayButton.Billboard.Menu.Enabled = false
						PlayersMoveButtons.StayButton.Billboard.Unavailable.Enabled = true
						PlayersMoveButtons.StayButton.Touch.Color = Color3.fromRGB(255, 201, 201)
						PlayersMoveButtons.StayButton.Part.Color = Color3.fromRGB(207, 255, 254)
						PlayersMoveButtons.StayButton.Part.Transparency = 0.6
						PlayersMoveButtons.StayButton.Effect:Destroy()
					end
					
					TerrainSaveLoad:Load(ReplicatedStorage.Environments.Terrains.TrainStation)
					if workspace:FindFirstChild("Map") then
						workspace.Map:Destroy()
					end
					LobbyTimer = 0
					FirstReady = nil
					for i = 1, #PlayersNeedReviving do
						tbr(PlayersNeedReviving, i)
					end
					PlayersNeedReviving = {}
					PlayersMoveButtons.Parent = workspace
					local IntermissionTimer = 65
					while IntermissionTimer > 0 do
						PlayersMoveButtons.StayButton.Billboard.Menu.Frame1.Subtitle1.Text = "PLAYERS REPLAYING (" .. IntermissionTimer .. ")"
						PlayersMoveButtons.ReturnButton.Billboard.Menu.Frame1.Subtitle1.Text = "PLAYERS LEAVING (" .. IntermissionTimer .. ")"
						wait(rateOfDown)
						IntermissionTimer = IntermissionTimer - 1
						local Count = 0
						for Name,Value in pairs(PlayersMoveMode.PlayersQueuedToLeave) do
							if Value == true then
								Count = Count + 1
							end
						end
						if Count < 1 then
							IntermissionTimer = 0
						end
					end
					
					zoneService:removeZone("ReturnButton")
					PlayersMoveButtons:Destroy()
					local PlayersToTeleport = {}
					if SoloTest == false then
						for Name, Value in pairs(PlayersMoveMode.PlayersQueuedToLeave) do
							if Value == true then
								for _, PlayerInQueue in ipairs(Players:GetPlayers()) do
									if PlayerInQueue.Name == Name then
										tbi(PlayersToTeleport, PlayerInQueue)
									end
								end
							end
						end
						if #PlayersToTeleport > 0 then
							MatchMaking:TeleportBack(PlayersToTeleport)
						end
						if PlayersMoveMode.Replay == false then
							break
						end
					end
					
					workspace.Enemies:ClearAllChildren()
					GameObjectHandler:DeleteEnemies()
					GameObjectHandler:DeleteGameData()
					Enemies = GameObjectHandler:GetEnemies()
					GameData = GameObjectHandler:GameData()
					
					wait(3)
				end
			end
		end
	end
end

return GameLogic
