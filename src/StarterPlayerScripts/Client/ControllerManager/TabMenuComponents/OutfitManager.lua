-- << Services >> --
local MarketplaceService 	= game:GetService("MarketplaceService")
local TweenService			= game:GetService("TweenService")
local Players 				= game:GetService("Players")
local RS					= game:GetService("ReplicatedStorage")
local CollectionService 	= game:GetService("CollectionService")

-- << Constants >> --
local CLIENT 	 = script.Parent.Parent.Parent
local MODULES 	 = CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	 = Players.LocalPlayer
local GUI 		 = PLAYER:WaitForChild("PlayerGui")
local NEWMENU 	 = GUI:WaitForChild("DesktopPauseMenu").Base.Mask
local MODIFYSKIN = NEWMENU.EditWindow.NotHide.AnalyzeWindow.Analyze.ModifySkin
local LIMBSHOWER = NEWMENU.EditWindow:WaitForChild("SkinLimbShower")
local SWAPPART	 = MODIFYSKIN.SwapPart
local COLOURPICK = MODIFYSKIN.ColourPicker
local SAVE		 = MODIFYSKIN.Save
local SAVESLOTS  = SAVE.WorkingSpace

-- << Modules >> --
local Socket 		= require(MODULES.socket)
local PaletteScript	= require(MODULES.PaletteScript)
local ColourPicker	= require(MODULES.ColorPicker)
local Hint		  	= require(CLIENT.UIEffects.Hint)
local DataValues 	= require(CLIENT.DataValues)
local Morpher		= require(RS.Scripts.Modules.Morpher)

-- << Variables >> --
local currentColourGroups = {"Primary", "Secondary", "Tertiary", "Quaternary"}
local limbInfo = Morpher:GetLimbInfo()
local currentColourTarget
local currentOutfitSlot


-----------------------------
NEWMENU:GetPropertyChangedSignal("Size"):Connect(function()
	MODIFYSKIN.Visible = false
	LIMBSHOWER.Visible = false
	COLOURPICK.Visible = false
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.SaveSet.Visible = false
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.LoadSet.Visible = false
	SAVE.Visible = false
	SWAPPART.Temp:ClearAllChildren()
end)

MODIFYSKIN:GetPropertyChangedSignal("Visible"):Connect(function()
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.SaveSet.Visible = false
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.LoadSet.Visible = false
	local colorPick = GUI:FindFirstChild("Colorpicker") 
	if colorPick then
		colorPick:Destroy()
	end
	SWAPPART.Temp:ClearAllChildren()
	for _, window in ipairs(MODIFYSKIN:GetChildren()) do
		window.Visible = window.Name == SWAPPART.Name and true or false
	end
end)

NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.ModifySet.MouseButton1Down:Connect(function()
	local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()
	
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.Equip.Visible = false
	MODIFYSKIN.Visible = not MODIFYSKIN.Visible
	NEWMENU.EditWindow.Weapons.Visible = not MODIFYSKIN.Visible
	TweenService:Create(GUI.DesktopPauseMenu.Gradient, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {ImageTransparency = not NEWMENU.EditWindow.Weapons.Visible and 1 or 0}):Play()
	
	if not NEWMENU.EditWindow.Weapons.Visible then
		DataValues.CAMERAOFFSET = Vector3.new(4, 0.25, 6)

		for limb, _ in pairs(DataValues.CharInfo.CurrentSkinPieces) do
			local part = CHARACTER:FindFirstChild(limb)
			if part then
				local newBillboard = SWAPPART.Template.BillboardGui:Clone()
				newBillboard.TextButton.Text = limb
				newBillboard.Adornee = part
				newBillboard.Enabled = true
				newBillboard.Parent = SWAPPART.Temp

				newBillboard.TextButton.MouseButton1Down:Connect(function()
					if COLOURPICK.Visible then
						currentColourTarget = PLAYER.Character:FindFirstChild(limbInfo[limb])
						COLOURPICK.WorkingSpace.Targeting.Target.Text = currentColourTarget and limb or "Nothing"
						for _, limb in ipairs(SWAPPART.Temp:GetChildren()) do
							limb.Enabled = false
						end
					else
						local oldInventory = LIMBSHOWER:FindFirstChild("Inventory")
						if oldInventory then
							oldInventory:Destroy()
						end
						local newInventory = NEWMENU.EditWindow.Weapons.Inventory:Clone()
						newInventory.Size = UDim2.new(1, 0, 0.9, 0)
						newInventory.Position = UDim2.new(0, 0, 0.1, 0)

						for _, outfitButton in ipairs(newInventory:GetChildren()) do
							if outfitButton:IsA("Frame") then
								outfitButton.TextButton.MouseButton1Down:Connect(function()
									Socket:Emit("EquipPiece", limb, outfitButton.Name)
									LIMBSHOWER.Visible = false
								end)
							end
						end

						newInventory.Parent = LIMBSHOWER
						LIMBSHOWER.Visible = true
					end
				end)
			end
		end
	end
end)

