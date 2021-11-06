-- << Services >> --
local ReplicatedStorage 	= game:GetService("ReplicatedStorage")
local Players 				= game:GetService("Players")
local TweenService			= game:GetService("TweenService")
local Debris 				= game:GetService("Debris")
local RunService 			= game:GetService("RunService")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local NEWMENU 	= GUI:WaitForChild("DesktopPauseMenu").Base.Mask

-- << Modules >> --
local Socket 			= require(MODULES.socket)
local StoryTeller 		= require(MODULES.StoryTeller)
local DataValues 		= require(CLIENT.DataValues)
local Hint		  		= require(CLIENT.UIEffects.Hint)
local round				= require(CLIENT.UIEffects.RoundNumbers)
local toClock 			= require(CLIENT.UIEffects.SecondsToClock)
local animateText 		= require(CLIENT.UIEffects.TextScrolling)
local PlayTutorialMsg	= require(CLIENT.UIEffects.TutorialPopUpWindow)
local ColorChange		= require(script.Parent.UIColorChange)
local CreateSettings 	= require(script.Parent.DefaultRoomSettings)
local FS				= require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local Promise			= require(ReplicatedStorage.Scripts.Modules.Promise)

-- << Variables >> --
local Camera			= workspace.Camera
local MMGui 			= NEWMENU.Parent.DungeonChoose
local MainPage 			= MMGui.MMType
local MapObj 			= nil
local CreateRoom 		= MMGui.CreateRoom
local Difficulty 		= "Normal"
local CurrentMapButt 	= nil
local GettingHighScore 	= false
local IsStory			= false
local Rand				= Random.new()


