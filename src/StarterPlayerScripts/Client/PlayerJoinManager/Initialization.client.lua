-- << Services >> --
local Players 			= game:GetService("Players")
local StarterGui 		= game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting 			= game:GetService("Lighting")
local TweenService		= game:GetService("TweenService")
local ContentProvider 	= game:GetService("ContentProvider")
local Debris			= game:GetService("Debris")
local UserInputService	= game:GetService("UserInputService")
local Teams				= game:GetService("Teams")
local RunService		= game:GetService("RunService")
local GuiService		= game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")


-- << Constants >> --
local TERRAIN	= workspace.Terrain
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local NEWMENU 	= GUI:WaitForChild("DesktopPauseMenu").Base.Mask
local Chat		= not UserInputService.GamepadEnabled and GUI:WaitForChild("Chat")

--[[
local CollectionService = game:GetService("CollectionService")
for _, part in ipairs(CollectionService:GetTagged("TownLights")) do
	if part:IsA("PointLight") or part:IsA("SurfaceLight") then
		part.Enabled = false
	else
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(26, 25, 25)
	end
end--]]
-- << Modules >> --
local PromiseSetCore	= require(script.Parent.PromiseSetCore)
local FS 		  		= require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local Socket	  		= require(MODULES.socket)
local StoryTeller 		= require(MODULES.StoryTeller)
local MusicPlayer 		= require(MODULES.MusicPlayer)
local RainAPI	  		= require(MODULES.Rain)
local Terrain			= require(MODULES.TerrainSaveLoad)
local DataValues  		= require(CLIENT.DataValues)
local showS		  		= require(CLIENT.UIEffects.NumbersFlair)
local animateText 		= require(CLIENT.UIEffects.TextScrolling)
local Hint		  		= require(CLIENT.UIEffects.Hint)
local PlayTutorialMsg 	= require(CLIENT.UIEffects.TutorialPopUpWindow)
local physicalCompass	= require(CLIENT.UIEffects.PhysicalCompass)


-- << Core Initialization >> --
NEWMENU.Size = UDim2.new(1,0,0,0)
NEWMENU.Parent.Parent.Enabled = true
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
PromiseSetCore("ResetButtonCallback", false)
GUI:SetTopbarTransparency(1)

if Chat then
	Chat.Enabled = false
end
---------------------------------------------------------------------------


-- << Variables >> --
local BackFromBattle 	= false
local Camera			= workspace.Camera
local Blur				= Lighting.Blur
local Bloom				= Lighting.Bloom
local ColorCorrection	= Lighting.ColorCorrection
local SunRays			= Lighting.SunRays
local Character			= PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid			= Character:WaitForChild("Humanoid")
local Objs 				= DataValues.Objs
local Numbers 			= DataValues.Numbers
local bools 			= DataValues.bools
local Options			= DataValues.Options


-- << Physical Stuff Init >> --
if game.PlaceId == 785484984 or game.PlaceId == 563493615 then
	bools.InSoloPlace = true
end

local MainMenuBuild = ReplicatedStorage.Environments.MainMenu:Clone()
local MainMenuBuildWaters = ReplicatedStorage.Environments.Terrains.MainMenuBuildWaters
MainMenuBuild.Parent = workspace

TERRAIN.WaterColor = MainMenuBuildWaters.WaterProperties.WaterColor.Value
TERRAIN.WaterReflectance = MainMenuBuildWaters.WaterProperties.WaterReflectance.Value
TERRAIN.WaterTransparency = MainMenuBuildWaters.WaterProperties.WaterTransparency.Value
TERRAIN.WaterWaveSize = MainMenuBuildWaters.WaterProperties.WaterWaveSize.Value
TERRAIN.WaterWaveSpeed = MainMenuBuildWaters.WaterProperties.WaterWaveSpeed.Value

Humanoid.WalkSpeed 				= 0
Lighting.Ambient 				= Color3.fromRGB(15,15,15)
Lighting.Brightness 			= 5
Lighting.ColorShift_Bottom 		= Color3.fromRGB(0,0,0)
Lighting.ColorShift_Top 		= Color3.fromRGB(0,0,0)
Lighting.OutdoorAmbient 		= Color3.fromRGB(50,50,50)
Lighting.GlobalShadows 			= true
Lighting.ClockTime 				= 16.900
Lighting.GeographicLatitude 	= 29
Lighting.FogColor 				= Color3.fromRGB(172,182,180)
Lighting.FogEnd 				= 10000
Blur.Size 						= 20
ColorCorrection.Saturation 		= -.7
ColorCorrection.TintColor 		= Color3.fromRGB(199,171,151)
SunRays.Intensity				= .065
SunRays.Spread					= .45
Camera.FieldOfView 				= 50
GUI.Main.Enabled = false

local OnMenu = true

