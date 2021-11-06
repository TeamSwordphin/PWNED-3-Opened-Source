-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players			= game:GetService("Players")
local TweenService		= game:GetService("TweenService")
local CAS				= game:GetService("ContextActionService")
local Debris			= game:GetService("Debris")

-- << Constants >> -- 
local CLIENT 	= script.Parent.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local NEWMENU 	= GUI:WaitForChild("DesktopPauseMenu").Base.Mask

-- << Modules >> --
local Socket 			= require(MODULES.socket)
local Effects			= require(MODULES.Effects)
local PlatformButtons 	= require(MODULES.PlatformButtons)
local DataValues 		= require(CLIENT.DataValues)
local Hint		  		= require(CLIENT.UIEffects.Hint)
local format_int 		= require(CLIENT.UIEffects.FormatInteger)
local round				= require(CLIENT.UIEffects.RoundNumbers)
local FS 		  		= require(ReplicatedStorage.Scripts.Modules.FastSpawn)

-- << Variables >> --
local bools 			= DataValues.bools


------------------------
local InventoryGUI = GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow
InventoryGUI.Buttons.PreviewCombos.MouseButton1Down:Connect(function()
	if DataValues.CurrentSelectedSkill ~= nil and DataValues.AccInfo ~= nil then
		if workspace.Tutorial:FindFirstChild("TutorialChar") then
			workspace.Tutorial.TutorialChar:Destroy()
		end
		local AnimId = DataValues.CurrentSelectedSkill.AnimId
		local Animators = ReplicatedStorage.Scripts.ClassAnimateScripts
		DataValues.CharInfo = Socket:Request("getCharacterInfo")
		if Animators:FindFirstChild(DataValues.AccInfo.CurrentClass) then
			local Animate = Animators[DataValues.AccInfo.CurrentClass]
			local Animation, No;
			local Animations = Animate.attackY:GetChildren()
			for i = 1, #Animations do
				local Heavy = Animations[i]
				if Heavy:IsA("Animation") and Heavy.AnimationId == AnimId then
					No = tonumber(string.match(Heavy.Name, "%d+"))
					Animation = Heavy
					break
				end
			end
			if Animation then
				local Fig = MODULES.Effects.MiscEffects.LFClone:Clone()
				local Script = Animate:Clone()
				Script.Name = "Animate"
				Script.Disabled = false
				Script.Parent = Fig
				
				local SkillLoadOut = DataValues.CharInfo.SkillsLoadOut
				
				for i = 1, 3 do
					local Counter = 1
					for b = 1, 3 do
						if SkillLoadOut["C"..i][b] ~= nil then
							local SkillInfo = Socket:Request("getSkillInfo", SkillLoadOut["C"..i][b])
							if SkillInfo ~= nil then
								for _,Skills in ipairs(Script.attackY:GetChildren()) do
									if Skills:IsA("Animation") then
										if Skills.AnimationId == SkillInfo.AnimId then
											local NewSkill = Skills:Clone()
											NewSkill.Name = "Y"..i.."-"..Counter
											NewSkill.Parent = Script.attackY
											Counter = Counter + 1
											break
										end
									end
								end
							end
						end
					end
				end
				
				Fig.Name = "TutorialChar"
				workspace.Tutorial.Baseplate.Transparency = 0.4
				Fig:SetPrimaryPartCFrame(workspace.Tutorial.Baseplate.CFrame * CFrame.new(0,4.5,0))
				Fig.Parent = workspace.Tutorial
				Fig.Weapon:Destroy()
				Fig.Humanoid.AnimationPlayed:Connect(function(AnimTrack)
					Effects.CreateHitEffects(DataValues.AccInfo.CurrentClass, Fig, AnimTrack)
				end)
				for _,Part in ipairs(Fig:GetChildren()) do
					if Part:IsA("BasePart") and Part ~= Fig.PrimaryPart then
						Part.Transparency = 0
						Part.Material = Enum.Material.SmoothPlastic
						Part.Color = Color3.fromRGB(163, 162, 165)
					end
				end
				local WeaponName = DataValues.AccInfo.CurrentClass.."Weapon"
				local weapon = ReplicatedStorage.Models.Weapons[WeaponName]:Clone()
				local Motor6D = weapon:FindFirstChild("WristToHandle")
				weapon.Name = "Weapon"
				weapon.Parent = Fig
				if Motor6D then
					Motor6D.Part0 = Fig.RightHand
					if weapon:FindFirstChild("Handle") == nil then
						Motor6D.Part1 = weapon.Hand.Value
					else
						Motor6D.Part1 = weapon.Handle
					end
					Motor6D.Parent = Fig.RightHand
				end
				bools.PlayingTutorial = true
				local SkillIn = GUI.DesktopPauseMenu.Base.Mask.EditWindow.Inputs
				for _,Inputs in ipairs(SkillIn.SkillMenu:GetChildren()) do
					if Inputs:IsA("Frame") then
						Inputs:Destroy()
					end
				end
				TweenService:Create(GUI.DesktopPauseMenu.Gradient,TweenInfo.new(.5,Enum.EasingStyle.Linear),{ImageTransparency = 1}):Play()
				GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Analyze.Visible = false
				GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Description.Visible = false
				GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Buttons.PreviewCombos.Visible = false
				GUI.DesktopPauseMenu.Base.Mask.EditWindow.NotHide.AnalyzeWindow.Buttons.Upgrade.Visible = false
				GUI.DesktopPauseMenu.Base.Mask.OuterFrame.Visible = false
				GUI.DesktopPauseMenu.Base.Mask.EditWindow.Skills.Visible = false
				GUI.DesktopPauseMenu.Base.Mask.EditWindow.Visible = true
				GUI.DesktopPauseMenu.Base.Mask.EditWindow.Inputs.Visible = true
				wait(1)
				FS.spawn(function()
					local function PlayAnimation(Mode, Name)
						local TargetAnim = Script["attack"..Mode]:FindFirstChild(Name)
						if TargetAnim then
							local ExampleAnimation = Fig.Humanoid:LoadAnimation(TargetAnim)
							local Length = ExampleAnimation.Length
							ExampleAnimation:Play()
							local TempLabel;
							if DataValues.ControllerType == "Keyboard" then
								TempLabel = PlatformButtons:GetImageLabel("Button"..Mode, "Light", "PC")
							elseif DataValues.ControllerType == "Controller" then
								TempLabel = PlatformButtons:GetImageLabel("Button"..Mode, "Light", "XboxOne")
							elseif DataValues.ControllerType == "Touch" then
								TempLabel = CAS:GetButton(Mode == "X" and "MouseButton1" or "MouseButton2"):Clone()
								TempLabel.Active = false
								TempLabel.Visible = true
								TempLabel.Position = UDim2.new(0,0,0,0)
								TempLabel.Size = UDim2.new(1,0,1,0)
								TempLabel.Name = "ImageLabel"
							end
							local Template = SkillIn.Template:Clone()
							Template.Visible = true
							TempLabel.BackgroundTransparency = 1
							TempLabel.Parent = Template
							Template.UIAspectRatioConstraint.Parent = TempLabel
							Template.Parent = GUI.DesktopPauseMenu.Base.Mask.EditWindow.Inputs.SkillMenu
							wait(Length+.1)
						else
							return false
						end
					end
					
					local function ResetGUI()
						local SkillInn = GUI.DesktopPauseMenu.Base.Mask.EditWindow.Inputs.SkillMenu:GetChildren()
						for i = 1, #SkillInn do
							local Inputs = SkillInn[i]
							if Inputs:IsA("Frame") then
								TweenService:Create(Inputs.ImageLabel,TweenInfo.new(0.7,Enum.EasingStyle.Quad),{ImageTransparency = 1}):Play()
								Debris:AddItem(Inputs,1)
							end
						end
					end
					
					while Fig ~= nil and bools.PlayingTutorial do
						if Script["attackY"]:FindFirstChild("Y2-1") then
							Hint("Playing Active Combo 1")
							for i = 1, 3 do
								local TargetAnim = PlayAnimation("Y", "Y1-"..i)
								if TargetAnim == false then
									break
								end
							end
						end
						
						ResetGUI()
						if Script["attackY"]:FindFirstChild("Y2-1") then
							wait(1)
							Hint("Playing Active Combo 2")
							PlayAnimation("X", "X1")
							for i = 1, 3 do
								local TargetAnim = PlayAnimation("Y", "Y2-"..i)
								if TargetAnim == false then
									break
								end
							end
						end
						
						ResetGUI()
						if Script["attackY"]:FindFirstChild("Y3-1") then
							wait(1)
							Hint("Playing Active Combo 3")
							PlayAnimation("X", "X1")
							PlayAnimation("X", "X2")
							for i = 1, 3 do
								local TargetAnim = PlayAnimation("Y", "Y3-"..i)
								if TargetAnim == false then
									break
								end
							end
						end
						
						wait(1)
						ResetGUI()
						Hint("Playing Light Attack Combos")
						for i = 1, 5 do
							local TargetAnim = PlayAnimation("X", "X"..i)
							if TargetAnim == false then
								break
							end
						end
						
						ResetGUI()
						wait(1)
						if bools.PlayingTutorial == false then
							break
						end
					end
					if Fig then
						Fig:Destroy()
					end
				end)
			end
		end
	end
end)

