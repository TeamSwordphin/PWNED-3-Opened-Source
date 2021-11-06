--[[ Main variables ]]--

print("Initialized")

local ContextActionService	= game:GetService("ContextActionService")
local Debris 				= game:GetService("Debris")
local GuiService			= game:GetService("GuiService")
local InsertService			= game:GetService("InsertService")
local Lighting				= game:GetService("Lighting")
local Players 				= game:GetService("Players")
local ReplicatedStorage 	= game:GetService("ReplicatedStorage")
local RunService 			= game:GetService("RunService")
local StarterGui 			= game:GetService("StarterGui")
local Teams 				= game:GetService("Teams")
local TweenService			= game:GetService("TweenService")
local TextService			= game:GetService("TextService");
local UserInputService		= game:GetService("UserInputService")
local Workspace				= game:GetService("Workspace")
local Blur					= Lighting.Blur
local Bloom					= Lighting.Bloom
local ColorCorrection		= Lighting.ColorCorrection
local SunRays				= Lighting.SunRays
local Player 				= Players.LocalPlayer
local Character 			= Player.Character or Player.CharacterAdded:wait()
local Humanoid 				= Character:WaitForChild("Humanoid")
local RootPart 				= Character:WaitForChild("HumanoidRootPart")
local CurrentHealth			= Humanoid.Health
local Camera				= workspace.CurrentCamera

local Gui 					= Player:WaitForChild("PlayerGui")
local Console 				= Gui.Console

local FS					= require(ReplicatedStorage.Scripts.Modules.FastSpawn)

local Modules 				= script.Parent.Parent:WaitForChild("Modules")
local buildRagdoll 			= require(ReplicatedStorage.Scripts.Modules:WaitForChild("buildRagdoll"))
local Util					= require(ReplicatedStorage.Scripts.Modules["AIUtil"])
local PartCache				= require(ReplicatedStorage.Scripts.Modules.PartCache)
local Cam					= require(Modules["Camera"])
local Effects				= require(Modules["Effects"])
local MusicPlayer			= require(Modules["MusicPlayer"])
local Socket 				= require(Modules["socket"])
local RainAPI				= require(Modules["Rain"])
local RegionModule			= require(Modules["RegionModule"])
local PlatformButtons		= require(Modules["PlatformButtons"])
local PaletteScript			= require(Modules["PaletteScript"])
local StoryTeller			= require(Modules.StoryTeller)
local Terrain 				= require(Modules.TerrainSaveLoad)
local DataValues			= require(script.Parent.DataValues)
local BattleModeON 			= require(script.Parent.CharacterManager.RebuildBattleMode)
local showS 				= require(script.Parent.UIEffects.NumbersFlair)
local animateText 			= require(script.Parent.UIEffects.TextScrolling)
local Hint					= require(script.Parent.UIEffects.Hint)
local format_int 			= require(script.Parent.UIEffects.FormatInteger)
local Animate 				= require(script.Parent.UIEffects.AnimateSpriteSheet)
local round					= require(script.Parent.UIEffects.RoundNumbers)
local DamageIndicator 		= require(script.Parent.UIEffects.DamageIndicator)
local Dialogue 				= require(script.Parent.DialogueSystem.AutomatedDialogue)
local execute_Dialogue		= require(script.Parent.DialogueSystem.MainExecutorDialogue)
local toClock 				= require(script.Parent.UIEffects.SecondsToClock)
local physicalCompass		= require(script.Parent.UIEffects.PhysicalCompass)

local CurrentPlayers		= #Players:GetPlayers()-1

local En 					= Enum
local EnumHumanoidStateType	= En.HumanoidStateType
local EnumRenderPriority	= En.RenderPriority
local EnumKeyCode 			= En.KeyCode
local EnumUserInputType 	= En.UserInputType
local EnumUserInputState 	= En.UserInputState
local KeyboardMapping 		= DataValues.KeyboardMapping
local ControllerMapping 	= DataValues.ControllerMapping
local Options 				= DataValues.Options

local Vec3					= Vector3.new
local OtherPlayerShown		= true

local Objs = DataValues.Objs
local Numbers = DataValues.Numbers
local bools = DataValues.bools
local Ticks = DataValues.Ticks

local CFNew, CFAng, CFtoObjectSpace = CFrame.new, CFrame.Angles, CFrame.new( ).toObjectSpace
local atan2, asin, pi, hpi, rad 	= math.atan2, math.asin, math.pi, math.pi * .5, math.rad
local RGB, Insta, UDi				= Color3.fromRGB, Instance.new, UDim2.new

local CCReset				= tick()
local Menu 					= nil

local Rando = Random.new
local Rand = math.random
local Floor = math.floor
local TIN = TweenInfo.new

local EnemiesFolder = workspace.Enemies

local CanJump = false
local DoubleJumpCD = false

local NewMenu = Gui.DesktopPauseMenu.Base.Mask
local Chat = not UserInputService.GamepadEnabled and Gui:WaitForChild("Chat")

local Mover 	= Insta("BodyVelocity")
Mover.MaxForce 	= Vector3.new(1, 1, 1)*10^6;
Mover.P = 10^4;
Mover.Velocity = Vector3.new();

local ParkourGyro = Instance.new("BodyGyro");
ParkourGyro.maxTorque = Vector3.new(1, 1, 1)*10^6;
ParkourGyro.P = 10^6;

local ParkourVelocity = Instance.new("BodyVelocity")
ParkourVelocity.maxForce = Vector3.new(1, 1, 1)*10^6;
ParkourVelocity.P = 0

local AlignPositionAttachment = DataValues.AlignPositionAttachment

GuiService.AutoSelectGuiEnabled = false

--[[ Useful Functions ]]--

function attachMorph(obj, char,partName, bodyPart)
	local character = char
	if character:findFirstChild("Humanoid") and character:findFirstChild(partName) == nil then
		character[bodyPart].Transparency = 1
		character.Humanoid:RemoveAccessories()
		if character.Head:FindFirstChild("face") then
			character.Head.face:Destroy()
		end
		local g = obj[partName]:clone()
		g.Parent = character
		local C = g:GetChildren()
		for i=1, #C do
			if C[i].className == "Part" or C[i].className == "UnionOperation" or C[i].className == "WedgePart" or C[i].className == "MeshPart" then
				C[i].CollisionGroupId = 1
				if C[i].Name ~= "Fabric" then
					local W = Insta("Weld")
					W.Part0 = g.Middle
					W.Part1 = C[i]
					local CJ = CFNew(g.Middle.Position)
					local C0 = g.Middle.CFrame:inverse()*CJ
					local C1 = C[i].CFrame:inverse()*CJ
					W.C0 = C0
					W.C1 = C1
					W.Parent = g.Middle
				else
					C[i].CFrame = character.Head.CFrame
				end
			end
			local Y = Insta("Weld")
			Y.Part0 = character[bodyPart]
			Y.Part1 = g.Middle
			Y.C0 = CFNew(0, 0, 0)
			Y.Parent = Y.Part0
		end
		local h = g:GetChildren()
		for i = 1, # h do
			if h[i].className == "Part" or C[i].className == "UnionOperation" or C[i].className == "WedgePart" or C[i].className == "MeshPart" then
				h[i].Anchored = false
				if h[i].Name ~= "Fabric" then
					h[i].CanCollide = false
				else
					h[i].CanCollide = false
				end
			end
		end
	end
end

local PlayerUI = Gui.Main.GameGUI.PlayerUI