if DataValues.WatchedIntro == false then
	local MenuInputs = {}
	local clicked = false
	local MainMenu = GUI.MainMenu.Intro
	GUI.MainMenu.Enabled = true
	local IntroTweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	)
	local BlurTweenInfo = TweenInfo.new(
		1,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	)
	Camera.CameraType = "Scriptable"
	Camera.CFrame = MainMenuBuild.CamPart.CFrame
	local LoadingIcon = GUI.Console.Background.LoadingIcon
	local HasLoaded = false
	local SkippedTimer = 0
	FS.spawn(function()
		ContentProvider:PreloadAsync({LoadingIcon.loadring1, LoadingIcon.loadring2, LoadingIcon.loadring3, LoadingIcon.loadring4, LoadingIcon.loadhex, LoadingIcon.loadarrow})
	end)
	TweenService:Create(GUI.Console.Background.ChatLabel, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play()
	TweenService:Create(GUI.Console.Background.ChatLabel.Line, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 0.1}):Play()
	TweenService:Create(LoadingIcon.loadring1, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0, ImageTransparency = 0}):Play() wait(.2)
	TweenService:Create(LoadingIcon.loadring2, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0, ImageTransparency = 0}):Play() wait(.2)
	TweenService:Create(LoadingIcon.loadring3, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0, ImageTransparency = 0}):Play() wait(.2)
	TweenService:Create(LoadingIcon.loadring4, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0, ImageTransparency = 0}):Play() wait(.2)
	TweenService:Create(LoadingIcon.loadhex, TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0, ImageTransparency = 0}):Play()
	TweenService:Create(LoadingIcon.loadarrow, TweenInfo.new(3,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out,0,false,0), {Rotation = 0, ImageTransparency = 0}):Play()
	GUI.Console.Background.Skip.MouseButton1Down:Connect(function()
		GUI.Console.Background.Skip.Visible = false
		HasLoaded = true
	end)
	FS.spawn(function()
		while wait(1.5) and LoadingIcon.Visible and HasLoaded == false and GUI.Main.Enabled == false do
			LoadingIcon.loadhex.Rotation = 0
			LoadingIcon.loadarrow.Rotation = 0
			TweenService:Create(LoadingIcon.loadhex, TweenInfo.new(4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0,false,0), {Rotation = 360}):Play()
			TweenService:Create(LoadingIcon.loadarrow, TweenInfo.new(4,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out,0,false,0), {Rotation = 360}):Play()
			TweenService:Create(LoadingIcon.loadring1, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 90}):Play() wait(.2)
			TweenService:Create(LoadingIcon.loadring2, TweenInfo.new(1.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = -90}):Play() wait(.2)
			TweenService:Create(LoadingIcon.loadring3, TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 90}):Play() wait(.2)
			TweenService:Create(LoadingIcon.loadring4, TweenInfo.new(.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = -90}):Play() wait(.2)
			TweenService:Create(LoadingIcon.loadring1, TweenInfo.new(.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0}):Play() wait(.2)
			TweenService:Create(LoadingIcon.loadring2, TweenInfo.new(.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0}):Play() wait(.2)
			TweenService:Create(LoadingIcon.loadring3, TweenInfo.new(1.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0}):Play() wait(.2)
			TweenService:Create(LoadingIcon.loadring4, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Rotation = 0}):Play() wait(.2)
			SkippedTimer = SkippedTimer + 3.1
			if SkippedTimer >= 15 and not HasLoaded and GUI.Main.Enabled == false then
				GUI.Console.Background.Skip.Visible = true
			end
		end
	end)
	
	local confirmLoad, Reserved, CurrLev 
	while confirmLoad == nil or Reserved == nil or CurrLev == nil do
		confirmLoad, Reserved, CurrLev = Socket:Request("PCallLoadStats")
		if (confirmLoad == nil and typeof(Reserved) == "table" and CurrLev == 0) or (confirmLoad == true and typeof(Reserved) == "table" and CurrLev >= 0) or (confirmLoad == "error") then ---Starts new game
			break
		else
			wait(1)
			print("Calling Pcall")
		end
	end
	print("Stat Loaded")
	
	FS.spawn(function()
		local change = tick()
		while OnMenu do
			local p = Instance.new("Part")
			p.Name = "Firefly"
			p.Shape = "Ball"
			p.Size = Vector3.new(.075,075,.075)
			p.CFrame = MainMenuBuild.CamPart.CFrame * CFrame.new(math.random() - 0.5, 1 + math.random(), math.random() - 0.5)
			p.Transparency = .3
			p.CanCollide=false
			p.TopSurface = "Smooth"
			p.BottomSurface = "Smooth"
			p.Material = "Neon"
			local bv = Instance.new("BodyVelocity")
			bv.maxForce = Vector3.new(1,1,1)*10^2
			bv.velocity = Vector3.new(math.random()-.5,1,math.random()-.5)*4
			bv.Parent = p
			local bf = Instance.new("BodyAngularVelocity")
			bf.maxTorque = Vector3.new(1,1,1)*10^2
			bf.angularvelocity = Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*20
			bf.Parent = p
			local pl = Instance.new("PointLight")
			pl.Color = Color3.fromRGB(231, 255, 75)
			pl.Range = math.random(4,8)
			pl.Brightness = 1
			pl.Parent = p
			FS.spawn(function()
				wait(.5+math.random())
				bv.velocity=bv.velocity*Vector3.new(1,0,1)
				for _=1,100 do
					bv.velocity=bv.velocity+Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*5
					wait(.5+math.random())
				end
			end)
			Debris:AddItem(p, Random.new():NextNumber(20,30))
			p.Parent=MainMenuBuild
			if tick() - change >= 2 then
				change = tick()
				TweenService:Create(Lighting, TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {GeographicLatitude = 29+(Random.new():NextNumber(-.1,.3))}):Play()
			end
			wait(.15)
		end
	end)
	
	local assets = {}
	
	table.insert(assets, GUI.Main.Tutorial.BackKeyboard)
	table.insert(assets, GUI.Main.Tutorial.Front)
	table.insert(assets, GUI.Main.Tutorial.Combat)
	table.insert(assets, ReplicatedStorage.Scripts.ClassAnimateScripts)
	
	FS.spawn(function()
		ContentProvider:PreloadAsync({GUI.MainMenu.Intro.Logo, ReplicatedStorage.Images.Decals.Intro, ReplicatedStorage.Sounds.Music.MenuMusic})
		if HasLoaded == false then
			MusicPlayer:Play(ReplicatedStorage.Sounds.Music.MenuMusic)
		end
		ContentProvider:PreloadAsync(assets)
		HasLoaded = true
	end)
	repeat wait(.5) until HasLoaded or bools.InSoloPlace
	GUI.Console.Background.Skip.Visible = false
	TweenService:Create(LoadingIcon.loadhex, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingIcon.loadarrow, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingIcon.loadring1, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingIcon.loadring2, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingIcon.loadring3, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingIcon.loadring4, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingIcon.loadring1, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingIcon.loadring2, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play() 
	TweenService:Create(LoadingIcon.loadring3, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingIcon.loadring4, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 1}):Play()
	TweenService:Create(GUI.Console.Background.ChatLabel, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play()
	TweenService:Create(GUI.Console.Background.ChatLabel.Line, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 1}):Play()
	
	FS.spawn(function()
		if confirmLoad and bools.InSoloPlace then
			wait(1)
			OnMenu = false
			MainMenu.Visible = false
		end
	end)
	
	if Reserved ~= nil and Reserved.IsReserved == false then
		if bools.CanLoad == false and Random.new():NextNumber(0,1) < 0.4 then
			TweenService:Create(MainMenu.Number, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = .4}):Play()
			wait(1)
			showS( MainMenu.Number.Number, 0, Random.new():NextInteger(500000,999999999), 2500, 14 )
			wait(3.5)
			TweenService:Create(MainMenu.Number, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play()
			TweenService:Create(MainMenu.Number.Number, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play()
			wait(1)
		end
		FS.spawn(function()
			wait(1)
			LoadingIcon.Visible = false
		end)
		local year = os.date("*t").year
		local Msg = game.PlaceId == 785484984 and "Test Server. Data in this version will not save" or "Version 0.10.50"
		MainMenu.License.Text = "TEAM SWORDPHIN CO.,"..year..". GAME DESIGNER: SWORDPHIN123. CO-DESIGNER: VASIL12345. ART DESIGN: LOOTIAS - " ..Msg
		TweenService:Create(Lighting.Blur, BlurTweenInfo, {Size = 7}):Play() wait(1.5)
		TweenService:Create(MainMenu.Logo, IntroTweenInfo, {Position = UDim2.new(.265,0,.05,0), ImageTransparency = 0.35}):Play()
		TweenService:Create(MainMenu.NEWGAME, IntroTweenInfo, {Position = UDim2.new(.4,0,.65,0), TextTransparency = 0}):Play() 
		TweenService:Create(MainMenu.License, IntroTweenInfo, {Position = UDim2.new(.1,0,.95,0), TextTransparency = 0.4}):Play()wait(.2)
		TweenService:Create(MainMenu.CREDITS, IntroTweenInfo, {Position = UDim2.new(.4,0,.7,0), TextTransparency = 0}):Play() wait(.8)
		MainMenu.Line.Visible = true
		TweenService:Create(MainMenu.Line, TweenInfo.new(.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.4,0,.65,0), Size = UDim2.new(.2,0,.05,0)}):Play() wait(.8)
		MenuInputs.NewGameOver = MainMenu.NEWGAME.MouseEnter:connect(function()
			if OnMenu then
				TweenService:Create(MainMenu.Line, TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.4,0,.65,0)}):Play()
			end
		end)
		MenuInputs.CreditsOver = MainMenu.CREDITS.MouseEnter:connect(function()
			if OnMenu then
				TweenService:Create(MainMenu.Line, TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.4,0,.7,0)}):Play()
			end	
		end)
		local s = {"I", "E", "S", "A", "M", "A", "G", "N", "I", "S", "L", "I", "V", "E", "S"}
		local i = 1
		MenuInputs.TestServerInput = UserInputService.InputBegan:connect(function(InputObject, gameProcessed)
			if InputObject.UserInputType == Enum.UserInputType.Keyboard then
				if InputObject.KeyCode == Enum.KeyCode[s[i]] then
					i = i + 1
				else
					i = 1
				end
			end
			if i == #s+1 then
				MenuInputs.TestOver = MainMenu.TESTSERVER.MouseEnter:connect(function()
					if OnMenu then
						TweenService:Create(MainMenu.Line, TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.4,0,.75,0)}):Play()
					end	
				end)
				MenuInputs.TestServer = MainMenu.TESTSERVER.MouseButton1Click:connect(function()
					ReplicatedStorage.Sounds.SFX.ButtonSelect:Play()
					game:GetService('TeleportService'):Teleport(785484984)
				end)
				TweenService:Create(MainMenu.TESTSERVER, IntroTweenInfo, {Position = UDim2.new(.4,0,.75,0), TextTransparency = 0}):Play()
				i = 1
			end
		end)
		MenuInputs.CreditsClose = MainMenu.Back.MouseButton1Click:Connect(function()
			MainMenu.Credit.Visible = false
			MainMenu.Back.Visible = false
		end)
		MenuInputs.CreditsPress = MainMenu.CREDITS.MouseButton1Click:connect(function()
			ReplicatedStorage.Sounds.SFX.ButtonSelect:Play()
			MainMenu.Credit.Visible = true
			MainMenu.Back.Visible = true
		end)
		MenuInputs.NewGamePress = MainMenu.NEWGAME.MouseButton1Click:connect(function()
			TweenService:Create(MainMenu.Line, TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.4,0,.65,0)}):Play()
			if clicked == false then
				ReplicatedStorage.Sounds.SFX.ButtonSelect:Play()
				clicked = true
				OnMenu = false
				TweenService:Create(MainMenu.Line.Line1, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.05,0,.9,0)}):Play()
				TweenService:Create(MainMenu.Line.Line2, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.9,0,.9,0)}):Play() wait(.2)
				TweenService:Create(MainMenu.CREDITS, IntroTweenInfo, {Position = UDim2.new(.4,0,.73,0), TextTransparency = 1}):Play()
				TweenService:Create(MainMenu.Line.Line1, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.0,0,.9,0)}):Play()
				TweenService:Create(MainMenu.Line.Line2, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.95,0,.9,0)}):Play() wait(.5)
				TweenService:Create(MainMenu.Line, TweenInfo.new(.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.5,0,.65,0), Size = UDim2.new(0,0,.05,0)}):Play() wait(.8)
				MainMenu.Line.Visible = false
				TweenService:Create(MainMenu.NEWGAME, IntroTweenInfo, {Position = UDim2.new(.4,0,.68,0), TextTransparency = 1}):Play() wait(1)
				TweenService:Create(MainMenu.Logo, IntroTweenInfo, {Position = UDim2.new(.265,0,0,0), ImageTransparency = 1}):Play()
				TweenService:Create(MainMenu.License, IntroTweenInfo, {Position = UDim2.new(.1,0,.99,0), TextTransparency = 1}):Play() wait(1)
				TweenService:Create(Lighting.Blur, BlurTweenInfo, {Size = 20}):Play() wait(1.5)
				MainMenu.Visible = false
				clicked = false
			end
		end)
		if UserInputService.GamepadEnabled then
			MainMenu.NEWGAME.Selectable = true
			MainMenu.CREDITS.Selectable = true
			GuiService.SelectedObject = MainMenu.NEWGAME
		end
	elseif Reserved ~= nil then
		if Reserved.BackFromBattle == false then
			bools.CanLoad = true
		end
		OnMenu = false
		MainMenu.Visible = false
		Objs.CurrentLevel = CurrLev
	end

	repeat wait() until (OnMenu == false and MainMenu.Visible == false) or (confirmLoad == "error")
	MainMenu = GUI.MainMenu.CharSelect
	MainMenu.Visible = true
	TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(.5)
	if confirmLoad == "maintenance" then
		TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(.2)
		MainMenu.Console.Text = "The game is currently down for maintenance. Please try again later."
		TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(10)
		Socket:Emit("Quit")
		GUI:Destroy()
	elseif confirmLoad == "error" then
		for i = 1,10,1 do
			TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(.2)
			MainMenu.Console.Text = "Error: Unable to contact the official RBLX Data Store service. Attempting connection retry " ..i.. " of 10."
			TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(6.1)
			confirmLoad, Reserved, CurrLev = Socket:Request("PCallLoadStats")
			if confirmLoad ~= "error" then break end
		end
		if confirmLoad == "error" then
			TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(.2)
			MainMenu.Console.Text = "Error Unresolved: RBLX Data Store services is temporarily unavailable. Please rejoin the session or try again later."
			TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(5)
			Socket:Emit("Quit")
			GUI:Destroy()
		else
			TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(.2)
			MainMenu.Console.Text = "Connection to the official RBLX Data Store service has been reestablished. Resuming..."
			TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(1.8)
		end
	end
	bools.Reserved = Reserved.IsReserved and Reserved.IsReserved or false
	if bools.Reserved == false or Reserved.BackFromBattle then
		BackFromBattle = Reserved.BackFromBattle
	else
		ReplicatedStorage.Environments.TrainStation:Clone().Parent = workspace
	end
	if confirmLoad then
		TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(.2)
		if not bools.InSoloPlace then
			MainMenu.Console.Text = Reserved.IsReserved == true and "Connecting to the match..." or "Loading last played character..."
			Socket:Emit("ForceMorph")
			TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(1)
			TweenService:Create(MainMenu.BG, TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 0}):Play() wait(2)
			MainMenu.Console.Visible = false
			DataValues.WatchedIntro = true
			MainMenuBuild:Destroy()
		else
			MainMenu.Console.Text = "Teleporting to lobby, this may take a moment..."
			Socket:Emit("NewGameButtonPress")
			TweenService:Create(MainMenu.Console, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(1)
			while true do
				wait(30)
				print("Awaiting teleportation")
				Socket:Emit("NewGameButtonPress")
			end
		end
	elseif confirmLoad == nil and bools.InSoloPlace then
		bools.NewPlayer = true
		TweenService:Create(MainMenu.BG, TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 0}):Play() wait(2.5)

		Socket:Emit("Story", "gawrgonr")
		
		local CameraOp1 = ReplicatedStorage.Models.Misc.CameraOperator:Clone()
		Camera.CameraType = "Scriptable"
		Camera.CFrame = CameraOp1.Forward.CFrame * CFrame.new(0, -1.5, 1)
		CameraOp1.Parent = workspace
		
		local CameraGuy = ReplicatedStorage.Models.Misc.CameraGuy:Clone()
		CameraGuy.Parent = workspace
		
		local CamAnim = workspace.CameraOperator.AnimationController:LoadAnimation(CameraOp1.CamAnim)
		local GuyAnim = Character.Humanoid:LoadAnimation(CameraGuy.HangAnimation)
		local CanContinue = false
		local conn;
		
		local BindableEvent = CLIENT.Bindables.ContinueStory
		
		if not UserInputService.GamepadEnabled then
			GUI:WaitForChild("Chat").Enabled = false
		end
		GUI.Main.GameGUI.PlayerUI.Left.Timer.Visible = false
		Socket:Emit("ForceMorph")
		
		BindableEvent.Event:Connect(function()
			DataValues.CameraEnabled = false
			BindableEvent:Destroy()
			MusicPlayer:Stop(2)
			TweenService:Create(MainMenu.BG, TweenInfo.new(2.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 0}):Play() wait(2.5)
			GUI.Main.Environment.Visible = true
			MainMenu.TextLabel.Text = "We walked for what felt like an eternity."
			FS.spawn(function()
				MusicPlayer:Play(ReplicatedStorage.Sounds.SFX.Introduction.Walking, 2)
			end)
			Character.PrimaryPart.Anchored = true
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(3)
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(2)
			TweenService:Create(MainMenu.BG, TweenInfo.new(2.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 1}):Play() wait(2.5)
			MainMenu.TextLabel.Text = "The land was quiet, with no movement in sight."
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(3.5)
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(1)
			MainMenu.TextLabel.Text = "Even the wind was still, as if it was watching us."
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(5)
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(1)
			MainMenu.TextLabel.Text = "As if we were trespassers on an unwelcome land."
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(3)
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(1)
			FS.spawn(function()
				MusicPlayer:Stop(4)
			end)
			
			local Lobby = workspace.Lobby
			
			if workspace:FindFirstChild("ReadyButton") then
				workspace.ReadyButton:Destroy()
			end
			
			Socket:Emit("ResetPlayer")
			DataValues.CameraEnabled = true
			
			MainMenu.TextLabel.Text = "Finally, the silhouette of a small town rose from the horizon."
			TweenService:Create(MainMenu.BG, TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 0}):Play()
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(5)
			DataValues.AccInfo = Socket:Request("getAccountInfo")
			Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed
			TweenService:Create(MainMenu.TextLabel, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(1)
			StoryTeller:SpawnStoryElement(DataValues.AccInfo.StoryProgression)
			PLAYER.TeamColor = Teams.Lobby.TeamColor
			DataValues.WatchedIntro = true
			bools.InDialogue = false
			GUI.Main.Environment.Visible = false
			TweenService:Create(MainMenu.BG, TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 1}):Play() wait(2)
			Hint("Explore the abandoned town.")

			local yield = PLAYER.Character or PLAYER.CharacterAdded:Wait()

			local textLabel = physicalCompass:new(workspace.Cutscene.Story1.PrimaryPart, true)
			textLabel.Text = "Story"

			repeat wait(1) until table.find(DataValues.AccInfo.StoryProgression, "1")
			physicalCompass:new(workspace.Lobby.DungeonEntrance)
			wait(3)
			PlayTutorialMsg("StoryCompass")
		end)
		
		MusicPlayer:Play(ReplicatedStorage.Sounds.SFX.Ambient.Fire, 4, .2)
		
		FS.spawn(function()
			conn = RunService.RenderStepped:Connect(function()
				if CanContinue or workspace:FindFirstChild("CameraOperator") == nil then
					conn:Disconnect()
					conn = nil
				end
				Camera.CameraType = "Scriptable"
				Camera.CFrame = workspace.CameraOperator.Forward.CFrame * CFrame.new(0, -1.5, 1)
			end)
		end)

		TweenService:Create(MainMenu.TextLabel, TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0}):Play() wait(3)
		TweenService:Create(MainMenu.TextLabel, TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 1}):Play() wait(2.5)
		
		Character.PrimaryPart.Anchored = true
		Character:SetPrimaryPartCFrame(CameraGuy.PrimaryPart.CFrame)
		
		GuyAnim.KeyframeReached:Connect(function(KF)
			if KF == "FadeOut" then
				wait(3)
				TweenService:Create(MainMenu.BG, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 0}):Play()
				MusicPlayer:Play(ReplicatedStorage.Sounds.Music["Introduction_Atmos"], 1)
				CanContinue = true
			elseif KF == "ImpactSmoke" then
				local SFX = ReplicatedStorage.Sounds.SFX.Introduction.Impact:Clone()
				SFX.Parent = Character.UpperTorso
				SFX:Play()
				Debris:AddItem(SFX,2)
				local ImpactSmoke = MODULES["Effects"].HitEffects.Smoke.LittleSmoke:Clone()
				local Attachment = Instance.new("Attachment")
				Attachment.CFrame = Character.UpperTorso.CFrame*CFrame.new(0,0,0)
				ImpactSmoke.Parent = Attachment
				Debris:AddItem(Attachment,5)
				Attachment.Parent = TERRAIN
				ImpactSmoke.Enabled = true wait(.1)
				ImpactSmoke.Enabled = false
			elseif KF == "BreakChains" then
				local SFX = ReplicatedStorage.Sounds.SFX.Introduction.ChainBreak:Clone()
				SFX.PitchShiftSoundEffect.Octave = Random.new():NextNumber(0.5,1.2)
				SFX.Parent = Character.Head
				SFX:Play()
				Debris:AddItem(SFX,2)
			end
		end)

		Camera.FieldOfView = 50
		Blur.Size = 0
		Lighting.Ambient = Color3.fromRGB(53, 53, 53)
		Lighting.Brightness = 5
		Lighting.ColorShift_Bottom = Color3.fromRGB(112, 112, 112)
		Lighting.ColorShift_Top = Color3.fromRGB(131, 131, 131)
		Lighting.OutdoorAmbient = Color3.fromRGB(61, 64, 83)
		Lighting.FogEnd = 99999
		Lighting.GlobalShadows = true
		Lighting.ClockTime = 20
		Lighting.GeographicLatitude = 41.733
		
		SunRays.Intensity = .1
		ColorCorrection.Saturation = 0
		ColorCorrection.TintColor = Color3.fromRGB(255,255,255)
		MainMenu.Console.TextTransparency = 1
		
		CamAnim:Play()
		GuyAnim:Play()
		
		TweenService:Create(MainMenu.BG, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 1}):Play()
		
		repeat wait() until CanContinue == true
		
		if Character:FindFirstChild("Animate") then
			Character.Animate:Destroy()
		end
		
		local Newscript = ReplicatedStorage.Scripts.AnimateLater:Clone()
		Newscript.Name = "Animate"
		Newscript.Parent = Character
		
		DataValues.WatchedIntro = true
		CanContinue = false
		
		CameraOp1:Destroy()
		CameraGuy:Destroy()
		GuyAnim:Stop()
		GuyAnim:Destroy()
		
		Character.PrimaryPart.Anchored = false
		wait(0.25)
		Character.PrimaryPart.Anchored = true
		wait(0.25)
		Character.PrimaryPart.Anchored = false
		Character.Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed
		PLAYER.TeamColor = Teams.InGame.TeamColor
		TweenService:Create(MainMenu.BG, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 1}):Play()
		
		local function FindDistance()
			local Althea = workspace.Players:WaitForChild("Althea", 1)
			if Character and Althea and Character.PrimaryPart ~= nil then
				if (Althea.PrimaryPart.Position - Character.PrimaryPart.Position).magnitude <= 70 then
					return true
				end
				return false
			end
			return false
		end
		
		repeat wait(.25) until FindDistance()
		
		DataValues.CameraEnabled = false
		bools.InDialogue = true
		
		local CameraOp2 = ReplicatedStorage.Models.Misc.CameraOperator2:Clone()
		CameraOp2.Parent = workspace
		local CameraGuy2 = ReplicatedStorage.Models.Misc.CameraGuy2:Clone()
		CameraGuy2.Parent = workspace
		
		local CamAnim = workspace.CameraOperator2.AnimationController:LoadAnimation(CameraOp2.CamAnim)
		local GuyAnim = Character.Humanoid:LoadAnimation(CameraGuy2.GuyAnim)
		local GirlAnim = workspace.Players.Althea.Humanoid:LoadAnimation(workspace.Players.Althea.GirlAnim)
		
		TweenService:Create(MainMenu.BG, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 0}):Play() wait(1)
		
		local OldCF = CameraGuy2.PrimaryPart.CFrame * CFrame.new(0, 0.3, 5)
		
		Character.PrimaryPart.Anchored = true
		Character:SetPrimaryPartCFrame(CameraGuy2.PrimaryPart.CFrame)
		
		Camera.FieldOfView = 50
		
		FS.spawn(function()
			local conn;
			conn = RunService.Heartbeat:Connect(function()
				if CanContinue or workspace:FindFirstChild("CameraOperator2") == nil  then
					conn:Disconnect()
					conn = nil
					return
				end
				Camera.CameraType = "Scriptable"
				Camera.CFrame = CameraOp2.Forward.CFrame * CFrame.new(0, 0, 1)
			end)
		end)
		
		local DialogueGui = GUI.MainDialogue.Dialogue
		DialogueGui.Visible = true
		
		GuyAnim.KeyframeReached:Connect(function(KF)
			if KF == "Dialogue1" then
				TweenService:Create(DialogueGui.ImageLabel, TweenInfo.new(1,Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
				animateText(true,DialogueGui.ChatLabel,"So you're awake. These three relics... They're reaching out, screaming out. You can feel it too, can't you?")
				wait(5)
				animateText(true,DialogueGui.ChatLabel,"")
			elseif KF == "Dialogue2" then
				TweenService:Create(DialogueGui.ImageLabel, TweenInfo.new(1,Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
				animateText(true,DialogueGui.ChatLabel,"I don't know why, but it seems like they're calling... ")
				wait(3)
				animateText(true,DialogueGui.ChatLabel,"")
			elseif KF == "Dialogue3" then
				animateText(true,DialogueGui.ChatLabel,"...for you.")
				wait(3)
				TweenService:Create(DialogueGui.ImageLabel, TweenInfo.new(1,Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
				bools.InDialogue = true
				animateText(true,DialogueGui.ChatLabel,"")
				TweenService:Create(MainMenu.BG, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 0}):Play() wait(1)
				CanContinue = true
				CamAnim:Stop()
				GuyAnim:Stop()
				GirlAnim:Stop()
				DataValues.CameraEnabled = true
				DialogueGui.Visible = false
				CameraOp2:Destroy()
				CameraGuy2:Destroy()
			end
		end)
		
		CamAnim:Play()
		GuyAnim:Play()
		GirlAnim:Play()
		
		MusicPlayer:Play(ReplicatedStorage.Sounds.SFX.Introduction.AltheaTheme, 1, .4)
		
		wait(1)
		TweenService:Create(MainMenu.BG, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 1}):Play()
		
		repeat wait() until CanContinue == true
		
		CanContinue = false
		
		Character:SetPrimaryPartCFrame(OldCF)
		Character.PrimaryPart.Anchored = false
		Character.Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
		PLAYER.TeamColor = Teams.InGame.TeamColor
		TweenService:Create(MainMenu.BG, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 1}):Play() wait(1)
		
		FS.spawn(function()
			Character.PrimaryPart.Anchored = true
			wait(0.5)
			Character.PrimaryPart.Anchored = false
		end)
		PlayTutorialMsg("ChooseCharacter")
		
		if Character:FindFirstChild("Animate") then
			Character.Animate:Destroy()
		end
		
		local Newscript = ReplicatedStorage.Scripts.AnimateLater:Clone()
		Newscript.Name = "Animate"
		Newscript.Parent = Character
	end
end

if not bools.InSoloPlace then
	do
		repeat wait() until DataValues.WatchedIntro
		if Chat then
			Chat.Enabled = true
		end
		FS.spawn(function()
			while bools.JustCameIn do
				GUI.Main.LobbyCommands.Left.Tab.Glow.Rotation = 0
				TweenService:Create(GUI.Main.LobbyCommands.Left.Tab.Glow, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
				wait(3)
			end
			TweenService:Create(GUI.Main.LobbyCommands.Left.Tab.Glow, TweenInfo.new(2), {ImageTransparency = 1, Rotation = GUI.Main.LobbyCommands.Left.Tab.Glow.Rotation + 240}):Play()
		end)
		repeat wait() until PLAYER.Character
		Character = PLAYER.Character
		Character:MoveTo(Vector3.new(-32.5, 13.475, 518.898)) -- Spawn Location Loot location
		DataValues.AccInfo = Socket:Request("getAccountInfo")
		local NewOptions = Socket:Request("UpdateSetting", "Get")
		if typeof(NewOptions) == "table" then
			DataValues.Options = NewOptions
			Options = DataValues.Options
			Numbers.CombatFov = Options.CombatFov
			Numbers.LobbyFov = Options.LobbyFov
		else
			Socket:Emit("UpdateSetting", "Post", Options)
		end

		if Options.RainEffects == false then
			RainAPI:StopRain()
		end

		if Options.LobbyShadowSmall == false then
			for _, part in ipairs(CollectionService:GetTagged("ShadowObjectsSmall")) do
				part.CastShadow = false
			end
		end

		if Options.LobbyShadowMedium == false then
			for _, part in ipairs(CollectionService:GetTagged("ShadowObjectsMedium")) do
				part.CastShadow = false
			end
		end

		if Options.LobbyShadowLarge == false then
			for _, part in ipairs(CollectionService:GetTagged("ShadowObjectsLarge")) do
				part.CastShadow = false
			end
		end

		local BonusWS = 0
		if table.find(DataValues.AccInfo.Vestiges, 4) then
			Numbers.LobbyWalkSpeed = Numbers.LobbyWalkSpeed * (1.3)
		elseif table.find(DataValues.AccInfo.Vestiges, 3) then
			Numbers.LobbyWalkSpeed = Numbers.LobbyWalkSpeed * (1.2)
		elseif table.find(DataValues.AccInfo.Vestiges, 2) then
			Numbers.LobbyWalkSpeed = Numbers.LobbyWalkSpeed * (1.1)
		end
		if table.find(DataValues.AccInfo.Vestiges, 7) then
			Numbers.CombatWalkSpeed = Numbers.CombatWalkSpeed * (1.15)
		elseif table.find(DataValues.AccInfo.Vestiges, 6) then
			Numbers.CombatWalkSpeed = Numbers.CombatWalkSpeed * (1.1)
		elseif table.find(DataValues.AccInfo.Vestiges, 5) then
			Numbers.CombatWalkSpeed = Numbers.CombatWalkSpeed * (1.05)
		end
		Humanoid.WalkSpeed = Numbers.LobbyWalkSpeed 
		if Character and Character.PrimaryPart then
			Character:SetPrimaryPartCFrame(workspace.LobbySpawns.SpawnLocationLoot.CFrame * CFrame.new(0,4,0))
		end
		if bools.Reserved == false or BackFromBattle then
			if DataValues.AccInfo then
				StoryTeller:SpawnStoryElement(DataValues.AccInfo.StoryProgression)
			end
			Lighting.Ambient = Color3.fromRGB(76, 76, 76)
			Lighting.Brightness = 10
			Lighting.ColorShift_Bottom = Color3.fromRGB(53, 44, 150)
			Lighting.ColorShift_Top = Color3.fromRGB(119, 137, 255)
			Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
			Lighting.EnvironmentDiffuseScale = 0.623
			Lighting.EnvironmentSpecularScale = 0.229
			Lighting.FogColor = Color3.fromRGB(172, 182, 180)
			Lighting.FogEnd = 9999
			Lighting.GlobalShadows = true
			Lighting.ClockTime = 20
			Lighting.GeographicLatitude = 41.733
			Bloom.Intensity = .2
			Blur.Size = 0
			SunRays.Intensity = .35
			workspace.Lobby.Lighting.Atmosphere:Clone().Parent = Lighting
		else
			Lighting.Brightness = 5
			Lighting.Ambient = Color3.fromRGB(31, 24, 24)
			Lighting.ColorShift_Bottom = Color3.fromRGB(97, 112, 109)
			Lighting.ColorShift_Top = Color3.fromRGB(108, 122, 131)
			Lighting.ClockTime = 20
			Lighting.GeographicLatitude = 41.733
			Lighting.FogColor = Color3.fromRGB(172, 182, 180)
		end
		if workspace:FindFirstChild("TrainStation") then
			local OldMusic = ReplicatedStorage.Sounds.Music.LobbyMusic
			ReplicatedStorage.Sounds.Music.LobbyBattleMusic.Name = "LobbyMusic"
			OldMusic.Name = "OldMusic"

			Terrain:Load(ReplicatedStorage.Environments.Terrains.TrainStation)

			FS.spawn(function()
				wait(2)
				Hint("Touch the green button to ready up.")
				wait(2)
			end)
		elseif workspace:FindFirstChild("Lobby") then
			if StoryTeller:Check(DataValues.AccInfo.StoryProgression, "2") then
				workspace.Lobby.Garbage:Destroy()
				physicalCompass:new(workspace.Lobby.DungeonEntrance)
				physicalCompass:new(workspace.Lobby.Notifications.Main)
			elseif StoryTeller:Check(DataValues.AccInfo.StoryProgression, "1") then
				workspace.Lobby.Garbage.LargeDebris:Destroy()
				physicalCompass:new(workspace.Lobby.DungeonEntrance)
			end

			if StoryTeller:Check(DataValues.AccInfo.StoryProgression, "2.5") then
				physicalCompass:new(workspace.Lobby.ShopEntrance)
			end

			if StoryTeller:Check(DataValues.AccInfo.StoryProgression, "High Vigils: Mysterious Distress Signal") then
				physicalCompass:new(workspace.Lobby.BlacksmithEntrance)
			end

			local LobbyWaters = ReplicatedStorage.Environments.Terrains.Lobby

			TERRAIN.WaterColor = LobbyWaters.WaterProperties.WaterColor.Value
			TERRAIN.WaterReflectance = LobbyWaters.WaterProperties.WaterReflectance.Value
			TERRAIN.WaterTransparency = LobbyWaters.WaterProperties.WaterTransparency.Value
			TERRAIN.WaterWaveSize = LobbyWaters.WaterProperties.WaterWaveSize.Value
			TERRAIN.WaterWaveSpeed = LobbyWaters.WaterProperties.WaterWaveSpeed.Value

		--	RainAPI:SetCollisionMode(RainAPI.CollisionMode.Blacklist, {workspace.Lobby.InvisWall})
		end
		ColorCorrection.Saturation = 0
		ColorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
		TERRAIN:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(106, 127, 63))
		TERRAIN:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(102, 92, 59))
		TERRAIN:SetMaterialColor(Enum.Material.Mud, Color3.fromRGB(58, 46, 36))
		TERRAIN:SetMaterialColor(Enum.Material.Rock, Color3.fromRGB(102, 108, 111))
		Camera.FieldOfView = Numbers.LobbyFov
		ReplicatedStorage.ClassicSky:Clone().Parent = Lighting
		GUI.Main.Enabled = true
		if bools.CanLoad == false then
			GUI.Main.Icon.Visible = true
		end
		wait(3) 
		TweenService:Create(GUI.Main.Icon, TweenInfo.new(5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Size = UDim2.new(0.8,0,.8,0), Position = UDim2.new(.3,0,0.1,0), ImageTransparency = 1}):Play()
		TweenService:Create(GUI.MainMenu.CharSelect.BG, TweenInfo.new(2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {BackgroundTransparency = 1}):Play()
		TweenService:Create(Lighting.Blur, TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Size = 0}):Play()
		if Options ~= nil and Options.PlayMusic then
			MusicPlayer:Play(ReplicatedStorage.Sounds.Music.LobbyMusic, 4)
		else
			MusicPlayer:Stop(1)
		end
		wait(4) 
		GUI.Main.Icon.Visible = false
		GUI.MainMenu.Enabled = false
		OnMenu = false
	end
end
