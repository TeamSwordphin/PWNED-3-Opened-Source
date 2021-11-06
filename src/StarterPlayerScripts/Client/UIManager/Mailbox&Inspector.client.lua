local PLAYERS 	= game:GetService("Players")
local TEAMS		= game:GetService("Teams")
local UIS		= game:GetService("UserInputService")
local CAS		= game:GetService("ContextActionService")
local TS		= game:GetService("TweenService")
local RS		= game:GetService("ReplicatedStorage")

local CLIENT = script.Parent.Parent
local PLAYER = PLAYERS.LocalPlayer
local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()

local GUI 	= PLAYER:WaitForChild("PlayerGui")
local CARD 	= GUI:WaitForChild("PlayerCardInspect")
local INBOX = GUI:WaitForChild("Mailbox")
local MODULE = CLIENT.Parent:WaitForChild("Modules")

local SOCKET 	 = require(MODULE.socket)
local DYNDOF 	 = require(MODULE.EffectManipulation.DynamicDepthOfField)
local FS	 	 = require(RS.Scripts.Modules.FastSpawn)
local Animate	 = require(CLIENT.UIEffects.AnimateSpriteSheet)
local round		 = require(CLIENT.UIEffects.RoundNumbers)
local DataValues = require(CLIENT.DataValues)

local characters = workspace.Players

local card = CARD.Card
local mailbox = INBOX.Main

local TARGET
local ACHIEVEMENT_LIST

---- functions

