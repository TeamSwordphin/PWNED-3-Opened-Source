-- << Services >> --
local ReplicatedStorage 	= game:GetService("ReplicatedStorage")
local Players 				= game:GetService("Players")
local TweenService			= game:GetService("TweenService")
local GuiService			= game:GetService("GuiService")
local ContextActionService 	= game:GetService("ContextActionService")
local CollectionService 	= game:GetService("CollectionService")


-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local BINDABLES	= CLIENT.Bindables
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local NEWMENU 	= GUI:WaitForChild("DesktopPauseMenu").Base.Mask


-- << Modules >> --
local Socket 			= require(MODULES.socket)
local StoryTeller 		= require(MODULES.StoryTeller)
local RainAPI			= require(MODULES.Rain)
local PlatformButtons 	= require(MODULES.PlatformButtons)
local MusicPlayer		= require(MODULES.MusicPlayer)
local DataValues 		= require(CLIENT.DataValues)
local Hint		  		= require(CLIENT.UIEffects.Hint)
local Animate 			= require(CLIENT.UIEffects.AnimateSpriteSheet)
local format_int 		= require(CLIENT.UIEffects.FormatInteger)
local round				= require(CLIENT.UIEffects.RoundNumbers)
local PlayTutorialMsg	= require(CLIENT.UIEffects.TutorialPopUpWindow)
local FS 		  		= require(ReplicatedStorage.Scripts.Modules.FastSpawn)


-- << Variables >> --
local bools 		= DataValues.bools
local Numbers		= DataValues.Numbers
local Character		= PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid		= Character:WaitForChild("Humanoid")