InventoryGUI.Buttons.Equip.MouseButton1Down:Connect(function()
	if DataValues.CurrentSelectedSkill then
		Hint("Select a skill order location that you would like to equip it to.")
		NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
		NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.PreviewCombos.Visible = true
		NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.ComboMaker.Visible = true
		for _, Combos in ipairs(NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.ComboMaker:GetDescendants()) do
			if Combos.Name == "ButtonPrompt" then
				local Attacks = Combos.Parent
				if (Attacks:FindFirstChild("Limit") == nil or not Attacks.Limit.Visible) then
					FS.spawn(function()
						while DataValues.CurrentSelectedSkill ~= nil and NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.ComboMaker.Visible do
							Attacks.Outline.Highlight.ImageTransparency = 0
							Attacks.Outline.Highlight.Size = UDim2.new(1, 0, 1, 0)
							Attacks.Outline.Highlight.Position = UDim2.new(0, 0, 0, 0)
							TweenService:Create(Attacks.Outline.Highlight,TweenInfo.new(1,Enum.EasingStyle.Quad),{ImageTransparency = 1, Position = UDim2.new(-.1, 0, -.1, 0), Size = UDim2.new(1.2, 0, 1.2, 0)}):Play()
							wait(1.25)
						end
					end)
				end
			end
		end
	elseif DataValues.CurrentSelectedCostume then
		local NewChar = Socket:Request("EquipCostume", DataValues.CurrentSelectedCostume)
		if NewChar then
			NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
			Hint("Equipped costume!")
			DataValues.CharInfo = NewChar
		end
	else
		if DataValues.CurrentObj then
			if DataValues.CurrentObj.Equipped == nil then
				local success, newCharData = Socket:Request("EquipGem", DataValues.CurrentObj)
				if success == "Full slots!" then
					Hint("All Gem slots are filled! Please unequip one in order to equip another.")
				elseif success == "Quick" then
					Hint("You are equipping too quickly! Please try again later.")
				elseif success == "Duplicate" then
					Hint("There is already a similar Gemstone equipped!")
				else
					if success == true and DataValues.CurrentButt ~= nil then
						ReplicatedStorage.Sounds.SFX.UI.EquipGemstone:Play()
						DataValues.CurrentButt.TextButton.BackgroundColor3 = Color3.fromRGB(232, 255, 20)
						InventoryGUI.Buttons.Sell.Visible = false
						InventoryGUI.Buttons.Reforge.Visible = false
						InventoryGUI.Buttons.Equip.Title.Text = "Unequip"
						InventoryGUI.Buttons.Equip.Visible = true
						Hint("Equipped the Gem!")
					elseif success == "Destroy" then
						if DataValues.CurrentButt ~= nil then
							InventoryGUI.Buttons.Sell.Visible = false
							InventoryGUI.Buttons.Reforge.Visible = false
							InventoryGUI.Buttons.Equip.Visible = false
							InventoryGUI.Description.Description.Text = "Hover or select an item to view their details."
							DataValues.CurrentButt.TextButton.BackgroundColor3 = Color3.fromRGB(19, 22, 31)
							--if DataValues.InventoryInputs[DataValues.CurrentObj] ~= nil then
							--	DataValues.InventoryInputs[DataValues.CurrentObj]:Disconnect()
							--	DataValues.InventoryInputs[DataValues.CurrentObj] = nil
							--end
							--DataValues.CurrentButt:Destroy()
						end
					end
					DataValues.CharInfo = newCharData
				end
			else
				local success, newCharData = Socket:Request("EquipWeapon", DataValues.CurrentObj)
				if success == "Low Level" then
					Hint("You are too low level to equip this item!")
				elseif success then
					if DataValues.CurrentObj.Map == nil then
						ReplicatedStorage.Sounds.SFX.UI.EquipWeapon:Play()
					else
						ReplicatedStorage.Sounds.SFX.UI.EquipTrophy:Play()
						Socket:Emit("EquipTrophy")
					end
					Hint("Equipped the Weapon!")
					InventoryGUI.Buttons.Sell.Visible = false
					InventoryGUI.Buttons.Equip.Visible = false
					InventoryGUI.Description.Description.Text = "Hover or select an item to view their details."
					DataValues.CurrentButt.Parent.NewWeaponEquip:Fire(DataValues.CurrentButt)
					DataValues.CharInfo = newCharData
					local Description = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description
					for _,Descs in ipairs(Description:GetChildren()) do
						if Descs:IsA("Frame") then
							Descs:Destroy()
						end
					end
				end
			end
		end
	end
end)