local LockTweenInfo = TIN(
	.3,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

RunService.Heartbeat:Connect(function(step)
	if not Character then
		return
	else
		if Character and Character:FindFirstChild("HumanoidRootPart") then
			local FocusPoint = Character.HumanoidRootPart.Position
			local NearestNPC,Proximity = nil,7
			local NPCs = workspace.Interactables:GetChildren()
			
			for i, NPC in ipairs(NPCs) do
				if NPC.PrimaryPart then
					if NPC.PrimaryPart:FindFirstChild("Input") then
						NPC.PrimaryPart.Input:Destroy()
					end
					local Distance = (NPC.PrimaryPart.Position - FocusPoint).Magnitude
					if Distance < Proximity then
						NearestNPC = NPC
						Proximity = Distance
					end
				end
			end
			
			if NearestNPC then
				if NearestNPC.PrimaryPart:FindFirstChild("Input") == nil then
					local TempLabel;
					if DataValues.ControllerType == "Keyboard" then
						TempLabel = PlatformButtons:GetImageLabel("ButtonY", "Light", "PC")
					elseif DataValues.ControllerType == "Controller" then
						TempLabel = PlatformButtons:GetImageLabel("ButtonY", "Light", "XboxOne")
					elseif DataValues.ControllerType == "Touch" then
						TempLabel = ContextActionService:GetButton("MouseButton2"):Clone()
					end
					local NewInputObj = ReplicatedStorage.GUI.BillboardGui.Input:Clone()
					TempLabel.Active = false
					TempLabel.Visible = true
					TempLabel.Position = UDim2.new(0,0,0,0)
					TempLabel.Size = UDim2.new(1,0,1,0)
					TempLabel.Name = "ImageLabel"
					TempLabel.Parent = NewInputObj.Player
					if NearestNPC:FindFirstChild("Surface") then
						NewInputObj.TextLabel.Text = "Ascend to Surface"
					end
					NewInputObj.Parent = NearestNPC.PrimaryPart
				end
			end
		end
	end
	
	if Player.TeamColor ~= Teams.Lobby.TeamColor or DataValues.SpectatingTarget then
		if Gui.DesktopPauseMenu.Gradient.ImageTransparency < 1 then
			NewMenu.EditWindow.Visible = false
			TweenService:Create(Gui.DesktopPauseMenu.Gradient,TweenInfo.new(0.5, Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
			NewMenu.Size = UDi(1, 0, 0, 0)
		end
		
		--[[
			if Ticks.SlideTimer == 0 then
				ParkourVelocity.Parent = nil
			end
			
			if Ground.Transparency < 0.5 then
				local GroundParallel = GroundNormal:Cross(HRP.CFrame.UpVector)
				local SlopeParallel = GroundNormal:Cross(GroundParallel)
				
				local acos = math.acos( HRP.CFrame.UpVector:Dot(SlopeParallel) / (HRP.CFrame.UpVector.Magnitude * SlopeParallel.Magnitude) )
				local SlopeAngle = math.deg(acos)
				
				if SlopeAngle >= 120 then
					local LookAt = Util:Raycast(HRP.Position, HRP.CFrame.LookVector*30, {workspace.Players, EnemiesFolder, workspace.Terrain}, false, .5, false, true)
					if LookAt == nil then
						if Character.Humanoid.MoveDirection.Magnitude > 0.7 then
							if Ticks.SlideTimer == 0 then
								Ticks.SlideTimer = os.time()
							elseif os.time()-Ticks.SlideTimer >= 2 then
								if Objs.AnimTrack == nil then
									Objs.AnimTrack = Character.Humanoid:LoadAnimation(script.SlopeSlide)
									Objs.AnimTrack:Play()
								end
								local Vel = (os.time()-Ticks.SlideTimer)/4
								local VelDone = Vel*50 >= 50 and 50 or Vel*50
								ParkourVelocity.maxForce = Vector3.new(0, 0, Vel*1 >= 1 and 1 or Vel*1)*10^6;
								ParkourVelocity.Velocity = (SlopeParallel.unit)*(VelDone)
								ParkourVelocity.Parent = HRP
							end
						else
							Ticks.SlideTimer = 0
						end
					else
						Ticks.SlideTimer = 0
					end
				else
					Ticks.SlideTimer = 0
				end
			end
		--]]
		
		for _, enemies in ipairs(DataValues.Enemies) do
			if enemies.Auto == false and enemies.HRP.Parent and enemies.HRP.Parent.Parent and enemies.HRP.Parent.Parent.PrimaryPart then
				TweenService:Create(enemies.HRP.Parent.Parent.PrimaryPart, TIN(0.025,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0), {CFrame = enemies.HRP.CFrame*CFNew(0,enemies.HRP.Parent.Parent.PrimaryPart.Offset.Value.Y, 0)}):Play()
			end
		end
		for _, Bullet in ipairs(DataValues.Bullets) do
			if Bullet.Tick < Bullet.MaxTick then
				Bullet.Obj.PrimaryPart.CFrame = Bullet.Obj.PrimaryPart.CFrame * CFNew(0, 0, Bullet.Speed)
			end
		end
		if Ticks.FloatTime - tick() >= -.3 then
			bools.JumpRequest = false
			Ticks.WallCooldown = os.time()
			Mover.Parent = Character.PrimaryPart
		else
			Mover.Parent = nil
		end
	end


	if DataValues.WatchedIntro and Player.TeamColor == Teams.Lobby.TeamColor then
		Gui.Main.LobbyCommands.Visible = true

		if not NewMenu.EditWindow.NotHide.AnalyzeWindow.Analyze.ModifySkin.Visible then
			DataValues.CAMERAOFFSET = Vec3(0, 2, 15)
		end

		physicalCompass:run()

		Gui.Main.GameGUI.Visible = false

		if tick() - Ticks.LightingTick >= .4 and workspace:FindFirstChild("Lobby") and Character.PrimaryPart then
			
			local FocusPoint = Character.HumanoidRootPart.Position
			local NearestNPC,Proximity = nil,10
			local NPCs = workspace.Cutscene:GetChildren()
			table.insert(NPCs, workspace.Lobby.Notifications.Main)
			
			for _, otherPlayer in ipairs(workspace.Players:GetChildren()) do
				if otherPlayer ~= Character then
					table.insert(NPCs, otherPlayer)
				end
			end
			
			for i=1, #NPCs do
				local NPC = NPCs[i]
				if NPC:IsA("Model") and NPC.PrimaryPart and NPC:FindFirstChild("Humanoid") then
					local Distance = (NPC.PrimaryPart.Position - FocusPoint).magnitude
					if Distance < Proximity then
						NearestNPC = NPC.PrimaryPart
						Proximity = Distance
					else
						if NPC.PrimaryPart:FindFirstChild("Input") then
							NPC.PrimaryPart.Input:Destroy()
						end
					end
				elseif NPC:IsA("BasePart") then
					local Distance = (NPC.Position - FocusPoint).magnitude
					if Distance < Proximity then
						NearestNPC = NPC
						Proximity = Distance
					else
						if NPC:FindFirstChild("Input") then
							NPC.Input:Destroy()
						end
					end
				end
			end
			if NearestNPC then
				if NearestNPC:FindFirstChild("Input") == nil then					
					local TempLabel;
					if DataValues.ControllerType == "Keyboard" then
						TempLabel = PlatformButtons:GetImageLabel("ButtonY", "Light", "PC")
					elseif DataValues.ControllerType == "Controller" then
						TempLabel = PlatformButtons:GetImageLabel("ButtonY", "Light", "XboxOne")
					elseif DataValues.ControllerType == "Touch" then
						TempLabel = ContextActionService:GetButton("MouseButton2"):Clone()
					end
					local NewInputObj = ReplicatedStorage.GUI.BillboardGui.Input:Clone()
					TempLabel.Active = false
					TempLabel.Visible = true
					TempLabel.Position = UDim2.new(0,0,0,0)
					TempLabel.Size = UDim2.new(1,0,1,0)
					TempLabel.Name = "ImageLabel"
					TempLabel.Parent = NewInputObj.Player
					NewInputObj.Parent = NearestNPC
					
					if Players:GetPlayerFromCharacter(NearestNPC.Parent) then
						NewInputObj.TextLabel.Text = "Inspect"
						NewInputObj.ExtentsOffsetWorldSpace = Vector3.new(0, -2, 0)
					end
				end
			end
			
			if not bools.OpenShop and not Gui.MainDialogue.Dialogue.Visible then
				Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed
				Character.PrimaryPart.Anchored = false
			end

			Ticks.LightingTick = tick()

			
			local CF2 			= workspace.Lobby.ShopEntrance.CFrame
			local BoxSize2 		= workspace.Lobby.ShopEntrance.Size
			local Region2 		= RegionModule.new(CF2, BoxSize2)
			local parts2 		= Region2:Cast()
			local CFB 			= workspace.Lobby.BlacksmithEntrance.CFrame
			local BoxSizeB 		= workspace.Lobby.BlacksmithEntrance.Size
			local RegionB		= RegionModule.new(CFB, BoxSizeB)
			local partsB 		= RegionB:Cast()
			local CFC 			= workspace.Lobby.BarEntrance.CFrame
			local BoxSizeC 		= workspace.Lobby.BarEntrance.Size
			local RegionC		= RegionModule.new(CFC, BoxSizeC)
			local partsC		= RegionC:Cast()
			local DoLighting 	= true
			local FoundShop		= false
			if DataValues.AccInfo and StoryTeller:Check(DataValues.AccInfo.StoryProgression, "2.5") then
				for _,part in ipairs(parts2) do
					if part == Character.HumanoidRootPart then
						FoundShop = true
						if bools.OpenShop == false then
							if workspace:FindFirstChild("Shop") == nil then
								ReplicatedStorage.Environments.Shop:Clone().Parent = workspace
							end
							Objs.ShopObj = workspace.Shop
							RainAPI:StopRain()
							bools.OpenShop = true
							Character.PrimaryPart.Anchored = true
							Gui.ShopGUI.Enabled = true
							local Img = ReplicatedStorage.Models.Story.Story1.Dialogue.Expressions.Neutral:Clone()
							Img.Image = "rbxassetid://2057504633"
							Img.Parent = Gui.MainDialogue.DialoguePortraits.Frame.Expressions
							local ShopKeep;
							if not StoryTeller:Check(DataValues.AccInfo.StoryProgression, "0.1") then
								ShopKeep = {
									{M = "So you're the one Althea was telling me about. I hope you don't mind me setting up camp here. It's been a while since I've settled down somewhere.", Expression = "Neutral"},
									{M = "You're saying I look shady? If you can't trust me yet, perhaps what I'm selling might change your mind?", Expression = "Neutral"},
									{M = "Don't worry about who I am; we can just keep it simple. You provide the money, and I'll give you some shiny new items. They're hand-tailored for you!", Expression = "Neutral"},
									{M = "So what will it be, my dear customer?", Expression = "Neutral"},
								}
								execute_Dialogue(ShopKeep, true)
								table.insert(DataValues.AccInfo.StoryProgression, "0.1")
								Socket:Emit("Story", "0.1")
								StoryTeller:SpawnStoryElement(DataValues.AccInfo.StoryProgression)
							else
								ShopKeep = {
									{M = "Welcome back, friend. Here to browse?", Expression = "Neutral",
										Answers = {
											{A = "Show me your wares."},
											{A = "Actually, I changed my mind. Goodbye."}
										}
									}
								}
								execute_Dialogue(ShopKeep, true)
							end
						end
						break
					end
				end
				for _,part in ipairs(partsB) do
					if part == Character.HumanoidRootPart then
						FoundShop = true
						if bools.OpenShop == false and StoryTeller:Check(DataValues.AccInfo.StoryProgression, "2.5") then -- "High Vigils: Mysterious Distress Signal"
							if workspace:FindFirstChild("Blacksmith") == nil then
								ReplicatedStorage.Environments.Blacksmith:Clone().Parent = workspace
							end
							Objs.ShopObj = workspace.Blacksmith
							bools.OpenShop = true
							Gui.BlacksmithGUI.Enabled = true
							Character.PrimaryPart.Anchored = true
						end
						break
					end
				end
				--- guild
				for _,part in ipairs(partsC) do
					if part == Character.HumanoidRootPart then
						FoundShop = true
						if bools.OpenShop == false and StoryTeller:Check(DataValues.AccInfo.StoryProgression, "High Vigils: Mysterious Distress Signal") then
							if workspace:FindFirstChild("Blacksmith") == nil then
								ReplicatedStorage.Environments.Blacksmith:Clone().Parent = workspace
							end
							Objs.ShopObj = workspace.Blacksmith
							bools.OpenShop = true
							Gui.Main.Guilds.Visible = true
							Character.PrimaryPart.Anchored = true
						end
						break
					end
				end
				if FoundShop == false then
					bools.OpenShop = false
				end
			end
			
			
			if DoLighting then
				if bools.Reserved == false then
					if bools.OpenShop then
						Lighting.ExposureCompensation = -0.91
					else
						Lighting.ExposureCompensation = 0.25
					end
				--	TweenService:Create(Lighting, TIN(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Brightness = 10, Ambient = bools.OpenShop and RGB(21, 21, 21) or RGB(45, 45, 45), OutdoorAmbient = RGB(50,50,50)}):Play()
				end
				if tick() - Ticks.Flickertick >= Rand(1,10)*.1 then
					Ticks.Flickertick = tick()
					if workspace.Lobby.Flicker.JOJO.Range == 5 then
						workspace.Lobby.Flicker.Material = "Glass"
						TweenService:Create(workspace.Lobby.Flicker.JOJO, TIN(.05,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Range = 0}):Play()
						TweenService:Create(workspace.Lobby.Flicker, TIN(.05,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Color = RGB(255, 244, 250)}):Play()
					elseif workspace.Lobby.Flicker.JOJO.Range == 0 then
						workspace.Lobby.Flicker.Material = "Neon"
						TweenService:Create(workspace.Lobby.Flicker.JOJO, TIN(.05,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Range = 5}):Play()
						TweenService:Create(workspace.Lobby.Flicker, TIN(.05,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Color = RGB(158, 158, 158)}):Play()
					end
				end
				if tick()-Ticks.TrainTick >= 1.1 then
					Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed
					Ticks.TrainTick = tick()
					local Smok = workspace.Lobby.TrainLogoSmoke
					for _,SmokePart in ipairs(Smok:GetChildren()) do
						SmokePart.Transparency = .9
					end
					if Numbers.TrainNum < 12 then
						Numbers.TrainNum = Numbers.TrainNum + 1
						Smok["L"..Numbers.TrainNum].Transparency = 0
					else
						Numbers.TrainNum = 0
					end
				end
			else
			--	TweenService:Create(Lighting, TIN(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Brightness = 10, Ambient = RGB(76, 76, 76), OutdoorAmbient = RGB(0,0,0)}):Play() 
			end

		end

	elseif Player.TeamColor ~= Teams.Lobby.TeamColor then
		Gui.Main.LobbyCommands.Visible = false
		Gui.Main.GameGUI.Visible = (bools.PlayingUltimate and false or true)
		Gui.Main.LobbyGUI.Hint.Visible = false
	end

	PlayerUI.Visible = (Player.TeamColor ~= Teams.Lobby.TeamColor and true or false)
	--Gui.Main.GameGUI.PlayerCommands.Visible = (Player.TeamColor == Teams.InGame.TeamColor)
	if tick() - Ticks.updatePlayerStatus >= 2 then
		Ticks.updatePlayerStatus = tick()
		if CurrentPlayers ~= #Players:GetPlayers() then
			CurrentPlayers = #Players:GetPlayers()
			if Camera:FindFirstChild("PlayerHPs") then
				Camera.PlayerHPs:Destroy()
			end
		end
		if OtherPlayerShown then
			for _,Plyr in ipairs(Players:GetPlayers()) do
				if Plyr.Character and Plyr.Character.HumanoidRootPart then
					if Camera:FindFirstChild("PlayerHPs") == nil then
						local Model 			= Insta("Model")
						Model.Name				= "PlayerHPs"
						Model.Parent			= Camera
					end
					if Camera.PlayerHPs:FindFirstChild(Plyr.Name) == nil then
						local HPBar 			= ReplicatedStorage.GUI.BillboardGui.PlayerHP:Clone()
						HPBar.Name				= Plyr.Name
						HPBar.Player.Namer.Text = Plyr.Name
						HPBar.Adornee			= Plyr.Character.HumanoidRootPart
						HPBar.Parent			= Camera.PlayerHPs
					end
					local HPBar = Camera.PlayerHPs[Plyr.Name]
					if HPBar.Player.Namer.Text == Plyr.Name then
						if HPBar.Player.Namer.Text == "Player" then
							local PlayerStat = Socket:Request("GetPlayerInfo", Plyr.UserId)
							local PlayerLevel = PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel
							local PlayerGuild = PlayerStat.Guild
							if PlayerLevel then
								HPBar.Player.Namer.Text = "Lv " ..PlayerLevel.. " - " ..Plyr.Name
								if PlayerGuild ~= "" then
									HPBar.Player.Guild.Text = "< " ..PlayerGuild.. " >"
									HPBar.Player.Guild.Visible = true
								else
									HPBar.Player.Guild.Visible = false
								end
							else
								HPBar.Player.Namer.Text = Plyr.Name
							end
						end
					end
					if Plyr.Name ~= Player.Name or Plyr.TeamColor == Teams.Team1.TeamColor or Plyr.TeamColor == Teams.Team2.TeamColor then
						if Plyr.TeamColor == Teams.Team1.TeamColor or Plyr.TeamColor == Teams.Team2.TeamColor then
							HPBar.Player.HealthBar.Bar.BackgroundColor3 = Plyr.TeamColor == Teams.Team1.TeamColor and Color3.fromRGB(255, 23, 73) or Color3.fromRGB(78, 173, 255)
							HPBar.Player.HealthBar.Visible = true
							HPBar.Player.Namer.Visible = true
						end
						HPBar.Player.HealthBar.Bar.Size = UDi(.96*(Plyr.Character.Humanoid.Health/Plyr.Character.Humanoid.MaxHealth),0,.5,0)
						HPBar.Adornee = Plyr.Character.HumanoidRootPart
					else
						HPBar.Player.HealthBar.Visible = false
						HPBar.Player.Namer.Visible = false
					end
				end
			end
		end
	end
end)

if Chat then
	Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar.Focused:Connect(function()
		DataValues.LastChatTime = tick()
	end)
end

RunService:BindToRenderStep("Camera", EnumRenderPriority.Camera.Value-1, function()
	if Character and Character.PrimaryPart then
		if tick() - CCReset >= 1 then
			if Numbers.MaxCC > 0 then Numbers.MaxCC = Numbers.MaxCC - 1
			else Numbers.MaxCC = 0 end
			CCReset = tick()
		end
		if DataValues.WatchedIntro == false or bools.ChatEnabled or NewMenu.Parent.DungeonChoose.Visible or bools.OpenShop or Gui.Main.Emotes.Visible or Gui.WeaponPreview.RewardMenu.Visible or Gui.Main.GuildPrompt.Visible or Gui.MainDialogue.Dialogue.Visible or Gui.TutorialScreen.Enabled or Gui.DesktopPauseMenu.Base.Mask.Size.Y.Scale > 0 or Gui.PlayerCardInspect.Enabled or Gui.Mailbox.Main.Visible or (Chat and (Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar:IsFocused() or Chat.Frame.ChatBarParentFrame.Frame.EmojiTray.Visible or Chat.Frame.ChatBarParentFrame.Frame.StickerTray.Visible or tick() - DataValues.LastChatTime < 4)) or Gui.BlacksmithGUI.Enabled or Gui.NovasTerminalGUI.Enabled then
			UserInputService.MouseBehavior = "Default"
			if DataValues.ControllerType == "Keyboard" then
				UserInputService.MouseIconEnabled = true
			elseif DataValues.ControllerType == "Touch" then
				Gui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame").JumpButton.Visible = false
				ContextActionService:GetButton("MouseButton1").Visible = false
				ContextActionService:GetButton("MouseButton2").Visible = false
				ContextActionService:GetButton("CC").Visible = false
				if bools.OpenShop then
					ContextActionService:GetButton("Tab").Visible = false
				end
				ContextActionService:GetButton("LShift").Visible = false
			end
		else
			UserInputService.MouseIconEnabled = false
			UserInputService.MouseBehavior = "LockCenter"
			if DataValues.ControllerType == "Touch" then
				Gui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton").Visible = true
				ContextActionService:GetButton("MouseButton1").Visible = true
				ContextActionService:GetButton("MouseButton2").Visible = true
				ContextActionService:GetButton("CC").Visible = true
				ContextActionService:GetButton("Tab").Visible = true
				ContextActionService:GetButton("LShift").Visible = true
			end
		end
		if DataValues.CameraEnabled then
			if bools.OpenShop then
				if Gui.ShopGUI.Enabled == false and not Gui.BlacksmithGUI.Enabled and Gui.Main.Guilds.Visible == false then
					local rootPos 		= Character.HumanoidRootPart.Position
					local rotation 		= CFAng(0, DataValues.cameraAngles.X, 0) * CFAng(DataValues.cameraAngles.Y, 0, 0)
					local camPos		= CFNew(rootPos) * rotation * CFNew(bools.TPS and Vec3(2.2,2.5,4) or DataValues.CAMERAOFFSET)
					Camera.FieldOfView 	= Numbers.CombatFov
					TweenService:Create(Camera, TIN(0.1 * Options.CameraSmoothing,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {CFrame = camPos}):Play()
				else
					Camera.CFrame = Objs.ShopObj.Camera.CFrame
					Camera.Focus = Objs.ShopObj.CameraF.CFrame
				end
			elseif bools.PlayingTutorial then 
				Camera.CameraSubject = workspace.Tutorial.Baseplate
				Camera.CFrame = workspace.Tutorial.Baseplate.CFrame * CFAng(0,Numbers.TutorialRad,0) * CFNew(0,10,20)
				Numbers.TutorialRad = Numbers.TutorialRad + rad(.4)
			elseif DataValues.WatchedIntro and Character.PrimaryPart then
				if DataValues.SpectatingTarget then
					if not DataValues.SpectatingTarget.Character.PrimaryPart or DataValues.SpectatingTarget.TeamColor == Teams.Lobby.TeamColor or Player.TeamColor ~= Teams.Lobby.TeamColor then
						DataValues.SpectatingTarget = nil
						Gui.SpectatingGUI.Enabled = false
					end
					if workspace.StreamingEnabled then
						local Distance = (DataValues.SpectatingLastUpdatePosition - DataValues.SpectatingTarget.Character.PrimaryPart.Position).Magnitude
						if Distance >= 128 then
							DataValues.SpectatingLastUpdatePosition = DataValues.SpectatingTarget.Character.PrimaryPart.Position
							Player:RequestStreamAroundAsync(DataValues.SpectatingTarget.Character.PrimaryPart.Position)
						end
					end
				end

				local target		= DataValues.SpectatingTarget and DataValues.SpectatingTarget or Player
				local targetChar	= DataValues.SpectatingTarget and DataValues.SpectatingTarget.Character or Character

				local rootPos 		= targetChar.PrimaryPart.Position
				local rotation 		= CFAng(0, DataValues.cameraAngles.X, 0) * CFAng(DataValues.cameraAngles.Y, 0, 0)
				local camPos		= CFNew(rootPos) * rotation * CFNew(bools.TPS and Vec3(2.2,2.5,4) or DataValues.CAMERAOFFSET)

				Camera.FieldOfView 	= target.TeamColor == Teams.Lobby.TeamColor and Numbers.LobbyFov or Numbers.CombatFov
				Camera.CameraType 	= "Scriptable"

				if Objs.LockOn then
					local NewRootPos = rootPos + Vector3.new(0, 4, 0)
					camPos = CFNew(NewRootPos, Vector3.new(Objs.LockOn.Position.X, Character.HumanoidRootPart.Position.Y, Objs.LockOn.Position.Z)) * CFNew(DataValues.CAMERAOFFSET)

					if Options.PopperCam then
						local CameraRay = Ray.new(Character.HumanoidRootPart.Position, camPos.Position - Character.HumanoidRootPart.Position)
						local Ignore = {workspace.Players, EnemiesFolder}
						local HitPart, HitPosition = game.Workspace:FindPartOnRayWithIgnoreList(CameraRay, Ignore)
						if HitPart then
							local CanTurn = true
							if HitPart:IsA("BasePart") and not HitPart.CanCollide then
								CanTurn = false
							end
							if CanTurn then
						    	camPos = (camPos - (camPos.Position - HitPosition)) + (Character.HumanoidRootPart.Position - camPos.Position).Unit
							end
						end
					end
					TweenService:Create(Camera, LockTweenInfo, {CFrame = camPos}):Play()
				else
					if Options.PopperCam then
						local CameraRay = Ray.new(targetChar.HumanoidRootPart.Position, camPos.Position - targetChar.HumanoidRootPart.Position)
						local Ignore = {workspace.Players, EnemiesFolder}
						local HitPart, HitPosition = game.Workspace:FindPartOnRayWithIgnoreList(CameraRay, Ignore)
						if HitPart then
							local CanTurn = true
							if HitPart:IsA("BasePart") and not HitPart.CanCollide then
								CanTurn = false
							end
							if CanTurn then
						    	camPos = (camPos - (camPos.Position - HitPosition)) + (targetChar.HumanoidRootPart.Position - camPos.Position).Unit
							end
						end
					end

					if Options.CameraSmoothing > 0 then
						local TimeSmooth = 0.1 * Options.CameraSmoothing
						TweenService:Create(Camera, TIN(TimeSmooth,Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0, false, 0), {CFrame = camPos}):Play()
					else
						Camera.CFrame = camPos
					end
				end
				if Humanoid.Health <= Humanoid.MaxHealth *.3 then
					local fullHP = Humanoid.MaxHealth *.3
					local CurrentHealth = Humanoid.Health
					TweenService:Create(ColorCorrection, TIN(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Saturation = 0-(1.2*((fullHP-CurrentHealth)/fullHP)), TintColor = RGB(255, 255-(63*((fullHP-CurrentHealth)/fullHP)), 255-(63*((fullHP-CurrentHealth)/fullHP)))}):Play() 
				else
					TweenService:Create(ColorCorrection, TIN(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Saturation = 0, TintColor = RGB(255,255,255)}):Play()
				end
			end
		end
		if Ticks.Combo_Time ~= nil and tick() - Ticks.Combo_Time >= 4 then
			PlayerUI.Left.ComboCounter.Counter.Text = 0
			PlayerUI.Left.ComboCounter.DamageIncrease.Text = "ATKx1"
		end
		if PlayerUI.Left.BossHPBar.Visible then
			if os.time()-Ticks.UnderbarTimer >= 3 then
				TweenService:Create(PlayerUI.Left.BossHPBar.Underbar, TIN(0.5), {Size = UDi(PlayerUI.Left.BossHPBar.Bar.Size.X.Scale,0,.7,0)}):Play()
			end
		end
		if Player.TeamColor ~= Teams.Lobby.TeamColor then
			local HumanoidR = Character.Humanoid
			local CurrentHealthR = Floor((ReplicatedStorage.PlayerValues[Player.Name].Barrier.Value + Humanoid.Health) + 0.5)
			PlayerUI.Left.Bars.HPBar.Amnt.Text = string.format("%s / %s", CurrentHealthR, Floor(HumanoidR.MaxHealth + 0.5))
			if bools.IsSpecial then
				PlayerUI.Left.Bars.ZSpecialBar.Visible = true
				PlayerUI.Left.Bars.ZSpecialBar.Amnt.Text= Floor(Numbers.SpecialBar+.5).. " / 100"
			else
				PlayerUI.Left.Bars.ZSpecialBar.Visible = false
			end
			if tick() - Ticks.HPHurt >= 2 then
				Ticks.HPHurt = tick()
				PlayerUI.Left.Bars.HPBar.Bar2.Visible 	= false
				Numbers.oldScale						= PlayerUI.Left.Bars.HPBar.Bar.Size.X.Scale
			end
			if Numbers.CritWounds <= 0 then
				Numbers.CritWounds = 0
				PlayerUI.Left.Bars.HPBar.Bar3.Visible	= false
			end
		end
	end
end)

local tbi = table.insert
local tbr = table.remove

--[[ Client Input Requests ]]--

local function StateHasChanged(old, new)
	DataValues.state = new.Name
	if DataValues.state == "Landed" or DataValues.state == "Running" or DataValues.state == "RunningNoPhysics" then
		CanJump = true
		bools.JumpRequest = false
	end
	if DataValues.state == "Jumping" and (old ~= "Jumping" and old ~= "Freefall") then
		if DoubleJumpCD then return end
		DoubleJumpCD = true
		Mover.Parent = nil
		wait(0.25)
		DoubleJumpCD = false
	end
end

UserInputService.JumpRequest:Connect(function()
	if not bools.ded and not bools.PlayingUltimate then
		if DataValues.state == "Freefall" or DataValues.state == "Jumping" then
			if CanJump == false or DoubleJumpCD then return end
			Ticks.FloatTime = tick() - 10
			CanJump = false
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			if bools.IsCryForm then
				Character.HumanoidRootPart.Velocity = Vec3(0, 60, 0)
			else
				Character.HumanoidRootPart.Velocity = Vec3(0, 40, 0)
			end
			Effects.MagicCircleEffect(Character.HumanoidRootPart.CFrame)
			Character.AlignPosition.Enabled = false
		else
			local FocusPoint = Character.HumanoidRootPart.Position
			local NearestTorso,Proximity = nil,4
			local enemi = EnemiesFolder:GetChildren()
			for i=1, #enemi do
				local enemies = enemi[i]
				if enemies:FindFirstChild("Torso") then
					local Distance = (enemies.HumanoidRootPart.Position - FocusPoint).magnitude
					if Distance < Proximity then
						Character.HumanoidRootPart.Velocity = Vec3(0, 75, 0)
						Effects.MagicCircleEffect(Character.HumanoidRootPart.CFrame)
						Character.AlignPosition.Enabled = false
						break
					end
				end
			end
		end
	end
end)

do
	local function HealthHasChanged(Health)
		if DataValues.WatchedIntro then
			local HealthPercentage = Humanoid.Health/(Numbers.OriginalMaxHP)
			PlayerUI.Left.Bars.HPBar.Bar.Size = UDi(0.98 * (HealthPercentage), 0, 0.7, 0)
			if tick() - Ticks.HPHurt < 2 then
				Ticks.HPHurt = tick()
				PlayerUI.Left.Bars.HPBar.Bar2.Visible = true
				PlayerUI.Left.Bars.HPBar.Bar2.Position = UDi(PlayerUI.Left.Bars.HPBar.Bar.Size.X.Scale + 0.02, 0, 0.1, 0)
				PlayerUI.Left.Bars.HPBar.Bar2.Size 	= UDi(Numbers.oldScale-PlayerUI.Left.Bars.HPBar.Bar.Size.X.Scale, 0, 0.7, 0)
			end
			if Health < CurrentHealth then
				if bools.HealthDebounce == false then
					bools.HealthDebounce = true
					local Magni 	= 30
					local Pos 		= Character.HumanoidRootPart.Position
					local DropOff 	= (Camera.CFrame.Position - Pos).Magnitude
					Magni 			= Magni-DropOff/5
					for i = 1, Magni do
					    local rand1 = Rand(-5-(Magni/8),5+(Magni/8))*.01/(i+DropOff/5)	
					    local rand2 = Rand(-5-(Magni/8),5+(Magni/8))*.01/(i+DropOff/5)
					    local rand3 = Rand(-5-(Magni/8),5+(Magni/8))*.01/(i+DropOff/5)
					    Camera.CFrame = Camera.CFrame * CFrame.fromEulerAnglesXYZ(rand1,rand3,rand2)
					   	RunService.RenderStepped:wait()
					    Camera.CFrame = Camera.CFrame * CFrame.fromEulerAnglesXYZ(-rand1,-rand3,-rand2)
					end
					wait(3)
					bools.HealthDebounce 			= false
				end
			end
			CurrentHealth = Health
			if HealthPercentage <= .3 then
				if tick() - Ticks.Last_Flashing >= 2 then
					Ticks.Last_Flashing = tick()
					for i = .7,1,.05 do
						PlayerUI.Left.Bars.HPBar.Bar.BackgroundTransparency = i
						RunService.RenderStepped:wait()
					end
					for i = 1,.7,-.05 do
						PlayerUI.Left.Bars.HPBar.Bar.BackgroundTransparency = i
						RunService.RenderStepped:wait()
					end
					PlayerUI.Left.Bars.HPBar.Bar.BackgroundTransparency = .5
				end
			elseif HealthPercentage >= .5 or HealthPercentage <= 0 then
				bools.LowHPWarning = false
			end
		end
	end
	
	Humanoid.StateChanged:connect(function(old,new)
		StateHasChanged(old,new)
	end)
	Humanoid.HealthChanged:connect(function(Health)
		HealthHasChanged(Health)
	end)
	
	Socket:Listen("SpecialBarReset", function(Amnt)
		if bools.IsSpecial then
			Numbers.SpecialBar = Amnt and Amnt or 0
			PlayerUI.Left.Bars.ZSpecialBar.Bar.Size = UDi(0, 0, 0.7, 0)
		end
	end)
	
	Socket:Listen("Respawned", function(newChar, bol, sg)
		repeat wait() until game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") and game:GetService("Players").LocalPlayer.Character.Humanoid.Health >= 100
		local bool = bol or false
		DataValues.WatchedIntro = false
		if DataValues.ControllerType == "Touch" then
			DataValues.ControllerType = "Keyboard"
		end
		bools.TPS = false
		Player = Players.LocalPlayer
		Character = Player.Character or Player.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")
		RootPart = Character:WaitForChild("HumanoidRootPart")
		Camera.CameraSubject = RootPart
		Humanoid.StateChanged:connect(function(old,new)
			StateHasChanged(old,new)
		end)
		Humanoid.HealthChanged:connect(function(Health)
			HealthHasChanged(Health)
		end)
		local HealthPercentage 				= Humanoid.Health/Humanoid.MaxHealth
		PlayerUI.Left.Bars.HPBar.Bar.Size = UDi(.98*(HealthPercentage),0,.7,0)
		DataValues.MenuOpening = false
		bools.IsCryForm = false
		bools.Debounce = false
		bools.IsDodging = false
		bools.IsBlocking = false
		if DataValues.Inputs ~= nil then
			for _,inputs in next, DataValues.Inputs do
				print(typeof(inputs))
				inputs:Disconnect()
				inputs = nil
			end
		end
		DataValues.Inputs = nil
		for _,inputs in next, DataValues.StatInputs do
			inputs:Disconnect()
			inputs = nil
		end
		DataValues.StatInputs = {}
		DataValues.CurrentSelectedSkill = nil
		for _,inputs in next, DataValues.SkillInputs do
			inputs:Disconnect()
			inputs = nil
		end
		DataValues.SkillInputs = {}
		for _,inputs in next, DataValues.InventoryInputs do
			inputs:Disconnect()
			inputs = nil
		end
		DataValues.InventoryInputs = {}
		for _,inputs in next, DataValues.Norm do
			inputs:Disconnect()
			inputs = nil
		end
		DataValues.Norm = {}
		for _,inputs in next, DataValues.LearnInputs do
			inputs:Disconnect()
			inputs = nil
		end
		DataValues.LearnInputs = {}
		DataValues.WatchedIntro = true
		if Character:FindFirstChild("AlignPosition") then
			Character.AlignPosition.Attachment0 = Character.PrimaryPart.RootRigAttachment
			Character.AlignPosition.Attachment1 = AlignPositionAttachment 
		end
		bools.ded = false
		print("RESETED!")
		if bool and Player.TeamColor ~= Teams.Lobby.TeamColor then
			print("IN GAME!")
			BattleModeON(sg)
		end
	end)
	
	Socket:Listen("Warning", function(DontKeepLastMusic, PlayWarningSound)
		if DataValues.WatchedIntro then
			FS.spawn(function()
				local PreviousMusic = MusicPlayer:GetCurrentMusic()
				if PlayWarningSound == nil then
					MusicPlayer:Play(game.ReplicatedStorage.Sounds.Music.Warning, 1)
				end
				wait(10)
				if DontKeepLastMusic == nil then
					MusicPlayer:Play(PreviousMusic, 1)
				end
			end)
			local Warning = Gui.Main.GameGUI.WarningSign
			local Stuff = Warning.BG.BG
			local t1 = true
			Warning.Visible = true
			TweenService:Create(Warning, TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Size = UDi(1,0,.2,0), Position = UDi(0,0,.4,0)}):Play() wait(.3)
			TweenService:Create(Stuff.WarningLabel2.WarningLabel2, TweenInfo.new(14,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Position = UDi(0,0,0,0)}):Play()
			TweenService:Create(Stuff.WarningLabel2.WarningLabel2, TweenInfo.new(.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = .4}):Play() wait(.05)
			TweenService:Create(Stuff.WarningLabel.WarningLabel, TweenInfo.new(.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = .6}):Play() wait(.1)
			FS.spawn(function()
				if t1 then
					t1 = false
					for i = 1, 5 do
						TweenService:Create(Stuff.WarningLabel, TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = .4}):Play() wait(2)
						TweenService:Create(Stuff.WarningLabel, TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(.8)
					end
				end
			end) 
			TweenService:Create(Stuff.BarsLeft.Bars, TweenInfo.new(7,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Position = UDi(0,0,0,0)}):Play()
			TweenService:Create(Stuff.BarsRight.Bars, TweenInfo.new(7,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Position = UDi(0,0,0,0)}):Play()
			wait(6)
			TweenService:Create(Stuff.WarningLabel2.WarningLabel2, TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play()
			TweenService:Create(Stuff.WarningLabel.WarningLabel, TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play()
			TweenService:Create(Stuff.WarningLabel, TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() 
			TweenService:Create(Warning, TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Size = UDi(0,0,.2,0), Position = UDi(0.5,0,.4,0)}):Play() wait(.3)
			Warning.Visible = false
			wait(8)
			Stuff.WarningLabel2.WarningLabel2.Position = UDi(-1.2,0,0,0)
			Stuff.BarsLeft.Bars.Position = UDi(-2.5,0,0,0)
			Stuff.BarsRight.Bars.Position = UDi(-2.5,0,0,0)
		end
	end)
	
	Socket:Listen("ValeriBeams", function(Type, arg1, arg2)
		local CFN, CFA, MRAD = CFrame.new, CFrame.Angles, math.rad
		if Type == "Create" then
			for i = 1, #arg1 do
				local laser = DataValues.ValeriBeamsPool:GetPart()
				if laser ~= nil then
					laser.CFrame = arg1[i].StartCF
					laser.StringValue.Value = arg1[i].ID
					table.insert(DataValues.ActiveValeriBeams, laser)
				end
			end
		elseif Type == "MoveBeams" then
			for _,Beam in ipairs(DataValues.ActiveValeriBeams) do
				for _, BeamObject in ipairs(arg1) do
					if Beam.StringValue.Value == BeamObject.ID then
						Beam.CFrame = CFN(BeamObject.OldPos:lerp(BeamObject.Position, 0.5), BeamObject.Position)
					end
				end
			end
		elseif Type == "DestroyBullet" then
			for _, Beam in ipairs(DataValues.ActiveValeriBeams) do
				local BeamObject = arg1
				if Beam.StringValue.Value == BeamObject.ID then
					Beam.StringValue.Value = ""
					for index, potentialLaser in ipairs(DataValues.ActiveValeriBeams) do
						if potentialLaser == Beam then
							table.remove(DataValues.ActiveValeriBeams, index)
							break
						end
					end
					DataValues.ValeriBeamsPool:ReturnPart(Beam)
					break
				end
			end
		end
	end)
	
	Socket:Listen("Deflect", function(pos, uber, ClassName)
		local Deflection = true
		if Objs.AnimTrack == nil then
			if ClassName == "LingeringForce" then
				local Deflections = Character.Animate.attackdeflection:GetChildren()
				local ChosenDeflect = Deflections[Random.new():NextInteger(1, #Deflections)]
				if ChosenDeflect then
					local DeflectAnim = Humanoid:LoadAnimation(ChosenDeflect)
					DeflectAnim:Play()
				end
			elseif ClassName == "LingeringForceL" then
				Deflection = false
				local Deflections = Character.Animate.attacklaserdodge:GetChildren()
				local ChosenDeflect = Deflections[Random.new():NextInteger(1, #Deflections)]
				if ChosenDeflect then
					local DeflectAnim = Humanoid:LoadAnimation(ChosenDeflect)
					DeflectAnim:Play()
				end
			end
		end
		if Deflection then
			local Ub = uber or false
			local BulletPrefab = DataValues.BulletPool:GetPart()
			BulletPrefab.PrimaryPart.CFrame = Character.HumanoidRootPart.CFrame
			TweenService:Create(BulletPrefab.PrimaryPart, TIN(Ub and .2 or .4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {CFrame = pos.CFrame}):Play()
			FS.spawn(function()
				wait(Ub and .2 or .4)
				DataValues.BulletPool:ReturnPart(BulletPrefab)
			end)
			local Slash = DataValues.DeflectPool:GetPart()
			if Slash ~= nil then
				local CF = CFNew(Character.HumanoidRootPart.Position, pos.Position) * CFNew(0,0,-5)
				Slash.CFrame = CF
				TweenService:Create(Slash, TIN(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {CFrame = CF, Size = Vec3(10,10,0.05), Transparency = 1}):Play()	
				Slash.Parent = workspace.Terrain
				wait(.9)
				Slash.Size = Vec3(5, 5, 0.05)
				Slash.Transparency = 0.8
				DataValues.DeflectPool:ReturnPart(Slash)
			end
		end
	end)

	ReplicatedStorage.Sockets.Bullets.OnClientEvent:Connect(function(EnemyData)
		--- Sychronizes the bullet positions
		for v, i in ipairs(EnemyData) do
			for _,Bullet in ipairs(DataValues.Bullets) do
				if Bullet.ID == EnemyData[v][2] then
					Bullet.Tick = EnemyData[v][3]
					Bullet.Obj.PrimaryPart.CFrame = CFNew(Bullet.Obj.PrimaryPart.Position:lerp(EnemyData[v][1].Position, 0.5), EnemyData[v][1].Position)
				end
			end
		end
	end)
	
	Socket:Listen("EnemyAnimate", function(EnemyData, Animation, Delay)
		if Animation == "MakeBullet" then
			--- Creates a bullet
			local Bullet = DataValues.BulletPool:GetPart()
			if Bullet ~= nil then
				local BulletStuff = {}
				BulletStuff.Obj = Bullet
				BulletStuff.Tick = Delay.Tick
				BulletStuff.MaxTick = Delay.MaxTick
				BulletStuff.CFrame = Delay.CFrame
				BulletStuff.ID = Delay.ID
				BulletStuff.Speed = Delay.Speed
				tbi(DataValues.Bullets, BulletStuff)
				Bullet.PrimaryPart.CFrame = BulletStuff.CFrame
				
				local Sound = Bullet.PrimaryPart.BulletHellShoot
				Sound.PitchShiftSoundEffect.Octave = Rando():NextNumber(.7, 1.4) 
				Sound:Play()
			end
		elseif Animation == "RemoveBullets" then
			for i, Bullet in ipairs(DataValues.Bullets) do
				for v, NewBullet in ipairs(Delay) do
					if Bullet ~= nil and Bullet.ID == NewBullet.ID then
						DataValues.BulletPool:ReturnPart(Bullet.Obj)
						tbr(DataValues.Bullets, i)
					end
				end
			end
		else
			for _, enemies in ipairs(DataValues.Enemies) do
				if enemies.Auto == false and enemies.HRP ~= nil and enemies.HRP == EnemyData.Torso and enemies.HRP.Parent.Parent:FindFirstChild("Humanoid") then
					if enemies.Animation ~= nil and enemies.Attacking == false then
						enemies.Animation:Stop()
						enemies.Animation:Destroy()
						enemies.Animation = nil
					end
					local AnimController = enemies.HRP.Parent.Parent.Humanoid
					if EnemyData.Configuration.Type == "Melee" then
						if Animation == "KnockedBack" then
							local Anim = AnimController:LoadAnimation(Delay == 1 and ReplicatedStorage.Scripts.EnemyAnimations[enemies.Name].attacked.hurt2 or ReplicatedStorage.Scripts.EnemyAnimations[enemies.Name].attacked.hurt1)
							Anim:Play()
							enemies.Animation = Anim
						elseif Animation == "Running" and enemies.Attacking == false then
							local Anim = AnimController:LoadAnimation(ReplicatedStorage.Scripts.EnemyAnimations[enemies.Name].run.RunAnim)
							Anim:Play()
							Anim:AdjustSpeed(20/16)
							enemies.Animation = Anim
						elseif Animation == "Standing" and enemies.Attacking == false then
							local Anim = AnimController:LoadAnimation(ReplicatedStorage.Scripts.EnemyAnimations[enemies.Name].idle.Animation1)
							Anim:Play()
							enemies.Animation = Anim
						elseif Animation == "Attack" then
							enemies.Attacking = true
							local Anim = AnimController:LoadAnimation(ReplicatedStorage.Scripts.EnemyAnimations[enemies.Name].attackX.X1)
							Anim.KeyframeReached:connect(function(KF)
								if KF == "Alert" then
									local Alert = Modules["Effects"].MiscEffects.Alert:clone()
									Alert.CFrame = enemies.HRP.Parent.Parent.Head.CFrame*CFNew(0,0,-.5)
									Alert.Parent = enemies.HRP.Parent.Parent
									Debris:AddItem(Alert, .4)
									TweenService:Create(Alert.Beam, TIN(.35,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Width1 = 70}):Play() 
								end
							end)
							Anim:Play()
							enemies.Animation = Anim
							enemies.Attacking = false
						end
					end
					break
				end
			end		
		end
	end)
	Socket:Listen("MusicChange", function(Mode, MusicName, FDO, FDI)
		if Mode == "Play" then
			if Options.PlayMusic and ReplicatedStorage.Sounds.Music:FindFirstChild(MusicName) then
				MusicPlayer:Play(ReplicatedStorage.Sounds.Music[MusicName], FDO and FDO or 1.5, nil, FDI)
			end
		elseif Mode == "Stop" then
			MusicPlayer:Stop(FDO and FDO or 1.5)
		end
	end)
	Socket:Listen("EnemyStatus", function(EnemyData, Status, nan, OK)
		local Overkill = OK or 0
		local KilledBy = nan or ""

		local MAXHPLEVEL = 30
		local HP = 0
		local HPLevels = {}
		local HPLevelCurrent = MAXHPLEVEL + 1
		local splitValue = 0

		if Status == "BossHP" and PlayerUI.Left.BossHPBar.Visible then
			Ticks.UnderbarTimer = os.time()

			HP = EnemyData.Configuration.HP
			splitValue = EnemyData.Configuration.MAXHP/MAXHPLEVEL

			for i = 0, MAXHPLEVEL do
				table.insert(HPLevels, 0 + (splitValue * i))
			end

			local value = HPLevelCurrent - 1
			local nextStage = HPLevelCurrent > 1 and HPLevels[HPLevelCurrent - 1] or 0
			local CurrentValue = HP - nextStage
			while CurrentValue <= 0 and nextStage ~= 0 do
				HPLevelCurrent = math.max(1, HPLevelCurrent - 1)
				nextStage = HPLevelCurrent > 1 and HPLevels[HPLevelCurrent - 1] or 0
				CurrentValue = HP - nextStage
				value = HPLevelCurrent - 1
			end

			PlayerUI.Left.BossHPBar.Levels.Visible = value > 1 and true or false
			PlayerUI.Left.BossHPBar.Levels.Text = string.format("x%s", value)
			PlayerUI.Left.BossHPBar.Bar.Size = UDi(0.98 * (CurrentValue / splitValue), 0, 0.7, 0)
			if PlayerUI.Left.BossHPBar.Bar.Size.X.Scale > PlayerUI.Left.BossHPBar.Underbar.Size.X.Scale then
				PlayerUI.Left.BossHPBar.Underbar.Size = UDi(0.98 * (CurrentValue / splitValue), 0, 0.7, 0)
			end
			local newFlash = PlayerUI.Left.BossHPBar.Flash:Clone()
			newFlash.Position = UDim2.new(PlayerUI.Left.BossHPBar.Bar.Size.X.Scale - 0.1, 0, 0.5, 0)
			newFlash.Parent = PlayerUI.Left.BossHPBar
			Debris:AddItem(newFlash, 1)

			TweenService:Create(newFlash, TIN(0.8), {
				Size = UDim2.new(0.2, 0, 5, 0),
				ImageTransparency = 1
			}):Play() wait(.1)

		elseif Status == "Spawn" then
			local Enemy = {}
			Enemy.HRP = EnemyData.Torso
			Enemy.Animation = nil
			Enemy.Attacking = false
			Enemy.Auto = EnemyData.Auto
			if EnemyData.Boss or (EnemyData.Auto and Enemy.HRP:FindFirstChildOfClass("BoolValue") == nil) then
				PlayerUI.Left.BossHPBar.Namer.Text = EnemyData.Configuration.Name
				PlayerUI.Left.BossHPBar.Bar.Size = UDi(.98,0,.7,0)
				PlayerUI.Left.BossHPBar.Underbar.Size = UDi(.98,0,.7,0)
				PlayerUI.Left.BossHPBar.Visible = true
			end
			Enemy.Name = EnemyData.Configuration.Name
			local function CollisionID(model)
				local Ri = model:GetChildren()
				for i = 1, #Ri do
					if Ri[i]:IsA("MeshPart") or Ri[i]:IsA("Part") then
						Ri[i].CollisionGroupId = 1
					elseif Ri[i]:IsA("Model") then
						CollisionID(Ri[i])
					end
				end
			end
			if EnemyData.Auto == false then
				local Rig = EnemyData.Configuration.ArmorModel == "BossManSuit" and ReplicatedStorage.EnemyType.BossMan:Clone() or ReplicatedStorage.EnemyType.EnemyR15:Clone()
				Rig.Humanoid.MaxHealth = EnemyData.Configuration.HP
				Rig.Humanoid:SetStateEnabled(EnumHumanoidStateType.Climbing, false)
				Rig.Humanoid:SetStateEnabled(EnumHumanoidStateType.Swimming, false)
				Rig.Parent = EnemiesFolder
				Enemy.HRP.Transparency = 1
				Enemy.HRP.CanCollide = true
				
				Enemy.HRP.Parent.Parent = Rig
				Rig:MoveTo(Enemy.HRP.Position)
				local obj = game.ReplicatedStorage.Models.Armor:FindFirstChild(EnemyData.Configuration.ArmorModel)
				CollisionID(Rig)
			else
				local enemyName = string.gsub(Enemy.Name, '%b()', '')
				local modifiedName = string.gsub(enemyName, '^%s*(.-)%s*$', '%1') 
				Effects.CreateHitEffects(modifiedName, Enemy.HRP.Parent)
				CollisionID(EnemyData.Torso.Parent)
			end
			DataValues.Enemies[#DataValues.Enemies+1] = Enemy
		elseif Status == "Died" then
			for i = 1, #DataValues.Enemies do
				if DataValues.Enemies[i].HRP == EnemyData.Torso then
					if DataValues.Enemies[i].HRP == Objs.LockOn then
						if DataValues.Enemies[i].HRP:FindFirstChild("LockOn") then
							DataValues.Enemies[i].HRP.LockOn:Destroy()
						end
						Objs.LockOn = nil
					end
					if EnemyData.Boss then
						PlayerUI.Left.BossHPBar.Visible = false
					end

					local Enemy = DataValues.Enemies[i].Auto and DataValues.Enemies[i].HRP.Parent or DataValues.Enemies[i].HRP.Parent.Parent
					Debris:AddItem(Enemy, DataValues.ControllerType == "Touch" and 4 or 10)

					local EXPS = {}
					if Options.ParticleEffects then
						local OldHRP = Enemy.HumanoidRootPart
						for i=1,Rand(2,4) do
							if OldHRP ~= nil then
								local Attach1 = Insta("Attachment")
								Attach1.Position = Vec3(Rand(-8,8),Rand(5,7),Rand(-8,8))
								Debris:AddItem(Attach1, 5)
								Attach1.Parent = OldHRP
								local EXP1 = Modules["Effects"].MiscEffects.Exp:clone()
								EXP1.CFrame = OldHRP.CFrame
								EXP1.Parent = Character
								EXP1.Velocity = (Attach1.WorldPosition-OldHRP.Position).unit*Rand(95,108)
								Debris:AddItem(EXP1, 3.5)
								tbi(EXPS,EXP1)
							end
						end
					end
					local oldHP = Enemy.Humanoid.MaxHealth
					local OverKillSign = ReplicatedStorage.GUI.BillboardGui.Overkill:Clone()
					OverKillSign.Enabled = true
					OverKillSign.Parent = Enemy.HumanoidRootPart
					DataValues.Enemies[i].HRP.CanCollide = false
					showS( OverKillSign.Menu.Number, 0, Floor(Overkill+.5), Numbers.duration, Numbers.fps )
					tbr(DataValues.Enemies, i)
					if Options.ParticleEffects and Player.TeamColor ~= Teams.Lobby.TeamColor then
						FS.spawn(function()
							wait(.4)
							for i = 1, #EXPS do
								local duration = Rand(7,9)*.1
								Debris:AddItem(EXPS[i], duration+.2)
								TweenService:Create(EXPS[i], TIN(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {CFrame = Character.HumanoidRootPart.CFrame}):Play() 
							end
						end)
						wait()
					end
					break
				end
			end
		end
	end)
	Socket:Listen("ParryAnimation", function(Target, AnimObj)
		Character.HumanoidRootPart.Anchored = true
		local Playing = false
		Humanoid.WalkSpeed = 0
		local CamAngle = script.Parent.MoonCam.Animations:FindFirstChild(AnimObj.AnimationId)
		if CamAngle then
			DataValues.CameraEnabled = false
			CamAngle.Settings.Reference.Value = Character.PrimaryPart
			CamAngle.Settings.Reference.Has.Value = true
			script.Parent.MoonCam.Play:Fire(AnimObj.AnimationId)
		end
		local Offset;
		local TargOffset
		if AnimObj:FindFirstChild("CF") then
			Offset = CFNew(AnimObj.CF.Value.X, AnimObj.CF.Value.Y, AnimObj.CF.Value.Z)
		else
			Offset = CFNew()
		end
		if AnimObj:FindFirstChild("HipHeight") then
			TargOffset = Target.Humanoid.HipHeight
			Target.Humanoid.HipHeight = AnimObj.HipHeight.Value
		end
		local TPd = false
		local OldCF = Character.HumanoidRootPart.CFrame
		local Anim = Character.Humanoid:LoadAnimation(AnimObj)
		Anim.KeyframeReached:connect(function(KF)
			if KF == "PlayFalse" then
				Playing = false
			elseif KF == "PlayerAnimationEnd" then
				DataValues.CameraEnabled = true
				TPd = true
				Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
				Character.Humanoid.AutoRotate = true
				Character.HumanoidRootPart.Anchored = false
				Character.HumanoidRootPart.CFrame = OldCF
				if TargOffset then
					Target.Humanoid.HipHeight = TargOffset
				end
				Playing = false
				if CamAngle then
					script.Parent.MoonCam.Stop:Fire()
					CamAngle.Settings.Reference.Value = nil
					CamAngle.Settings.Reference.Has.Value = false
				end
				Anim:Stop()
				Anim:Destroy()
			end
		end)
		Playing = true
		FS.spawn(function()
			FS.spawn(function()
				wait(1)
				wait(Anim.Length ~= 0 and Anim.Length+1 or 5)
				Playing = false
				DataValues.CameraEnabled = true
				Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
				if not TPd then
					Character.Humanoid.AutoRotate = true
					Character.HumanoidRootPart.Anchored = false
					Character.HumanoidRootPart.CFrame = OldCF
				end
				if CamAngle then
					script.Parent.MoonCam.Stop:Fire()
					CamAngle.Settings.Reference.Value = nil
					CamAngle.Settings.Reference.Has.Value = false
				end
			end)
			while Playing do
				Humanoid.WalkSpeed = 0
				Character.HumanoidRootPart.Anchored = true
				Character.HumanoidRootPart.CFrame = Target.PrimaryPart.CFrame * Offset
				RunService.Heartbeat:wait()
			end
		end)
		Character.Humanoid.AutoRotate = false
		Anim:Play()
	end)
	
	Socket:Listen("LootFound", function(tbl, PlayerBanners, TopScores, Timeelapsed, SpecialRewards)
		if Player.TeamColor == Teams.Lobby.TeamColor then
			if Lighting:FindFirstChild("Sky") then
				Lighting.Sky:Destroy()
			end
			Lighting.Brightness = 0
			Lighting.Ambient = RGB(31, 31, 31)
			Lighting.ColorShift_Bottom = RGB(97, 112, 109)
			Lighting.ColorShift_Top = RGB(108, 122, 131)
			Lighting.ClockTime = 20
			Lighting.GeographicLatitude = 41.733
			Lighting.FogColor = RGB(172, 182, 180)
			FS.spawn(function()
				wait(3)
				if Character then
					Character.Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed
				end
			end)
		end
		if PlayerBanners and TopScores then
			Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.Position = UDi(1, 0, 0, 0)
			Gui.WeaponPreview.RewardMenu.Visible = true
			TweenService:Create(Blur, TIN(2), {Size = 39}):Play()
			TweenService:Create(Gui.WeaponPreview.RewardMenu, TIN(2), {BackgroundTransparency = .3}):Play()
			TweenService:Create(Gui.WeaponPreview.RewardMenu.MissionComplete, TIN(2), {TextTransparency = 0, Position = UDi(0, 0, .1, 0)}):Play()
			TweenService:Create(Gui.WeaponPreview.RewardMenu.DungeonPlayerShow, TIN(2, Enum.EasingStyle.Elastic), {Position = UDi(0, 0, 0, 0)}):Play()
			Gui.WeaponPreview.RewardMenu.Time.Text = "Clear Time - " .. toClock(Timeelapsed, true)
			TweenService:Create(Gui.WeaponPreview.RewardMenu.Time, TIN(2), {TextTransparency = 0, Position = UDi(0, 0, .18, 0)}):Play()
			table.sort(TopScores.DamageDealt, function(a,b) return a[2] > b[2] end)
			table.sort(TopScores.HighestCombo, function(a,b) return a[2] > b[2] end)
			table.sort(TopScores.DodgedAttacks, function(a,b) return a[2] > b[2] end)
			table.sort(TopScores.DamageTaken, function(a,b) return a[2] > b[2] end)
			table.sort(TopScores.SupportSkills, function(a,b) return a[2] > b[2] end)
			table.sort(TopScores.Revivals, function(a,b) return a[2] > b[2] end)
			local PlayerShows = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.DungeonPlayerShow2:GetChildren()
			for i = 1, #PlayerShows do
				if not PlayerShows[i]:IsA("UIGridLayout") then
					PlayerShows[i]:Destroy()
				end
			end
			local LootShows = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.LootFound.DungeonPlayerShow2:GetChildren()
			for i = 1, #LootShows do
				if not LootShows[i]:IsA("UIGridLayout") then
					LootShows[i]:Destroy()
				end
			end
			if #TopScores.DamageDealt > 0 then
				local NewQuip = Gui.WeaponPreview.RewardMenu.Templates.Quip:Clone()
				NewQuip.Visible = true
				NewQuip.Frame.Val.Text = "Damage Dealt"
				NewQuip.Parent = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.DungeonPlayerShow2
				local TotalValue = 0
				for i = 1, #TopScores.DamageDealt do
					local PlayerObj = TopScores.DamageDealt[i]
					local PlayerName = PlayerObj[1]
					local Value = PlayerObj[2]
					local NewPlayerBar = Gui.WeaponPreview.RewardMenu.Templates.Player1:Clone()
					NewPlayerBar.Namer.Text = PlayerName.. " - " .. Value
					NewPlayerBar.Visible = true
					NewPlayerBar.Parent = NewQuip.Frame.Bars
					TotalValue = TotalValue + Value
					FS.spawn(function()
						wait(2)
						TweenService:Create(NewPlayerBar.Bar, TIN(1), {Size = UDi(.98*(Value / TotalValue), 0, .7, 0)}):Play()
					end)
				end
				FS.spawn(function()
					wait(2.25)
					TweenService:Create(NewQuip.Frame.Banner, TIN(1), {Position = UDi(0, 0, .15, 0)}):Play()
					local PlayerName = TopScores.DamageDealt[1][1]
					local BG;
					for v = 1, #PlayerBanners do
						if PlayerBanners[v].User == PlayerName then
							BG = PlayerBanners[v].Banner
						end
					end
					local Banner = NewQuip.Frame.Banner
					local Banners = ReplicatedStorage.Images.Banners
					if Banners:FindFirstChild(BG) then
						Banner.BannerImg.Image = Banners[BG].Image
					end
					Banner.BannerImg.PlayerName.Text = PlayerName
					Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
					Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
					if ReplicatedStorage.Images.Banners[BG]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[BG]:FindFirstChild("NumOfSprites") then
						Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
						FS.spawn(function()
							local CanContinue = true
							FS.spawn(function()
								while wait() and CanContinue do
									if Banner.BannerImg.Image == "" then
										CanContinue = false
									end
								end
							end)
							while Banner.BannerImg.Image ~= "" and CanContinue do
								Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
								Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
								local NumOfSpritesX = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X or 3
								local NumOfSpritesY = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y or 9
								Animate(Banner.BannerImg, false, NumOfSpritesX, NumOfSpritesY, ReplicatedStorage.Images.Banners[BG].Framerate.Value, 0,0, ReplicatedStorage.Images.Banners[BG].Maxframes.Value)
					--			wait((1/ReplicatedStorage.Images.Banners[BG].Framerate.Value)*(ReplicatedStorage.Images.Banners[BG].Maxframes.Value)+.5)
							end
						end)
					end
					FS.spawn(function()
						wait(10)
						Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
						Banner.BannerImg.Image = ""
					end)
				end)
			end
			if #TopScores.HighestCombo > 0 then
				local NewQuip = Gui.WeaponPreview.RewardMenu.Templates.Quip:Clone()
				NewQuip.Visible = true
				NewQuip.Frame.Val.Text = "Highest Combo"
				NewQuip.Parent = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.DungeonPlayerShow2
				local TotalValue = 0
				for i = 1, #TopScores.HighestCombo do
					local PlayerObj = TopScores.HighestCombo[i]
					local PlayerName = PlayerObj[1]
					local Value = PlayerObj[2]
					local NewPlayerBar = Gui.WeaponPreview.RewardMenu.Templates.Player1:Clone()
					NewPlayerBar.Namer.Text = PlayerName.. " - " .. Value
					NewPlayerBar.Visible = true
					NewPlayerBar.Parent = NewQuip.Frame.Bars
					TotalValue = TotalValue + Value
					FS.spawn(function()
						wait(2.75)
						TweenService:Create(NewPlayerBar.Bar, TIN(1), {Size = UDi(.98*(Value / TotalValue), 0, .7, 0)}):Play()
					end)
				end
				FS.spawn(function()
					wait(3)
					TweenService:Create(NewQuip.Frame.Banner, TIN(1), {Position = UDi(0, 0, .15, 0)}):Play()
					local PlayerName = TopScores.HighestCombo[1][1]
					local BG;
					for v = 1, #PlayerBanners do
						if PlayerBanners[v].User == PlayerName then
							BG = PlayerBanners[v].Banner
						end
					end
					local Banner = NewQuip.Frame.Banner
					local Banners = ReplicatedStorage.Images.Banners
					if Banners:FindFirstChild(BG) then
						Banner.BannerImg.Image = Banners[BG].Image
					end
					Banner.BannerImg.PlayerName.Text = PlayerName
					Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
					Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
					if ReplicatedStorage.Images.Banners[BG]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[BG]:FindFirstChild("NumOfSprites") then
						Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
						FS.spawn(function()
							local CanContinue = true
							FS.spawn(function()
								while wait() and CanContinue do
									if Banner.BannerImg.Image == "" then
										CanContinue = false
									end
								end
							end)
							while Banner.BannerImg.Image ~= "" and CanContinue do
								Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
								Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
								local NumOfSpritesX = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X or 3
								local NumOfSpritesY = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y or 9
								Animate(Banner.BannerImg, false, NumOfSpritesX, NumOfSpritesY, ReplicatedStorage.Images.Banners[BG].Framerate.Value, 0,0, ReplicatedStorage.Images.Banners[BG].Maxframes.Value)
					--			wait((1/ReplicatedStorage.Images.Banners[BG].Framerate.Value)*(ReplicatedStorage.Images.Banners[BG].Maxframes.Value)+.5)
							end
						end)
					end
					FS.spawn(function()
						wait(10)
						Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
						Banner.BannerImg.Image = ""
					end)
				end)
			end
			if #TopScores.DodgedAttacks > 0 then
				local NewQuip = Gui.WeaponPreview.RewardMenu.Templates.Quip:Clone()
				NewQuip.Visible = true
				NewQuip.Frame.Val.Text = "Dodged Attacks"
				NewQuip.Parent = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.DungeonPlayerShow2
				local TotalValue = 0
				for i = 1, #TopScores.DodgedAttacks do
					local PlayerObj = TopScores.DodgedAttacks[i]
					local PlayerName = PlayerObj[1]
					local Value = PlayerObj[2]
					local NewPlayerBar = Gui.WeaponPreview.RewardMenu.Templates.Player1:Clone()
					NewPlayerBar.Namer.Text = PlayerName.. " - " .. Value
					NewPlayerBar.Visible = true
					NewPlayerBar.Parent = NewQuip.Frame.Bars
					TotalValue = TotalValue + Value
					FS.spawn(function()
						wait(3.5)
						TweenService:Create(NewPlayerBar.Bar, TIN(1), {Size = UDi(.98*(Value / TotalValue), 0, .7, 0)}):Play()
					end)
				end
				FS.spawn(function()
					wait(3.75)
					TweenService:Create(NewQuip.Frame.Banner, TIN(1), {Position = UDi(0, 0, .15, 0)}):Play()
					local PlayerName = TopScores.DodgedAttacks[1][1]
					local BG;
					for v = 1, #PlayerBanners do
						if PlayerBanners[v].User == PlayerName then
							BG = PlayerBanners[v].Banner
						end
					end
					local Banner = NewQuip.Frame.Banner
					local Banners = ReplicatedStorage.Images.Banners
					if Banners:FindFirstChild(BG) then
						Banner.BannerImg.Image = Banners[BG].Image
					end
					Banner.BannerImg.PlayerName.Text = PlayerName
					Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
					Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
					if ReplicatedStorage.Images.Banners[BG]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[BG]:FindFirstChild("NumOfSprites") then
						Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
						FS.spawn(function()
							local CanContinue = true
							FS.spawn(function()
								while wait() and CanContinue do
									if Banner.BannerImg.Image == "" then
										CanContinue = false
									end
								end
							end)
							while Banner.BannerImg.Image ~= "" and CanContinue do
								Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
								Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
								local NumOfSpritesX = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X or 3
								local NumOfSpritesY = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y or 9
								Animate(Banner.BannerImg, false, NumOfSpritesX, NumOfSpritesY, ReplicatedStorage.Images.Banners[BG].Framerate.Value, 0,0, ReplicatedStorage.Images.Banners[BG].Maxframes.Value)
					--			wait((1/ReplicatedStorage.Images.Banners[BG].Framerate.Value)*(ReplicatedStorage.Images.Banners[BG].Maxframes.Value)+.5)
							end
						end)
					end
					FS.spawn(function()
						wait(10)
						Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
						Banner.BannerImg.Image = ""
					end)
				end)
			end
			if #TopScores.DamageTaken > 0 then
				local NewQuip = Gui.WeaponPreview.RewardMenu.Templates.Quip:Clone()
				NewQuip.Visible = true
				NewQuip.Frame.Val.Text = "Damage Taken"
				NewQuip.Parent = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.DungeonPlayerShow2
				local TotalValue = 0
				for i = 1, #TopScores.DamageTaken do
					local PlayerObj = TopScores.DamageTaken[i]
					local PlayerName = PlayerObj[1]
					local Value = PlayerObj[2]
					local NewPlayerBar = Gui.WeaponPreview.RewardMenu.Templates.Player1:Clone()
					NewPlayerBar.Namer.Text = PlayerName.. " - " .. Value
					NewPlayerBar.Visible = true
					NewPlayerBar.Parent = NewQuip.Frame.Bars
					TotalValue = TotalValue + Value
					FS.spawn(function()
						wait(4.25)
						TweenService:Create(NewPlayerBar.Bar, TIN(1), {Size = UDi(.98*(Value / TotalValue), 0, .7, 0)}):Play()
					end)
				end
				FS.spawn(function()
					wait(4.5)
					TweenService:Create(NewQuip.Frame.Banner, TIN(1), {Position = UDi(0, 0, .15, 0)}):Play()
					local PlayerName = TopScores.DamageTaken[1][1]
					local BG;
					for v = 1, #PlayerBanners do
						if PlayerBanners[v].User == PlayerName then
							BG = PlayerBanners[v].Banner
						end
					end
					local Banner = NewQuip.Frame.Banner
					local Banners = ReplicatedStorage.Images.Banners
					if Banners:FindFirstChild(BG) then
						Banner.BannerImg.Image = Banners[BG].Image
					end
					Banner.BannerImg.PlayerName.Text = PlayerName
					Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
					Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
					if ReplicatedStorage.Images.Banners[BG]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[BG]:FindFirstChild("NumOfSprites") then
						Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
						FS.spawn(function()
							local CanContinue = true
							FS.spawn(function()
								while wait() and CanContinue do
									if Banner.BannerImg.Image == "" then
										CanContinue = false
									end
								end
							end)
							while Banner.BannerImg.Image ~= "" and CanContinue do
								Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
								Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
								local NumOfSpritesX = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X or 3
								local NumOfSpritesY = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y or 9
								Animate(Banner.BannerImg, false, NumOfSpritesX, NumOfSpritesY, ReplicatedStorage.Images.Banners[BG].Framerate.Value, 0,0, ReplicatedStorage.Images.Banners[BG].Maxframes.Value)
					--			wait((1/ReplicatedStorage.Images.Banners[BG].Framerate.Value)*(ReplicatedStorage.Images.Banners[BG].Maxframes.Value)+.5)
							end
						end)
					end
					FS.spawn(function()
						wait(10)
						Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
						Banner.BannerImg.Image = ""
					end)
				end)
			end
			if #TopScores.SupportSkills > 0 then
				local NewQuip = Gui.WeaponPreview.RewardMenu.Templates.Quip:Clone()
				NewQuip.Visible = true
				NewQuip.Frame.Val.Text = #TopScores.SupportSkills[1] > 2 and "Kills" or "Support Skills Used"
				NewQuip.Parent = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.DungeonPlayerShow2
				local TotalValue = 0
				for i = 1, #TopScores.SupportSkills do
					local PlayerObj = TopScores.SupportSkills[i]
					local PlayerName = PlayerObj[1]
					local Value = PlayerObj[2]
					local NewPlayerBar = Gui.WeaponPreview.RewardMenu.Templates.Player1:Clone()
					NewPlayerBar.Namer.Text = PlayerName.. " - " .. Value
					NewPlayerBar.Visible = true
					NewPlayerBar.Parent = NewQuip.Frame.Bars
					TotalValue = TotalValue + Value
					FS.spawn(function()
						wait(5)
						TweenService:Create(NewPlayerBar.Bar, TIN(1), {Size = UDi(.98*(Value / TotalValue), 0, .7, 0)}):Play()
					end)
				end
				FS.spawn(function()
					wait(5.25)
					TweenService:Create(NewQuip.Frame.Banner, TIN(1), {Position = UDi(0, 0, .15, 0)}):Play()
					local PlayerName = TopScores.SupportSkills[1][1]
					local BG;
					for v = 1, #PlayerBanners do
						if PlayerBanners[v].User == PlayerName then
							BG = PlayerBanners[v].Banner
						end
					end
					local Banner = NewQuip.Frame.Banner
					local Banners = ReplicatedStorage.Images.Banners
					if Banners:FindFirstChild(BG) then
						Banner.BannerImg.Image = Banners[BG].Image
					end
					Banner.BannerImg.PlayerName.Text = PlayerName
					Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
					Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
					if ReplicatedStorage.Images.Banners[BG]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[BG]:FindFirstChild("NumOfSprites") then
						Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
						FS.spawn(function()
							local CanContinue = true
							FS.spawn(function()
								while wait() and CanContinue do
									if Banner.BannerImg.Image == "" then
										CanContinue = false
									end
								end
							end)
							while Banner.BannerImg.Image ~= "" and CanContinue do
								Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
								Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
								local NumOfSpritesX = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X or 3
								local NumOfSpritesY = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y or 9
								Animate(Banner.BannerImg, false, NumOfSpritesX, NumOfSpritesY, ReplicatedStorage.Images.Banners[BG].Framerate.Value, 0,0, ReplicatedStorage.Images.Banners[BG].Maxframes.Value)
					--			wait((1/ReplicatedStorage.Images.Banners[BG].Framerate.Value)*(ReplicatedStorage.Images.Banners[BG].Maxframes.Value)+.5)
							end
						end)
					end
					FS.spawn(function()
						wait(10)
						Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
						Banner.BannerImg.Image = ""
					end)
				end)
			end
			if #TopScores.Revivals > 0 then
				local NewQuip = Gui.WeaponPreview.RewardMenu.Templates.Quip:Clone()
				NewQuip.Visible = true
				NewQuip.Frame.Val.Text = #TopScores.Revivals[1] > 2 and "Deaths" or "Player Revivals"
				NewQuip.Parent = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.DungeonPlayerShow2
				local TotalValue = 0
				for i = 1, #TopScores.Revivals do
					local PlayerObj = TopScores.Revivals[i]
					local PlayerName = PlayerObj[1]
					local Value = PlayerObj[2]
					local NewPlayerBar = Gui.WeaponPreview.RewardMenu.Templates.Player1:Clone()
					NewPlayerBar.Namer.Text = PlayerName.. " - " .. Value
					NewPlayerBar.Visible = true
					NewPlayerBar.Parent = NewQuip.Frame.Bars
					TotalValue = TotalValue + Value
					FS.spawn(function()
						wait(5.75)
						TweenService:Create(NewPlayerBar.Bar, TIN(1), {Size = UDi(.98*(Value / TotalValue), 0, .7, 0)}):Play()
					end)
				end
				FS.spawn(function()
					wait(6)
					TweenService:Create(NewQuip.Frame.Banner, TIN(1), {Position = UDi(0, 0, .15, 0)}):Play()
					local PlayerName = TopScores.Revivals[1][1]
					local BG;
					for v = 1, #PlayerBanners do
						if PlayerBanners[v].User == PlayerName then
							BG = PlayerBanners[v].Banner
						end
					end
					local Banner = NewQuip.Frame.Banner
					local Banners = ReplicatedStorage.Images.Banners
					if Banners:FindFirstChild(BG) then
						Banner.BannerImg.Image = Banners[BG].Image
					end
					Banner.BannerImg.PlayerName.Text = PlayerName
					Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
					Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
					if ReplicatedStorage.Images.Banners[BG]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[BG]:FindFirstChild("NumOfSprites") then
						Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
						FS.spawn(function()
							local CanContinue = true
							FS.spawn(function()
								while wait() and CanContinue do
									if Banner.BannerImg.Image == "" then
										CanContinue = false
									end
								end
							end)
							while Banner.BannerImg.Image ~= "" and CanContinue do
								Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
								Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
								local NumOfSpritesX = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X or 3
								local NumOfSpritesY = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y or 9
								Animate(Banner.BannerImg, false, NumOfSpritesX, NumOfSpritesY, ReplicatedStorage.Images.Banners[BG].Framerate.Value, 0,0, ReplicatedStorage.Images.Banners[BG].Maxframes.Value)
					--			wait((1/ReplicatedStorage.Images.Banners[BG].Framerate.Value)*(ReplicatedStorage.Images.Banners[BG].Maxframes.Value)+.5)
							end
						end)
					end
					FS.spawn(function()
						wait(10)
						Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
						Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
						Banner.BannerImg.Image = ""
					end)
				end)
			end
			wait(10)
			TweenService:Create(Gui.WeaponPreview.RewardMenu.DungeonPlayerShow, TIN(2, Enum.EasingStyle.Quad), {Position = UDi(-1, 0, 0, 0)}):Play() wait(1)
			if #SpecialRewards > 0 then
				for i = 1, #SpecialRewards do
					FS.spawn(function()
						local Loot = SpecialRewards[i]
						local IsGold =  false
						if Loot.Name == "Gold" or Loot.Name == "LesserGold" then
							IsGold = true
						end
						local RarityImage = ReplicatedStorage.Images.Textures["Rarity".. (IsGold and "1" or Loot.Object.Rarity)]
						local WeaponPreview = IsGold and ReplicatedStorage.Models.Misc.BigGoldPile:Clone() or Loot.Object.Model:Clone()
						local NewWeaponBlock = ReplicatedStorage.GUI.NormalGui.WeaponBlock:Clone()
						NewWeaponBlock.TextButton.Visible = false
						NewWeaponBlock.ViewportFrame.Visible = false
						NewWeaponBlock.TextButton.Image = RarityImage.Image
						local NewTextLabel = Instance.new("TextLabel")
						NewTextLabel.BorderSizePixel = 0
						NewTextLabel.Size = UDi(0, 0, 0, 0)
						NewTextLabel.Position = UDi(.5, 0, .5, 0) 
						NewTextLabel.ZIndex = 13
						NewTextLabel.Text = ""
						NewTextLabel.Parent = NewWeaponBlock
						local function UpdateWeaponPreview(bool)
							if bool then
								Gui.WeaponPreview.Weapon.Visible = false
							else
								Gui.WeaponPreview.Weapon.WeaponBlock.ViewportFrame:ClearAllChildren()
								if Gui.WeaponPreview.Weapon.WeaponBlock.ViewportFrame:FindFirstChild(WeaponPreview.Name) == nil then
									local WeaponPreviewPopup = WeaponPreview:Clone()
									if WeaponPreviewPopup:FindFirstChild("CameraCF") then
										local CameraPre = Instance.new("Camera")
										CameraPre.CFrame = WeaponPreviewPopup.CameraCF.Value
										Gui.WeaponPreview.Weapon.WeaponBlock.ViewportFrame.CurrentCamera = CameraPre
									else
										if Loot.Object.ID <= 0 then
											local CameraSkin = Instance.new("Camera")
											CameraSkin.CameraType = Enum.CameraType.Scriptable
											CameraSkin.CameraSubject = WeaponPreviewPopup.Chest1.Middle
											local Pos = CFNew(WeaponPreviewPopup.Chest1.Middle.Position) * CFNew(-3.25,.25,0)
											CameraSkin.CFrame = CFNew(Pos.Position, WeaponPreviewPopup.Chest1.Middle.Position)
											CameraSkin.Parent = WeaponPreviewPopup
											Gui.WeaponPreview.Weapon.WeaponBlock.ViewportFrame.CurrentCamera = CameraSkin
										end
									end
									WeaponPreviewPopup.Parent = Gui.WeaponPreview.Weapon.WeaponBlock.ViewportFrame
								end
								Gui.WeaponPreview.Weapon.WeaponBlock.TextButton.Image = NewWeaponBlock.TextButton.Image
								Gui.WeaponPreview.Weapon.Title.TextColor3 = RarityImage.Color.Value
								Gui.WeaponPreview.Weapon.SkillDescriptions.WeaponSkill.Text = ""
								if not IsGold then
									Gui.WeaponPreview.Weapon.Title.Text = Loot.Object.WeaponName
									Gui.WeaponPreview.Weapon.Desc.Text = Loot.Object.Description
									local HP = Loot.Object.Stats.HP > 0 and "\nHP \t+" ..Loot.Object.Stats.HP or ""
									local ATK = Loot.Object.Stats.ATK > 0 and "\nATK \t+" ..Loot.Object.Stats.ATK or ""
									local DEF = Loot.Object.Stats.DEF > 0 and "\nDEF \t+" ..Loot.Object.Stats.DEF.. "%" or ""
									local STAM = Loot.Object.Stats.STAM > 0 and "\nSTAM \t+" ..Loot.Object.Stats.STAM or ""
									local CRIT = Loot.Object.Stats.CRIT > 0 and "\nCRIT \t+" ..Loot.Object.Stats.CRIT or ""
									local CRITDEF = ""
									if Loot.Object.Stats.CRITDEF ~= 0 then
										Gui.WeaponPreview.Weapon.UpgradeDesc.Text = "Equippable Trophy \nRequired Level: "..Loot.Object.LevelReq
										CRITDEF = "\nIframe Duration \t" .. tostring(round(Loot.Object.Stats.CRITDEF*100), 2).. "%"
									elseif Loot.IsSkin then
										Gui.WeaponPreview.Weapon.UpgradeDesc.Text = "Skin. Wearable by all."
									else
										Gui.WeaponPreview.Weapon.UpgradeDesc.Text = "Weapon Exclusive to " ..Loot.Ownership.. "\nPossible Tier Upgrades: "..Loot.Object.MaxUpgrades.."\nRequired Level: "..Loot.Object.LevelReq
									end
									Gui.WeaponPreview.Weapon.StatDesc.Text = "[Stats]" ..HP.. "" ..ATK.. "" ..DEF.. "" ..STAM.. "" ..CRIT.. "" ..CRITDEF
									
								else
									Gui.WeaponPreview.Weapon.WeaponBlock.ViewportFrame.Ambient = Color3.fromRGB(200, 172, 33)
									Gui.WeaponPreview.Weapon.Title.Text = "Pile of Gold"
									Gui.WeaponPreview.Weapon.Desc.Text = "A standard currency used throughout the world of PWNED."
									Gui.WeaponPreview.Weapon.UpgradeDesc.Text = "Gold +50"
									Gui.WeaponPreview.Weapon.StatDesc.Text = ""
								end
								Gui.WeaponPreview.Weapon.Visible = true
							end
						end
						if DataValues.ControllerType ~= "Touch" then
							DataValues.InventoryInputs.MouseMove = NewWeaponBlock.TextButton.MouseMoved:Connect(function(x, y)
								Gui.WeaponPreview.Weapon.Position = UDi(0, x, 0, y)
								if Gui.WeaponPreview.Weapon.Position.X.Offset > Gui.Main.AbsoluteSize.X*.5 then
									Gui.WeaponPreview.Weapon.Position = UDi(0, Gui.WeaponPreview.Weapon.Position.X.Offset - Gui.WeaponPreview.Weapon.AbsoluteSize.X, 0, Gui.WeaponPreview.Weapon.Position.Y.Offset)
								end
								if Gui.WeaponPreview.Weapon.Position.Y.Offset > Gui.Main.AbsoluteSize.Y*.5 then
									Gui.WeaponPreview.Weapon.Position = UDi(0, Gui.WeaponPreview.Weapon.Position.X.Offset, 0, Gui.WeaponPreview.Weapon.Position.Y.Offset - Gui.WeaponPreview.Weapon.AbsoluteSize.Y)
								end
								UpdateWeaponPreview()
							end)
							DataValues.InventoryInputs.MouseLeave = NewWeaponBlock.TextButton.MouseLeave:Connect(function(x, y)
								UpdateWeaponPreview(true)
							end)
						else
							DataValues.InventoryInputs.TouchPress = NewWeaponBlock.TextButton.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.Touch then
									Gui.WeaponPreview.Weapon.Size = UDi(0.4, 0, 1, 0)
									if NewWeaponBlock.AbsolutePosition.X < Gui.Main.AbsoluteSize.X*.5 then
										Gui.WeaponPreview.Weapon.Position = UDi(0.5, 0, 0, 0)
									else
										Gui.WeaponPreview.Weapon.Position = UDi(0.15, 0, 0, 0)
									end
									UpdateWeaponPreview()
								end
							end)
							DataValues.InventoryInputs.TouchPressOff = NewWeaponBlock.TextButton.InputEnded:Connect(function(input)
								UpdateWeaponPreview(true)
							end)
						end
						if WeaponPreview:FindFirstChild("CameraCF") then
							local CameraPre = Instance.new("Camera")
							CameraPre.CFrame = WeaponPreview.CameraCF.Value
							NewWeaponBlock.ViewportFrame.CurrentCamera = CameraPre
						end
						if not IsGold and Loot.Object.ID <= 0 then
							local CameraSkin = Instance.new("Camera")
							CameraSkin.CameraType = Enum.CameraType.Scriptable
							CameraSkin.CameraSubject = WeaponPreview.Chest1.Middle
							local Pos = CFNew(WeaponPreview.Chest1.Middle.Position) * CFNew(-3.25,.25,0)
							CameraSkin.CFrame = CFNew(Pos.Position, WeaponPreview.Chest1.Middle.Position)
							CameraSkin.Parent = WeaponPreview
							NewWeaponBlock.ViewportFrame.CurrentCamera = CameraSkin
						end
						
						if IsGold then
							NewWeaponBlock.ViewportFrame.Ambient = Color3.fromRGB(200, 172, 33)
						end
						WeaponPreview.Parent = NewWeaponBlock.ViewportFrame
						NewWeaponBlock.Parent = Gui.WeaponPreview.RewardMenu.DungeonPlayerShow.LootFound.DungeonPlayerShow2
						TweenService:Create(NewTextLabel, TIN(.5), {Size = UDi(1,0,1,0), Position = UDi(0,0,0,0)}):Play() wait(1)
						NewWeaponBlock.TextButton.Visible = true
						NewWeaponBlock.ViewportFrame.Visible = true
						TweenService:Create(NewTextLabel, TIN(.5), {BackgroundTransparency = 1}):Play() wait(.6)
						NewTextLabel:Destroy()
					end)
					wait(.25)
				end
				wait(10)
			end
			TweenService:Create(Blur, TIN(2), {Size = 0}):Play()
			TweenService:Create(Gui.WeaponPreview.RewardMenu, TIN(2), {BackgroundTransparency = 1}):Play()
			TweenService:Create(Gui.WeaponPreview.RewardMenu.MissionComplete, TIN(2), {TextTransparency = 1, Position = UDi(0, 0, .05, 0)}):Play()
			TweenService:Create(Gui.WeaponPreview.RewardMenu.Time, TIN(2), {TextTransparency = 1, Position = UDi(0, 0, .13, 0)}):Play()
			TweenService:Create(Gui.WeaponPreview.RewardMenu.DungeonPlayerShow, TIN(2, Enum.EasingStyle.Elastic), {Position = UDi(-2, 0, 0, 0)}):Play()
			FS.spawn(function()
				wait(2.3)
				Gui.WeaponPreview.RewardMenu.Visible = false
			end)
		end
		for i = 1, #tbl do
			local obj = tbl[i]
			if obj ~= nil then
				wait(Random.new():NextNumber(0,1.5))
				local LootBox = ReplicatedStorage.Models.Misc.Lootbox:clone()
				LootBox.Light1.Color = obj.Color
				LootBox.Light2.Color = obj.Color
				LootBox.Light1.Sparks.Color = ColorSequence.new(obj.Color)
				LootBox.Parent = workspace
				local RandomSpace = workspace.LobbySpawns.LootSpawns.Size*Vec3(Random.new():NextNumber()-.5, Random.new():NextNumber()-.5, Random.new():NextNumber()-.5)
				LootBox:SetPrimaryPartCFrame(workspace.LobbySpawns.LootSpawns.CFrame*CFNew(RandomSpace.X, RandomSpace.Y, RandomSpace.Z))
				local LAnim = LootBox.HRP.AnimationController:LoadAnimation(LootBox.HRP.AnimationController.Animation)
				LAnim.KeyframeReached:connect(function(KF)
					if KF == "LootExplode" then
						local Attach1 = Insta("Attachment")
						Attach1.Position = LootBox.Bottom.Position
						Debris:AddItem(Attach1, 15)
						Attach1.Parent = workspace.Terrain
						local LootBlock = ReplicatedStorage.GUI.BillboardGui.Loot:clone()
						LootBlock.Player.LootBlock.Title.Text = "Found Loot:\n" .. obj.Name
						LootBlock.Player.LootBlock.ImageLabel.Image = obj.Image
						LootBlock.Parent = Attach1
						local loot = LootBox:GetChildren()
						LootBox.Bottom["Bottom ? Lid"]:Destroy()
						for i = 1, #loot do
							loot[i].CanCollide = true
							loot[i].Anchored = false
						end
						LootBox.Lid.Velocity = -(LootBox.Bottom.Position-LootBox.Lid.Position).unit*55
						LootBox.Light1.Sparks.Enabled = true
						TweenService:Create(LootBlock, TIN(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ExtentsOffsetWorldSpace = Vec3(0,5,0)}):Play()
						TweenService:Create(LootBlock.Player.LootBlock, TIN(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDi(0,0,0,0), Size = UDi(1,0,1,0)}):Play()
						wait(7)
						for i = 1, #loot do
							TweenService:Create(loot[i], TIN(2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Transparency = 1}):Play()
						end
						wait(2)
						LootBox.Light1.Sparks.Enabled = false
						wait(5)
						LootBox:Destroy()
					end
				end)
				LAnim:Play()
			end
		end
	end)
	
	Humanoid.HealthChanged:connect(function(Health)
		HealthHasChanged(Health)
	end)

end