----------------------
function OnRespawn(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
end

PLAYER.CharacterAdded:Connect(OnRespawn)

NEWMENU.OuterFrame.ContentWindow.Achievements.Claim.Frame.MouseButton1Down:Connect(function()
	local Information = Socket:Request("UpdateClaimRewards")
	if Information then
		NEWMENU.OuterFrame.ContentWindow.Achievements.Claim.Visible = false
		NEWMENU.OuterFrame.Buttons.Achievements.notice.Visible = false
		for _, stuff in ipairs(GUI.Notification.PopupWindow.Obtained:GetChildren()) do
			if stuff:IsA("TextLabel") then
				stuff:Destroy()
			end
		end
		if DataValues.ControllerType == "Touch" then
			GUI.Notification.PopupWindow.Position = UDim2.new(0.1, 0, 0.1, 0)
			GUI.Notification.PopupWindow.Size = UDim2.new(0.8, 0, 0.8, 0)
		end
		GUI.Notification.PopupWindow.Visible = true
		if DataValues.ControllerType == "Controller" then
			GuiService.SelectedObject = GUI.Notification.PopupWindow.Close.Frame
		end
		for _, stuff in ipairs(Information) do
			local item = GUI.Notification.PopupWindow.Template.Item:Clone()
			local frame = item.Frame
			if stuff.Type == "Gold" then
				item.LayoutOrder = 0
				frame.ImageFrame.ImageLabel.Image = "rbxassetid://179409544"
				frame.Information.Description.Text = string.format("Obtained %s", format_int(stuff.Value))
			elseif stuff.Type == "Tears" then
				item.LayoutOrder = 1
				frame.ImageFrame.ImageLabel.Image = "rbxassetid://179409545"
				frame.Information.Title.Text = "Tears"
				frame.Information.Description.Text = string.format("Obtained %s", format_int(stuff.Value))
			elseif stuff.Type == "Vestiges" then
				item.LayoutOrder = 5
				frame.ImageFrame.Folder.VestigeGradient.Parent = frame.ImageFrame.ImageLabel
				frame.ImageFrame.ImageLabel.VestigeGradient.Enabled = true
				frame.ImageFrame.ImageLabel.Image = "rbxassetid://5617699009"
				frame.Information.Title.Text = "Vestige"
				frame.Information.Description.Text = string.format("Obtained %s", stuff.Value)
			elseif stuff.Type == "Infusions" then
				item.LayoutOrder = 2
				frame.ImageFrame.ImageLabel.Image = "rbxassetid://5617596445"
				frame.Information.Title.Text = "Weapon Upgrade"
				frame.Information.Description.Text = string.format("Obtained %s", stuff.Value)
			elseif stuff.Type == "ChatTitles" then
				item.LayoutOrder = 3
				frame.ImageFrame.Folder.ChatGradient.Parent = frame.ImageFrame.ImageLabel
				frame.ImageFrame.ImageLabel.ChatGradient.Enabled = true
				frame.ImageFrame.ImageLabel.Image = "rbxassetid://4273127328"
				frame.Information.Title.Text = "Chat Title"
				frame.Information.Description.Text = string.format("Obtained %s", stuff.Value)
			else
				item.LayoutOrder = 4
				frame.ImageFrame.Folder.BannerGradient.Parent = frame.ImageFrame.ImageLabel
				frame.ImageFrame.ImageLabel.BannerGradient.Enabled = true
				frame.ImageFrame.ImageLabel.ScaleType = Enum.ScaleType.Fit
				frame.ImageFrame.ImageLabel.Image = "rbxassetid://5617714687"
				frame.Information.Title.Text = "Banner"
				frame.Information.Description.Text = string.format("Obtained %s", stuff.Value)
			end 
			item.Visible = true
			item.Parent = GUI.Notification.PopupWindow.Obtained
			TweenService:Create(item.Frame, TweenInfo.new(0.75), {Position = UDim2.new(0.005, 0, 0.025, 0)}):Play()
		end
		GUI.Notification.PopupWindow.Obtained.CanvasPosition = Vector2.new(0, 0)
		GUI.Notification.PopupWindow.Obtained.CanvasSize = UDim2.new(0, 0, 0, GUI.Notification.PopupWindow.Obtained.UIListLayout.AbsoluteContentSize.Y)
	end
end)

GUI.Notification.PopupWindow.Close.Frame.MouseButton1Down:Connect(function()
	GUI.Notification.PopupWindow.Visible = false
end)

function OpenMenu(Folk, FO)
	if game.PlaceId == 785484984 or game.PlaceId == 563493615 then return end

	local ForceOpen = FO and FO or false
	if (not GUI.ShopGUI.Enabled and not GUI.BlacksmithGUI.Enabled and NEWMENU.Size.Y.Scale < 1) or ForceOpen then
		bools.JustCameIn = false
		for _,input in next, DataValues.StatInputs do
			input:Disconnect()
			input = nil
		end
		for _,input in next, DataValues.SkillInputs do
			input:Disconnect()
			input = nil
		end
		for _,input in next, DataValues.Norm do
			input:Disconnect()
			input = nil
		end
		if DataValues.Inputs ~= nil then
			for _,input in next, DataValues.Inputs do
				if input and type(input) ~= "function" then
					input:Disconnect()
				end
				input = nil
			end
			DataValues.Inputs = nil
		end

		if DataValues.ControllerType == "Touch" then
			NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.CanvasPosition = Vector2.new(6,0)
		end
		
		NEWMENU.OuterFrame.Visible = true
		GUI.DesktopPauseMenu.Enabled = true
		TweenService:Create(GUI.DesktopPauseMenu.Gradient,TweenInfo.new(.5,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
		TweenService:Create(NEWMENU,TweenInfo.new(.5,Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,1,0)}):Play()
		NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.ModifySet.Visible = false

		if DataValues.ControllerType == "Controller" then
			FS.spawn(function()
				wait(.5)
				if not DataValues.LastSelected then
					DataValues.LastSelected = NEWMENU.OuterFrame.ContentWindow.Character.Banner.Frame
				end
				GuiService.SelectedObject = DataValues.LastSelected
			end)
		end

		local Inspect = (Folk==nil and nil or Folk)
		DataValues.CharInfo = Socket:Request("getCharacterInfo", Inspect==nil and nil or Inspect)
		DataValues.AccInfo = Socket:Request("getAccountInfo", Inspect==nil and nil or Inspect)
		local CharCount = 0
		local CodexCount = 0
		local Inve = 0
		local Ache = 0
		for _, chars in pairs(DataValues.AccInfo.Characters) do
			CharCount = CharCount + 1
		end
		for _, codexs in pairs(DataValues.AccInfo.Codex) do
			CodexCount = CodexCount + 1
		end
		NEWMENU.OuterFrame.ContentWindow.Achievements.Claim.Visible = false
		NEWMENU.OuterFrame.Buttons.Achievements.notice.Visible = false
		for _, n in pairs(DataValues.AccInfo.UnclaimedAchievements) do
			NEWMENU.OuterFrame.ContentWindow.Achievements.Claim.Visible = true
			NEWMENU.OuterFrame.Buttons.Achievements.notice.Visible = true
		end
		for i = 1, #DataValues.CharInfo.GemInventory do
			local Item = DataValues.CharInfo.GemInventory[i]
			if Item ~= nil then
				Inve = Inve + 1
			end
		end
		for i = 1, #DataValues.CharInfo.WeaponInventory do
			local Item = DataValues.CharInfo.WeaponInventory[i]
			if Item ~= nil then
				Inve = Inve + 1
			end
		end
		for i = 1, #DataValues.CharInfo.TrophyInventory do
			local Item = DataValues.CharInfo.TrophyInventory[i]
			if Item ~= nil then
				Inve = Inve + 1
			end
		end
		for i = 1, #DataValues.AccInfo.Achievements do
			if DataValues.AccInfo.Achievements[i].C == 1 then
				Ache = Ache + 1
			end
		end
		local Tabl = {
			Achievements = Ache,
			AchievementList = Socket:Request("GetAchievements"),
			Characters = CharCount,
			Titles = #DataValues.AccInfo.Titles,
			Codex = CodexCount,
			Recipes = #DataValues.AccInfo.Recipes
		}
		DataValues.MenuOpening = true
		local Banner = NEWMENU.OuterFrame.ContentWindow.Character.Banner.Frame
		local Banners = ReplicatedStorage.Images.Banners
		local BG = DataValues.AccInfo.ProfileBackground
		if Banners:FindFirstChild(BG) then
			Banner.BannerImg.Image = Banners[BG].Image
		end
		Banner.BannerImg.ImageRectOffset = Vector2.new(0,0)
		Banner.BannerImg.ImageRectSize = Vector2.new(0,0)
		if ReplicatedStorage.Images.Banners[BG]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[BG]:FindFirstChild("NumOfSprites") then
			Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
			Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X, ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
			FS.spawn(function()
				local CanContinue = true
				wait(1)
				FS.spawn(function()
					while wait() and CanContinue do
						if (not NEWMENU.OuterFrame.ContentWindow.Character.Visible or NEWMENU.EditWindow.Visible or NEWMENU.Size.Y.Scale < 1) then
							CanContinue = false
						end
					end
				end)
				while (NEWMENU.OuterFrame.ContentWindow.Character.Visible and not NEWMENU.EditWindow.Visible and NEWMENU.Size.Y.Scale == 1 and CanContinue) do
					Banner.BannerImg.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[BG].Width.Value.X,0)
					Banner.BannerImg.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[BG].Width.Value.X,ReplicatedStorage.Images.Banners[BG].Width.Value.Y)
					--Animate = function(image, reverse, numSpritesX, numSpritesY, framerate, startrowX, startrowY, MaxFrames, StartColor, EndColor)
					local NumOfSpritesX = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.X or 3
					local NumOfSpritesY = ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y ~= 0 and ReplicatedStorage.Images.Banners[BG].NumOfSprites.Value.Y or 9
					Animate(Banner.BannerImg, false, NumOfSpritesX, NumOfSpritesY, ReplicatedStorage.Images.Banners[BG].Framerate.Value, 0,0, ReplicatedStorage.Images.Banners[BG].Maxframes.Value)
		--			wait((1/ReplicatedStorage.Images.Banners[BG].Framerate.Value)*(ReplicatedStorage.Images.Banners[BG].Maxframes.Value)+.5)
				end
			end)
		end
		if Inve >= (DataValues.AccInfo.InventorySpace * 0.9) then
			Hint("Inventory is nearing its limit! Clear space by selling Gemstones, Trophies or Weapons.")
		end

		local Stats = {
			HP = 0,
			Damage = 0,
			Defense = 0,
			Crit = 0,
			CritDef = 0,
			Stamina = 0
		}
		local Gems = {
			Gem1 = nil,
			Gem2 = nil,
			Gem3 = nil
		}
		if DataValues.CharInfo.Gemstone1 ~= nil then
			Gems.Gem1 = Socket:Request("getLootInfo", DataValues.CharInfo.Gemstone1, Inspect==nil and nil or Inspect)
			NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones.Gem1.Frame.Image = Gems.Gem1.Image
		else
			NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones.Gem1.Frame.Image = ""
		end
		if DataValues.CharInfo.Gemstone2 ~= nil then
			Gems.Gem2 = Socket:Request("getLootInfo", DataValues.CharInfo.Gemstone2, Inspect==nil and nil or Inspect)
			NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones.Gem2.Frame.Image = Gems.Gem2.Image
		else
			NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones.Gem2.Frame.Image = ""
		end
		if DataValues.CharInfo.Gemstone3 ~= nil then
			Gems.Gem3 = Socket:Request("getLootInfo", DataValues.CharInfo.Gemstone3, Inspect==nil and nil or Inspect)
			NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones.Gem3.Frame.Image = Gems.Gem3.Image
		else
			NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones.Gem3.Frame.Image = ""
		end
		local function CheckGemName(Name)
			if Gems.Gem1 and Gems.Gem1.Name == Name then
				return Gems.Gem1
			elseif Gems.Gem2 and Gems.Gem2.Name == Name then
				return Gems.Gem2
			elseif Gems.Gem3 and Gems.Gem3.Name == Name then
				return Gems.Gem3
			end
			return false
		end
		local CurrWep = DataValues.CharInfo.CurrentWeapon
		local CurrTrop = DataValues.CharInfo.CurrentTrophy
		local Wepon, MoreTrophyInfo = Socket:Request("GetCurrentWeapon", true)
		local MoreWepInfo = Wepon.Object
		if MoreWepInfo then
			Stats.HP = Stats.HP + (MoreTrophyInfo.Object.Stats.HP+(MoreTrophyInfo.Object.StatsPerLevel.HP*CurrTrop.UpLvl))
			Stats.Defense = Stats.Defense + (MoreTrophyInfo.Object.Stats.DEF+(MoreTrophyInfo.Object.StatsPerLevel.DEF*CurrTrop.UpLvl))
			Stats.CritDef = Stats.CritDef + (MoreWepInfo.Stats.CRITDEF+(MoreWepInfo.StatsPerLevel.CRITDEF*CurrWep.UpLvl))
			Stats.Crit = Stats.Crit + (MoreWepInfo.Stats.CRIT+(MoreWepInfo.StatsPerLevel.CRIT*CurrWep.UpLvl))
			Stats.Damage = Stats.Damage + (MoreWepInfo.Stats.ATK+(MoreWepInfo.StatsPerLevel.ATK*CurrWep.UpLvl))
			Stats.Stamina = Stats.Stamina + (MoreWepInfo.Stats.STAM+(MoreWepInfo.StatsPerLevel.STAM*CurrWep.UpLvl))
		end
		local HPIn = CheckGemName("HP Increase")
		if HPIn then
			Stats.HP = Stats.HP + ((Stats.HP+DataValues.CharInfo.HP)*(HPIn.Value*.01))
		end
		local Rein = CheckGemName("Reinforced Armor")
		if Rein then
			Stats.Defense = Stats.Defense + ((Stats.Defense+DataValues.CharInfo.Defense))
		end
		local CloD = CheckGemName("Close Defense")
		if CloD then
			Stats.CritDef = Stats.CritDef + ((Stats.CritDef+DataValues.CharInfo.CritDef)*(CloD.Value*.01))
		end
		local Muscu = CheckGemName("Muscular Power")
		if Muscu then
			Stats.Damage = Stats.Damage + ((Stats.HP+DataValues.CharInfo.HP)*(Muscu.Value*.01))
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
			Stats.Damage = Stats.Damage + ((Stats.Damage+DataValues.CharInfo.Damage)*(Primal.Value*.01))
		end
		local ATKI = CheckGemName("ATK Increase")
		if ATKI then
			Stats.Damage = Stats.Damage + ((Stats.Damage+DataValues.CharInfo.Damage)*(ATKI.Value*.01))
		end
		local wepacc = 40+((DataValues.CharInfo.CurrentLevel*.1)+(DataValues.AccInfo.WeaponLevel*4))
		local atkspd = DataValues.CharInfo.Stamina*0.04 ---   -30
		local critdmg = 30+((DataValues.CharInfo.Damage*0.00015)*100)
		local excessat = 40-atkspd
		local reqEXP = math.floor(((DataValues.CharInfo.CurrentLevel+1)^1.6+(DataValues.CharInfo.CurrentLevel+1))/2*100-((DataValues.CharInfo.CurrentLevel+1)*100))
		local EXP = math.floor(DataValues.CharInfo.EXP)
		local CappedDefense = (DataValues.CharInfo.Defense*100) + Stats.Defense

		local Skills = DataValues.CharInfo.Skills
		for _, v in ipairs(Skills) do
			if v.Name == "Attack Speed Mastery" and v.Unlocked then
				atkspd += (1.5 * v.Rank)
				break
			end
		end
		
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.HP.Second.Text = tostring(format_int(math.floor(DataValues.CharInfo.HP + Stats.HP)))
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.Damage.Second.Text = tostring(format_int(DataValues.CharInfo.Damage + Stats.Damage))
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.DEF.Second.Text = tostring(round(CappedDefense > 80 and 80 or CappedDefense, 2)) .. "%"
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.Crit.Second.Text = tostring(format_int(DataValues.CharInfo.Crit + Stats.Crit))
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.CritDEF.Second.Text = tostring(format_int(DataValues.CharInfo.CritDef + Stats.CritDef)) 
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.Stamina.Second.Text = tostring(format_int(DataValues.CharInfo.Stamina + Stats.Stamina))
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.Accuracy.Second.Text = wepacc < 95 and tostring(round( wepacc, 2 )).. "%" or "95%"
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.AttackSpeed.Second.Text = tostring(round( 100+atkspd, 2 )).. "%"
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.ComboMulti.Second.Text = excessat < 0 and tostring(round( math.abs(excessat), 2 )).. "%" or "100%"
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.CritDamage.Second.Text = tostring(round( 100+critdmg, 2 )).. "%"
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.RequiredEXP.Second.Text = reqEXP
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.EXP.Second.Text = EXP
		NEWMENU.OuterFrame.ContentWindow.Character.Info.Level.Text = "Lv. " ..DataValues.CharInfo.CurrentLevel
		
		NEWMENU.OuterFrame.ContentWindow.Character.Title.Frame.TextLabel.Text = DataValues.AccInfo.ChatTitle == "" and "[ None ]" or "[ " ..DataValues.AccInfo.ChatTitle.. " ]"
		NEWMENU.OuterFrame.ContentWindow.Character.Title.Frame.TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
		
		local TitleInfo = Socket:Request("GetTitles")
		for _,tet in ipairs(TitleInfo) do
			if tet.Name == DataValues.AccInfo.ChatTitle then
				NEWMENU.OuterFrame.ContentWindow.Character.Title.Frame.TextLabel.TextColor3 = tet.Color
				break
			end
		end
		--[[
		for _,DisplayButtons in ipairs(NEWMENU.OuterFrame.Buttons:GetChildren()) do
			if DisplayButtons:IsA("ImageButton") then
				TweenService:Create(DisplayButtons,TweenInfo.new(0.2),{ImageColor3 = Color3.fromRGB(134, 134, 134)}):Play()
				if NEWMENU.OuterFrame.ContentWindow:FindFirstChild(DisplayButtons.Name) then
					NEWMENU.OuterFrame.ContentWindow[DisplayButtons.Name].Visible = false
				end
				if DisplayButtons.Name == "Character" then
					TweenService:Create(DisplayButtons,TweenInfo.new(0.2),{ImageColor3 = Color3.fromRGB(255, 246, 146)}):Play()
					NEWMENU.OuterFrame.ContentWindow.Character.Visible = true
					NEWMENU.OuterFrame.Texter.NavButtonSelection.Text = "Character"
				end
			end
		end
		--]]
		if EXP < reqEXP then
			NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.RequiredEXP.Second.TextColor3 = Color3.fromRGB(159, 63, 63)
		else
			NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats.RequiredEXP.Second.TextColor3 = Color3.fromRGB(159, 159, 159)
			Hint("Level up by upgrading a Stat in the Character tab")
		end
		
		if DataValues.CharInfo.CurrentLevel >= 5 then
			NEWMENU.OuterFrame.ContentWindow.Character.Skills.Visible = true
		end

		if DataValues.Inputs == nil then
			DataValues.Inputs = {}
			
			local function Back(JustClose)
				if bools.PlayingTutorial then
					TweenService:Create(GUI.DesktopPauseMenu.Gradient,TweenInfo.new(.5,Enum.EasingStyle.Linear),{ImageTransparency = 0}):Play()
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Description.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Buttons.PreviewCombos.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Buttons.Upgrade.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.OuterFrame.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.Skills.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.Visible = true
					GUI.DesktopPauseMenu.Base.Mask.EditWindow.Inputs.Visible = false
					bools.PlayingTutorial = false
				else
					DataValues.SellObjs = {}
					DataValues.CurrentSelectedSkill = nil
					DataValues.CurrentSelectedCostume = nil
					DataValues.ReforgeMode = false
					DataValues.ReforgeQueue = {}
					NEWMENU.EditWindow.Weapons.Inventory.UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
					NEWMENU.EditWindow.Weapons.Inventory.UIGridLayout.CellSize = UDim2.new(0, 100, 0, 100)
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Reforge.Visible = false
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Title.Text = "Reforge"
					
					bools.SellMode = false
					for _,Windows in ipairs(NEWMENU.EditWindow:GetChildren()) do
						if Windows:IsA("Frame") then
							Windows.Visible = false
						end
					end
					for _,Windows in ipairs(NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description:GetChildren()) do
						if not Windows:IsA("UIListLayout") then
							Windows:Destroy()
						end
					end
					
					NEWMENU.EditWindow.Visible = false
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = "Hover or select an item to view their details."
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = "Null"
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.ComboMaker.Visible = false
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.PreviewCombos.Visible = false
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Upgrade.Visible = false
					NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = false
					
					if JustClose ~= nil then
						OpenMenu(nil, true)
					end
				end
			end
			
			local StatFetchOnce = true
			for _,StatButton in ipairs(NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats:GetChildren()) do
				if StatButton:IsA("Frame") and StatButton:FindFirstChild("Second") then
					if EXP >= reqEXP then
						if StatButton.Second:FindFirstChild("Upgrade") then
							if StatFetchOnce then
								StatFetchOnce = false
								local CurrentLevels, LevelRates = Socket:Request("GetLevelRates")
								local StatFrames = NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats
								local HPAdd = math.floor(LevelRates.HP.Start*(LevelRates.HP.Decay)^CurrentLevels.HP)
								local DmgAdd = math.floor(LevelRates.ATK.Start*(LevelRates.ATK.Decay)^CurrentLevels.ATK)
								local DEFAdd = LevelRates.DEF.Start*(LevelRates.DEF.Decay)^CurrentLevels.DEF
								local CRTAdd = math.floor(LevelRates.CRT.Start*(LevelRates.CRT.Decay)^CurrentLevels.CRT)
								local CRDAdd = math.floor(LevelRates.CRD.Start*(LevelRates.CRD.Decay)^CurrentLevels.CRD)
								local STAAdd = math.floor(LevelRates.STA.Start*(LevelRates.STA.Decay)^CurrentLevels.STA)
								if HPAdd <= LevelRates.HP.Minimum then
									HPAdd = LevelRates.HP.Minimum
								end
								if DmgAdd <= LevelRates.ATK.Minimum then
									DmgAdd = LevelRates.ATK.Minimum
								end
								if DEFAdd <= LevelRates.DEF.Minimum then
									DEFAdd = LevelRates.DEF.Minimum
								end
								if CRTAdd <= LevelRates.CRT.Minimum then
									CRTAdd = LevelRates.CRT.Minimum
								end
								if CRDAdd <= LevelRates.CRD.Minimum then
									CRDAdd = LevelRates.CRD.Minimum
								end
								if STAAdd <= LevelRates.STA.Minimum then
									STAAdd = LevelRates.STA.Minimum
								end
								StatFrames.HP.Second.Text = tostring(format_int(DataValues.CharInfo.HP + Stats.HP)).. " > " .. tostring(format_int((DataValues.CharInfo.HP+HPAdd) + Stats.HP))
								StatFrames.Damage.Second.Text = tostring(format_int(DataValues.CharInfo.Damage + Stats.Damage)).. " > " .. tostring(format_int((DataValues.CharInfo.Damage+DmgAdd) + Stats.Damage))
								if DataValues.CharInfo.CurrentLevel >= 10 then
									StatFrames.DEF.Second.Text = tostring(round((DataValues.CharInfo.Defense*100) + Stats.Defense, 2)) .. " > " .. tostring(round(((DataValues.CharInfo.Defense+DEFAdd)*100) + Stats.Defense, 2)) .. "%"
									StatFrames.Crit.Second.Text = tostring(format_int(DataValues.CharInfo.Crit + Stats.Crit)).. " > " .. tostring(format_int((DataValues.CharInfo.Crit+CRTAdd) + Stats.Crit))
									StatFrames.CritDEF.Second.Text = tostring(format_int(DataValues.CharInfo.CritDef + Stats.CritDef)).. " > " .. tostring(format_int((DataValues.CharInfo.CritDef+CRDAdd) + Stats.CritDef))
									StatFrames.Stamina.Second.Text = tostring(format_int(DataValues.CharInfo.Stamina + Stats.Stamina)).. " > " .. tostring(format_int((DataValues.CharInfo.Stamina+STAAdd) + Stats.Stamina))
								end
							end
							
							DataValues.Inputs["Upgrading" ..StatButton.Name.."Stat"] = StatButton.Second.Upgrade.MouseButton1Down:Connect(function()
								DataValues.LastSelected = StatButton.Second.Upgrade
								local success = Socket:Request("UpgradeStat", StatButton.Name)
								if success then
									for _,StatButton2 in ipairs(NEWMENU.OuterFrame.ContentWindow.Character.Info.Stats:GetChildren()) do
										if StatButton2:IsA("Frame") and StatButton2:FindFirstChild("Second") then
											if StatButton2.Second:FindFirstChild("Upgrade") then
												StatButton2.Second.Upgrade.Visible = false
											end
										end
									end
									Back(true)
								end
							end)
							if ((StatButton.Name == "HP" or StatButton.Name == "Damage") and DataValues.CharInfo.CurrentLevel < 10) or (DataValues.CharInfo.CurrentLevel >= 10) then
								StatButton.Second.Upgrade.Visible = true
							end
						end
					else
						if StatButton.Second:FindFirstChild("Upgrade") then
							StatButton.Second.Upgrade.Visible = false
						end
					end
				end
			end
			
			DataValues.Inputs.BackButton = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.BackButton.MouseButton1Down:Connect(function()
				Back(true)
			end)
			
			Back()
			
			DataValues.Inputs.OpenCharacterTab = NEWMENU.OuterFrame.ContentWindow.Character:GetPropertyChangedSignal("Visible"):Connect(function()
				if NEWMENU.OuterFrame.ContentWindow.Character.Visible then
					DataValues.LastSelected = NEWMENU.OuterFrame.ContentWindow.Character.Banner.Frame
					if DataValues.ControllerType == "Controller" then
						GuiService.SelectedObject = DataValues.LastSelected
					end
					OpenMenu(nil, true)
				end
			end)
			
			DataValues.Inputs.OpenEquipmentTab = NEWMENU.OuterFrame.ContentWindow.Equipment:GetPropertyChangedSignal("Visible"):Connect(function()
				if NEWMENU.OuterFrame.ContentWindow.Equipment.Visible then
					if DataValues.ControllerType == "Controller" then
						DataValues.LastSelected = NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Weapon.Frame
						GuiService.SelectedObject = NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Weapon.Frame
					end
					if NEWMENU.OuterFrame.ContentWindow.Character.Visible then
						NEWMENU.OuterFrame.ContentWindow.Character.Visible = false
					end
					if Inve >= DataValues.AccInfo.InventorySpace then
						NEWMENU.OuterFrame.ContentWindow.Equipment.InventorySpace.Content.Title.TextColor3 = Color3.fromRGB(255, 85, 85)
					else
						NEWMENU.OuterFrame.ContentWindow.Equipment.InventorySpace.Content.Title.TextColor3 = Color3.fromRGB(255, 235, 224)
					end
					NEWMENU.OuterFrame.ContentWindow.Equipment.InventorySpace.Content.Bar.Size = UDim2.new(0, 0, 1, 0)
					NEWMENU.OuterFrame.ContentWindow.Equipment.Title.TextTransparency = 1
					NEWMENU.OuterFrame.ContentWindow.Equipment.Title2.TextTransparency = 1
					NEWMENU.OuterFrame.ContentWindow.Equipment.Title3.TextTransparency = 1
					NEWMENU.OuterFrame.ContentWindow.Equipment.Lines.HoriLine.Size = UDim2.new(0, 1, 0, 1)
					NEWMENU.OuterFrame.ContentWindow.Equipment.Lines.VertLine.Size = UDim2.new(0, 1, 0, 1)
					wait(0.25)
					local InventorySize = Inve/DataValues.AccInfo.InventorySpace
					NEWMENU.OuterFrame.ContentWindow.Equipment.InventorySpace.Content.Title.Text = string.format("INVENTORY SPACE - %s / %s", Inve, DataValues.AccInfo.InventorySpace)
					TweenService:Create(NEWMENU.OuterFrame.ContentWindow.Equipment.InventorySpace.Content.Bar,TweenInfo.new(0.25),{Size = UDim2.new(InventorySize, 0, 1, 0)}):Play()
					TweenService:Create(NEWMENU.OuterFrame.ContentWindow.Equipment.Lines.HoriLine,TweenInfo.new(0.25),{Size = UDim2.new(.35, 1, 0, 1)}):Play()
					TweenService:Create(NEWMENU.OuterFrame.ContentWindow.Equipment.Lines.VertLine,TweenInfo.new(0.25),{Size = UDim2.new(0, 1, 0.2, 1)}):Play()
					wait(.15)
					TweenService:Create(NEWMENU.OuterFrame.ContentWindow.Equipment.Title,TweenInfo.new(0.25),{TextTransparency = 0}):Play()
					TweenService:Create(NEWMENU.OuterFrame.ContentWindow.Equipment.Title2,TweenInfo.new(0.25),{TextTransparency = 0}):Play()
					TweenService:Create(NEWMENU.OuterFrame.ContentWindow.Equipment.Title3,TweenInfo.new(0.25),{TextTransparency = 0}):Play()
				end
			end)
			
			local InventoryGUI = NEWMENU.EditWindow.Weapons
			local Height = 0
			local Current = "Weapons"
			--InventoryGUI.ClipsDescendants = false
			InventoryGUI.Parent.NotHide.AnalyzeWindow.Money.Gold.Price.Text = tostring(format_int(DataValues.AccInfo.Gold))
			InventoryGUI.Parent.NotHide.AnalyzeWindow.Money.Tears.Price.Text = tostring(format_int(DataValues.AccInfo.Tears))
			local function RemoveMenuItems()
				for _,existingStuff in next, InventoryGUI.Inventory:GetChildren() do
					if existingStuff:IsA("Frame") or existingStuff:IsA("BindableEvent") then
						existingStuff:Destroy()
					end
				end
			end
			local function ShowInventory(Type)
				NEWMENU.OuterFrame.Visible = false
				
				DataValues.SellObjs = {}
				bools.SellMode = false
				for bu,input in next, DataValues.InventoryInputs do
					if bu ~= "InventoryGems" and bu ~= "InventoryMats" and bu ~= "InventoryWeapons" then
						input:Disconnect()
						input = nil
					end
				end
				DataValues.ReforgeMode = false
				DataValues.ReforgeQueue = {}
				
				DataValues.CurrentSelectedCostume = nil
				
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = "Hover or select an item to view their details."
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = "Null"
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
				
				local Description = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description
				for _,Descs in ipairs(Description:GetChildren()) do
					if Descs:IsA("Frame") then
						Descs:Destroy()
					end
				end
				
				RemoveMenuItems()
				local Inventory = Socket:Request("getLootInfo", nil, Type, Inspect~=nil and Inspect or nil)
				local NewWeaponEquip;
				if Type == "Weapons" or Type == "Trophies" then
					NewWeaponEquip = Instance.new("BindableEvent")
					NewWeaponEquip.Name = "NewWeaponEquip"
					NewWeaponEquip.Parent = InventoryGUI.Inventory
				end
				
				for i=1,#Inventory do
					local Item = Inventory[i]
					if Item ~= nil then
						if Type == "Weapons" or Type == "Trophies" then
							local Loot = Item
							local RarityImage = ReplicatedStorage.Images.Textures["Rarity"..Loot.Object.Rarity]
							local WeaponPreview = Loot.Object.Model ~= nil and Loot.Object.Model:Clone() or nil
							local NewWeaponBlock = ReplicatedStorage.GUI.NormalGui.WeaponBlock:Clone()
							NewWeaponBlock.TextButton.Image = RarityImage.Image
							NewWeaponBlock.LayoutOrder = -((200*Loot.Object.Rarity)+(Loot.Object.LevelReq*10)+Loot.CurrentWeapon.UpLvl)
							if DataValues.InventoryInputs[Loot] ~= nil then
								DataValues.InventoryInputs[Loot]:Disconnect()
								DataValues.InventoryInputs[Loot] = nil
							end
							NewWeaponEquip.Event:Connect(function(Butt)
								if Butt == NewWeaponBlock then
									Loot.Equipped = true
									NewWeaponBlock.ViewportFrame.BackgroundColor3 = Color3.fromRGB(232, 255, 20)
								else
									Loot.Equipped = false
									NewWeaponBlock.ViewportFrame.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
								end
								Wepon, MoreTrophyInfo = Socket:Request("GetCurrentWeapon", true)
								MoreWepInfo = Wepon.Object
							end)
							local function UpdateWeaponPreview(bool)
								if bool then
									GUI.WeaponPreview.Weapon.Visible = false
								else
									GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame:ClearAllChildren()
									if WeaponPreview and GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame:FindFirstChild(WeaponPreview.Name) == nil then
										local WeaponPreviewPopup = WeaponPreview:Clone()
										if WeaponPreviewPopup:FindFirstChild("CameraCF") then
											local CameraPre = Instance.new("Camera")
											CameraPre.CFrame = WeaponPreviewPopup.CameraCF.Value
											GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame.CurrentCamera = CameraPre
										end
										WeaponPreviewPopup.Parent = GUI.WeaponPreview.Weapon.WeaponBlock.ViewportFrame
									end
									local WepSkills = {}
									local WeaponSkillPreview = GUI.WeaponPreview.Weapon.SkillDescriptions.WeaponSkill
									WeaponSkillPreview.Text = ""
									for i = 1, #Loot.WeaponSkills do
										local Skills = Loot.WeaponSkills[i]
										for v = 1, #Loot.CurrentWeapon.Skls do
											if Loot.CurrentWeapon.Skls[v].I == Skills.ID then
												table.insert(WepSkills, "[" ..Skills.Name.."] " ..Skills.Desc.. (Skills.Tier1 and " (" ..Loot.CurrentWeapon.Skls[v].V.. "" ..Skills.Prefix..")" or "") .."\n\n")
												break
											end
										end
										WeaponSkillPreview.Text = table.concat(WepSkills, "")
										WeaponSkillPreview.Visible = true
									end
									GUI.WeaponPreview.Weapon.WeaponBlock.TextButton.Image = NewWeaponBlock.TextButton.Image
									GUI.WeaponPreview.Weapon.Title.TextColor3 = RarityImage.Color.Value
									local NewLvl = Loot.CurrentWeapon.UpLvl
									local UpLvl = NewLvl > 0 and "+" ..NewLvl or ""
									GUI.WeaponPreview.Weapon.Title.Text = Loot.Object.WeaponName .. " " ..UpLvl
									GUI.WeaponPreview.Weapon.Desc.Text = Loot.Object.Description
									local UpReq = Loot.CurrentWeapon.Tier and Loot.Object.MaxUpgrades - Loot.CurrentWeapon.Tier or 0
									local LObj = Loot.Object
									GUI.WeaponPreview.Weapon.UpgradeDesc.Text = "Weapon Exclusive to " ..Loot.Ownership.. "\nPossible Tier Upgrades: "..UpReq.."\nRequired Level: "..Loot.Object.LevelReq
									local HP = Loot.Object.Stats.HP+(LObj.StatsPerLevel.HP*(Loot.CurrentWeapon.UpLvl)) > 0 and "\nHP \t+" ..Loot.Object.Stats.HP+(LObj.StatsPerLevel.HP*(Loot.CurrentWeapon.UpLvl)) or ""
									local ATK = Loot.Object.Stats.ATK+(LObj.StatsPerLevel.ATK*(Loot.CurrentWeapon.UpLvl)) > 0 and "\nATK \t+" ..Loot.Object.Stats.ATK+(LObj.StatsPerLevel.ATK*(Loot.CurrentWeapon.UpLvl)) or ""
									local DEF = Loot.Object.Stats.DEF+(LObj.StatsPerLevel.DEF*(Loot.CurrentWeapon.UpLvl)) > 0 and "\nDEF \t+" ..Loot.Object.Stats.DEF+(LObj.StatsPerLevel.DEF*(Loot.CurrentWeapon.UpLvl)) or ""
									local STAM = Loot.Object.Stats.STAM+(LObj.StatsPerLevel.STAM*(Loot.CurrentWeapon.UpLvl)) > 0 and "\nSTAM \t+" ..Loot.Object.Stats.STAM+(LObj.StatsPerLevel.STAM*(Loot.CurrentWeapon.UpLvl)) or ""
									local CRIT = Loot.Object.Stats.CRIT+(LObj.StatsPerLevel.CRIT*(Loot.CurrentWeapon.UpLvl)) > 0 and "\nCRIT \t+" ..Loot.Object.Stats.CRIT+(LObj.StatsPerLevel.CRIT*(Loot.CurrentWeapon.UpLvl)) or ""
									local CRITDEF = Loot.Object.Stats.CRITDEF+(LObj.StatsPerLevel.CRITDEF*(Loot.CurrentWeapon.UpLvl)) > 0 and "\nCRIT DEF \t+" ..Loot.Object.Stats.CRITDEF+(LObj.StatsPerLevel.CRITDEF*(Loot.CurrentWeapon.UpLvl)) or ""
									GUI.WeaponPreview.Weapon.StatDesc.Text = "[Stats]" ..HP.. "" ..ATK.. "" ..DEF.. "" ..STAM.. "" ..CRIT.. "" ..CRITDEF
									GUI.WeaponPreview.Weapon.Visible = true
								end
							end
							local LastColor = NewWeaponBlock.TextButton.BackgroundColor3
							DataValues.InventoryInputs[Loot] = NewWeaponBlock.TextButton.MouseButton1Down:Connect(function()
								DataValues.CurrentObj = Loot
								DataValues.CurrentButt = NewWeaponBlock
								if bools.SellMode then
									if not DataValues.CurrentObj.Equipped then
										if Loot.Object.ID ~= 1 then
											local NotFound = true
											for i = 1, #DataValues.SellObjs do
												if DataValues.SellObjs[i] ~= nil and DataValues.SellObjs[i].Button == NewWeaponBlock then
													table.remove(DataValues.SellObjs, i)
													NewWeaponBlock.ViewportFrame.BackgroundColor3 = LastColor
													NotFound = false
													print("Removing")
												end
											end
											if NotFound then
												print("Selling")
												local ToSell = {}
												ToSell.Object = Loot
												ToSell.Button = NewWeaponBlock
												NewWeaponBlock.ViewportFrame.BackgroundColor3 = Color3.fromRGB(232, 30, 20)
												table.insert(DataValues.SellObjs, ToSell)
											end
										else
											Hint("You cannot sell your default weapon.")
										end
									else
										Hint("You must unequip this item before selling it.")
									end
								end
								local NewLvl = Loot.CurrentWeapon.UpLvl
								local UpLvl = NewLvl > 0 and "+" ..NewLvl or ""
								local Equipped = DataValues.CurrentObj.Equipped and "(Equipped) " or ""
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = Loot.Object.Description
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = Equipped.. Loot.Object.WeaponName .. " " ..UpLvl
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
								
								local Assets = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Assets
								local TitleL = Assets.DescLeft:Clone()
								local TitleR = Assets.DescRight:Clone()
								
								local Frame = Instance.new("Frame")
								local Layout = Instance.new("UIListLayout")
								Frame.BackgroundTransparency = 1
								Frame.Size = UDim2.new(1, 0, .08, 0)
								Layout.FillDirection = Enum.FillDirection.Horizontal
								Layout.Parent = Frame
								
								for _,Descs in ipairs(Description:GetChildren()) do
									if Descs:IsA("Frame") then
										Descs:Destroy()
									end
								end
								
								TitleL.Text = Type == "Weapons" and "Current Weapon " or "Current Trophy "
								TitleL.TextColor3 = Color3.fromRGB(255, 216, 216)
								TitleL.LayoutOrder = 0
								TitleR.Text = Type == "Weapons" and "-> Selected Weapon " or "-> Selected Trophy"
								TitleR.TextColor3 = Color3.fromRGB(212, 255, 232)
								TitleR.LayoutOrder = 1

								TitleL.Visible = true
								TitleR.Visible = Equipped ~= "(Equipped) " and true or false
								
								local Spacer = Frame:Clone()
								Spacer.LayoutOrder = 2
								Spacer.Size = UDim2.new(1, 0, .08, 0)
								Spacer.Parent = Description
								
								local LObj = Loot.Object
								local ATK = LObj.Stats.ATK+(LObj.StatsPerLevel.ATK*(Loot.CurrentWeapon.UpLvl)) 
								local STAM = LObj.Stats.STAM+(LObj.StatsPerLevel.STAM*(Loot.CurrentWeapon.UpLvl))
								local CRIT = LObj.Stats.CRIT+(LObj.StatsPerLevel.CRIT*(Loot.CurrentWeapon.UpLvl))
								
								local ATKF = Frame:Clone()
								local STAF = Frame:Clone()
								local CRIF = Frame:Clone()
								local LVLF = Frame:Clone()
								ATKF.LayoutOrder = Type == "Weapons" and 3 or 4
								STAF.LayoutOrder = Type == "Weapons" and 4 or 3
								CRIF.LayoutOrder = 5
								LVLF.LayoutOrder = 7
								
								TitleL.Parent = Frame
								TitleR.Parent = Frame
								
								Frame.Parent = Description
								
								local ATKL = TitleL:Clone()
								ATKL.Text = Type == "Weapons" and "Damage: " .. (MoreWepInfo.Stats.ATK+(MoreWepInfo.StatsPerLevel.ATK*CurrWep.UpLvl)) .. " "
									or "Damage Reduction: " .. (MoreTrophyInfo.Object.Stats.DEF) .. "% "
								ATKL.Parent = ATKF
								
								local ATKR = TitleR:Clone()
								ATKR.Text = Type == "Weapons" and "> " ..ATK
									or "> " .. (LObj.Stats.DEF) .. "% "
								ATKR.TextColor3 = Type == "Weapons" and ((MoreWepInfo.Stats.ATK+(MoreWepInfo.StatsPerLevel.ATK*CurrWep.UpLvl)) > ATK and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(133, 255, 124))
									or ((MoreTrophyInfo.Object.Stats.DEF) > (LObj.Stats.DEF) and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(133, 255, 124))
								ATKR.Parent = ATKF
								
								local STAL = TitleL:Clone()
								STAL.Text = Type == "Weapons" and "Stamina: " .. (MoreWepInfo.Stats.STAM+(MoreWepInfo.StatsPerLevel.STAM*CurrWep.UpLvl)) .. " "
									or "Health Increase: " .. (MoreTrophyInfo.Object.Stats.HP) .. " "
								STAL.Parent = STAF
								
								local STAR = TitleR:Clone()
								STAR.Text = Type == "Weapons" and "> " ..STAM
									or "> " .. (LObj.Stats.HP)
								STAR.TextColor3 = Type == "Weapons" and ((MoreWepInfo.Stats.STAM+(MoreWepInfo.StatsPerLevel.STAM*CurrWep.UpLvl)) > STAM and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(133, 255, 124))
									or ((MoreTrophyInfo.Object.Stats.HP) > (LObj.Stats.HP) and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(133, 255, 124))
								STAR.Parent = STAF
								
								local CRIL = TitleL:Clone()
								CRIL.Text = Type == "Weapons" and "Critical Rate: " .. (MoreWepInfo.Stats.CRIT+(MoreWepInfo.StatsPerLevel.CRIT*CurrWep.UpLvl)) .. " "
									or "Dodge Invulerability: " .. (MoreTrophyInfo.Object.Stats.CRITDEF*100) .. "% "
								CRIL.Parent = CRIF
								
								local CRIR = TitleR:Clone()
								CRIR.Text = Type == "Weapons" and "> " ..CRIT
									or "> " .. (LObj.Stats.CRITDEF*100).. "%"
								CRIR.TextColor3 = Type == "Weapons" and ((MoreWepInfo.Stats.CRIT+(MoreWepInfo.StatsPerLevel.CRIT*CurrWep.UpLvl)) > CRIT and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(133, 255, 124))
									or ((MoreTrophyInfo.Object.Stats.CRITDEF*100) > (LObj.Stats.CRITDEF*100) and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(133, 255, 124))
								CRIR.Parent = CRIF
								
								ATKF.Parent = Description
								STAF.Parent = Description
								CRIF.Parent = Description
								
								local Spacer2 = Spacer:Clone()
								Spacer2.LayoutOrder = 6
								Spacer2.Parent = Description
								
								local LVLL = TitleL:Clone()
								LVLL.Text = Type == "Weapons" and "Required Level: " .. (MoreWepInfo.LevelReq) .. " "
									or "Required Level: " .. (MoreTrophyInfo.Object.LevelReq) .. " "
								LVLL.Parent = LVLF
								
								local LVLR = TitleR:Clone()
								LVLR.Text = "> " ..LObj.LevelReq
								LVLR.TextColor3 = Type == "Weapons" and (MoreWepInfo.LevelReq < LObj.LevelReq and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(133, 255, 124))
									or (MoreTrophyInfo.Object.LevelReq < LObj.LevelReq and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(133, 255, 124))
								LVLR.Parent = LVLF
								
								LVLF.Parent = Description
							

								if not DataValues.CurrentObj.Equipped then
									NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Title.Text = "Equip"
									NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = (Inspect~=nil) and false or true
									if Loot.Object.ID ~= 1 then
										NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = (Inspect~=nil) and false or true
									end
									if bools.SellMode then
										NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
									end
								end
							end)
							if DataValues.ControllerType ~= "Touch" then
								DataValues.InventoryInputs.MouseMove = NewWeaponBlock.TextButton.MouseMoved:Connect(function(x, y)
									GUI.WeaponPreview.Weapon.Position = UDim2.new(0, x, 0, y)
									if GUI.WeaponPreview.Weapon.Position.X.Offset > GUI.Main.AbsoluteSize.X*.5 then
										GUI.WeaponPreview.Weapon.Position = UDim2.new(0, GUI.WeaponPreview.Weapon.Position.X.Offset - GUI.WeaponPreview.Weapon.AbsoluteSize.X, 0, GUI.WeaponPreview.Weapon.Position.Y.Offset)
									end
									if GUI.WeaponPreview.Weapon.Position.Y.Offset > GUI.Main.AbsoluteSize.Y*.5 then
										GUI.WeaponPreview.Weapon.Position = UDim2.new(0, GUI.WeaponPreview.Weapon.Position.X.Offset, 0, GUI.WeaponPreview.Weapon.Position.Y.Offset - GUI.WeaponPreview.Weapon.AbsoluteSize.Y)
									end
									UpdateWeaponPreview()
								end)
								DataValues.InventoryInputs.MouseLeave = NewWeaponBlock.TextButton.MouseLeave:Connect(function(x, y)
									UpdateWeaponPreview(true)
								end)
							else
								DataValues.InventoryInputs.TouchPress = NewWeaponBlock.TextButton.InputBegan:Connect(function(input)
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
								DataValues.InventoryInputs.TouchPressOff = NewWeaponBlock.TextButton.InputEnded:Connect(function(input)
									UpdateWeaponPreview(true)
								end)
							end
							if Loot.Equipped then
								NewWeaponBlock.ViewportFrame.BackgroundColor3 = Color3.fromRGB(232, 255, 20)
								NewWeaponBlock.LayoutOrder = -9999999
							end
							if WeaponPreview then
								if WeaponPreview:FindFirstChild("CameraCF") then
									local CameraPre = Instance.new("Camera")
									CameraPre.CFrame = WeaponPreview.CameraCF.Value
									NewWeaponBlock.ViewportFrame.CurrentCamera = CameraPre
								end
								WeaponPreview.Parent = NewWeaponBlock.ViewportFrame
							end
							NewWeaponBlock.Parent = InventoryGUI.Inventory
						else
							local ItemBlock = ReplicatedStorage.GUI.NormalGui.ItemBlock:Clone()
							Height = Height + 10
							ItemBlock.Info.Value = Item.Description
							ItemBlock.TextButton.Image = Item.Image
							if Item.IG == false and Item.Q > 1 then
								ItemBlock.Info1.Text = tostring(Item.Q)
								ItemBlock.Info1.Visible = true
								if Item.Q >= 99 then
									ItemBlock.Info1.TextColor3 = Color3.fromRGB(255, 112, 102)
								else
									ItemBlock.Info1.TextColor3 = Color3.fromRGB(155, 255, 214)
								end
							end
							local ColorChange = false
							ItemBlock.LayoutOrder = -(Item.R)
							if Item.R == 0 then
								ItemBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord2.Image
							elseif Item.R == 1 then
								ItemBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord3.Image
							elseif Item.R == 2 then
								ItemBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord4.Image
							elseif Item.R == 3 then
								ItemBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord5.Image
							elseif Item.R == 4 then
								ItemBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord6.Image
							elseif Item.R == 5 then
								ItemBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord7.Image
							else
								ItemBlock.Border.Image = ReplicatedStorage.Images.Textures.Bord1.Image
								ItemBlock.LayoutOrder = 2
							end
							if Type == "Gems" then
								if (DataValues.CharInfo.Gemstone1 ~= nil and DataValues.CharInfo.Gemstone1.IND == Item.IND) or (DataValues.CharInfo.Gemstone2 ~= nil and DataValues.CharInfo.Gemstone2.IND == Item.IND) or (DataValues.CharInfo.Gemstone3 ~= nil and DataValues.CharInfo.Gemstone3.IND == Item.IND) then
									ColorChange = true
								end
							else
								Item.R = 0
							end
							if ColorChange then
								ItemBlock.TextButton.BackgroundColor3 = Color3.fromRGB(232, 255, 20)
								ItemBlock.LayoutOrder = -9999
							end
							if DataValues.InventoryInputs[Item] ~= nil then
								DataValues.InventoryInputs[Item]:Disconnect()
								DataValues.InventoryInputs[Item] = nil
							end
							local LastColor = ItemBlock.TextButton.BackgroundColor3
							DataValues.InventoryInputs[Item] = ItemBlock.TextButton.MouseButton1Down:connect(function()
								DataValues.CurrentObj = Item
								DataValues.CurrentButt = ItemBlock
								if bools.SellMode then
									if (DataValues.CharInfo.Gemstone1 ~= nil and DataValues.CharInfo.Gemstone1.IND == DataValues.CurrentObj.IND) or (DataValues.CharInfo.Gemstone2 ~= nil and DataValues.CharInfo.Gemstone2.IND == DataValues.CurrentObj.IND) or (DataValues.CharInfo.Gemstone3 ~= nil and DataValues.CharInfo.Gemstone3.IND == DataValues.CurrentObj.IND) then
										Hint("You must unequip this item before selling it.")
									else
										local NotFound = true
										for i = 1, #DataValues.SellObjs do
											if DataValues.SellObjs[i] ~= nil and DataValues.SellObjs[i].Button == ItemBlock then
												table.remove(DataValues.SellObjs, i)
												ItemBlock.TextButton.BackgroundColor3 = LastColor
												NotFound = false
											end
										end
										if NotFound then
											local ToSell = {}
											ToSell.Object = Item
											ToSell.Button = ItemBlock
											ItemBlock.TextButton.BackgroundColor3 = Color3.fromRGB(232, 30, 20)
											table.insert(DataValues.SellObjs, ToSell)
										end
									end
								end
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = (Inspect~=nil or bools.SellMode) and false or true
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false

								if DataValues.CurrentObj.IG == true then
									if (DataValues.CharInfo.Gemstone1 ~= nil and DataValues.CharInfo.Gemstone1.IND == DataValues.CurrentObj.IND) or (DataValues.CharInfo.Gemstone2 ~= nil and DataValues.CharInfo.Gemstone2.IND == DataValues.CurrentObj.IND) or (DataValues.CharInfo.Gemstone3 ~= nil and DataValues.CharInfo.Gemstone3.IND == DataValues.CurrentObj.IND) then
										if DataValues.ReforgeMode == false then
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = (Inspect~=nil) and false or true
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Title.Text = "Unequip"
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
											if bools.SellMode then
												NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
											end
										else
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
										end
									else
										if DataValues.ReforgeMode == false then
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = (Inspect~=nil) and false or true
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Title.Text = "Equip"
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = (Inspect~=nil) and false or true
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Title.Text = "Reforge"
											if bools.SellMode then
												NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
												NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
											end
										else
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = (Inspect~=nil) and false or true
											NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Title.Text = "Add"
											if bools.SellMode then
												NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
												--InventoryGUI.Info.Reforge.Visible = false
											end
										end
									end
								else
									if DataValues.ReforgeMode then
										NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
										NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
										NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
									end
								end
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = Item.Name.. (Item.R > 0 and (Current == "Gems" and " +" .. tostring(Item.R) or " ") or " ")
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = ItemBlock.Info.Value.. "\n\nSell Price: " ..Item.SellPrice
							end)
							ItemBlock.Parent = InventoryGUI.Inventory
						end
					end
				end				
				InventoryGUI.Inventory.CanvasSize = UDim2.new(0, 0, 0, InventoryGUI.Inventory.UIGridLayout.AbsoluteContentSize.Y)
				NEWMENU.EditWindow.Weapons.Visible = true
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = true
				NEWMENU.EditWindow.Visible = true
			end
			
			if NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Weapon.Frame:FindFirstChild("WeaponBlock") then
				NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Weapon.Frame.WeaponBlock:Destroy()
			end
			
			NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Weapon.Frame:ClearAllChildren()
			
			local CurrentWeapon = MoreWepInfo
			local RarityImage = ReplicatedStorage.Images.Textures["Rarity"..CurrentWeapon.Rarity]
			local WeaponPreview = CurrentWeapon.Model:Clone()
			local NewWeaponBlock = ReplicatedStorage.GUI.NormalGui.WeaponBlock:Clone()
			local NewImageLabel = Instance.new("ImageLabel")
			NewImageLabel.Size = UDim2.new(1, 0, 1, 0)
			NewImageLabel.BackgroundTransparency = 1
			NewImageLabel.Image = RarityImage.Image
			NewImageLabel.ZIndex = 12
			NewImageLabel.Parent = NewWeaponBlock
			NewWeaponBlock.TextButton:Destroy()
			NewWeaponBlock.LayoutOrder = 1
			NewWeaponBlock.Position = UDim2.new(0, 0, 0, 0)
			NewWeaponBlock.Size = UDim2.new(1, 0, 1, 0)
			if WeaponPreview:FindFirstChild("CameraCF") then
				local CameraPre = Instance.new("Camera")
				CameraPre.CFrame = WeaponPreview.CameraCF.Value
				NewWeaponBlock.ViewportFrame.CurrentCamera = CameraPre
			end
			WeaponPreview.Parent = NewWeaponBlock.ViewportFrame
			NewWeaponBlock.Parent = NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Weapon.Frame
			
			DataValues.Inputs.OpenWeaponInventory = NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Weapon.Frame.MouseButton1Down:Connect(function()
				DataValues.ReforgeMode = false
				DataValues.ReforgeButt = {}
				DataValues.ReforgeQueue = {}
				for _,input in next, DataValues.InventoryInputs do
					input:Disconnect()
					input = nil
				end
				ShowInventory("Weapons")
			end)
			
			NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Trophy.Frame:ClearAllChildren()
			
			local CurrentTrophy = MoreTrophyInfo.Object
			local RarityImage = ReplicatedStorage.Images.Textures["Rarity"..CurrentTrophy.Rarity]
			local WeaponPreview = CurrentTrophy.Model ~= nil and CurrentTrophy.Model:Clone()
			local NewWeaponBlock = ReplicatedStorage.GUI.NormalGui.WeaponBlock:Clone()
			local NewImageLabel = Instance.new("ImageLabel")
			NewImageLabel.Size = UDim2.new(1, 0, 1, 0)
			NewImageLabel.BackgroundTransparency = 1
			NewImageLabel.Image = RarityImage.Image
			NewImageLabel.ZIndex = 12
			NewImageLabel.Parent = NewWeaponBlock
			NewWeaponBlock.TextButton:Destroy()
			NewWeaponBlock.LayoutOrder = 1
			NewWeaponBlock.Position = UDim2.new(0, 0, 0, 0)
			NewWeaponBlock.Size = UDim2.new(1, 0, 1, 0)
			if WeaponPreview then
				if WeaponPreview:FindFirstChild("CameraCF") then
					local CameraPre = Instance.new("Camera")
					CameraPre.CFrame = WeaponPreview.CameraCF.Value
					NewWeaponBlock.ViewportFrame.CurrentCamera = CameraPre
				end
				WeaponPreview.Parent = NewWeaponBlock.ViewportFrame
			end
			NewWeaponBlock.Parent = NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Trophy.Frame
			
			DataValues.Inputs.OpenTrophyInventory = NEWMENU.OuterFrame.ContentWindow.Equipment.Equip.Trophy.Frame.MouseButton1Down:Connect(function()
				for _,input in next, DataValues.InventoryInputs do
					input:Disconnect()
					input = nil
				end
				ShowInventory("Trophies")
			end)
			
			for _,Gem in ipairs(NEWMENU.OuterFrame.ContentWindow.Equipment.Gemstones:GetChildren()) do
				if Gem:IsA("Frame") then
					DataValues.Inputs["Open" ..Gem.Name.. "Inventory"] = Gem.Frame.MouseButton1Down:Connect(function()
						for _,input in next, DataValues.InventoryInputs do
							input:Disconnect()
							input = nil
						end
						ShowInventory("Gems")
					end)
				end
			end
			
			DataValues.Inputs.OpenInventoryTab = NEWMENU.OuterFrame.ContentWindow.Inventory:GetPropertyChangedSignal("Visible"):Connect(function()
				if DataValues.ControllerType == "Controller" then
					DataValues.LastSelected = NEWMENU.OuterFrame.ContentWindow.Inventory.Materials.Frame
					GuiService.SelectedObject = NEWMENU.OuterFrame.ContentWindow.Inventory.Materials.Frame
				end
			end)

			DataValues.Inputs.OpenMaterialInventory = NEWMENU.OuterFrame.ContentWindow.Inventory.Materials.Frame.MouseButton1Down:Connect(function()
				for _,input in next, DataValues.InventoryInputs do
					input:Disconnect()
					input = nil
				end
				ShowInventory("Mats")
			end)
			
			DataValues.Inputs.OpenVestigesInventory = NEWMENU.OuterFrame.ContentWindow.Inventory.Vestiges.Frame.MouseButton1Down:Connect(function()
				local Height = 0

				NEWMENU.OuterFrame.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
				
				NEWMENU.EditWindow.Weapons.Inventory.UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 0)
				NEWMENU.EditWindow.Weapons.Inventory.UIGridLayout.CellSize = UDim2.new(1, 0, 0, 50)
				
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = "No Vestiges Selected"
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = "Vestiges are passives that are automatically applied to all characters."
				
				RemoveMenuItems()
				
				local Vestiges = Socket:Request("GetVestiges")
				if Vestiges then
					for _,Vestige in ipairs(Vestiges) do
						local Block = NEWMENU.OuterFrame.ContentWindow.Inventory.Vestiges:Clone()
						Block.Name = "Vestige"
						Block.Frame.Title.Text = Vestige.Name
						Block.Frame.MouseButton1Down:Connect(function()
							NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = Vestige.Name
							NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = Vestige.Description
						end)
						Block.Parent = NEWMENU.EditWindow.Weapons.Inventory
					end
				end
				InventoryGUI.Inventory.CanvasSize = UDim2.new(0, 0, 2.5, Height)
				NEWMENU.EditWindow.Weapons.Visible = true
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = false
				NEWMENU.EditWindow.Visible = true
			end)
			
			NEWMENU.OuterFrame.ContentWindow.Equipment.Skin.Skin.Frame:ClearAllChildren()
			
			Character.Archivable = true
			local SkinModel = Character:Clone()
			local CostumeBlock = ReplicatedStorage.GUI.NormalGui.CostumeBlock:Clone()
			SkinModel.Parent = CostumeBlock.ViewportFrame
			local CameraSkin = Instance.new("Camera")
			CameraSkin.CameraType = Enum.CameraType.Scriptable
			CameraSkin.CameraSubject = SkinModel.PrimaryPart
			local Pos = CFrame.new(SkinModel.PrimaryPart.Position + (SkinModel.PrimaryPart.CFrame.LookVector * 4)) * CFrame.new(0, 1, 0)
			CameraSkin.CFrame = CFrame.new(Pos.Position, SkinModel.PrimaryPart.Position)
			CameraSkin.Parent = SkinModel
			CostumeBlock.ViewportFrame.CurrentCamera = CameraSkin
			CostumeBlock.TextButton:Destroy()
			CostumeBlock.Parent = NEWMENU.OuterFrame.ContentWindow.Equipment.Skin.Skin.Frame
			
			DataValues.Inputs.OpenSkinInventory = NEWMENU.OuterFrame.ContentWindow.Equipment.Skin.Skin.Frame.MouseButton1Down:Connect(function()
				NEWMENU.OuterFrame.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Reforge.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.ModifySet.Visible = true
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.ModifySkin.Visible = false
				
				local Description = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description
				for _,Descs in ipairs(Description:GetChildren()) do
					if Descs:IsA("Frame") then
						Descs:Destroy()
					end
				end
				
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = "Skin Manager"
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = "These items are purely cosmetic and will not affect your gameplay performance."
				
				RemoveMenuItems()

				for i = 1, #DataValues.CharInfo.Skins do
					local Skin = DataValues.CharInfo.Skins[i]
					if typeof(Skin) == "table" then
						if ReplicatedStorage.Models.Armor:FindFirstChild(Skin.Name) then
							local SkinModel = ReplicatedStorage.Models.Armor[Skin.Name]:Clone()
							local CostumeBlock = ReplicatedStorage.GUI.NormalGui.CostumeBlock:Clone()
							SkinModel.Parent = CostumeBlock.ViewportFrame
							local CameraSkin = Instance.new("Camera")
							CameraSkin.CameraType = Enum.CameraType.Scriptable
							CameraSkin.CameraSubject = SkinModel.Chest1.Middle
							local Pos = SkinModel.Chest1.Middle.Position + (SkinModel.Chest1.Middle.CFrame.LookVector * 3.5) + Vector3.new(0, 0.75, 0)
							CameraSkin.CFrame = CFrame.lookAt(Pos, SkinModel.Chest1.Middle.Position)
							CameraSkin.Parent = SkinModel
							CostumeBlock.ViewportFrame.CurrentCamera = CameraSkin
							CostumeBlock.TextButton.MouseButton1Down:Connect(function()
								DataValues.CurrentSelectedCostume = Skin
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = true
							end)
							CostumeBlock.Name = Skin.Name
							CostumeBlock.Parent = NEWMENU.EditWindow.Weapons.Inventory
						end
					end
				end
				InventoryGUI.Inventory.CanvasSize = UDim2.new(0, 0, 0, InventoryGUI.Inventory.UIGridLayout.AbsoluteContentSize.Y)
				NEWMENU.EditWindow.Weapons.Visible = true
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = true
				NEWMENU.EditWindow.Visible = true
			end)

			local PModel = ReplicatedStorage.Models.Pets:FindFirstChild(DataValues.AccInfo.CurrentPet)
			if PModel then
				local PetModel = PModel:Clone()
				local PetBlock = ReplicatedStorage.GUI.NormalGui.CostumeBlock:Clone()
				PetModel.Parent = PetBlock.ViewportFrame
				local CameraSkin = Instance.new("Camera")
				CameraSkin.CameraType = Enum.CameraType.Scriptable
				CameraSkin.CameraSubject = PetModel.PrimaryPart
				local Pos = CFrame.new(PetModel.PrimaryPart.Position + (PetModel.PrimaryPart.CFrame.LookVector * 1.5))
				CameraSkin.CFrame = CFrame.new(Pos.Position, PetModel.PrimaryPart.Position)
				CameraSkin.Parent = PetModel
				PetBlock.ViewportFrame.CurrentCamera = CameraSkin
				PetBlock.TextButton:Destroy()
				PetBlock.Parent = NEWMENU.OuterFrame.ContentWindow.Equipment.Skin.Pet.Frame
			end

			DataValues.Inputs.OpenPets = NEWMENU.OuterFrame.ContentWindow.Equipment.Skin.Pet.Frame.MouseButton1Down:Connect(function()
				NEWMENU.OuterFrame.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Sell.Visible = false
				
				local Description = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description
				for _,Descs in ipairs(Description:GetChildren()) do
					if Descs:IsA("Frame") then
						Descs:Destroy()
					end
				end
				
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = "Pet Manager"
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = "Pets are cosmetics that will float near your character."
				
				RemoveMenuItems()

				local CostumeBlock = ReplicatedStorage.GUI.NormalGui.CostumeBlock:Clone()
				CostumeBlock.TextButton.MouseButton1Down:Connect(function()
					Socket:Emit("PetChange", "Nothing")
					Hint("Removed pet!")
				end)
				CostumeBlock.Parent = NEWMENU.EditWindow.Weapons.Inventory

				for _, Pet in ipairs(DataValues.AccInfo.Pets) do
					local pPet = ReplicatedStorage.Models.Pets:FindFirstChild(Pet)
					if pPet then
						local PetModel = pPet:Clone()
						local CostumeBlock = ReplicatedStorage.GUI.NormalGui.CostumeBlock:Clone()
						PetModel.Parent = CostumeBlock.ViewportFrame
						local CameraSkin = Instance.new("Camera")
						CameraSkin.CameraType = Enum.CameraType.Scriptable
						CameraSkin.CameraSubject = PetModel.PrimaryPart
						local Pos = PetModel.PrimaryPart.Position + (PetModel.PrimaryPart.CFrame.LookVector * 1.5)
						CameraSkin.CFrame = CFrame.lookAt(Pos, PetModel.PrimaryPart.Position)
						CameraSkin.Parent = PetModel
						CostumeBlock.ViewportFrame.CurrentCamera = CameraSkin
						CostumeBlock.TextButton.MouseButton1Down:Connect(function()
							Socket:Emit("PetChange", Pet)
							Hint(string.format("%s Pet equipped!", Pet))
						end)
						CostumeBlock.Name = Pet
						CostumeBlock.Parent = NEWMENU.EditWindow.Weapons.Inventory
					end
				end
				InventoryGUI.Inventory.CanvasSize = UDim2.new(0, 0, 0, InventoryGUI.Inventory.UIGridLayout.AbsoluteContentSize.Y)
				NEWMENU.EditWindow.Weapons.Visible = true
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = true
				NEWMENU.EditWindow.Visible = true
			end)
			
			DataValues.Inputs.OpenAuras = NEWMENU.OuterFrame.ContentWindow.Equipment.Skin.Auras.Frame.MouseButton1Down:Connect(function()
				if #DataValues.AccInfo.WeaponAuras <= 0 and #DataValues.AccInfo.CharacterAuras <= 0 then
					Hint("You currently do not own any auras.")
				end
			end)

			DataValues.Inputs.Dailies = NEWMENU.OuterFrame.ContentWindow.Achievements.MissionTab.Daily.MouseButton1Down:Connect(function()
				NEWMENU.OuterFrame.ContentWindow.Achievements.DailyAchievementFrame.Visible = true
				NEWMENU.OuterFrame.ContentWindow.Achievements.WeeklyAchievementFrame.Visible = false
				NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame.Visible = false
			end)

			DataValues.Inputs.Weeklies = NEWMENU.OuterFrame.ContentWindow.Achievements.MissionTab.Weekly.MouseButton1Down:Connect(function()
				NEWMENU.OuterFrame.ContentWindow.Achievements.DailyAchievementFrame.Visible = false
				NEWMENU.OuterFrame.ContentWindow.Achievements.WeeklyAchievementFrame.Visible = true
				NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame.Visible = false
			end)

			DataValues.Inputs.All = NEWMENU.OuterFrame.ContentWindow.Achievements.MissionTab.All.MouseButton1Down:Connect(function()
				NEWMENU.OuterFrame.ContentWindow.Achievements.DailyAchievementFrame.Visible = false
				NEWMENU.OuterFrame.ContentWindow.Achievements.WeeklyAchievementFrame.Visible = false
				NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame.Visible = true
			end)
			
			DataValues.Inputs.OpenAchievements = NEWMENU.OuterFrame.ContentWindow.Achievements:GetPropertyChangedSignal("Visible"):Connect(function()
				if DataValues.ControllerType == "Controller" and NEWMENU.OuterFrame.ContentWindow.Achievements.Claim.Visible then
					DataValues.LastSelected = NEWMENU.OuterFrame.ContentWindow.Achievements.Claim
					GuiService.SelectedObject = NEWMENU.OuterFrame.ContentWindow.Achievements.Claim
				end
				NEWMENU.OuterFrame.ContentWindow.Achievements.DailyAchievementFrame.Visible = true
				NEWMENU.OuterFrame.ContentWindow.Achievements.WeeklyAchievementFrame.Visible = false
				NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame.Visible = false
				NEWMENU.OuterFrame.ContentWindow.Achievements.Info.TextTransparency = 1
				NEWMENU.OuterFrame.ContentWindow.Achievements.Info.Text = "( Click tile for reward info )" 
				TweenService:Create(NEWMENU.OuterFrame.ContentWindow.Achievements.Info,TweenInfo.new(.75),{TextTransparency = 0}):Play()
				
				local Invent = NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame:GetChildren()
				for i = 1, #Invent do
					if not Invent[i]:IsA("UIListLayout") then
						Invent[i]:Destroy()
					end
				end
				local Invent = NEWMENU.OuterFrame.ContentWindow.Achievements.DailyAchievementFrame:GetChildren()
				for i = 1, #Invent do
					if not Invent[i]:IsA("UIListLayout") then
						Invent[i]:Destroy()
					end
				end
				local Invent = NEWMENU.OuterFrame.ContentWindow.Achievements.WeeklyAchievementFrame:GetChildren()
				for i = 1, #Invent do
					if not Invent[i]:IsA("UIListLayout") then
						Invent[i]:Destroy()
					end
				end
				NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame.CanvasPosition = Vector2.new(0,0)
				local GetAchievementInfos = Tabl.AchievementList and Tabl.AchievementList or Socket:Request("GetAchievements")
				if GetAchievementInfos then
					for i = 1, #DataValues.AccInfo.Achievements do
						local Achievement = DataValues.AccInfo.Achievements[i]
						for v = 1, #GetAchievementInfos do
							local AchInfo = GetAchievementInfos[v]
							local hasAttributes = AchInfo.Attributes
							if Achievement.I == AchInfo.ID then --- Just to see if its the right one
								local AchBlock = NEWMENU.OuterFrame.ContentWindow.Achievements.Template.AchievementBlock:Clone()
								if Achievement.C == 0 then
									AchBlock.Main.ProgressBar.Bar.Size = UDim2.new(0.98 * (Achievement.V / AchInfo.MaxValue), 0, 0.7, 0)
									AchBlock.Main.ProgressBar.Namer.Text = string.format("%s / %s", Achievement.V, AchInfo.MaxValue)
									AchBlock.Main.Frame.Title.Text = AchInfo.Name
									if Achievement.V > 0 then
										AchBlock.LayoutOrder = AchInfo.ID - (1000 * (1 + (Achievement.V / AchInfo.MaxValue)))
									else
										AchBlock.LayoutOrder = AchInfo.ID
									end
								else
									AchBlock.Main.ProgressBar.Bar.Size = UDim2.new(.98, 0, .7, 0)
									AchBlock.Main.ProgressBar.Namer.Text = AchInfo.MaxValue .. " / " ..AchInfo.MaxValue
									AchBlock.Main.Frame.Title.Text = string.format("%s [Completed]", AchInfo.Name)
									AchBlock.LayoutOrder = AchInfo.ID + 1000
								end
								AchBlock.Main.Frame.MouseButton1Down:Connect(function()
									if AchBlock.Main.Frame.Title.Visible then --- Main Mode
										AchBlock.Main.Frame.Title.Visible = false
										AchBlock.Main.ProgressBar.Visible = false
										
										for _,OtherRewards in ipairs(AchBlock.Switch.Rewards:GetChildren()) do
											if not OtherRewards:IsA("UIGridLayout") then
												OtherRewards:Destroy()
											end
										end
										
										for Index, Value in pairs(AchInfo.Reward) do
											if Index == "Gold" or Index == "Tears" then
												local Block = AchBlock.Switch.Template[Index]:Clone()
												Block.Price.Text = tostring(format_int(Value))
												Block.Visible = true
												Block.Parent = AchBlock.Switch.Rewards
											elseif Index == "Infusions" then
												local Block = AchBlock.Switch.Template["Enchant"]:Clone()
												Block.TitleReward.Text = Socket:Request("GetSkill", Value).Name
												Block.Visible = true
												Block.Parent = AchBlock.Switch.Rewards
											elseif Index == "Titles" then
												local Block = AchBlock.Switch.Template["Title"]:Clone()
												Block.TitleReward.Text = Value
												Block.Visible = true
												Block.Parent = AchBlock.Switch.Rewards
											elseif Index == "Vestiges" then
												local Block = AchBlock.Switch.Template["Vestige"]:Clone()
												Block.TitleReward.Text = Socket:Request("GetVestige", Value).Name
												Block.Visible = true
												Block.Parent = AchBlock.Switch.Rewards
											end
										end
										
										AchBlock.Switch.Rewards.Visible = true
										AchBlock.Switch.Title.Visible = true
									else
										AchBlock.Main.Frame.Title.Visible = true
										AchBlock.Main.ProgressBar.Visible = true
										AchBlock.Switch.Rewards.Visible = false
										AchBlock.Switch.Title.Visible = false
									end
								end)
								AchBlock.Visible = true
								AchBlock.Parent = AchInfo.Attributes and NEWMENU.OuterFrame.ContentWindow.Achievements[string.format("%sAchievementFrame", AchInfo.Attributes[1])] or NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame

								if hasAttributes and not table.find(DataValues.AccInfo[string.format("%sAchievements", AchInfo.Attributes[1])], Achievement.I) then
									AchBlock:Destroy()
								end
								break
							end
						end
					end
				end
				NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame.CanvasSize = UDim2.new(0, 0, 0, NEWMENU.OuterFrame.ContentWindow.Achievements.AchievementFrame.UIListLayout.AbsoluteContentSize.Y)
				NEWMENU.OuterFrame.ContentWindow.Achievements.DailyAchievementFrame.CanvasSize = UDim2.new(0, 0, 0, NEWMENU.OuterFrame.ContentWindow.Achievements.DailyAchievementFrame.UIListLayout.AbsoluteContentSize.Y)
				NEWMENU.OuterFrame.ContentWindow.Achievements.WeeklyAchievementFrame.CanvasSize = UDim2.new(0, 0, 0, NEWMENU.OuterFrame.ContentWindow.Achievements.WeeklyAchievementFrame.UIListLayout.AbsoluteContentSize.Y)
			end)
			
			DataValues.Inputs.OpenTitle = NEWMENU.OuterFrame.ContentWindow.Character.Title.Frame.MouseButton1Down:Connect(function()
				if bools.PlayingTutorial then
					return
				end
				local BannerGUI = NEWMENU.EditWindow.Titles
				for _,Banner in ipairs(BannerGUI.Titles:GetChildren()) do
					if Banner:IsA("TextButton") then
						Banner:Destroy()
					end
				end
				local TitleInfo = Socket:Request("GetTitles")
				local BannerClone1 = ReplicatedStorage.GUI.NormalGui.TitleText:Clone()
				BannerClone1.Text = "None"
				BannerClone1.MouseButton1Click:Connect(function()
					Socket:Emit("UpdateTitle", "None")
					Hint("Title set! Press Return to review your changes.")
				end)
				BannerClone1.Parent = BannerGUI.Titles
				for _,Banner in ipairs(DataValues.AccInfo.ChatTitles) do
					local BannerClone = ReplicatedStorage.GUI.NormalGui.TitleText:Clone()
					BannerClone.Text = Banner
					for _,tet in ipairs(TitleInfo) do
						if tet.Name == Banner then
							BannerClone.TextColor3 = tet.Color
							BannerClone.MouseEnter:Connect(function()
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = Banner
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = tet.Description
							end)
							break
						end
					end
					BannerClone.MouseButton1Click:Connect(function()
						Socket:Emit("UpdateTitle", Banner)
						Hint("Title set! Press Return to review your changes.")
					end)
					BannerClone.Parent = BannerGUI.Titles
				end
				NEWMENU.OuterFrame.Visible = false
				NEWMENU.EditWindow.Titles.Visible = true
				NEWMENU.EditWindow.Visible = true
			end)
			
			DataValues.Inputs.OpenBanners = NEWMENU.OuterFrame.ContentWindow.Character.Banner.Frame.MouseButton1Down:Connect(function()
				if bools.PlayingTutorial then
					return
				end
				local BannerGUI = NEWMENU.EditWindow.Banners
				for _,Banner in ipairs(BannerGUI.Banners:GetChildren()) do
					if Banner:IsA("ImageButton") then
						Banner:Destroy()
					end
				end
				BannerGUI.Visible = true
				for _,Banner in ipairs(DataValues.AccInfo.Titles) do
					if ReplicatedStorage.Images.Banners:FindFirstChild(Banner) then
						local BannerClone = ReplicatedStorage.Images.BannerImg:Clone()
						BannerClone.Image = ReplicatedStorage.Images.Banners[Banner].Image
						BannerClone.MouseButton1Click:Connect(function()
							Socket:Emit("UpdateBanner", Banner)
							Hint("Banner set! Press Return to review your changes.")
						end)
						BannerClone.MouseEnter:Connect(function()
							NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = "Decorative Banner"
							NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = "A banner that appears on your Player Card and displays upon accomplishing feats such as scoring the first hit in a mission."
						end)
						BannerClone.Parent = BannerGUI.Banners
						if ReplicatedStorage.Images.Banners[Banner]:FindFirstChild("Width") and ReplicatedStorage.Images.Banners[Banner]:FindFirstChild("NumOfSprites") then
							BannerClone.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[Banner].Width.Value.X,0)
							BannerClone.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[Banner].Width.Value.X,ReplicatedStorage.Images.Banners[Banner].Width.Value.Y)
							FS.spawn(function()
								local CanContinue = true
								FS.spawn(function()
									while wait(.3) and CanContinue do
										if not BannerGUI.Visible then
											CanContinue = false
										end
									end
								end)
								while BannerGUI.Visible and CanContinue do
									BannerClone.ImageRectOffset = Vector2.new(-ReplicatedStorage.Images.Banners[Banner].Width.Value.X,0)
									BannerClone.ImageRectSize = Vector2.new(ReplicatedStorage.Images.Banners[Banner].Width.Value.X,ReplicatedStorage.Images.Banners[Banner].Width.Value.Y)
									local NumOfSpritesX = ReplicatedStorage.Images.Banners[Banner].NumOfSprites.Value.X ~= 0 and ReplicatedStorage.Images.Banners[Banner].NumOfSprites.Value.X or 3
									local NumOfSpritesY = ReplicatedStorage.Images.Banners[Banner].NumOfSprites.Value.Y ~= 0 and ReplicatedStorage.Images.Banners[Banner].NumOfSprites.Value.Y or 9
									Animate(BannerClone, false, NumOfSpritesX, NumOfSpritesY, ReplicatedStorage.Images.Banners[Banner].Framerate.Value, 0,0, ReplicatedStorage.Images.Banners[Banner].Maxframes.Value)
								end
							end)
						end
					end
				end
				BannerGUI.Banners.CanvasPosition = Vector2.new(0, 0)
				BannerGUI.Banners.CanvasSize = UDim2.new(0, 0, 0, BannerGUI.Banners.UIListLayout.AbsoluteContentSize.Y)
				
				NEWMENU.OuterFrame.Visible = false
				NEWMENU.EditWindow.Visible = true
			end)
			
			DataValues.Inputs.SkillMenu = NEWMENU.OuterFrame.ContentWindow.Character.Skills.Frame.MouseButton1Down:Connect(function()
				if bools.PlayingTutorial then
					return
				end
				local SkillsGUI = NEWMENU.EditWindow.Skills
				local SkillInformation = Socket:Request("getSkillInfo", nil, Inspect==nil and nil or Inspect)
				
				DataValues.CurrentSelectedSkill = nil
				
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Money.SkillPoints.Price.Text = tostring(format_int(DataValues.CharInfo.SkillPoints))
									
				local ComboMaker = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.ComboMaker
				local SkillLoadout = DataValues.CharInfo.SkillsLoadOut
				local LevelTable = {
					{Level = 60, B = 1, I = 2}, {Level = 90, B = 1, I = 3}, {Level = 70, B = 2, I = 2}, {Level = 100, B = 2, I = 3}, {Level = 120, B = 3, I = 2}, {Level = 140, B = 3, I = 3}
				}
				
				local function UpdateRow(skillList, b)
					local ChainCooldown = 0
					local SkillCount = 0
					local comboSleeve = ComboMaker["Combo" ..b]
					
					for _, attribute in ipairs(comboSleeve.BonusAttributes:GetChildren()) do
						if attribute:IsA("TextLabel") then
							attribute:Destroy()
						end
					end
					
					for _, skill in pairs(skillList) do
						if skill and skill.IsActive then
							SkillCount += 1
							if skill.Cooldown > 0 then
								ChainCooldown += skill.Cooldown
							end
						end
					end
					
					local AdditionalDamage = b == 1 and (SkillCount <= 2 and 1*SkillCount or 5) or b == 2 and (SkillCount <= 2 and 4*SkillCount or 15) or (SkillCount <= 2 and 10*SkillCount or 40)
					ChainCooldown *= 1-((SkillCount-1) * (b * .05))
					
					if ChainCooldown > 0 then
						local attribute = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Assets.BonusAttribute:Clone()
						attribute.Text = string.format("Chain Cooldown: %s", round(ChainCooldown, 2).. " sec")
						attribute.TextColor3 = Color3.fromRGB(132, 94, 94)
						attribute.Visible = true
						attribute.Parent = comboSleeve.BonusAttributes
					end
					if SkillCount > 0 then
						local attribute = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Assets.BonusAttribute:Clone()
						attribute.Text = string.format("Bonus: +%s", AdditionalDamage.. "% ATK")
						attribute.Visible = true
						attribute.Parent = comboSleeve.BonusAttributes
						--[[
						if SkillCount == 3 and ChainCooldown > 0 then
							local attribute = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Assets.BonusAttribute:Clone()
							attribute.Text = "-25% CD at end chain"
							attribute.Visible = true
							attribute.Parent = comboSleeve.BonusAttributes
						end
						--]]
					end
				end
				
				local TempLabelY
				if DataValues.ControllerType == "Keyboard" then
					TempLabelY = PlatformButtons:GetImageLabel("ButtonY", "Light", "PC")
				elseif DataValues.ControllerType == "Controller" then
					TempLabelY = PlatformButtons:GetImageLabel("ButtonY", "Light", "XboxOne")
				elseif DataValues.ControllerType == "Touch" then
					TempLabelY = ContextActionService:GetButton("MouseButton2"):Clone()
				end
				
				local TempLabelX
				if DataValues.ControllerType == "Keyboard" then
					TempLabelX = PlatformButtons:GetImageLabel("ButtonX", "Light", "PC")
				elseif DataValues.ControllerType == "Controller" then
					TempLabelX = PlatformButtons:GetImageLabel("ButtonX", "Light", "XboxOne")
				elseif DataValues.ControllerType == "Touch" then
					TempLabelX = ContextActionService:GetButton("MouseButton1"):Clone()
				end
				
					--- 'b' is row. 'i' is column.
				for b = 1, 3 do
					local ComboSleeve = ComboMaker["Combo" ..b]
					local SkillList = {}
					if b >= 2 then
						---- This just sets the placeholder images for the first input
						ComboSleeve.AttackDefault.Attack.Image = TempLabelX.Image
						ComboSleeve.AttackDefault.Attack.ImageRectOffset = TempLabelX.ImageRectOffset
						ComboSleeve.AttackDefault.Attack.ImageRectSize = TempLabelX.ImageRectSize
						if TempLabelX:FindFirstChild("ActionTitle") then
							ComboSleeve.AttackDefault.Attack:ClearAllChildren()
							TempLabelX.ActionTitle:Clone().Parent = ComboSleeve.AttackDefault.Attack
						end
					end
					for i = 1, 3 do
						local SkillSlot = SkillLoadout["C"..b][i]
						ComboSleeve["Attack" ..i].ButtonPrompt.Attack.Image = TempLabelY.Image
						ComboSleeve["Attack" ..i].ButtonPrompt.Attack.ImageRectOffset = TempLabelY.ImageRectOffset
						ComboSleeve["Attack" ..i].ButtonPrompt.Attack.ImageRectSize = TempLabelY.ImageRectSize
						if TempLabelY:FindFirstChild("ActionTitle") then
							ComboSleeve["Attack" ..i].ButtonPrompt.Attack:ClearAllChildren()
							TempLabelY.ActionTitle:Clone().Parent = ComboSleeve["Attack" ..i].ButtonPrompt.Attack
						end
						if i >= 2 then
							ComboSleeve["Attack" ..i].Limit.Visible = true
						end
						for _,Lvls in ipairs(LevelTable) do
							if DataValues.CharInfo.CurrentLevel >= Lvls.Level and b == Lvls.B and i == Lvls.I then
								ComboSleeve["Attack" ..i].Limit.Visible = false
								break
							end
						end
						DataValues.Inputs["Combo"..b.."Attack"..i] = ComboSleeve["Attack" ..i].ImageButton.MouseButton1Down:Connect(function()
							if DataValues.CurrentSelectedSkill then
								local EquippedSkill, ReturnedSkill, Slot = Socket:Request("ModifySkill", {DataValues.CurrentSelectedSkill, b, i})
								if EquippedSkill == "Equipped" then
									Hint("Equipped Skill to slot!")
									for _, Animations in ipairs(ReplicatedStorage.Scripts.ClassAnimateScripts[DataValues.AccInfo.CurrentClass].attackY:GetChildren()) do
										if Animations:IsA("Animation") and Animations.AnimationId == ReturnedSkill.AnimId then
											ComboSleeve["Attack" ..Slot].ImageButton.Image = ReturnedSkill.ImageIcon == "" and "rbxassetid://4273128035" or ReturnedSkill.ImageIcon
											SkillList[Slot] = ReturnedSkill
											break
										end
									end
								elseif EquippedSkill == "Removed" then
									Hint("Unequipped skill!")
									ComboSleeve["Attack" ..Slot].ImageButton.Image = "rbxassetid://4273128035"
									SkillList[Slot] = nil
								elseif EquippedSkill == "Locked" then
									Hint("Requires Level " .. Slot .. " to unlock this skill slot!")
								elseif EquippedSkill == "Duplicate" then
									Hint("Cannot have duplicate skill in the same attack chain.")
								end
								UpdateRow(SkillList, b)
							end
						end)
						if SkillSlot ~= nil then
							local NewS = Socket:Request("getSkillInfo", SkillSlot, Inspect==nil and nil or Inspect)
							for _, Animations in ipairs(ReplicatedStorage.Scripts.ClassAnimateScripts[DataValues.AccInfo.CurrentClass].attackY:GetChildren()) do
								if Animations:IsA("Animation") and Animations.AnimationId == NewS.AnimId then
									ComboSleeve["Attack" ..i].ImageButton.Image = NewS.ImageIcon == "" and "rbxassetid://4273128035" or NewS.ImageIcon
									SkillList[i] = NewS
									break
								end
							end
						else
							ComboSleeve["Attack" ..i].ImageButton.Image = "rbxassetid://4273128035"
						end
						UpdateRow(SkillList, b)
					end
				end
				TempLabelY:Destroy()
				TempLabelX:Destroy()
				
				local function OpenSkillList(Type)
					if not StoryTeller:Check(DataValues.AccInfo.StoryProgression, Type) then
						Socket:Emit("Story", Type)
						table.insert(DataValues.AccInfo.StoryProgression, Type)
						PlayTutorialMsg(Type)
					end
					local SkillNo = 0
					for _, Banner in ipairs(SkillsGUI.Inventory:GetChildren()) do
						if Banner:IsA("Frame") then
							Banner:Destroy()
						end
					end
					for _, Skills in ipairs(SkillInformation) do
						if Skills ~= nil then
							local Rank = Skills.Rank
							local SkillBlock = SkillsGUI.Assets.SkillBlock:Clone()
							SkillBlock.Info.Value = Skills.Description
							SkillBlock.Details.InfoBar.Rank.Text = (Rank <= 8 and "Rank" or "Exceed")
							SkillBlock.Details.InfoBar.RankVal.Text = (Rank==0 and "F") or (Rank==1 and "E") or (Rank==2 and "D") or (Rank==3 and "C") or (Rank==4 and "B") or (Rank==5 and "A") or (Rank==6 and "S") or (Rank==7 and "SS") or (Rank==8 and "SSS") or (Rank>8 and tostring(Rank-8))
							SkillBlock.Details.InfoBar.CostValueFrame.CostVal.Text = tostring(Rank < 23 and 4*(Rank+1) or "N/A")
							SkillBlock.Details.TitleBar.Title.Text = Skills.Name
							SkillBlock.Details.InfoBar.TypeVal.Text = (Skills.IsActive and "Active" or "Passive")
							SkillBlock.LayoutOrder = Skills.LevelReq
							if Skills.IsActive then
								if Type == "Actives" then
									SkillBlock.Visible = true
								end 
							elseif not Skills.IsActive and Type == "Passives" and Skills.PercentageIncrease ~= nil then
								SkillBlock.Visible = true
							elseif Skills.PercentageIncrease == nil then						--- Class Passive
								if Type == "ClassPassives" then
									SkillBlock.Visible = true
								end 
							end
							SkillBlock.Warning.Bottom.Learn.Visible = Inspect==nil and true or false
							local function UpdateSkillInfo(JustLearned)
								local LearnedActive = JustLearned and JustLearned or false
								local NewCharInfo = Socket:Request("getCharacterInfo", Inspect==nil and nil or Inspect)
								if NewCharInfo then
									if Inspect == nil then
										DataValues.CharInfo = NewCharInfo
									end
									for i=1,#NewCharInfo.Skills do
										local NewSkill = NewCharInfo.Skills[i]
										if NewSkill.Name == Skills.Name then
											local NewS = Socket:Request("getSkillInfo", NewSkill.Name, Inspect==nil and nil or Inspect)
											if NewS ~= nil then
												Rank = NewSkill.Rank
												Skills = NewS
												break
											end
										end
									end
								end
								DataValues.CurrentSelectedSkill = Skills
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Title.Text = Skills.Name
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Description.Description.Text = "Click Upgrade to increase your skill potency or Equip to slot it into a combo chain."
								if NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description:FindFirstChild("SkillDescription") then
									NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description.SkillDescription:Destroy()
								end
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.ComboMaker.Visible = false
								NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.PreviewCombos.Visible = false
								
								local SkillInfo = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Assets.SkillDescription:Clone()
								SkillInfo.Title.Text = SkillBlock.Info.Value.. (Skills.PercentageIncrease == nil and "" or ( "\n\nCurrent: " .. tostring(round((Skills.PercentageIncrease[Rank+1])*100,2)) .. "" .. Skills.Prefix.. "\nNext: " .. tostring(Rank < 23 and tostring(round((Skills.PercentageIncrease[Rank+2])*100,2)) or "N/A") .. "" .. Skills.Prefix .."\nFP Cost: " .. tostring(Rank < 23 and 4*(Rank+1) or "N/A")))
								SkillInfo.Visible = true
								SkillInfo.Parent = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description
								if Inspect==nil then
									NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Upgrade.Visible = Rank <23 and true or false
								else
									NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Upgrade.Visible = false
								end
								if Skills.IsActive then
									NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Title.Text = "Equip"
									NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = Skills.Unlocked and true or false
								else
									NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
								end
							end
							
							if Skills.Unlocked then
								SkillBlock.Warning.Visible = false
							else
								if DataValues.CharInfo.CurrentLevel >= Skills.LevelReq then
									SkillBlock.Warning.Title.TextColor3 = Color3.new(0,1,0)
								end
								SkillBlock.Warning.Title.Text = string.format("Level Required: %s", Skills.LevelReq)
								SkillBlock.Warning.Bottom.Gold.Price.Text = tostring(Skills.Cost)
								if DataValues.LearnInputs[Skills.Name] ~= nil then
									DataValues.LearnInputs[Skills.Name]:Disconnect()
									DataValues.LearnInputs[Skills.Name] = nil
								end
								DataValues.LearnInputs[Skills.Name] = SkillBlock.Warning.Bottom.Learn.MouseButton1Down:connect(function()
									local success,curgold = Socket:Request("LearnSkill", Skills.Name)
									if success == "NoGold" then
										Hint("Insufficient gold to learn skill!")
									elseif success == "LowLevel" then
										Hint("You must be Level " ..Skills.LevelReq.. " to learn this!")
									elseif success then
										Skills.Unlocked = true
										SkillBlock.Warning.Visible = false
										Hint("Successfully purchased skill!")
										ReplicatedStorage.Sounds.SFX.UI.LearnSkill:Play()
										NEWMENU.EditWindow.NotHide.AnalyzeWindow.Money.Gold.Price.Text = tostring(format_int(DataValues.AccInfo.Gold))
										DataValues.AccInfo = Socket:Request("getAccountInfo")
										DataValues.CharInfo = Socket:Request("getCharacterInfo")
										NEWMENU.EditWindow.NotHide.AnalyzeWindow.Money.SkillPoints.Price.Text = tostring(format_int(DataValues.CharInfo.SkillPoints))
										UpdateSkillInfo(true)
									end
								end)
							end
							
							if Skills.ImageIcon ~= "" then
								SkillBlock.Details.TitleBar.RMB.Image = Skills.ImageIcon
							end
							
							SkillBlock.Name = SkillNo.. "" ..Skills.Name
							SkillNo = SkillNo + 1
							if DataValues.SkillInputs[Skills.Name] ~= nil then
								DataValues.SkillInputs[Skills.Name]:Disconnect()
								DataValues.SkillInputs[Skills.Name] = nil
							end
							DataValues.SkillInputs[Skills.Name] = SkillBlock.TextButton.MouseButton1Down:Connect(function()
								UpdateSkillInfo()
							end)
							SkillBlock.Parent = SkillsGUI.Inventory
						end
					end
					SkillsGUI.Inventory.CanvasSize = UDim2.new(0, 0, 0, SkillsGUI.Inventory.UIGridLayout.AbsoluteContentSize.Y)
				end
				
				for _,v in ipairs(SkillsGUI.Buttons:GetChildren()) do
					if v:IsA("TextButton") then
						DataValues.Inputs[v.Name] = v.MouseButton1Down:Connect(function()
							OpenSkillList(v.Name)
						end)
					end
				end
				
				OpenSkillList("ClassPassives")
				NEWMENU.OuterFrame.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = true
				NEWMENU.EditWindow.Skills.Visible = true
				NEWMENU.EditWindow.Visible = true
			end)
			
			DataValues.Inputs.Options = NEWMENU.OuterFrame.ContentWindow.Settings:GetPropertyChangedSignal("Visible"):Connect(function()
				local Options = DataValues.Options
				local Settings = NEWMENU.OuterFrame.ContentWindow.Settings
				
				if Settings.Visible then
					if DataValues.ControllerType == "Touch" then
						Settings.Size = UDim2.new(0.9, 0, 1, 0)
						Settings.Position = UDim2.new(0.025, 0, 0, 0)
					end
					
					for _, input in pairs(DataValues.SettingInputs) do
						input:Disconnect()
						input = nil
					end
					
					for _, Buttons in ipairs(Settings.TopBar:GetChildren()) do
						if Buttons:IsA("TextButton") then
							Buttons.Title.TextColor3 = Color3.fromRGB(134, 134, 134)
							DataValues.SettingInputs[Buttons.Name] = Buttons.MouseButton1Down:Connect(function()
								for _, Buttons2 in ipairs(Settings.TopBar:GetChildren()) do
									if Buttons2:IsA("TextButton") then
										Settings.SideBar[Buttons2.Name].Visible = false
										Buttons2.Title.TextColor3 = Color3.fromRGB(134, 134, 134)
									end
								end
								Settings.SideBar[Buttons.Name].Visible = true
								Buttons.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
							end)
						end
					end
					
					local function UpdateSetting(Setting, Clipped, IsChanged)
						if Setting.Name == "LobbyShadowSmall" then
							if IsChanged then
								Options.LobbyShadowSmall = (Options.LobbyShadowSmall == false and true or false)

								for _, part in ipairs(CollectionService:GetTagged("ShadowObjectsSmall")) do
									part.CastShadow = Options.LobbyShadowSmall
								end
							end
							if Options.LobbyShadowSmall == false then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							elseif Options.LobbyShadowSmall == true then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "LobbyShadowMedium" then
							if IsChanged then
								Options.LobbyShadowMedium = (Options.LobbyShadowMedium == false and true or false)

								for _, part in ipairs(CollectionService:GetTagged("ShadowObjectsMedium")) do
									part.CastShadow = Options.LobbyShadowMedium
								end
							end
							if Options.LobbyShadowMedium == false then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							elseif Options.LobbyShadowMedium == true then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "LobbyShadowLarge" then
							if IsChanged then
								Options.LobbyShadowLarge = (Options.LobbyShadowLarge == false and true or false)

								for _, part in ipairs(CollectionService:GetTagged("ShadowObjectsLarge")) do
									part.CastShadow = Options.LobbyShadowLarge
								end
							end
							if Options.LobbyShadowLarge == false then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							elseif Options.LobbyShadowLarge == true then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						end

						if Setting.Name == "FOVCombat" then
							if IsChanged then
								Numbers.CombatFov = (
									Numbers.CombatFov == 60 and 70 or
									Numbers.CombatFov == 70 and 80 or
									Numbers.CombatFov == 80 and 90 or
									60
								)
								Options.CombatFov = Numbers.CombatFov
							end
							for _, Toggler in ipairs(Clipped.Toggle:GetChildren()) do
								if Toggler:IsA("TextLabel") then
									Toggler.TextColor3 = Color3.fromRGB(134, 134, 134)
									if tostring(Numbers.CombatFov) == Toggler.Text then
										Toggler.TextColor3 = Color3.fromRGB(255, 246, 146)
									end
								end
							end
						elseif Setting.Name == "FOVLobby" then
							if IsChanged then
								Numbers.LobbyFov = (
									Numbers.LobbyFov == 50 and 60 or
									Numbers.LobbyFov == 60 and 70 or
									Numbers.LobbyFov == 70 and 80 or
									50
								)
								Options.LobbyFov = Numbers.LobbyFov
							end
							for _, Toggler in ipairs(Clipped.Toggle:GetChildren()) do
								if Toggler:IsA("TextLabel") then
									Toggler.TextColor3 = Color3.fromRGB(134, 134, 134)
									if tostring(Numbers.LobbyFov) == Toggler.Text then
										Toggler.TextColor3 = Color3.fromRGB(255, 246, 146)
									end
								end
							end
						elseif Setting.Name == "PopperCam" then
							if IsChanged then
								Options.PopperCam = (Options.PopperCam == false and true or false)
							end
							if Options.PopperCam == false then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							elseif Options.PopperCam == true then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "Smoothing" then
							if IsChanged then
								Options.CameraSmoothing = (
									Options.CameraSmoothing == 1 and 0 or
									Options.CameraSmoothing == 0 and 0.5 or
									1
								)
							end
							if Options.CameraSmoothing == 1 then
								Clipped.Toggle["3"].TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle["2"].TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle["1"].TextColor3 = Color3.fromRGB(134, 134, 134)
							elseif Options.CameraSmoothing == 0.5 then
								Clipped.Toggle["3"].TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle["2"].TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle["1"].TextColor3 = Color3.fromRGB(134, 134, 134)
							else
								Clipped.Toggle["3"].TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle["2"].TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle["1"].TextColor3 = Color3.fromRGB(255, 246, 146)
							end
						elseif Setting.Name == "CombatEffect" then
							if IsChanged then
								Options.ParticleEffects = (Options.ParticleEffects == false and true or false)
							end
							if Options.ParticleEffects == false then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							else
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "RainEffect" then
							if IsChanged then
								Options.RainEffects = (Options.RainEffects == false and true or false)
							end
							if Options.RainEffects == false then
								RainAPI:StopRain()
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							else
								RainAPI:StartRain()
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "CumulativeAnim" then
							if IsChanged then
								Options.NumberAnim = (Options.NumberAnim == false and true or false)
							end
							if Options.NumberAnim == false then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							else
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "DamageIndicator" then
							if IsChanged then
								Options.DamageIndicator = (Options.DamageIndicator == false and true or false)
							end
							if Options.DamageIndicator == false then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							else
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "CumulativeNumber" then
							if IsChanged then
								Options.CumulativeNum = (Options.CumulativeNum == false and true or false)
							end
							if Options.CumulativeNum == false then
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							else
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "CustomMusic" then
							if IsChanged then
								Options.PlayMusic = (Options.PlayMusic == false and true or false)
							end
							if Options.PlayMusic == false then
								MusicPlayer:Stop(2)
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(134, 134, 134)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(255, 246, 146)
							else
								Clipped.Toggle.Yes.TextColor3 = Color3.fromRGB(255, 246, 146)
								Clipped.Toggle.No.TextColor3 = Color3.fromRGB(134, 134, 134)
							end
						elseif Setting.Name == "BackgroundPicture" then
							local ProfileBGs = ReplicatedStorage.Images.ProfileBackground
							if IsChanged then
								for _, imageButton in ipairs(NEWMENU.EditWindow.ProfileBackgrounds.Inventory:GetChildren()) do
									if imageButton:IsA("ImageButton") then
										imageButton:Destroy()
									end
								end
								
								for _, BGs in ipairs(DataValues.AccInfo.CardBackgrounds) do
									local CardBG = ProfileBGs:FindFirstChild(BGs)
									if CardBG then
										local NewBG = NEWMENU.EditWindow.ProfileBackgrounds.Template.BG:Clone()
										NewBG.Image = CardBG.Image
										NewBG.MouseButton1Down:Connect(function()
											Clipped.Toggle.Image = NewBG.Image
											Socket:Emit("UpdateBackground", BGs)
											Hint("Background set! Press return to see changes.")
										end)
										NewBG.Visible = true
										NewBG.Parent = NEWMENU.EditWindow.ProfileBackgrounds.Inventory
									end
								end
								
								NEWMENU.EditWindow.ProfileBackgrounds.Inventory.CanvasSize = UDim2.new(0, 0, 0, NEWMENU.EditWindow.ProfileBackgrounds.Inventory.UIListLayout.AbsoluteContentSize.Y)
								NEWMENU.EditWindow.ProfileBackgrounds.Inventory.CanvasPosition = Vector2.new(0,0)
								
								NEWMENU.EditWindow.ProfileBackgrounds.Visible = true
								NEWMENU.EditWindow.Visible = true
							end
							if ProfileBGs:FindFirstChild(DataValues.AccInfo.PlayerCardBackground) then
								Clipped.Toggle.Image = ProfileBGs[DataValues.AccInfo.PlayerCardBackground].Image
							else
								Clipped.Toggle.Image = ""
							end
						end
					end

					local buttons = {}

					if DataValues.ControllerType == "Controller" then
						DataValues.Inputs.OptionsControllerClose = BINDABLES.ControllerClose.Event:Connect(function()
							if GuiService.SelectedObject.Name == "Toggle" then
								buttons[GuiService.SelectedObject.Parent.Parent.Button.Title.Text]()
							elseif GuiService.SelectedObject.Name == "Button" then
								GuiService.SelectedObject = Settings.TopBar[GuiService.SelectedObject.Parent.Parent.Name]
							end
						end)

						for _, otherObjects in ipairs(Settings.SideBar:GetDescendants()) do
							if otherObjects.Name == "Button" then
								otherObjects.Selectable = true
							elseif otherObjects.Name == "Toggle" then
								otherObjects.Selectable = false
							end
						end
					end

					for _, Frames in ipairs(Settings.SideBar:GetChildren()) do
						for _, Setting in ipairs(Frames:GetChildren()) do
							if Setting.Name ~= "Blank" and Setting:IsA("Frame") then
								local Clipped = Setting.ClipContent
								UpdateSetting(Setting, Clipped, false)
								DataValues.SettingInputs[Setting.Button.Title.Text.."Toggle"] = Clipped.Toggle.MouseButton1Down:Connect(function()
									UpdateSetting(Setting, Clipped, true)
									Socket:Emit("UpdateSetting", "Post", Options)
								end)
								Clipped.Toggle.Selectable = false
								Setting.Size = UDim2.new(0.8, 0, 0, 30)
								Setting.Button.Icon.Drop.Rotation = 0
								DataValues.SettingInputs[Setting.Button.Title.Text] = Setting.Button.MouseButton1Down:Connect(function()
									buttons[Setting.Button.Title.Text]()
								end)
								buttons[Setting.Button.Title.Text] = function()
									if Setting.Size.Y.Offset <= 30 then
										if DataValues.ControllerType == "Controller" then
											--- Disables selection input
											for _, otherObjects in ipairs(Setting.Parent:GetDescendants()) do
												if otherObjects.Name == "Toggle" or otherObjects.Name == "Button" then
													otherObjects.Selectable = false
												end
											end
											Clipped.Toggle.Selectable = true
											GuiService.SelectedObject = Clipped.Toggle
										end
										TweenService:Create(Setting.Button.Icon.Drop, TweenInfo.new(0.2), {Rotation = 90}):Play()
										TweenService:Create(Setting, TweenInfo.new(0.2), {Size = UDim2.new(0.8, 0, 0, Setting.MaxHeightInPixels.Value)}):Play()
									else
										if DataValues.ControllerType == "Controller" then
											for _, otherObjects in ipairs(Setting.Parent:GetDescendants()) do
												if otherObjects.Name == "Button" then
													otherObjects.Selectable = true
												end
											end
											Clipped.Toggle.Selectable = false
											GuiService.SelectedObject = Setting.Button
										end
										TweenService:Create(Setting.Button.Icon.Drop, TweenInfo.new(0.2), {Rotation = 0}):Play()
										TweenService:Create(Setting, TweenInfo.new(0.2), {Size = UDim2.new(0.8, 0, 0, 30)}):Play()
									end
									wait(.2)
									Setting.Parent.CanvasSize = UDim2.new(0, 0, 0, Setting.Parent.UIListLayout.AbsoluteContentSize.Y)
								end

								Setting.Parent.CanvasSize = UDim2.new(0, 0, 0, Setting.Parent.UIListLayout.AbsoluteContentSize.Y)
								Setting.Parent.CanvasPosition = Vector2.new(0,0)
							end
						end
						Socket:Emit("UpdateSetting", "Post", Options)
						Frames.Visible = false
					end
					Settings.TopBar.Gameplay.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
					Settings.SideBar.Gameplay.Visible = true
					if DataValues.ControllerType == "Controller" then
						DataValues.LastSelected = Settings.TopBar.Gameplay
						GuiService.SelectedObject = Settings.TopBar.Gameplay
					end
				
				end
			end)
		end
		wait(.5)
		DataValues.MenuOpening = false
	else
		if DataValues.MenuOpening == false then
			DataValues.MenuOpening = true
			GuiService.SelectedObject = nil
			TweenService:Create(GUI.DesktopPauseMenu.Gradient,TweenInfo.new(.5,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
			TweenService:Create(GUI.DesktopPauseMenu.Base.Mask,TweenInfo.new(.5,Enum.EasingStyle.Linear),{Size = UDim2.new(1,0,0,0)}):Play()
			DataValues.MenuOpening = false
		end
	end
end

for _, module in ipairs(script.Parent.TabMenuComponents:GetChildren()) do
	require(module)
end

return OpenMenu