InventoryGUI.Buttons.Sell.MouseButton1Down:Connect(function()
	if bools.SellMode == false then
		bools.SellMode = true
		InventoryGUI.Buttons.Reforge.Visible = false
		InventoryGUI.Buttons.Equip.Visible = false
		local ToSell = {}
		ToSell.Object = DataValues.CurrentObj
		ToSell.Button = DataValues.CurrentButt
		table.insert(DataValues.SellObjs, ToSell)
		if DataValues.CurrentButt:FindFirstChild("ViewportFrame") then
			DataValues.CurrentButt.ViewportFrame.BackgroundColor3 = Color3.fromRGB(232, 30, 20)
		else
			DataValues.CurrentButt.TextButton.BackgroundColor3 = Color3.fromRGB(232, 30, 20)
		end
		Hint("Bulk Sell: Click more items if you want to sell them together, or click Return to cancel.")
	else
		if #DataValues.SellObjs > 0 then
			local WeaponPile = {}
			local GemPile = {}
			for i = 1, #DataValues.SellObjs do
				if DataValues.SellObjs[i].Object.IND ~= nil then
					table.insert(GemPile, DataValues.SellObjs[i])
				else
					table.insert(WeaponPile, DataValues.SellObjs[i])
				end
			end
			if #GemPile > 0 then
				local success, newAccData, gone = Socket:Request("SellGem", GemPile)
				if success == "Quick" then
					Hint("You are selling too quickly! Please try again later.")
				elseif success == true then
					for i = 1, #GemPile do
						local Butt = GemPile[i].Button
						local Obj = GemPile[i].Object
						if Butt ~= nil then
							local Amnt = tonumber(Butt.Info1.Text)-1
							if Amnt == nil or Amnt <= 0 then
								InventoryGUI.Buttons.Sell.Visible = false
								InventoryGUI.Buttons.Reforge.Visible = false
								InventoryGUI.Buttons.Equip.Visible = false
								InventoryGUI.Description.Description.Text = "Hover or select an item to view their details."
								if DataValues.InventoryInputs[Obj] ~= nil then
									DataValues.InventoryInputs[Obj]:Disconnect()
									DataValues.InventoryInputs[Obj] = nil
								end
								Butt:Destroy()
							else
								Butt.Info1.Text = Amnt
								Butt.TextButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
								if Amnt <= 1 then
									Butt.Info1.Visible = false
								else
									if Amnt >= 99 then
										Butt.Info1.TextColor3 = Color3.fromRGB(255, 112, 102)
									else
										Butt.Info1.TextColor3 = Color3.fromRGB(155, 255, 214)
									end
								end
							end
						end
					end
					ReplicatedStorage.Sounds.SFX.UI.Sell:Play()
					DataValues.AccInfo = newAccData
					bools.SellMode = false
					DataValues.SellObjs = {}
				end
			else
				local success, newCharData, newAccInfo = Socket:Request("SellWeapon", WeaponPile)
				if success then
					for i = 1, #WeaponPile do
						WeaponPile[i].Button:Destroy()
						WeaponPile[i].Object = nil
					end
					ReplicatedStorage.Sounds.SFX.UI.Sell:Play()
					InventoryGUI.Buttons.Sell.Visible = false
					InventoryGUI.Buttons.Equip.Visible = false
					InventoryGUI.Description.Description.Text = "Hover or select an item to view their details."
					DataValues.AccInfo = newAccInfo
					DataValues.CharInfo = newCharData
					bools.SellMode = false
					DataValues.SellObjs = {}
					local Description = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.Description
					for _,Descs in ipairs(Description:GetChildren()) do
						if Descs:IsA("Frame") then
							Descs:Destroy()
						end
					end
				end
			end
			InventoryGUI.Money.Gold.Price.Text = tostring(format_int(DataValues.AccInfo.Gold))
		end
	end
end)