SWAPPART.Buttons.ColourChange.MouseButton1Down:Connect(function()
	local success = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(PLAYER.UserId, 7052268)
	end)
	if success then
		SWAPPART.Visible = false
		SAVE.Visible = false
		COLOURPICK.Visible = true
		currentColourTarget = PLAYER.Character or PLAYER.CharacterAdded:Wait()
		COLOURPICK.WorkingSpace.Targeting.Target.Text = "Character"

		for _, limb in ipairs(SWAPPART.Temp:GetChildren()) do
			limb.Enabled = false
		end
	else
		Hint("Color Dye Module or a Spraycan is required. This can be purchased at the shop.")
	end
end)

COLOURPICK.WorkingSpace.Targeting.TargetChar.MouseButton1Down:Connect(function()
	currentColourTarget = PLAYER.Character
	COLOURPICK.WorkingSpace.Targeting.Target.Text = "Character"
	for _, limb in ipairs(SWAPPART.Temp:GetChildren()) do
		limb.Enabled = false
	end
end)

COLOURPICK.WorkingSpace.Targeting.TargetLimb.MouseButton1Down:Connect(function()
	Hint("Select a limb on the left to target.")
	for _, limb in ipairs(SWAPPART.Temp:GetChildren()) do
		limb.Enabled = true
	end
end)

COLOURPICK.WorkingSpace.ColourType.Reset.MouseButton1Down:Connect(function()
	local target = currentColourTarget == PLAYER.Character and DataValues.CharInfo.CurrentSkinPieces

	if not target then
		for realLimb, limb in pairs(limbInfo) do
			if limb == currentColourTarget.Name then
				target = {}
				target[realLimb] = DataValues.CharInfo.CurrentSkinPieces[realLimb]
				break
			end
		end
	end

	local published = {}

	for limb, value in pairs(target) do
		local colours = {}
		local convertedLimb = limbInfo[limb]
		local armor = RS.Models.Armor:FindFirstChild(value.N)

		--- Find original armor piece colours
		if armor then
			local limbPart = armor:FindFirstChild(convertedLimb)
			if limbPart then
				for _, part in ipairs(limbPart:GetDescendants()) do
					if part:IsA("BasePart") then
						local tags = CollectionService:GetTags(part)
						for _, tag in ipairs(tags) do
							if not colours[tag] and table.find(currentColourGroups, tag) then
								colours[tag] = part.Color
							end
						end
					end
				end
			end
		end

		if not published[limb] then
			published[limb] = {}
		end

		--- Reset current worn armor pieces to normal colours
		local findPiece = PLAYER.Character:FindFirstChild(convertedLimb)
		if findPiece then
			for _, part in ipairs(findPiece:GetDescendants()) do
				if part:IsA("BasePart") then
					for colourGroup, colour in pairs(colours) do
						if CollectionService:HasTag(part, colourGroup) then
							part.Color = colour
							published[limb][colourGroup] = -1
						end
					end
				end
			end
		end
	end

	Socket:Emit("ChangeColour", published)
end)

