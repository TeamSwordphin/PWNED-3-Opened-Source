-- << Services >> --
local Debris 			= game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players			= game:GetService("Players")
local TweenService		= game:GetService("TweenService")

-- << Constants >> -- 
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local PLAYERUI 	= GUI:WaitForChild("Main").GameGUI.PlayerUI

-- << Modules >> --
local Socket 			= require(MODULES.socket)
local StoryTeller 		= require(MODULES.StoryTeller)
local DataValues 		= require(CLIENT.DataValues)
local Hint		  		= require(CLIENT.UIEffects.Hint)
local CreateTutorial	= require(CLIENT.UIEffects.TutorialPlatformButtons)
local Animate 			= require(CLIENT.UIEffects.AnimateSpriteSheet)
local execute_Dialogue	= require(CLIENT.DialogueSystem.MainExecutorDialogue)
local FS 		  		= require(ReplicatedStorage.Scripts.Modules.FastSpawn)

-- << Variables >> --
local LastMsg = ""
local IsPlayingBanner = false
local Character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local CharacterValues = ReplicatedStorage.PlayerValues:WaitForChild(PLAYER.Name)


-----------------------------------------
function OnRespawn(character)
	Character = character
	CharacterValues = ReplicatedStorage.PlayerValues:WaitForChild(PLAYER.Name)
	PLAYERUI.Left.Bars.StaminaBar.Amnt.Text	= CharacterValues.StaminaMax.Value.. " / " .. CharacterValues.StaminaMax.Value
	PLAYERUI.Left.Bars.StaminaBar.Bar.Size = UDim2.new(0.98, 0, 0.7, 0)

	CharacterValues.Stamina:GetPropertyChangedSignal("Value"):Connect(function()
		PLAYERUI.Left.Bars.StaminaBar.Amnt.Text	= math.floor(CharacterValues.Stamina.Value + 0.5).. " / " .. CharacterValues.StaminaMax.Value
		PLAYERUI.Left.Bars.StaminaBar.Bar.Size = UDim2.new(0.98 * (CharacterValues.Stamina.Value/CharacterValues.StaminaMax.Value), 0, 0.7, 0)
	end)

	CharacterValues.Barrier:GetPropertyChangedSignal("Value"):Connect(function()
		PLAYERUI.Left.Bars.HPBar.Barrier.Size = UDim2.new(0.98 * (CharacterValues.Barrier.Value/Character.Humanoid.MaxHealth), 0, 0.7, 0)
	end)
end

OnRespawn(Character)
PLAYER.CharacterAdded:Connect(OnRespawn)

Socket:Listen("Intermission", function(msg, bol)
	local bool = bol or nil
	if bool == nil then
		GUI.Main.LobbyGUI.Hint.TextLabel.Text = msg
	else
		execute_Dialogue(msg)
	end
end)

Socket:Listen("InfoUpdate", function(Data, TimeLeft, EnemiesLeft, DungeonMsg, AddText)
	if DataValues.WatchedIntro then
		local GameData = Data
		if GameData.CurrentMap.Type == "PVP" then
			PLAYERUI.Left.EnemiesAlive.Text = "Defeat the other team to win!"
		else   
			if GameData.CurrentMap.TypeProperties.Type == "Wave" then
				PLAYERUI.Left.EnemiesAlive.Text = "Wave " .. tostring(GameData.CurrentWave).. " - " .. tostring(EnemiesLeft) .. " Enemies Alive"
			elseif GameData.CurrentMap.TypeProperties.Type == "Dungeon" and game.PlaceId ~= 785484984 and game.PlaceId ~= 563493615 then
				if LastMsg ~= DungeonMsg then
					Hint("Objective Updated")
					LastMsg = DungeonMsg
				end
				if AddText ~= nil then
					PLAYERUI.Left.EnemiesAlive.Text = DungeonMsg.. "" ..AddText
				else
					PLAYERUI.Left.EnemiesAlive.Text = DungeonMsg
				end
			end
		end
		PLAYERUI.Left.Timer.Text = TimeLeft
		PLAYERUI.Left.TeamHPBar.Amnt.Text = tostring(math.floor(GameData.TeamHP))
		TweenService:Create(PLAYERUI.Left.TeamHPBar.Bar, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Size = UDim2.new(.98*(GameData.TeamHP/GameData.MAXTeamHP),0,.7,0)}):Play()
		if DataValues.AccInfo and not GameData.HeroMode and GameData.CurrentMap.MissionName == "Riukaya-Hara: A Journey's Start" then
			if not StoryTeller:Check(DataValues.AccInfo.StoryProgression, "T1.1") then
				Socket:Emit("Story", "T1.1")
				table.insert(DataValues.AccInfo.StoryProgression, "T1.1")
				FS.spawn(function()
					wait(10)
					CreateTutorial(nil, "Most attacks can hit projectiles and reflect them.", 20)
				end)
			end
		end
	end
end)

Socket:Listen("Banner", function(msg, BG, naim)
	if IsPlayingBanner == false and DataValues.WatchedIntro then
		IsPlayingBanner = true
		local Banner = GUI.DesktopPauseMenu.Base.OtherUI.Banners
		local Banners = ReplicatedStorage.Images.Banners
		if Banners:FindFirstChild(BG) then
			Banner.BannerImg.Image = Banners[BG].Image
		end
		Banner.BannerImg.Award.Text = msg
		Banner.BannerImg.PlayerName.Text = naim
		Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
		Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
		if ReplicatedStorage.Images.Banners[BG]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[BG]:FindFirstChild("NumOfSprites") then
			Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
			Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
			FS.spawn(function()
				local CanContinue = true
				FS.spawn(function()
					while wait(.3) and CanContinue do
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
				end
			end)
		end
		TweenService:Create(Banner, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(.72,0,.3,0)}):Play()
		wait(5)
		TweenService:Create(Banner, TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Position = UDim2.new(1.2,0,.3,0)}):Play() wait(.7)
		Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
		Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
		Banner.BannerImg.Image = ""
		IsPlayingBanner = false
	end
end)

Socket:Listen("EnemyUpdate", function(enemyInfo)
	local notification = GUI.Notification.RightSideEnemy
	local template = notification.Template.Item:Clone()
	local main = template.Main

	main.Details.Description.Text = enemyInfo.Description
	main.Details.Title.Text = enemyInfo.Name
	template.Visible = true
	template.Parent = notification.Stuff

	Debris:AddItem(template, 15)	

	TweenService:Create(main, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)}):Play() wait(0.5)
	TweenService:Create(main.Loading.BackBar, TweenInfo.new(0.25), {BackgroundTransparency = 0.5}):Play()
	TweenService:Create(main.Loading.BackBar.Bar, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
	TweenService:Create(main.Loading.Title, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
	TweenService:Create(main.Loading.BackBar.Bar, TweenInfo.new(3), {Size = UDim2.new(1, 0, 1, 0)}):Play() wait(3)
	TweenService:Create(main.Loading.BackBar, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
	TweenService:Create(main.Loading.BackBar.Bar, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
	TweenService:Create(main.Loading.Title, TweenInfo.new(0.25), {TextTransparency = 1}):Play() wait(0.25)

	TweenService:Create(main.Details.Line, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
	TweenService:Create(main.Details.Title, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
	TweenService:Create(main.Details.Description, TweenInfo.new(0.25), {TextTransparency = 0}):Play() wait(7)
	TweenService:Create(main, TweenInfo.new(0.5), {Position = UDim2.new(2, 0, 0, 0)}):Play() wait(0.5)
	template:Destroy()
end)