function cardSetup()
	local banner = card.Banner
	local background = card.Background
	local mainWindow = card.MainWindow
	local generalInfo = mainWindow.GeneralInfo
	local equipment = mainWindow.Equipment
	local characterWindow = mainWindow.Character
	local statistics = mainWindow.Statistics
	local graphs = mainWindow.Graphs
	local tweenInfo = TweenInfo.new(0.25)
	
	GUI.DesktopPauseMenu.Base.Mask.OuterFrame.ContentWindow.Settings.SideBar.PlayerCard.PlayerCard.MouseButton1Down:Connect(function()
		if not CARD.Enabled then
			TARGET = PLAYER
			CARD.Enabled = true
		end
	end)
	
	CARD:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not CARD.Enabled then
			for _, characterCount in ipairs(graphs.Content:GetChildren()) do
				if characterCount:IsA("Frame") then
					characterCount:Destroy()
				end
			end
			
			equipment.Content.Weapons.Weapon.Block.ViewportFrame:ClearAllChildren()
			equipment.Content.Weapons.Trophy.Block.ViewportFrame:ClearAllChildren()
			
			mainWindow.TopSpacer.Size = UDim2.new(0, 100, 0, 242)
			banner.PlayerCardBackground.ImageTransparency = 0.1
			banner.PlayerCardBackground.PlayerName.Position = UDim2.new(0.025, 0, 0.8, 0)
			background.Position = UDim2.new(0, 0, 0, 302)
			background.Size = UDim2.new(1, 0, 1, -302)
			
			if not mailbox.Visible then
				DYNDOF:Disable()
			end
		else
			DYNDOF:Enable()
			DYNDOF:SetFocusRadius(50)
			DYNDOF:SetDepthToPart(CHARACTER.PrimaryPart)
			
			local PLAYER_ACC_INFO, INFORMATION = SOCKET:Request("GetPlayerInfo", TARGET.UserId)
			
			if PLAYER_ACC_INFO then
				local CHARACTER_INFO = PLAYER_ACC_INFO.Characters[PLAYER_ACC_INFO.CurrentClass]
				local achievementsCompleted = 0
				local weaponUpgradeLevel = CHARACTER_INFO.CurrentWeapon.UpLvl
				local Gemstones = INFORMATION.Gemstones
				local WeaponPreview = INFORMATION.Weapon.Model and INFORMATION.Weapon.Model:Clone() or nil
				local TrophyPreview = INFORMATION.Trophy.Model and INFORMATION.Trophy.Model:Clone() or nil
				local Stats = {HP = 0, Damage = 0, Defense = 0, Crit = 0, CritDef = 0, Stamina = 0}
				
				local function CheckGemName(Name)
					if Gemstones.Gemstone1 and Gemstones.Gemstone1.Name == Name then
						return Gemstones.Gemstone1
					elseif Gemstones.Gemstone2 and Gemstones.Gemstone2.Name == Name then
						return Gemstones.Gemstone2
					elseif Gemstones.Gemstone3 and Gemstones.Gemstone3.Name == Name then
						return Gemstones.Gemstone3
					end
				end
				
				for _, achievement in ipairs(PLAYER_ACC_INFO.Achievements) do
					if achievement.C == 1 then
						achievementsCompleted += 1
					end
				end
				
				if WeaponPreview:FindFirstChild("CameraCF") then
					local CameraPre = Instance.new("Camera")
					CameraPre.CFrame = WeaponPreview.CameraCF.Value
					equipment.Content.Weapons.Weapon.Block.ViewportFrame.CurrentCamera = CameraPre
				end
				if TrophyPreview and TrophyPreview:FindFirstChild("CameraCF") then
					local CameraPre = Instance.new("Camera")
					CameraPre.CFrame = TrophyPreview.CameraCF.Value
					equipment.Content.Weapons.Trophy.Block.ViewportFrame.CurrentCamera = CameraPre
					TrophyPreview.Parent = equipment.Content.Weapons.Trophy.Block.ViewportFrame
				end
				WeaponPreview.Parent = equipment.Content.Weapons.Weapon.Block.ViewportFrame
				
				Stats.HP = Stats.HP + (INFORMATION.Trophy.Stats.HP+(INFORMATION.Trophy.StatsPerLevel.HP*CHARACTER_INFO.CurrentTrophy.UpLvl))
				Stats.Defense = Stats.Defense + (INFORMATION.Trophy.Stats.DEF+(INFORMATION.Trophy.StatsPerLevel.DEF*CHARACTER_INFO.CurrentTrophy.UpLvl))
				Stats.CritDef = Stats.CritDef + (INFORMATION.Weapon.Stats.CRITDEF+(INFORMATION.Weapon.StatsPerLevel.CRITDEF*CHARACTER_INFO.CurrentWeapon.UpLvl))
				Stats.Crit = Stats.Crit + (INFORMATION.Weapon.Stats.CRIT+(INFORMATION.Weapon.StatsPerLevel.CRIT*CHARACTER_INFO.CurrentWeapon.UpLvl))
				Stats.Damage = Stats.Damage + (INFORMATION.Weapon.Stats.ATK+(INFORMATION.Weapon.StatsPerLevel.ATK*CHARACTER_INFO.CurrentWeapon.UpLvl))
				Stats.Stamina = Stats.Stamina + (INFORMATION.Weapon.Stats.STAM+(INFORMATION.Weapon.StatsPerLevel.STAM*CHARACTER_INFO.CurrentWeapon.UpLvl))
				
				local HPIn = CheckGemName("HP Increase")
				if HPIn then
					Stats.HP = Stats.HP + ((Stats.HP+CHARACTER_INFO.HP)*(HPIn.Value*.01))
				end
				local Rein = CheckGemName("Reinforced Armor")
				if Rein then
					Stats.Defense = Stats.Defense + ((Stats.Defense+CHARACTER_INFO.Defense))
				end
				local CloD = CheckGemName("Close Defense")
				if CloD then
					Stats.CritDef = Stats.CritDef + ((Stats.CritDef+CHARACTER_INFO.CritDef)*(CloD.Value*.01))
				end
				local Muscu = CheckGemName("Muscular Power")
				if Muscu then
					Stats.Damage = Stats.Damage + ((Stats.HP+CHARACTER_INFO.HP)*(Muscu.Value*.01))
				end
				local CritI = CheckGemName("Critical Increase")
				if CritI then
					Stats.Crit = Stats.Crit + CritI.Value
				end
				local CritI2 = CheckGemName("Life Drain on Crit")
				if CritI2 then
					Stats.Crit = Stats.Crit + CritI2.Value*10
				end
				local Primal = CheckGemName("Primal Curse and Bloodlust")
				if Primal then
					Stats.Damage = Stats.Damage + ((Stats.Damage+CHARACTER_INFO.Damage)*(Primal.Value*.01))
				end
				local ATKI = CheckGemName("ATK Increase")
				if ATKI then
					Stats.Damage = Stats.Damage + ((Stats.Damage+CHARACTER_INFO.Damage)*(ATKI.Value*.01))
				end
				
				local CappedDefense = (CHARACTER_INFO.Defense * 100) + Stats.Defense
				
				if RS.Images.ProfileBackground:FindFirstChild(PLAYER_ACC_INFO.PlayerCardBackground) then
					banner.PlayerCardBackground.Image = RS.Images.ProfileBackground[PLAYER_ACC_INFO.PlayerCardBackground].Image
				else
					banner.PlayerCardBackground.Image = ""
				end
				banner.PlayerCardBackground.PlayerName.Text = TARGET.Name
				generalInfo.TimePlayed.Content.Value.Text = string.format("%s Hours", math.floor(PLAYER_ACC_INFO.TotalHours / 3600))
				generalInfo.Achievements.Content.Value.Text = string.format("%s / %s", achievementsCompleted, #ACHIEVEMENT_LIST)
				
				equipment.Content.Weapons.Weapon.Namer.Text = string.format("%s %s", INFORMATION.Weapon.WeaponName, weaponUpgradeLevel > 0 and "+"..weaponUpgradeLevel or "")
				equipment.Content.Weapons.Trophy.Namer.Text = INFORMATION.Trophy.WeaponName
				equipment.Content.Weapons.Weapon.Block.Rarity.Image = RS.Images.Textures["Rarity"..INFORMATION.Weapon.Rarity].Image
				equipment.Content.Weapons.Trophy.Block.Rarity.Image = RS.Images.Textures["Rarity"..INFORMATION.Trophy.Rarity].Image
				---- SKIN STUFF HERE
				
				local Banner = equipment.Content.Gemstones
				local ProfileBackground = PLAYER_ACC_INFO.ProfileBackground
				local Banners = RS.Images.Banners
				if Banners:FindFirstChild(ProfileBackground) then
					Banner.BannerImg.Image = Banners[ProfileBackground].Image
				end
				Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
				Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
				if RS.Images.Banners[ProfileBackground]:FindFirstChild("Width") and RS.Images.Banners[ProfileBackground]:FindFirstChild("NumOfSprites") then
					Banner.BannerImg.ImageRectOffset = Vector2.new(-RS.Images.Banners[ProfileBackground].Width.Value.X,0)
					Banner.BannerImg.ImageRectSize = Vector2.new(RS.Images.Banners[ProfileBackground].Width.Value.X,RS.Images.Banners[ProfileBackground].Width.Value.Y)
					FS.spawn(function()
						while CARD.Enabled do
							Banner.BannerImg.ImageRectOffset = Vector2.new(-RS.Images.Banners[ProfileBackground].Width.Value.X,0)
							Banner.BannerImg.ImageRectSize = Vector2.new(RS.Images.Banners[ProfileBackground].Width.Value.X,RS.Images.Banners[ProfileBackground].Width.Value.Y)
							local NumOfSpritesX = RS.Images.Banners[ProfileBackground].NumOfSprites.Value.X ~= 0 and RS.Images.Banners[ProfileBackground].NumOfSprites.Value.X or 3
							local NumOfSpritesY = RS.Images.Banners[ProfileBackground].NumOfSprites.Value.Y ~= 0 and RS.Images.Banners[ProfileBackground].NumOfSprites.Value.Y or 9
							Animate(Banner.BannerImg, false, NumOfSpritesX, NumOfSpritesY, RS.Images.Banners[ProfileBackground].Framerate.Value, 0,0, RS.Images.Banners[ProfileBackground].Maxframes.Value)
						end
					end)
				end
				
				if Gemstones.Gemstone1 then
					equipment.Content.Gemstones.Gemstone1.Namer.Text = string.format("%s %s", Gemstones.Gemstone1.Name, Gemstones.Gemstone1.R > 0 and "+" ..Gemstones.Gemstone1.R or "")
					equipment.Content.Gemstones.Gemstone1.Block.GemstoneIcon.Image = Gemstones.Gemstone1.Image
				else
					equipment.Content.Gemstones.Gemstone1.Namer.Text = "No gemstone equipped."
					equipment.Content.Gemstones.Gemstone1.Block.GemstoneIcon.Image = ""
				end
				if Gemstones.Gemstone2 then
					equipment.Content.Gemstones.Gemstone2.Namer.Text = string.format("%s %s", Gemstones.Gemstone2.Name, Gemstones.Gemstone2.R > 0 and "+" ..Gemstones.Gemstone2.R or "")
					equipment.Content.Gemstones.Gemstone2.Block.GemstoneIcon.Image = Gemstones.Gemstone2.Image
				else
					equipment.Content.Gemstones.Gemstone2.Namer.Text = "No gemstone equipped."
					equipment.Content.Gemstones.Gemstone2.Block.GemstoneIcon.Image = ""
				end
				if Gemstones.Gemstone3 then
					equipment.Content.Gemstones.Gemstone3.Namer.Text = string.format("%s %s", Gemstones.Gemstone3.Name, Gemstones.Gemstone3.R > 0 and "+" ..Gemstones.Gemstone3.R or "")
					equipment.Content.Gemstones.Gemstone3.Block.GemstoneIcon.Image = Gemstones.Gemstone3.Image
				else
					equipment.Content.Gemstones.Gemstone3.Namer.Text = "No gemstone equipped."
					equipment.Content.Gemstones.Gemstone3.Block.GemstoneIcon.Image = ""
				end
				
				characterWindow.Content.Basic.Type.Content.Value.Text = PLAYER_ACC_INFO.CurrentClass
				characterWindow.Content.Basic.Level.Content.Value.Text = CHARACTER_INFO.CurrentLevel
				characterWindow.Content.Basic.EXP.Content.Value.Text = CHARACTER_INFO.EXP
				
				characterWindow.Content.Stats.HP.Content.Value.Text = math.floor(CHARACTER_INFO.HP + Stats.HP)
				characterWindow.Content.Stats.Damage.Content.Value.Text = CHARACTER_INFO.Damage + Stats.Damage
				characterWindow.Content.Stats.Def.Content.Value.Text = round(CappedDefense > 80 and 80 or CappedDefense, 2) .. "%"
				characterWindow.Content.Stats.Crit.Content.Value.Text = CHARACTER_INFO.Crit + Stats.Crit
				characterWindow.Content.Stats.CritDef.Content.Value.Text = CHARACTER_INFO.CritDef + Stats.CritDef
				characterWindow.Content.Stats.Stamina.Content.Value.Text = CHARACTER_INFO.Stamina + Stats.Stamina
				
				statistics.Content.Stats.Normal.Content.Value.Text = PLAYER_ACC_INFO.DungeonNormalCompleted
				statistics.Content.Stats.Hero.Content.Value.Text = PLAYER_ACC_INFO.DungeonHeroCompleted
				statistics.Content.Stats.HMD.Content.Value.Text = PLAYER_ACC_INFO.DungeonHMDCompleted
				
				statistics.Content.EnemyStats.BossesKilled.Content.Value.Text = PLAYER_ACC_INFO.BossesKilled
				statistics.Content.EnemyStats.HighestCombo.Content.Value.Text = PLAYER_ACC_INFO.HighestCombo
				statistics.Content.EnemyStats.HighestDamage.Content.Value.Text = PLAYER_ACC_INFO.HighestDamage
				
				local tierAmount = {25, 50, 75, 100, 150, 200, 400, 600, 1000, 1500, 2000, 2500, 3000, 3500}
				local proxyCharacterCount = {}
				for key, _ in pairs(PLAYER_ACC_INFO.CharacterPlayCount) do
					table.insert(proxyCharacterCount, key)
				end
				table.sort(proxyCharacterCount, function(A, B)
					return PLAYER_ACC_INFO.CharacterPlayCount[A] > PLAYER_ACC_INFO.CharacterPlayCount[B]
				end)
				
				local largest = PLAYER_ACC_INFO.CharacterPlayCount[proxyCharacterCount[1]]
				local tierIndex = 1
				
				if largest > tierAmount[#tierAmount] then
					table.insert(tierAmount, largest)
					tierIndex = tierAmount[#tierAmount]
				else
					for index, tier in ipairs(tierAmount) do
						if largest < tier then
							tierIndex = index
							break
						end
					end
				end
				
				for i, characterKey in ipairs(proxyCharacterCount) do
					local characterPlayCount = PLAYER_ACC_INFO.CharacterPlayCount[characterKey]
					local newCounter = graphs.Templates.Count:Clone()
					newCounter.Content.Bar.Cap.Value = tierAmount[tierIndex]
					newCounter.Content.Bar.BarSize.Value = characterPlayCount
					newCounter.Content.Title.Text = string.format("%s - %s", string.upper(characterKey), characterPlayCount)
					if graphs.Templates.ColorChart:FindFirstChild(characterKey) then
						newCounter.Content.Bar.BackgroundColor3 = graphs.Templates.ColorChart[characterKey].Value
					end
					newCounter.Visible = true
					newCounter.Parent = graphs.Content
				end
				
				graphs.Content.Size = UDim2.new(0.97, 0, 0, mainWindow.Graphs.Content.UIListLayout.AbsoluteContentSize.Y)
				mainWindow.CanvasSize = UDim2.new(0, 0, 0, mainWindow.UIListLayout.AbsoluteContentSize.Y)
				mainWindow.CanvasPosition = Vector2.new(0, 0)
			else
				CARD.Enabled = false
			end
		end
	end)
	
	mainWindow:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if mainWindow.CanvasPosition.Y >= 150 then
			local content = graphs.Content:GetChildren()
			if #content > 1 then
				for _, counter in ipairs(content) do
					if counter:IsA("Frame") then
						local barSize = counter.Content.Bar.BarSize.Value
						local capSize = counter.Content.Bar.Cap.Value
						TS:Create(counter.Content.Bar, tweenInfo, {Size = UDim2.new(barSize / capSize, 0, 1, 0)}):Play()
					end
				end
			end
		elseif mainWindow.CanvasPosition.Y > 10 then
			TS:Create(mainWindow.TopSpacer, tweenInfo, {Size = UDim2.new(0, 100, 0, 170)}):Play()
			TS:Create(background, tweenInfo, {Position = UDim2.new(0, 0, 0, 60), Size = UDim2.new(1, 0, 1, -60)}):Play()
			TS:Create(banner.PlayerCardBackground, tweenInfo, {ImageTransparency = 0.75}):Play()
			TS:Create(banner.PlayerCardBackground.PlayerName, tweenInfo, {Position = UDim2.new(0.025, 0, 0, 0)}):Play()
		else
			TS:Create(mainWindow.TopSpacer, tweenInfo, {Size = UDim2.new(0, 100, 0, 242)}):Play()
			TS:Create(background, tweenInfo, {Position = UDim2.new(0, 0, 0, 302), Size = UDim2.new(1, 0, 1, -302)}):Play()
			TS:Create(banner.PlayerCardBackground, tweenInfo, {ImageTransparency = 0.1}):Play()
			TS:Create(banner.PlayerCardBackground.PlayerName, tweenInfo, {Position = UDim2.new(0.025, 0, 0.8, 0)}):Play()
		end
	end)
	
	card.close.MouseButton1Down:Connect(function()
		CARD.Enabled = false
	end)
end

function mailSetup()
	local inbox = mailbox.Content.Inbox
	local reader = mailbox.Content.Reader
	local buttons = reader.Buttons
	local temp = mailbox.Template
	local currentSelected = nil
	local tweenInfo = TweenInfo.new(0.25)
	local function inboxView()
		TS:Create(reader, tweenInfo, {Position = UDim2.new(1, 0, 0, 0)}):Play()
		TS:Create(inbox, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()
	end
	
	mailbox:GetPropertyChangedSignal("Visible"):Connect(function()
		if not mailbox.Visible then
			for _, mail in ipairs(inbox:GetChildren()) do
				if mail:IsA("Frame") then
					mail:Destroy()
				end
			end
			inbox.Position = UDim2.new(0, 0, 0, 0)
			reader.Position = UDim2.new(1, 0, 0, 0)
			currentSelected = nil
			
			if not CARD.Enabled then
				DYNDOF:Disable()
			end
		else
			DYNDOF:Enable()
			DYNDOF:SetFocusRadius(50)
			DYNDOF:SetDepthToPart(CHARACTER.PrimaryPart)
			
			local mails = SOCKET:Request("GetMail")
			if #mails > 0 then
				currentSelected = nil
				for _, mail in ipairs(mails) do
					local newMailInfo = temp.MailInfo:Clone()
					local icon = newMailInfo.Button.Mail.mail
					local content = newMailInfo.Button.Mail.Content
					local date = mail.Date or {m = 0, d = 0, y = 0}
					local seen = mail.Seen or false
					content.Title.Text = string.format(seen and "SEEN - %s/%s/%s" or "UNREAD MAIL - %s/%s/%s", date.m, date.d, date.y) 
					content.Value.Text = mail.Name
					icon.ImageTransparency = seen and 0.9 or 0
					
					newMailInfo.Button.MouseButton1Down:Connect(function()
						local moreMailInfo = SOCKET:Request("GetItemDescription", mail.Name)
						if moreMailInfo then
							currentSelected = {Name = mail.Name, Object = newMailInfo}
							content.Title.Text = string.format("SEEN - %s/%s/%s", date.m, date.d, date.y) 
							icon.ImageTransparency = 0.9
							reader.To.Content.Value.Text = PLAYER.Name
							reader.From.Content.Value.Text = moreMailInfo.From
							reader.TextMessage.Value.Text = string.format("%s\n\n%s", mail.Name, moreMailInfo.Description)
							reader.CanvasPosition = Vector2.new(0, 0)
							reader.CanvasSize = UDim2.new(0, 0, 0, reader.UIListLayout.AbsoluteContentSize.Y)
							reader.TextMessage.CanvasPosition = Vector2.new(0, 0)
							buttons.Redeem.Visible = moreMailInfo.Redeemable
							buttons.Delete.Visible = moreMailInfo.CanDelete
							TS:Create(reader, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()
							TS:Create(inbox, tweenInfo, {Position = UDim2.new(-1, 0, 0, 0)}):Play()
						end
					end)
					
					newMailInfo.Visible = true
					newMailInfo.Parent = inbox
				end
			end
			
			inbox.CanvasPosition = Vector2.new(0, 0)
			inbox.CanvasSize = UDim2.new(0, 0, 0, inbox.UIListLayout.AbsoluteContentSize.Y)
		end
	end)
	
	buttons.Redeem.MouseButton1Down:Connect(function()
		if currentSelected then
			currentSelected.Object:Destroy()
			SOCKET:Emit("RedeemItem", currentSelected.Name)
			currentSelected = nil
		end
		inboxView()
	end)
	
	buttons.Delete.MouseButton1Down:Connect(function()
		if currentSelected then
			currentSelected.Object:Destroy()
			SOCKET:Emit("RedeemItem", currentSelected.Name, true)
			currentSelected = nil
		end
		inboxView()
	end)
	
	reader.Back.back.MouseButton1Down:Connect(function()
		inboxView()
	end)
	
	mailbox.close.MouseButton1Down:Connect(function()
		mailbox.Visible = false
	end)
end

---- logic

function openContextCard(actionName, inputState, inputObject)
	if not DataValues.WatchedIntro then return end

	if inputState == Enum.UserInputState.Begin and PLAYER.TeamColor == TEAMS.Lobby.TeamColor then
		if actionName == "Inspect" then
			--- Mailbox Checker
			if workspace:FindFirstChild("Lobby") then
				local MAILBOX_DIST = (workspace.Lobby.Notifications.Main.Position - CHARACTER.PrimaryPart.Position).Magnitude
				if MAILBOX_DIST <= 10 then
					mailbox.Visible = true
				end
			end
			
			--- Player Card Inspector
			if not CARD.Enabled then
				local CAN_SHOW_INSPECTOR = true
				local PRIMARY_PARTS = {}
				
				local function CheckDescendants(model)
					if CAN_SHOW_INSPECTOR then
						for _, Model in ipairs(model:GetDescendants()) do
							if Model:IsA("Model") and Model.PrimaryPart then
								local DIST = (Model.PrimaryPart.Position - CHARACTER.PrimaryPart.Position).Magnitude
								if DIST <= 11 then
									CAN_SHOW_INSPECTOR = false
									break
								end
							end
						end
					end
				end
				CheckDescendants(workspace.Cutscene)
				CheckDescendants(workspace.Interactables)
				
				if CAN_SHOW_INSPECTOR then
					local DIST = 10
					TARGET = nil

					for _, player in ipairs(characters:GetChildren()) do
						local playerFromCharacter = PLAYERS:GetPlayerFromCharacter(player)
						if playerFromCharacter and playerFromCharacter ~= PLAYER then
							local targetCharacter = playerFromCharacter.Character.PrimaryPart
							local range = (targetCharacter.Position - CHARACTER.PrimaryPart.Position).Magnitude
							
							if range <= DIST then
								DIST = range
								TARGET = playerFromCharacter
							end
						end
					end
					
					if TARGET then
						CARD.Enabled = true
					end
				end
			end
			
			----
		end
	end
end

function handleCharacterRespawn(character)
	CHARACTER = character
end

function init()
	CAS:BindAction("Inspect", openContextCard, true, Enum.KeyCode.ButtonY, Enum.UserInputType.MouseButton2)
	CARD.Enabled = false
	mailbox.Visible = false
	DYNDOF:Disable()
	
	if UIS.TouchEnabled then
		local jumpButton = GUI:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
		local inspectButton = CAS:GetButton("Inspect")
		--[[
		local mouse1 = CAS:GetButton("MouseButton1")
		local mouse2 = CAS:GetButton("MouseButton2")
		
		if PLAYER.TeamColor == TEAMS.Lobby.TeamColor then
			inspectButton.Visible = true
			mouse1.Visible = false
			mouse2.Visible = false
		else
			inspectButton.Visible = false
			mouse1.Visible = true
			mouse2.Visible = true
		end
		--]]
		card.Size = UDim2.new(0.55, 0, 0.96, 0)
		card.Position = UDim2.new(0.44, 0, 0.02, 0)
		inspectButton.Size = UDim2.new(0, (jumpButton.Size.X.Offset / 3) * 2.5, 0, (jumpButton.Size.Y.Offset / 3) * 2.5) 
		CAS:SetPosition("Inspect", UDim2.new(0, jumpButton.AbsolutePosition.X - ((jumpButton.AbsoluteSize.X/2)*-.7), 0, (jumpButton.AbsolutePosition.Y - ((jumpButton.AbsoluteSize.Y/4) * 3))))
	--	CAS:SetTitle("Inspect", "Inspect")
	end
	
	ACHIEVEMENT_LIST = SOCKET:Request("GetAchievements")
	cardSetup()
	mailSetup()
end

init()
PLAYER.CharacterAdded:Connect(handleCharacterRespawn)