InventoryGUI.Buttons.Reforge.MouseButton1Down:Connect(function()
	if DataValues.ReforgeMode == false then
		local GemSlots = InventoryGUI.Analyze.Reforge.Gems:GetChildren()
		for i = 1,  #GemSlots do
			local GemImg = GemSlots[i]
			GemImg.Image = ""
		end
		DataValues.ReforgeMode = true
		DataValues.ReforgeButt = {}
		Hint("Reforge enabled. Click a Gem and press Add to queue, or Return to cancel changes.")
		InventoryGUI.Analyze.Reforge.Visible = true
		InventoryGUI.Buttons.Reforge.Title.Text = "Add"
		InventoryGUI.Buttons.Sell.Visible = false
		InventoryGUI.Analyze.Reforge.Reforge.Visible = false
		InventoryGUI.Buttons.Equip.Visible = false
	else
		if #DataValues.ReforgeQueue < 5 then
			local CanAdd = true
			for i = 1, #DataValues.ReforgeQueue do
				if DataValues.ReforgeQueue[i] == DataValues.CurrentObj then
					CanAdd = false
				end
			end
			if CanAdd then
				table.insert(DataValues.ReforgeQueue, DataValues.CurrentObj)
				table.insert(DataValues.ReforgeButt, DataValues.CurrentButt)
				if #DataValues.ReforgeQueue >= 5 then
					InventoryGUI.Analyze.Reforge.Reforge.Visible = true
				end
				for i = 1,  #DataValues.ReforgeQueue do
					local GemImg = InventoryGUI.Analyze.Reforge.Gems["Gem"..i]
					GemImg.Image = DataValues.ReforgeQueue[i].Image
				end
			end
		end
	end
end)