for _, colourGroup in ipairs(COLOURPICK.WorkingSpace.ColourType:GetChildren()) do
	if colourGroup:IsA("TextButton") and colourGroup.Name ~= "Reset" then
		colourGroup.MouseButton1Down:Connect(function()
			COLOURPICK.Visible = false
			local ui = ColourPicker:Init()
			local published = {}
			local isCharacter = currentColourTarget == PLAYER.Character
			ui.Frame.ColourPicking.Event:Connect(function(changingColour)
				for _, part in ipairs(currentColourTarget:GetDescendants()) do
					if part:IsA("BasePart") then
						if CollectionService:HasTag(part, colourGroup.Name) then
							part.Color = changingColour

							for realLimb, limb in pairs(limbInfo) do
								if limb == part.Parent.Name then
									if not published[realLimb] then
										published[realLimb] = {}
									end
									published[realLimb][colourGroup.Name] = part.Color
									break
								end
							end
						end
					end
				end
			end)

			local applied, finalColour = ColourPicker:Prompt(ui)
			if applied then
				COLOURPICK.Visible = true
				Socket:Emit("ChangeColour", published)
			end
		end)
	end
end

SWAPPART.Buttons.Save.MouseButton1Down:Connect(function()
	SWAPPART.Visible = false
	COLOURPICK.Visible = false
	SAVE.Visible = true
	currentOutfitSlot = nil

	for i = 1, DataValues.AccInfo.OutfitSlots do
		local outfitSlot = SAVESLOTS[string.format("Slot%s", i)]
		outfitSlot.Lock.Visible = false
		outfitSlot.ViewportFrame:ClearAllChildren()

		for slotName, slotData in pairs(DataValues.CharInfo.CurrentSkinLoadout) do
			if slotName == outfitSlot.Name and slotData.Head then --- See if it exists first
				local worldModel = Instance.new("WorldModel")
				local newRig = PLAYER.Character:Clone()
				local camera = Instance.new("Camera", outfitSlot.ViewportFrame)

				for _, model in ipairs(newRig:GetChildren()) do
					if model:IsA("Model") or model:IsA("Script") or model:IsA("LocalScript") then
						model:Destroy()
					end
				end

				newRig.PrimaryPart.Anchored = true
				newRig.Parent = worldModel
				worldModel.Parent = outfitSlot.ViewportFrame
				
				local Pos = CFrame.new(newRig.PrimaryPart.Position + (newRig.PrimaryPart.CFrame.LookVector * 4))
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CameraSubject = newRig.PrimaryPart
				camera.CFrame = CFrame.lookAt(Pos.Position, newRig.PrimaryPart.Position)

				Morpher:morph(newRig, slotData)
				outfitSlot.ViewportFrame.CurrentCamera = camera
			end
		end
	end
end)

for _, slot in ipairs(SAVESLOTS:GetChildren()) do
	if slot:IsA("Frame") then
		slot.TextButton.MouseButton1Down:Connect(function()
			if not slot.Lock.Visible then
				currentOutfitSlot = slot
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.ModifySet.Visible = false
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.SaveSet.Visible = true
				NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.LoadSet.Visible = true
			else
				Hint("Additional outfit slots can be purchased at the shop.")
			end
		end)
	end
end

NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.SaveSet.MouseButton1Down:Connect(function()
	local slotName = currentOutfitSlot.Name
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.SaveSet.Visible = false
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.LoadSet.Visible = false
	local success, newCharacterData = Socket:Request("OutfitManage", "Save", slotName)
	if success ~= -1 then
		Hint(string.format("Outfit saved to %s", slotName))
		currentOutfitSlot.ViewportFrame:ClearAllChildren()

		local slotData = DataValues.CharInfo.CurrentSkinPieces
		local newRig = PLAYER.Character:Clone()
		local camera = Instance.new("Camera", currentOutfitSlot.ViewportFrame)

		newRig.Parent = currentOutfitSlot.ViewportFrame

		local Pos = CFrame.new(newRig.PrimaryPart.Position + (newRig.PrimaryPart.CFrame.LookVector * 4))
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CameraSubject = newRig.PrimaryPart
		camera.CFrame = CFrame.lookAt(Pos.Position, newRig.PrimaryPart.Position)

		currentOutfitSlot.ViewportFrame.CurrentCamera = camera
		DataValues.CharInfo = newCharacterData
	end
end)

NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.LoadSet.MouseButton1Down:Connect(function()
	local slotName = currentOutfitSlot.Name
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.SaveSet.Visible = false
	NEWMENU.EditWindow.NotHide.AnalyzeWindow.Buttons.LoadSet.Visible = false
	local success = Socket:Request("OutfitManage", "Load", slotName)
	if success == -1 then Hint("Cannot load outfit from empty slot.") return end
	if success then
		Hint(string.format("Outfit loaded from %s", slotName))
	end
end)


return nil