--------------------------
function OpenMapChoose(isStory)
	IsStory = isStory
	local Maps, IsPremium = Socket:Request("Matchmake", "GetMaps", Difficulty)
	MMGui.MapSelect.MapSelect.CanvasPosition = Vector2.new(0,0)
	if CurrentMapButt ~= nil then
		CurrentMapButt = nil
	end
	for _, OldMap in ipairs(MMGui.MapSelect.MapSelect:GetChildren()) do
		if not OldMap:IsA("UIListLayout") then
			OldMap:Destroy()
		end
	end
	for _, OldScore in ipairs(MMGui.MapSelect.Scoreboard:GetChildren()) do
		if not OldScore:IsA("UIListLayout") then
			OldScore:Destroy()
		end
	end
	for count, Map in ipairs(Maps) do
		if Map.Type == (isStory and "Story" or "Event") then
			local MapButton = MMGui.MapSelect.Template.MapButton:Clone()
			MapButton.LayoutOrder = Difficulty == "Hero" and -Map.MinLevelHero or -Map.MinLevel
			if not DataValues.CharInfo then
				DataValues.CharInfo = Socket:Request("getCharacterInfo")
			end

			if Map.UIEffects then
				MapButton.TextButton.Effects.Visible = true
				for _, effectFolder in ipairs(Map.UIEffects) do
					MapButton.TextButton.Effects[effectFolder].Visible = true
					Promise.try(function()
						local running = true
						while MapButton and running do
							if Rand:NextNumber() >= 0.9 then
								Promise.try(function()
									if not MapButton:FindFirstChild("TextButton") then return end

									local effect = MapButton.TextButton.Effects[effectFolder]:GetChildren()
									local chosen = effect[Rand:NextInteger(1, #effect)]:Clone()
									chosen.ImageTransparency = 1
									chosen.Position = UDim2.new(Rand:NextNumber(), 0, 0, 0)
									chosen.Size = UDim2.new(Rand:NextNumber(0.1, 0.4), 0, Rand:NextNumber(1, 1.1), 0)
									chosen.Visible = true
									chosen.Parent = MapButton.TextButton.Effects[effectFolder]
									TweenService:Create(chosen, TweenInfo.new(0.05), {ImageTransparency = Rand:NextNumber(0.3, 0.6)}):Play()
									wait(0.2)
									TweenService:Create(chosen, TweenInfo.new(Rand:NextNumber(0.1, 0.4)), {ImageTransparency = 1}):Play()
									wait(1)
									chosen:Destroy()
								end):catch(function()
									running = false
								end)
							end
							RunService.Heartbeat:Wait()
						end
					end):catch(print("Mapbutton disappeared!"))
				end
			end

			if Difficulty == "Hero" then
				MapButton.TextButton.BackgroundColor3 = Color3.fromRGB(100, 25, 0)
				MapButton.TextButton.Gradient.ImageColor3 = Color3.fromRGB(100, 25, 0)
				MapButton.TextButton.Information.LevelReq.TextColor3 = Color3.fromRGB(255, 161, 161)
				MapButton.TextButton.Information.MissionName.TextColor3 = Color3.fromRGB(255, 161, 161)
			elseif Difficulty == "EMD" then
				MapButton.TextButton.BackgroundColor3 = Color3.fromRGB(55, 13, 161)
				MapButton.TextButton.Gradient.ImageColor3 = Color3.fromRGB(55, 13, 161)
				MapButton.TextButton.Information.LevelReq.TextColor3 = Color3.fromRGB(237, 143, 255)
				MapButton.TextButton.Information.MissionName.TextColor3 = Color3.fromRGB(237, 143, 255)
			end
			if DataValues.CharInfo.CurrentLevel >= (Difficulty == "Hero" and Map.MinLevelHero or Difficulty == "EMD" and 200 or Map.MinLevel) then
				MapButton.TextButton.Information.MissionName.Text = Map.MissionName
				MapButton.TextButton.Information.LevelReq.Text = string.format("LV. %s", Difficulty == "Hero" and Map.MinLevelHero or Difficulty == "EMD" and "???" or Map.MinLevel)
				MapButton.TextButton.MapImage.Image = Map.MissionImage
				MapButton.TextButton.MouseEnter:Connect(function()
					if CurrentMapButt ~= MapButton then
						TweenService:Create(MapButton, TweenInfo.new(0.25,Enum.EasingStyle.Linear), {Size = UDim2.new(1, -10, 0, 75)}):Play()
					end
					MMGui.MapSelect.MapSelect.CanvasSize = UDim2.new(0, 0, 0, MMGui.MapSelect.MapSelect.UIListLayout.AbsoluteContentSize.Y)
				end)
				MapButton.TextButton.MouseLeave:Connect(function()
					if CurrentMapButt ~= MapButton then
						TweenService:Create(MapButton, TweenInfo.new(0.25,Enum.EasingStyle.Linear), {Size = UDim2.new(1, -10, 0, 50)}):Play()
					end
					MMGui.MapSelect.MapSelect.CanvasSize = UDim2.new(0, 0, 0, MMGui.MapSelect.MapSelect.UIListLayout.AbsoluteContentSize.Y)
				end)
				MapButton.TextButton.MouseButton1Down:Connect(function()
					MapObj = Map
					CreateSettings.Map = Map.MissionName
					MMGui.MapSelect.ScoreboardTitle.Text = "Top 50 Solo High Scores"
					if CurrentMapButt == MapButton then
						--- Confirms the map selection
						if CreateSettings.MaxPlayers > Map.MaxPlayers then
							CreateSettings.MaxPlayers = Map.MaxPlayers
							CreateRoom.NumbersOfPlayers.Text = "[ " ..CreateSettings.MaxPlayers.. " ]"
						end
						MMGui.MapSelect.Visible = false
						MMGui.CreateRoom.Create.Visible = true
						MMGui.CreateRoom.Visible = true
						if not Map.MaxPlayers == 6 then
							Hint("Max players are limited for this mission.")
						end
					else
						--- Enlarges button and fetches top leaderboard
						GettingHighScore = false
						if CurrentMapButt ~= nil then
							TweenService:Create(CurrentMapButt, TweenInfo.new(0.25,Enum.EasingStyle.Linear),{Size = UDim2.new(1, -10, 0, 50)}):Play()
							CurrentMapButt.TextButton.Information.MissionName.Text = string.gsub(CurrentMapButt.TextButton.Information.MissionName.Text, " | Click again to confirm", "")
							CurrentMapButt = nil
						end
						CurrentMapButt = MapButton
						for _, OldScore in ipairs(MMGui.MapSelect.Scoreboard:GetChildren()) do
							if not OldScore:IsA("UIListLayout") then
								OldScore:Destroy()
							end
						end
						MapButton.TextButton.Information.MissionName.Text = string.format("%s | Click again to confirm", Map.MissionName)
						TweenService:Create(MapButton, TweenInfo.new(0.25,Enum.EasingStyle.Linear), {Size = UDim2.new(1, -10, 0, 150)}):Play()
						MMGui.MapSelect.MapSelect.CanvasSize = UDim2.new(0, 0, 0, MMGui.MapSelect.MapSelect.UIListLayout.AbsoluteContentSize.Y)
						MMGui.MapSelect.Scoreboard.CanvasPosition = Vector2.new(0,0)
						MMGui.MapSelect.ScoreboardTitle.Text = "Fetching list..."
						local Scoreboard, ReturnedMissionName = Socket:Request("Matchmake", "GetHighScore", {Map, CreateSettings.EMD and "EMD" or Difficulty})
						if Scoreboard and ReturnedMissionName == CreateSettings.Map then
							local StartRank = 1
							for _, member in ipairs(Scoreboard) do
								local PlayerName = member.PlayerName
								local Class	= member.Class
								local Timer = member.Time
								local ScoreLabel = MMGui.MapSelect.Template.Score:Clone()
								ScoreLabel.Namer.Text = PlayerName
								ScoreLabel.Class.Text = Class
								ScoreLabel.Number.Text = StartRank
								ScoreLabel.Time.Text = toClock(Timer, true)
								ScoreLabel.Visible = true
								ScoreLabel.ImageColor3 = Difficulty == "Hero" and Color3.fromRGB(156, 23, 23) or Difficulty == "EMD" and Color3.fromRGB(197, 51, 255) or ScoreLabel.ImageColor3
								if ScoreLabel.Namer.Text == PLAYER.Name then
									ScoreLabel.ImageColor3 = Color3.fromRGB(255, 53, 53)
								end
								ScoreLabel.Parent = MMGui.MapSelect.Scoreboard
								MMGui.MapSelect.Scoreboard.CanvasSize = UDim2.new(0, 0, 0, MMGui.MapSelect.Scoreboard.UIListLayout.AbsoluteContentSize.Y)
								StartRank = StartRank + 1
							end
						else
							print("Already switched!")
						end
						MMGui.MapSelect.ScoreboardTitle.Text = "Top 50 Solo High Scores"
					end
				end)
			else
				if Difficulty ~= "EMD" then
					MapButton.Warning.Text = string.format("PROHIBITED AREA: LEVEL %s REQUIRED", Difficulty == "Hero" and Map.MinLevelHero or Map.MinLevel)
				else
					MapButton.Warning.Text = "PROHIBITED AREA: UNAUTHORIZED ACCESS"
				end
				MapButton.Warning.BackgroundTransparency = 1
				MapButton.Warning.TextTransparency = 1
				MapButton.Warning.Visible = true
			end
			MapButton.Visible = true
			MapButton.Parent = MMGui.MapSelect.MapSelect
			FS.spawn(function()
				wait((count - 1) * .05)
				TweenService:Create(MapButton.TextButton, TweenInfo.new(0.5), {Position = UDim2.new(0.01, 0, 0, 0)}):Play()
				if MapButton.Warning.Visible then
					wait(0.1)
					TweenService:Create(MapButton.Warning, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, TextTransparency = 0}):Play()
				end
			end)
		end
	end
	if DataValues.CharInfo.CurrentLevel >= 25 then
		MMGui.MapSelect.DifficultySelect.Hero.Visible = true
		local Type = "HeroDifficulty"
		if not StoryTeller:Check(DataValues.AccInfo.StoryProgression, Type) then
			Socket:Emit("Story", Type)
			table.insert(DataValues.AccInfo.StoryProgression, Type)
			PlayTutorialMsg(Type)
		end
	else
		MMGui.MapSelect.DifficultySelect.Hero.Visible = false
	end
	CreateRoom.Visible = false
	MMGui.MapSelect.Visible = true
end

function UpdateRoom(Room, Error)
	if DataValues.ControllerType == "Touch" then
		TweenService:Create(MMGui,  TweenInfo.new(0.5),{Size = UDim2.new(.75, 0, .95, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
	end

	local roomLobby = MMGui.RoomLobby
	local menus = roomLobby.Menus
	local selection = roomLobby.Selection
	local playerList = menus.PlayerList
	local missionDetail = menus.MissionDetails
	local buttons = selection.Buttons
	local loots = selection.Loots

	for _, olderQuips in ipairs(playerList:GetChildren()) do
		if olderQuips:IsA("Frame") then
			olderQuips:Destroy()
		end
	end
	
	for index, joinedPlayer in ipairs(Room.Players) do
		FS.spawn(function()
			local classInfo = require(ReplicatedStorage.Images.CharacterPortraits[joinedPlayer.Class].Information)
			local newQuip = playerList.Template.Quip:Clone()
			local imageLabel = newQuip.ImageLabel
			local isHost = Room.Host.PlayerObject.Name == joinedPlayer.PlayerObject.Name
			imageLabel.Level.Text = string.format("Lv. %s %s", joinedPlayer.Level, isHost and "[Host]" or "")
			imageLabel.PlayerName.Text = joinedPlayer.PlayerObject.Name
			imageLabel.Image = classInfo.Image_URL
			for setting, value in ipairs(classInfo.LobbyDimensions) do
				imageLabel[setting] = value
			end
			newQuip.LayoutOrder = isHost and -1 or index
			newQuip.Visible = true
			newQuip.Parent = playerList

			wait(0.25) TweenService:Create(imageLabel, TweenInfo.new(0.25), {ImageTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}):Play()
			wait(0.25) TweenService:Create(imageLabel.Level, TweenInfo.new(0.25), {TextTransparency = 0.2}):Play()
			TweenService:Create(imageLabel.PlayerName, TweenInfo.new(0.25), {TextTransparency = 0.2}):Play()
			TweenService:Create(imageLabel.Line, TweenInfo.new(0.25), {BackgroundTransparency = 0.2}):Play()
		end)
		wait(0.05)
	end

	missionDetail.MapFrame.ImageLabel.Image = Room.Map.MissionImage
	missionDetail.MapFrame.Map.Text = Room.Map.MissionName
	missionDetail.Description.Description.Text = Room.Map.Description

	buttons.Start.Visible = Room.Host.PlayerObject == PLAYER and true or false

	for _, oldItem in ipairs(missionDetail.TipContent:GetChildren()) do
		if oldItem:IsA("Frame") then
			oldItem:Destroy()
		end
	end
	for _, hint in ipairs(Room.Map.Hints) do
		local item = hint[1]
		local text = hint[2]
		local newHintItem = missionDetail.TipContent.Template[item]:Clone()
		newHintItem.Description.Text = text
		newHintItem.Visible = true
		newHintItem.Parent = missionDetail.TipContent
	end
	missionDetail.TipContent.Size = UDim2.new(0.95, 0, 0, missionDetail.TipContent.UIListLayout.AbsoluteContentSize.Y)
	missionDetail.CanvasSize = UDim2.new(0, 0, 0, missionDetail.UIListLayout.AbsoluteContentSize.Y)

	local Lvl = 999
	if Room.Difficulty then
		if Lvl < Room.Map.MinLevelHero then
			Lvl = Room.Map.MinLevelHero
		elseif Lvl > Room.Map.MaxLevelHero then
			Lvl = Room.Map.MaxLevelHero
		end
	else
		if Lvl < Room.Map.MinLevel then
			Lvl = Room.Map.MinLevel
		elseif Lvl > Room.Map.MaxLevel then
			Lvl = Room.Map.MaxLevel
		end
	end
	for _, oldLoot in ipairs(loots.Equips:GetChildren()) do
		if not oldLoot:IsA("UIGridLayout") then
			oldLoot:Destroy()
		end
	end
	for _, oldLoot in ipairs(loots.Materials:GetChildren()) do
		if not oldLoot:IsA("UIGridLayout") then
			oldLoot:Destroy()
		end
	end

	local Loots, MaterialLoots = Socket:Request("Matchmake", "GetLootInfos", Room)
	if Loots then
		for i, Loot in pairs(Loots) do
			local CanShow = true
			if Loot.Ownership and Loot.Ownership ~= "Everyone" then
				if Loot.Ownership ~= DataValues.AccInfo.CurrentClass then
					CanShow = false
				end
			end
			if CanShow then
				local RarityImage = ReplicatedStorage.Images.Textures["Rarity"..Loot.Object.Rarity]
				local WeaponPreview = Loot.Object.Model:Clone()
				local NewWeaponBlock = ReplicatedStorage.GUI.NormalGui.WeaponBlock:Clone()
				NewWeaponBlock.TextButton.Image = RarityImage.Image
				NewWeaponBlock.LayoutOrder = -(Loot.Object.Rarity)
				local function UpdateWeaponPreview(bool)
					if bool then
						GUI.WeaponPreview.Weapon.Visible = false
					else
						local WepSkills = {}
						local WeaponSkillPreview = GUI.WeaponPreview.Weapon.SkillDescriptions.WeaponSkill
						WeaponSkillPreview.Text = ""
		--[[				for i = 1, #Loot.WeaponSkills do
							if Loot.CurrentWeapon.Skls[v].I == Skills.ID then
								table.insert(WepSkills, "[" ..Skills.Name.."] " ..Skills.Desc.. (Skills.Tier1 and " (" ..Loot.CurrentWeapon.Skls[v].V.. "" ..Skills.Prefix..")" or "") .."\n\n")
								break
							end
							WeaponSkillPreview.Text = table.concat(WepSkills, "")
							WeaponSkillPreview.Visible = true
						end--]]
						GUI.WeaponPreview.Weapon.WeaponBlock.ImageButton.Visible = false
						GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame:ClearAllChildren()
						if GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame:FindFirstChild(WeaponPreview.Name) == nil then
							local WeaponPreviewPopup = WeaponPreview:Clone()
							if WeaponPreviewPopup:FindFirstChild("CameraCF") then
								local CameraPre = Instance.new("Camera")
								CameraPre.CFrame = WeaponPreviewPopup.CameraCF.Value
								GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame.CurrentCamera = CameraPre
							else
								if Loot.Object.ID <= 0 then
									local CameraSkin = Instance.new("Camera")
									CameraSkin.CameraType = Enum.CameraType.Scriptable
									CameraSkin.CameraSubject = WeaponPreviewPopup.Chest1.Middle
									local Pos = CFrame.new(WeaponPreviewPopup.Chest1.Middle.Position) * CFrame.new(-3.25,.25,0)
									CameraSkin.CFrame = CFrame.new(Pos.Position, WeaponPreviewPopup.Chest1.Middle.Position)
									CameraSkin.Parent = WeaponPreviewPopup
									GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame.CurrentCamera = CameraSkin
								end
							end
							WeaponPreviewPopup.Parent = GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame
						end
						GUI.WeaponPreview.Weapon.WeaponBlock.TextButton.Image = NewWeaponBlock.TextButton.Image
						GUI.WeaponPreview.Weapon.Title.TextColor3 = RarityImage.Color.Value
						GUI.WeaponPreview.Weapon.Title.Text = Loot.Object.WeaponName
						GUI.WeaponPreview.Weapon.Desc.Text = Loot.Object.Description
						
						local HP = Loot.Object.Stats.HP > 0 and "\nHP \t+" ..Loot.Object.Stats.HP or ""
						local ATK = Loot.Object.Stats.ATK > 0 and "\nATK \t+" ..Loot.Object.Stats.ATK or ""
						local DEF = Loot.Object.Stats.DEF > 0 and "\nDEF \t+" ..Loot.Object.Stats.DEF.. "%" or ""
						local STAM = Loot.Object.Stats.STAM > 0 and "\nSTAM \t+" ..Loot.Object.Stats.STAM or ""
						local CRIT = Loot.Object.Stats.CRIT > 0 and "\nCRIT \t+" ..Loot.Object.Stats.CRIT or ""
						local CRITDEF = ""
						if Loot.Object.ID <= 0 then
							GUI.WeaponPreview.Weapon.UpgradeDesc.Text = "Cosmetic Costume. Wearable by all characters."
							GUI.WeaponPreview.Weapon.StatDesc.Text = ""
						else
							if Loot.Object.Stats.CRITDEF ~= 0 then
								GUI.WeaponPreview.Weapon.UpgradeDesc.Text = "Equippable Trophy \nRequired Level: "..Loot.Object.LevelReq
								CRITDEF = "\nIframe Duration \t" .. tostring(round(Loot.Object.Stats.CRITDEF*100), 2).. "%"
							else
								GUI.WeaponPreview.Weapon.UpgradeDesc.Text = "Weapon Exclusive to " ..Loot.Ownership.. "\nPossible Tier Upgrades: "..Loot.Object.MaxUpgrades.."\nRequired Level: "..Loot.Object.LevelReq
							end
							GUI.WeaponPreview.Weapon.StatDesc.Text = "[Stats]" ..HP.. "" ..ATK.. "" ..DEF.. "" ..STAM.. "" ..CRIT.. "" ..CRITDEF
						end
						GUI.WeaponPreview.Weapon.Visible = true
					end
				end
				if DataValues.ControllerType ~= "Touch" then
					NewWeaponBlock.TextButton.MouseMoved:Connect(function(x, y)
						GUI.WeaponPreview.Weapon.Position = UDim2.new(0, x, 0, y)
						if GUI.WeaponPreview.Weapon.Position.X.Offset > GUI.Main.AbsoluteSize.X*.5 then
							GUI.WeaponPreview.Weapon.Position = UDim2.new(0, GUI.WeaponPreview.Weapon.Position.X.Offset - GUI.WeaponPreview.Weapon.AbsoluteSize.X, 0, GUI.WeaponPreview.Weapon.Position.Y.Offset)
						end
						if GUI.WeaponPreview.Weapon.Position.Y.Offset > GUI.Main.AbsoluteSize.Y*.5 then
							GUI.WeaponPreview.Weapon.Position = UDim2.new(0, GUI.WeaponPreview.Weapon.Position.X.Offset, 0, GUI.WeaponPreview.Weapon.Position.Y.Offset - GUI.WeaponPreview.Weapon.AbsoluteSize.Y)
						end
						UpdateWeaponPreview()
					end)
					NewWeaponBlock.TextButton.MouseLeave:Connect(function(x, y)
						UpdateWeaponPreview(true)
					end)
				else
					NewWeaponBlock.TextButton.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Touch then
							GUI.WeaponPreview.Weapon.Size = UDim2.new(0.4, 0, 1, 0)
							if NewWeaponBlock.AbsolutePosition.X < GUI.Main.AbsoluteSize.X*.5 then
								GUI.WeaponPreview.Weapon.Position = UDim2.new(0.5, 0, 0, 0)
							else
								GUI.WeaponPreview.Weapon.Position = UDim2.new(0.15, 0, 0, 0)
							end
							UpdateWeaponPreview()
						end
					end)
					NewWeaponBlock.TextButton.InputEnded:Connect(function(input)
						UpdateWeaponPreview(true)
					end)
				end
				if WeaponPreview:FindFirstChild("CameraCF") then
					local CameraPre = Instance.new("Camera")
					CameraPre.CFrame = WeaponPreview.CameraCF.Value
					NewWeaponBlock.ViewportFrame.CurrentCamera = CameraPre
				else
					if Loot.Object.ID <= 0 then
						local CameraSkin = Instance.new("Camera")
						CameraSkin.CameraType = Enum.CameraType.Scriptable
						CameraSkin.CameraSubject = WeaponPreview.Chest1.Middle
						local Pos = CFrame.new(WeaponPreview.Chest1.Middle.Position) * CFrame.new(-3.25,.25,0)
						CameraSkin.CFrame = CFrame.new(Pos.Position, WeaponPreview.Chest1.Middle.Position)
						CameraSkin.Parent = WeaponPreview
						NewWeaponBlock.ViewportFrame.CurrentCamera = CameraSkin
					end
				end
				WeaponPreview.Parent = NewWeaponBlock.ViewportFrame
				NewWeaponBlock.Parent = loots.Equips
				loots.Equips.Size = UDim2.new(1, 0, 0, loots.Equips.UIGridLayout.AbsoluteContentSize.Y)
			end
		end
	end
	if MaterialLoots then
		for _, material in ipairs(MaterialLoots) do
			local NewWeaponBlock = ReplicatedStorage.GUI.NormalGui.ItemBlock:Clone()
			NewWeaponBlock.TextButton.Image = material.Image
			if material.Rarity == 0 then
				NewWeaponBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord2.Image
			elseif material.Rarity == 1 then
				NewWeaponBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord3.Image
			elseif material.Rarity == 2 then
				NewWeaponBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord4.Image
			elseif material.Rarity == 3 then
				NewWeaponBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord5.Image
			elseif material.Rarity == 4 then
				NewWeaponBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord6.Image
			elseif material.Rarity == 5 then
				NewWeaponBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord7.Image
			else
				NewWeaponBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord1.Image
			end
			NewWeaponBlock.LayoutOrder = -(material.Rarity)

			local function UpdateWeaponPreview(bool)
				if bool then
					GUI.WeaponPreview.Weapon.Visible = false
				else
					local WepSkills = {}
					local WeaponSkillPreview = GUI.WeaponPreview.Weapon.SkillDescriptions.WeaponSkill
					GUI.WeaponPreview.Weapon.WeaponBlock.ImageButton.Visible = true
					GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame:ClearAllChildren()
					GUI.WeaponPreview.Weapon.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
					WeaponSkillPreview.Text = ""
					GUI.WeaponPreview.Weapon.WeaponBlock.ImageButton.Image = material.Image
					GUI.WeaponPreview.Weapon.WeaponBlock.TextButton.Image = NewWeaponBlock.Border.Image
					GUI.WeaponPreview.Weapon.Title.Text = material.Name == "" and "Random Gem +" ..material.Rarity or material.Name
					GUI.WeaponPreview.Weapon.Desc.Text = material.Description == "" and "Equippable gem that bolsters powerful energy." or material.Description
					GUI.WeaponPreview.Weapon.UpgradeDesc.Text = material.SubDescription
					GUI.WeaponPreview.Weapon.StatDesc.Text = ""
					GUI.WeaponPreview.Weapon.Visible = true
				end
			end
			if DataValues.ControllerType ~= "Touch" then
				NewWeaponBlock.TextButton.MouseMoved:Connect(function(x, y)
					GUI.WeaponPreview.Weapon.Position = UDim2.new(0, x, 0, y)
					if GUI.WeaponPreview.Weapon.Position.X.Offset > GUI.Main.AbsoluteSize.X*.5 then
						GUI.WeaponPreview.Weapon.Position = UDim2.new(0, GUI.WeaponPreview.Weapon.Position.X.Offset - GUI.WeaponPreview.Weapon.AbsoluteSize.X, 0, GUI.WeaponPreview.Weapon.Position.Y.Offset)
					end
					if GUI.WeaponPreview.Weapon.Position.Y.Offset > GUI.Main.AbsoluteSize.Y*.5 then
						GUI.WeaponPreview.Weapon.Position = UDim2.new(0, GUI.WeaponPreview.Weapon.Position.X.Offset, 0, GUI.WeaponPreview.Weapon.Position.Y.Offset - GUI.WeaponPreview.Weapon.AbsoluteSize.Y)
					end
					UpdateWeaponPreview()
				end)
				NewWeaponBlock.TextButton.MouseLeave:Connect(function(x, y)
					UpdateWeaponPreview(true)
				end)
			else
				NewWeaponBlock.TextButton.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						GUI.WeaponPreview.Weapon.Size = UDim2.new(0.4, 0, 1, 0)
						if NewWeaponBlock.AbsolutePosition.X < GUI.Main.AbsoluteSize.X*.5 then
							GUI.WeaponPreview.Weapon.Position = UDim2.new(0.5, 0, 0, 0)
						else
							GUI.WeaponPreview.Weapon.Position = UDim2.new(0.15, 0, 0, 0)
						end
						UpdateWeaponPreview()
					end
				end)
				NewWeaponBlock.TextButton.InputEnded:Connect(function(input)
					UpdateWeaponPreview(true)
				end)
			end

			NewWeaponBlock.Parent = loots.Materials
			loots.Materials.Size = UDim2.new(1, 0, 0, loots.Materials.UIGridLayout.AbsoluteContentSize.Y)
		end
	end
	loots.CanvasSize = UDim2.new(0, 0, 0, loots.UIListLayout.AbsoluteContentSize.Y)
end

function UpdatePVPRoom(Room)
	MMGui.RoomLobbyPVP.MapFrame.ImageLabel.Image = Room.Map.MissionImage
	MMGui.RoomLobbyPVP.MapFrame.Map.Text = Room.Map.MissionName
	MMGui.RoomLobbyPVP.Title.Text = Room.Name
	MMGui.RoomLobbyPVP.GameMode.Text = "Game Mode: " ..Room.GameMode
	for i = 1, 3 do
		local Ply = Room.PVP.RedTeam[i]
		MMGui.RoomLobbyPVP.RedTeam[i].Text = Ply and (Room.Host.PlayerObject.Name == Ply and Ply.. " [Host]" or Ply) or ""
		if Ply == PLAYER.Name then
			MMGui.RoomLobbyPVP.JoinBlueTeam.Visible = true
			MMGui.RoomLobbyPVP.JoinRedTeam.Visible = false
		end
	end
	for i = 1, 3 do
		local Ply = Room.PVP.BlueTeam[i]
		MMGui.RoomLobbyPVP.BlueTeam[i].Text = Ply and (Room.Host.PlayerObject.Name == Ply and Ply.. " [Host]" or Ply) or ""
		if Ply == PLAYER.Name then
			MMGui.RoomLobbyPVP.JoinBlueTeam.Visible = false
			MMGui.RoomLobbyPVP.JoinRedTeam.Visible = true
		end
	end
end

CreateRoom.FriendsOnly.MouseButton1Down:Connect(function()
	if CreateSettings.Local then
		CreateSettings.Local = false
		CreateRoom.FriendsOnly.Text = "[ Everyone ]"
	else
		CreateSettings.Local = true
		CreateRoom.FriendsOnly.Text = "[ Friends ]"
	end
end)

local function Clear(Location, Value)
	local disappearTime = 0.5
	local goal = Value and Value or 1
	for _, stuff in ipairs(Location:GetDescendants()) do
		if stuff:IsA("Frame") then
			TweenService:Create(stuff, TweenInfo.new(disappearTime), {BackgroundTransparency = goal}):Play()
			Debris:AddItem(stuff, disappearTime)
		elseif stuff:IsA("TextButton") or stuff:IsA("TextLabel") then
			TweenService:Create(stuff, TweenInfo.new(disappearTime), {BackgroundTransparency = goal, TextTransparency = goal, TextStrokeTransparency = goal}):Play()
			Debris:AddItem(stuff, disappearTime)
		elseif stuff:IsA("ImageButton") or stuff:IsA("ImageLabel") then
			TweenService:Create(stuff, TweenInfo.new(disappearTime), {BackgroundTransparency = goal, ImageTransparency = goal}):Play()
			Debris:AddItem(stuff, disappearTime)
		end
	end
end

local switchingDifficulty = false
MMGui.MapSelect.DifficultySelect.Normal.MouseButton1Down:Connect(function()
	if Difficulty == "Normal" or switchingDifficulty then return end
	switchingDifficulty = true
	CreateSettings.Difficulty = false
	CreateSettings.EMD = false
	Difficulty = "Normal"
	Clear(MMGui.MapSelect.MapSelect)
	Clear(MMGui.MapSelect.Scoreboard)
	TweenService:Create(MMGui.MapSelect.DifficultySelect.Normal, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
	TweenService:Create(MMGui.MapSelect.DifficultySelect.Hero, TweenInfo.new(0.5), {BackgroundTransparency = 0.4, TextTransparency = 0.4}):Play()
	TweenService:Create(MMGui.MapSelect.DifficultySelect.HMD, TweenInfo.new(0.5), {BackgroundTransparency = 0.4, TextTransparency = 0.4}):Play()
	ColorChange(Color3.fromRGB(255, 255, 255), MMGui.BG.UIGradient)
	wait(0.5)
	switchingDifficulty = false
	OpenMapChoose(IsStory)
end)

MMGui.MapSelect.DifficultySelect.Hero.MouseButton1Down:Connect(function()
	if Difficulty == "Hero" or switchingDifficulty then return end
	switchingDifficulty = true
	CreateSettings.Difficulty = true
	CreateSettings.EMD = false
	Difficulty = "Hero"
	Clear(MMGui.MapSelect.MapSelect)
	Clear(MMGui.MapSelect.Scoreboard)
	TweenService:Create(MMGui.MapSelect.DifficultySelect.Normal, TweenInfo.new(0.5), {BackgroundTransparency = 0.4, TextTransparency = 0.4}):Play()
	TweenService:Create(MMGui.MapSelect.DifficultySelect.Hero, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
	TweenService:Create(MMGui.MapSelect.DifficultySelect.HMD, TweenInfo.new(0.5), {BackgroundTransparency = 0.4, TextTransparency = 0.4}):Play()
	ColorChange(Color3.fromRGB(255, 0, 0), MMGui.BG.UIGradient)
	wait(.5)
	switchingDifficulty = false
	OpenMapChoose(IsStory)
end)

MMGui.MapSelect.DifficultySelect.HMD.MouseButton1Down:Connect(function()
	if Difficulty == "HMD" or switchingDifficulty then return end
	switchingDifficulty = true
	CreateSettings.Difficulty = true
	CreateSettings.EMD = true
	Difficulty = "EMD"
	Clear(MMGui.MapSelect.MapSelect)
	Clear(MMGui.MapSelect.Scoreboard)
	TweenService:Create(MMGui.MapSelect.DifficultySelect.Normal, TweenInfo.new(0.5), {BackgroundTransparency = 0.4, TextTransparency = 0.4}):Play()
	TweenService:Create(MMGui.MapSelect.DifficultySelect.Hero, TweenInfo.new(0.5), {BackgroundTransparency = 0.4, TextTransparency = 0.4}):Play()
	TweenService:Create(MMGui.MapSelect.DifficultySelect.HMD, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
	ColorChange(Color3.fromRGB(145, 71, 255), MMGui.BG.UIGradient)
	wait(.5)
	switchingDifficulty = false
	OpenMapChoose(IsStory)
end)

CreateRoom.NumbersOfPlayers.MouseButton1Down:Connect(function()
	local Max = 6
	if MapObj ~= nil then
		Max = MapObj.MaxPlayers 
	end
	CreateSettings.MaxPlayers = CreateSettings.MaxPlayers + 1
	if CreateSettings.MaxPlayers > Max then
		CreateSettings.MaxPlayers = 1
	end
	CreateRoom.NumbersOfPlayers.Text = "[ " ..CreateSettings.MaxPlayers.. " ]"
end)

CreateRoom.Create.MouseButton1Down:Connect(function()
	CreateSettings.Name = CreateRoom.NameOfRoom.Text
	local Room = Socket:Request("Matchmake", "CreateRoom", CreateSettings)
	if Room ~= nil then
		UpdateRoom(Room)
		MMGui.RoomLobby.Menus.MissionDetails.Visible = false
		MMGui.RoomLobby.Menus.PlayerList.Visible = true
		CreateRoom.Visible = false
		MMGui.RoomLobby.Visible = true
		MMGui.Back.Visible = false
	end
end)

Socket:Listen("StartingDungeon", function()
	MMGui.Visible = false
	DataValues.CameraEnabled = false
	TweenService:Create(Camera, TweenInfo.new(1), {CFrame = workspace.Lobby.CamPan.CFrame}):Play() wait(2)
	TweenService:Create(Camera, TweenInfo.new(5), {CFrame = workspace.Lobby.CamPanFinish.CFrame}):Play() wait(1.5)
	GUI.MainMenu.Enabled = true
	TweenService:Create(GUI.MainMenu.CharSelect.BG, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {BackgroundTransparency = 0}):Play()
	wait(35)
	MMGui.Visible = true
	DataValues.CameraEnabled = true
	GUI.MainMenu.Enabled = false
	GUI.MainMenu.CharSelect.BG.BackgroundTransparency = 1
end)

Socket:Listen("ErrorDungeon", function(Room, ErrorList)
	UpdateRoom(Room, ErrorList)
end)

MMGui.RoomLobby.Selection.Buttons.Information.MouseButton1Down:Connect(function()
	ReplicatedStorage.Sounds.SFX.UI.Click:Play()
	if MMGui.RoomLobby.Menus.PlayerList.Visible then
		MMGui.RoomLobby.Menus.MissionDetails.Visible = true
		MMGui.RoomLobby.Menus.PlayerList.Visible = false
	else
		MMGui.RoomLobby.Menus.MissionDetails.Visible = false
		MMGui.RoomLobby.Menus.PlayerList.Visible = true
	end
end)

MMGui.RoomLobby.Selection.Buttons.Start.MouseButton1Down:Connect(function()
	ReplicatedStorage.Sounds.SFX.UI.Click:Play()
	if DataValues.AccInfo then
		Socket:Emit("Story", "MM1")
		table.insert(DataValues.AccInfo.StoryProgression, "MM1")
	end
	Socket:Emit("Matchmake", "StartDungeon")
end)

MMGui.RoomLobby.Selection.Buttons.Leave.MouseButton1Down:Connect(function()
	ReplicatedStorage.Sounds.SFX.UI.Click:Play()
	if DataValues.ControllerType == "Touch" then
		TweenService:Create(MMGui,  TweenInfo.new(0.5),{Size = UDim2.new(.9,0,.95), Position = UDim2.new(.05,0,0,0)}):Play()
	end
	MMGui.RoomLobby.Visible = false
	MainPage.Visible = true
	MMGui.Back.Visible = true
	Socket:Emit("Matchmake", "LeaveRoom")
end)

Socket:Listen("Matchmake", function(Action, UpdatedRoom)
	if Action == "PlayerJoin" or Action == "PlayerLeft" then
		UpdateRoom(UpdatedRoom)
	end
end)
	
MMGui.MMType.PvPCreate.MouseButton1Down:Connect(function()
	MMGui.MMType.Visible = false
	MMGui.MapSelectPVP.Visible = true
end)

MMGui.MMType.PvP.MouseButton1Down:Connect(function()
	CreateSettings.IsPvP = true
	MMGui.MMType.MissionStory.Visible = false
	MMGui.MMType.MissionEvents.Visible = false
	MMGui.MMType.Find.Visible = false
	MMGui.MMType.PvP.Visible = false
	MMGui.MMType.PvPCreate.Visible = true
	MMGui.MMType.PvPFind.Visible = true
end)
	
MMGui.MMType.PvPCreate.MouseButton1Down:Connect(function()
	MMGui.MMType.Visible = false
	CreateSettings.IsPvP = true
	for _,OldMaps in ipairs(MMGui.MapSelectPVP.MapSelect:GetChildren()) do
		if OldMaps:IsA("Frame") then
			OldMaps:Destroy()
		end
	end
	local Maps = Socket:Request("MatchmakePVP", "GetMaps")
	for _, Map in ipairs(Maps) do
		local MapButton = MMGui.MapSelectPVP.Template.MapButton:Clone()
		MapButton.MapFrame.Map.Text = Map.MissionName
		MapButton.MapFrame.ImageLabel.Image = Map.MissionImage
		for _, GameModes in ipairs(Map.GameModes) do
			local GameMode = MMGui.MapSelectPVP.Template.TitleSequence:Clone()
			GameMode.Text = GameModes
			GameMode.Visible = true
			GameMode.Parent = MapButton.GameModes.List
		end
		MapButton.TextButton.MouseButton1Down:Connect(function()
			MMGui.MapSelectPVP.Visible = false
			CreateSettings.Map = Map.MissionName
			MMGui.CreatePVPRoom.Visible = true
		end)
		MapButton.Visible = true
		MapButton.Parent = MMGui.MapSelectPVP.MapSelect
	end
	MMGui.MapSelectPVP.Visible = true
end)
	
MMGui.CreatePVPRoom.FriendsOnly.MouseButton1Down:Connect(function()
	if CreateSettings.Local then
		CreateSettings.Local = false
		MMGui.CreatePVPRoom.FriendsOnly.Text = "[ Everyone ]"
	else
		CreateSettings.Local = true
		MMGui.CreatePVPRoom.FriendsOnly.Text = "[ Friends ]"
	end
end)
	
MMGui.CreatePVPRoom.GameMode.MouseButton1Down:Connect(function()
	if CreateSettings.GameMode == "1v1" then
		CreateSettings.GameMode = "2v2"
		MMGui.CreatePVPRoom.GameMode.Text = "[ 2 Vs 2 ]"
	elseif CreateSettings.GameMode == "2v2" then
		CreateSettings.GameMode = "3v3"
		MMGui.CreatePVPRoom.GameMode.Text = "[ 3 Vs 3 ]"
	else
		CreateSettings.GameMode = "1v1"
		MMGui.CreatePVPRoom.GameMode.Text = "[ 1 Vs 1 ]"
	end
end)
	
MMGui.CreatePVPRoom:GetPropertyChangedSignal("Visible"):Connect(function()
	for _,Chars in ipairs(MMGui.CreatePVPRoom.PlayableCharacters:GetChildren()) do
		if Chars:IsA("TextButton") then
			Chars:Destroy()
		end
	end
	for _,Chars in ipairs(MMGui.CreatePVPRoom.BannedCharacters:GetChildren()) do
		if Chars:IsA("TextButton") then
			Chars:Destroy()
		end
	end
	
	if MMGui.CreatePVPRoom.Visible then
		local AllowedCharacters = {"DarwinB", "Red", "Valeri", "LingeringForce", "Alburn", "Natsuko"}
		for _,Character in ipairs(AllowedCharacters) do
			local CharButton = MMGui.CreatePVPRoom.Template.Character:Clone()
			CharButton.Text = Character
			CharButton.Visible = true
			CharButton.Parent = MMGui.CreatePVPRoom.PlayableCharacters
			CharButton.MouseButton1Down:Connect(function()
				if CharButton.Text == DataValues.AccInfo.CurrentClass then
					Hint("You cannot ban your own character!")
					return
				end
				if CharButton.Parent.Name == "PlayableCharacters" then
					CharButton.Parent = MMGui.CreatePVPRoom.BannedCharacters
				else
					CharButton.Parent = MMGui.CreatePVPRoom.PlayableCharacters
				end
			end)
		end
	end
end)
	
MMGui.CreatePVPRoom.Create.MouseButton1Down:Connect(function()
	CreateSettings.Name = CreateRoom.NameOfRoom.Text
	
	for _,Chars in ipairs(MMGui.CreatePVPRoom.PlayableCharacters:GetChildren()) do
		if Chars:IsA("TextButton") then
			table.insert(CreateSettings.Playable, Chars.Text)
		end
	end
	for _,Chars in ipairs(MMGui.CreatePVPRoom.BannedCharacters:GetChildren()) do
		if Chars:IsA("TextButton") then
			table.insert(CreateSettings.Banned, Chars.Text)
		end
	end
	
	local Room = Socket:Request("MatchmakePVP", "CreateRoom", CreateSettings)
	if Room ~= nil then
		UpdatePVPRoom(Room)
		MMGui.CreatePVPRoom.Visible = false
		MMGui.RoomLobbyPVP.Visible = true
		MMGui.Back.Visible = false
	end
end)
	
MMGui.RoomLobbyPVP.JoinBlueTeam.MouseButton1Down:Connect(function()
	local NewRoom, Error = Socket:Request("MatchmakePVP", "JoinTeam")
	if NewRoom then 
		UpdatePVPRoom(NewRoom)
	end
	if Error then
		Hint(Error)
	end
end)
MMGui.RoomLobbyPVP.JoinRedTeam.MouseButton1Down:Connect(function()
	local NewRoom, Error = Socket:Request("MatchmakePVP", "JoinTeam")
	if NewRoom then 
		UpdatePVPRoom(NewRoom)
	end
	if Error then
		Hint(Error)
	end
end)
	
MMGui.RoomLobbyPVP.Leave.MouseButton1Down:Connect(function()
	CreateSettings.IsPvP = false
	MMGui.RoomLobbyPVP.Visible = false
	MMGui.MMType.MissionStory.Visible = true
	MMGui.MMType.MissionEvents.Visible = true
	MMGui.MMType.Find.Visible = true
	MMGui.MMType.PvP.Visible = true
	MMGui.MMType.PvPCreate.Visible = false
	MMGui.MMType.PvPFind.Visible = false
	MMGui.MMType.Visible = true
	MMGui.Back.Visible = true
	Socket:Emit("MatchmakePVP", "LeaveRoom")
end)
	
MMGui.RoomLobbyPVP.Start.MouseButton1Down:Connect(function()
	Socket:Emit("MatchmakePVP", "StartDungeon")
end)
	
Socket:Listen("MatchmakePVPHost_Left", function()
	CreateSettings.IsPvP = false
	MMGui.RoomLobbyPVP.Visible = false
	MainPage.Visible = true
	MMGui.Back.Visible = true
	Hint("The host has closed down the arena.")
end)
	
MMGui.MMType.PvPFind.MouseButton1Down:Connect(function()
	MMGui.ServerList.Visible = true
	MMGui.MMType.Visible = false
	while MMGui.ServerList.Visible do
		local CurrentRooms = MMGui.ServerList:GetChildren()
		for i = 1, #CurrentRooms do
			if CurrentRooms[i]:IsA("Frame") then
				CurrentRooms[i]:Destroy()
			end
		end
		local Rooms = Socket:Request("MatchmakePVP", "GetRooms")
		for i = 1, #Rooms do
			local Room = Rooms[i]
			local PlayersInRoom = 0
			for v = 1, #Room.Players do
				PlayersInRoom = PlayersInRoom + 1
			end
			if PlayersInRoom < Room.PlayerLimit and Room.Host and Room.Host.PlayerObject then
				local RoomBlock = ReplicatedStorage.GUI.NormalGui.Room1:Clone()
				RoomBlock.Difficulty.Text = Room.GameMode and Room.GameMode or "Unknown Game Mode"
				RoomBlock.Map.Text = Room.Map.MissionName
				RoomBlock.Title.Text = Room.Name
				RoomBlock.Owner.Text = "Host: " ..Room.Host.PlayerObject.Name
				RoomBlock.Level.Text = ""
				RoomBlock.Create.Text = "Join (" ..PlayersInRoom.."/"..Room.PlayerLimit..")"
				RoomBlock.Parent = MMGui.ServerList
				local conn;
				conn = RoomBlock.Create.MouseButton1Down:Connect(function()
					local Rum = Socket:Request("MatchmakePVP", "JoinRoom", Room.Host.PlayerObject)
					if typeof(Rum) == "table" then
						UpdatePVPRoom(Rum)
						MMGui.ServerList.Visible = false
						MMGui.RoomLobbyPVP.Visible = true
						MMGui.Back.Visible = false
					else
						if Rum == "Room not found! Host might have disbanded, or left!" or "Full room" then
							print(Rum)
							conn:Disconnect()
							RoomBlock:Destroy()
							conn = nil
						elseif Rum == "PLAYER was found in another room!" or "Friends only!" then
							print("WHAT?")
						end
					end
				end)
				local conn2;
				conn2 = RoomBlock.AncestryChanged:Connect(function()
					conn:Disconnect()
					conn = nil
					conn2:Disconnect()
					conn2 = nil
					RoomBlock:Destroy()
				end)
			end
		end
		wait(2)
	end
end)
	
Socket:Listen("MatchmakePVP", function(Action, UpdatedRoom)
	if Action == "PlayerJoin" or Action == "PlayerLeft" then
		UpdatePVPRoom(UpdatedRoom)
	end
end)
	
MMGui.Back.MouseButton1Down:Connect(function()
	if CreateSettings.IsPvP then
		CreateSettings.IsPvP = false
		MMGui.MapSelectPVP.Visible = false
		MMGui.CreatePVPRoom.Visible = false
		MMGui.MMType.MissionStory.Visible = true
		MMGui.MMType.MissionEvents.Visible = true
		MMGui.MMType.Find.Visible = true
		MMGui.MMType.PvP.Visible = true
		MMGui.MMType.PvPCreate.Visible = false
		MMGui.MMType.PvPFind.Visible = false
		MMGui.MMType.Visible = true
		MMGui.ServerList.Visible = false
	else
		if MMGui.RoomLobby.Visible == false then
			if MainPage.Visible then
				MMGui.Visible = false
			elseif MMGui.CreateRoom.Visible then
				MMGui.CreateRoom.Visible = false
				MainPage.Visible = true
			elseif MMGui.ServerList.Visible then
				MMGui.ServerList.Visible = false
				MainPage.Visible = true
			elseif MMGui.MapSelect.Visible then
				CreateSettings.Map = ""
				MMGui.CreateRoom.Create.Visible = false
				MMGui.MapSelect.Visible = false
				MMGui.CreateRoom.Visible = false
				MMGui.MMType.Visible = true
				MMGui.MMType.MissionStory.Visible = true
				MMGui.MMType.MissionEvents.Visible = true
				MMGui.MMType.Find.Visible = true
				MMGui.MMType.PvP.Visible = true
			end
		end
	end
	if DataValues.ControllerType == "Touch" then
		TweenService:Create(MMGui,  TweenInfo.new(0.5),{Size = UDim2.new(.9,0,.95), Position = UDim2.new(.05,0,0,0)}):Play()
	end
end)

MMGui.MMType.MissionStory.MouseButton1Down:Connect(function()
	MMGui.MMType.Visible = false
	OpenMapChoose(true)
end)

MMGui.MMType.MissionEvents.MouseButton1Down:Connect(function()
	MMGui.MMType.Visible = false
	OpenMapChoose(false)
end)

MMGui.MMType.Find.MouseButton1Down:Connect(function()
	MMGui.ServerList.Visible = true
	MMGui.MMType.Visible = false
	while MMGui.ServerList.Visible do
		local CurrentRooms = MMGui.ServerList:GetChildren()
		for i = 1, #CurrentRooms do
			if CurrentRooms[i]:IsA("Frame") then
				CurrentRooms[i]:Destroy()
			end
		end
		local Rooms = Socket:Request("Matchmake", "GetRooms")
		for i = 1, #Rooms do
			local Room = Rooms[i]
			local PlayersInRoom = 0
			for v = 1, #Room.Players do
				PlayersInRoom = PlayersInRoom + 1
			end
			if PlayersInRoom < Room.PlayerLimit and Room.Host and Room.Host.PlayerObject then
				local RoomBlock = ReplicatedStorage.GUI.NormalGui.Room1:clone()
				RoomBlock.Difficulty.Text = Room.Difficulty and "Difficulty: Hero" or "Difficulty: Normal"
				RoomBlock.Map.Text = "Map: " ..Room.Map.MissionName
				RoomBlock.Title.Text = Room.Name
				RoomBlock.Owner.Text = "Host: " ..Room.Host.PlayerObject.Name
				RoomBlock.Level.Text = "Avg Lvl: 0"
				RoomBlock.Create.Text = "Join (" ..PlayersInRoom.."/"..Room.PlayerLimit..")"
				RoomBlock.Parent = MMGui.ServerList
				local conn;
				conn = RoomBlock.Create.MouseButton1Down:Connect(function()
					local Rum = Socket:Request("Matchmake", "JoinRoom", Room.Host.PlayerObject)
					if typeof(Rum) == "table" then
						UpdateRoom(Rum)
						MMGui.RoomLobby.Menus.MissionDetails.Visible = false
						MMGui.RoomLobby.Menus.PlayerList.Visible = true
						MMGui.ServerList.Visible = false
						MMGui.RoomLobby.Visible = true
						MMGui.Back.Visible = false
					else
						if Rum == "Room not found! Host might have disbanded, or left!" or "Full room" then
							print(Rum)
							conn:Disconnect()
							RoomBlock:Destroy()
							conn = nil
						elseif Rum == "PLAYER was found in another room!" or "Friends only!" then
							print("WHAT?")
						end
					end
				end)
				local conn2;
				conn2 = RoomBlock.AncestryChanged:Connect(function()
					conn:Disconnect()
					conn = nil
					conn2:Disconnect()
					conn2 = nil
					RoomBlock:Destroy()
				end)
			end
		end
		wait(2)
	end
end)

--- Introduction places only
if game.PlaceId == 785484984 or game.PlaceId == 563493615 then
	MMGui.MMType.Find.Visible = false
	MMGui.MMType.MissionEvents.Visible = false
	MMGui.MMType.PvP.Visible = false
end