InventoryGUI.Analyze.Reforge.Help.MouseButton1Down:Connect(function()
	if DataValues.ControllerType == "Touch" then
		NEWMENU.Parent.ReforgeHelp.MoreInfo.Position = UDim2.new(.1,0,.1,0)
		NEWMENU.Parent.ReforgeHelp.MoreInfo.Size = UDim2.new(.8,0,.65,0)
		NEWMENU.Parent.ReforgeHelp.Close.Position = UDim2.new(.3,0,.85,0)
		NEWMENU.Parent.ReforgeHelp.Close.Size = UDim2.new(.4,0,.1,0)
	end
	NEWMENU.Parent.ReforgeHelp.Visible = true
end)

NEWMENU.Parent.ReforgeHelp.Close.MouseButton1Down:Connect(function()
	NEWMENU.Parent.ReforgeHelp.Visible = false
end)

InventoryGUI.Analyze.Reforge.Reforge.MouseButton1Down:Connect(function()
	if #DataValues.ReforgeQueue == 5 then
		local success, newcharinfo = Socket:Request("ReforgeGem", DataValues.ReforgeQueue)
		if success == "Max" then
			--InventoryGUI.Reforge.Warning.Text = "Octagon gemstones cannot be reforged any further!"
			Hint("You forged some new Octagon gemstones!")
		elseif success == true then
			DataValues.ReforgeMode = false
			DataValues.ReforgeQueue = {}
			InventoryGUI.Analyze.Reforge.Visible = false
			InventoryGUI.Buttons.Reforge.Title.Text = "Reforge"
			InventoryGUI.Analyze.Reforge.Visible = false
			for i = 1, #DataValues.ReforgeButt do
				DataValues.ReforgeButt[i]:Destroy()
			end
			DataValues.CharInfo = newcharinfo
		end
	end
end)

