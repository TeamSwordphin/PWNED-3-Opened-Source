local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CLIENT = script.Parent.Parent
local MODULES = CLIENT.Parent:WaitForChild("Modules")
local PLAYER = Players.LocalPlayer
local Gui = PLAYER:WaitForChild("PlayerGui")
local NewMenu = Gui:WaitForChild("DesktopPauseMenu").Base.Mask
local PlayerUI = Gui:WaitForChild("Main").GameGUI.PlayerUI

local Socket = require(MODULES.socket)
local DataValues = require(CLIENT.DataValues)
local MusicPlayer = require(MODULES.MusicPlayer)
local TerrainSaveLoad = require(MODULES.TerrainSaveLoad)

local Objs = DataValues.Objs
local Numbers = DataValues.Numbers
local bools = DataValues.bools
local Options = DataValues.Options
local CAMERAOFFSET = DataValues.CAMERAOFFSET

return function(sg)
	Socket:Emit("UpdateOptions", DataValues.Options)
	local SongName = sg or nil
	local Character = PLAYER.Character
	local NewAttkSpeed = 1
	local tweenInfo = TweenInfo.new(
			0.7,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out,
			0,
			false,
			0
	)
	GuiService.SelectedObject = nil
	NewMenu.EditWindow.Visible = false
	Gui.PlayerCardInspect.Enabled = false
	TweenService:Create(Gui.DesktopPauseMenu.Gradient,TweenInfo.new(.5,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
	TweenService:Create(NewMenu,TweenInfo.new(.5,Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,0,0)}):Play()
	TweenService:Create(Gui.Main.Tutorial, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.25,0,1,0)}):Play()
	Numbers.OriginalMaxHP = Character.Humanoid.MaxHealth
	Objs.CurrentClass, Objs.CurrentLevel, NewAttkSpeed, bools.IsSpecial, Numbers.ChainCooldowns = Socket:Request("GetBattleModeInfo")

	if Numbers.Att < 1.2 then
		Numbers.Att = NewAttkSpeed
	end
	Numbers.CritWounds = 0
	local HealthPercentage = Character.Humanoid.Health/(Numbers.OriginalMaxHP+Numbers.ShieldMaxHP)
	PlayerUI.Left.Bars.HPBar.Bar.Size = UDim2.new(.98*(HealthPercentage),0,.7,0)
	Gui.Main.GameGUI.PlayerCommands.Left.RMB.Visible = false
	--[[
	if Character:FindFirstChild("Animate") then
		if Character.Animate.attackY:FindFirstChild("Y1") then
			Gui.Main.GameGUI.PlayerCommands.Left.RMB.Image = Character.Animate.attackY["Y1"].img.Value
		end
	end
	--]]
	PlayerUI.Left.Bars.ZSpecialBar.Bar.Size = UDim2.new(0,0,.7,0)
	bools.TPS = false
	bools.IsBlocking = false
	bools.IsDodging = false
	bools.Debounce = false
	Character.Humanoid.WalkSpeed = Numbers.CombatWalkSpeed
	CAMERAOFFSET = Vector3.new(0,2,15)
	bools.OpenShop = false
	if workspace:FindFirstChild("Shop")  then
		workspace.Shop:Destroy()
	end
	if workspace:FindFirstChild("Blacksmith")  then
		workspace.Blacksmith:Destroy()
	end
	Gui.ShopGUI.Enabled = false
	if workspace:FindFirstChild("Map") then
		local mup = workspace.Map
		if Lighting:FindFirstChild("Sky") then
			Lighting.Sky:Destroy()
		end
		if Lighting:FindFirstChild("Atmosphere") then
			Lighting.Atmosphere:Destroy()
		end

		if mup.VisualEffectsSettings:FindFirstChild("Sky") then
			mup.VisualEffectsSettings.Sky:Clone().Parent = Lighting
			Lighting.SunRays.Intensity = mup.VisualEffectsSettings.SunRays.Intensity
			Lighting.SunRays.Spread = mup.VisualEffectsSettings.SunRays.Spread
			Lighting.Bloom.Intensity = mup.VisualEffectsSettings.Bloom.Intensity
			Lighting.Blur.Size = mup.VisualEffectsSettings.Blur.Size
			Lighting.ColorCorrection.Brightness = mup.VisualEffectsSettings.ColorCorrection.Brightness
			Lighting.ColorCorrection.Contrast = mup.VisualEffectsSettings.ColorCorrection.Contrast
			Lighting.ColorCorrection.Saturation = mup.VisualEffectsSettings.ColorCorrection.Saturation
			Lighting.ColorCorrection.TintColor = mup.VisualEffectsSettings.ColorCorrection.TintColor
		end
		for _, setting in ipairs(mup.LightSettings:GetChildren()) do
			Lighting[setting.Name] = setting.Value
		end

		if mup:FindFirstChild("Defending") then
			PlayerUI.Left.ComboCounter.Defend.Visible = true
			local dHumanoid = mup.Defending.DefendBlock.Humanoid
			local hp
			hp = dHumanoid.HealthChanged:Connect(function()
				if not PlayerUI.Left.ComboCounter.Defend.Visible then
					hp:Disconnect()
				end
				PlayerUI.Left.ComboCounter.Defend.Bar.Size = UDim2.new(math.max(0, 0.98 * (dHumanoid.Health / dHumanoid.MaxHealth)), 0, 0.7, 0)
			end)
		else
			PlayerUI.Left.ComboCounter.Defend.Visible = false
			PlayerUI.Left.ComboCounter.Defend.Bar.Size = UDim2.new(0.98, 0, 0.7, 0)
		end
	else
		TweenService:Create(Lighting, TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Brightness = 5, Ambient = Color3.fromRGB(30,30,30), OutdoorAmbient = Color3.fromRGB(50,50,50)}):Play() 
	end
	if Options.PlayMusic and SongName ~= nil and ReplicatedStorage.Sounds.Music:FindFirstChild(SongName) then
		MusicPlayer:Play(ReplicatedStorage.Sounds.Music[SongName], 1.5, nil, 4)
	end

	if bools.NewPlayer then
		Gui.Main.Tutorial.Front.ImageTransparency = 1
		for _,word in next, Gui.Main.Tutorial.Front:GetChildren() do
			if word:IsA("TextLabel") then
				word.TextTransparency = 1
				word.TextStrokeTransparency = 1
			end
		end
		wait(2)
		TweenService:Create(Gui.Main.Tutorial, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.25,0,0.6,0)}):Play() wait(1)
		for _,word in next, Gui.Main.Tutorial.Combat:GetChildren() do
			if word:IsA("TextLabel") then
				TweenService:Create(word, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
			end
		end
		TweenService:Create(Gui.Main.Tutorial.Combat, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {ImageTransparency = 0}):Play()
		wait(30)
		TweenService:Create(Gui.Main.Tutorial, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.25,0,1,0)}):Play()
		bools.NewPlayer = false
	end
end