InventoryGUI.Buttons.Upgrade.MouseButton1Down:Connect(function()
	local SkillBlock;
	local SkillNo = 0
	for _,existingStuff in next, InventoryGUI.Parent.Parent.Skills.Inventory:GetChildren() do
		if existingStuff:IsA("Frame") then
			if (SkillNo.. "" .. DataValues.CurrentSelectedSkill.Name) == existingStuff.Name then
				SkillBlock = existingStuff
				break
			end
			SkillNo = SkillNo + 1
		end
	end
	if SkillBlock ~= nil then
		local success,curRank,curFP,curChar = Socket:Request("UpgradeSkill", DataValues.CurrentSelectedSkill.Name)
		if success then
			Hint("Skill upgraded!")
			local Rank = curRank
			local Skills = DataValues.CurrentSelectedSkill
			DataValues.CharInfo = curChar
			NEWMENU.EditWindow.NotHide.AnalyzeWindow.Money.SkillPoints.Price.Text = tostring(format_int(DataValues.CharInfo.SkillPoints))
			SkillBlock.Details.InfoBar.Rank.Text = (Rank <= 8 and "Rank" or "Exceed")
			SkillBlock.Details.InfoBar.RankVal.Text = (Rank==0 and "F") or (Rank==1 and "E") or (Rank==2 and "D") or (Rank==3 and "C") or (Rank==4 and "B") or (Rank==5 and "A") or (Rank==6 and "S") or (Rank==7 and "SS") or (Rank==8 and "SSS") or (Rank>8 and tostring(Rank-8))
			SkillBlock.Details.InfoBar.CostValueFrame.CostVal.Text = tostring(Rank < 23 and 4*(Rank+1) or "N/A")
			InventoryGUI.Analyze.Description.SkillDescription.Title.Text = SkillBlock.Info.Value.. (Skills.PercentageIncrease == nil and "" or ( "\n\nCurrent: " .. tostring(round((Skills.PercentageIncrease[Rank+1])*100,2)) .. "" .. Skills.Prefix.. "\nNext: " .. tostring(Rank < 23 and tostring(round((Skills.PercentageIncrease[Rank+2])*100,2)) or "N/A") .. "" .. Skills.Prefix .."\nFP Cost: " .. tostring(Rank < 23 and 4*(Rank+1) or "N/A")))
			if Rank < 23 then
				InventoryGUI.Buttons.Upgrade.Visible = true
			else
				InventoryGUI.Buttons.Upgrade.Visible = false
			end
		elseif curRank and curRank == "Trials" then
			Hint(curFP)
		elseif curRank and curRank == "FP" then
			Hint("Insufficient Skill Points!")
		end
	else
		print("Not Found!")
	end
end)

return nil
