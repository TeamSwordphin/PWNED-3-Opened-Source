-- << Services >> --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local BS        = GUI:WaitForChild("BlacksmithGUI")
local WS        = BS.WeaponServices

-- << Modules >> --
local Socket 	    = require(MODULES.socket)
local Hint          = require(CLIENT.UIEffects.Hint)
local FormatInteger = require(CLIENT.UIEffects.FormatInteger)
local DataValues    = require(CLIENT.DataValues)
local Play          = require(MODULES.Effects.CommonModules.SoundManager)

-- << Variables >> --
local Wepon
local normal = 0
local heat = 0
local thermal = 0
local enchantment, catalyst


--------------------------------- FUNCTIONS
function resetWindow(window)
    ReplicatedStorage.Sounds.SFX.UI.Click:Play()
    for _, existingBlock in ipairs(window.WeaponInfo.Top.WeaponInfo:GetChildren()) do
        if existingBlock.Name == "WeaponBlock" then
            existingBlock:Destroy()
        end
    end

    Wepon = Socket:Request("GetCurrentWeapon", true)
    local CurrentWeapon = Wepon.Object
    local RarityImage = ReplicatedStorage.Images.Textures["Rarity"..CurrentWeapon.Rarity]
    local WeaponPreview = CurrentWeapon.Model:Clone()
    local NewWeaponBlock = ReplicatedStorage.GUI.NormalGui.WeaponBlock:Clone()
    local NewImageLabel = Instance.new("ImageLabel")
    local Constraint = Instance.new("UIAspectRatioConstraint", NewWeaponBlock)
    NewImageLabel.Size = UDim2.new(1, 0, 1, 0)
    NewImageLabel.BackgroundTransparency = 1
    NewImageLabel.Image = RarityImage.Image
    NewImageLabel.ZIndex = 12
    NewImageLabel.Parent = NewWeaponBlock
    NewWeaponBlock.TextButton:Destroy()
    NewWeaponBlock.LayoutOrder = 0
    NewWeaponBlock.Position = UDim2.new(0, 0, 0, 0)
    NewWeaponBlock.Size = UDim2.new(1, 0, 1, 0)
    if WeaponPreview:FindFirstChild("CameraCF") then
        local CameraPre = Instance.new("Camera")
        CameraPre.CFrame = WeaponPreview.CameraCF.Value
        NewWeaponBlock.ViewportFrame.CurrentCamera = CameraPre
    end
    WeaponPreview.Parent = NewWeaponBlock.ViewportFrame
    NewWeaponBlock.Parent = window.WeaponInfo.Top.WeaponInfo
    
    local weaponMight = Wepon.CurrentWeapon.UpLvl
    local maxMight = Wepon.CurrentWeapon.Tier * 25
    local stringMight = "Might <b><font color='rgb(142, 216, 255)'><font size='24'>%s</font></font></b>/%s"
    window.WeaponInfo.Top.WeaponInfo.Information.Title.Text = CurrentWeapon.WeaponName
    window.WeaponInfo.Top.WeaponInfo.Information.Level.Text = string.format(stringMight, weaponMight, maxMight)
    window.WeaponInfo.Bottom.Damage.Level.Text = CurrentWeapon.Stats.ATK + (CurrentWeapon.StatsPerLevel.ATK * weaponMight)
    window.WeaponInfo.Bottom.Critical.Level.Text = CurrentWeapon.Stats.CRIT + (CurrentWeapon.StatsPerLevel.CRIT * weaponMight)
    window.WeaponInfo.Bottom.Stamina.Level.Text = CurrentWeapon.Stats.STAM + (CurrentWeapon.StatsPerLevel.STAM * weaponMight)
end

function resetReinforceWindow()
    for _, otherFrame in ipairs(WS.ReinforceWeapon.Reinforcing.Inventory:GetChildren()) do
        if otherFrame:IsA("Frame") then
            otherFrame:Destroy()
        end
    end

    local listOfWeapons, CurrentWeapon = Socket:Request("Blacksmith", "GetReinforceables")
    for _, otherWeapon in ipairs(listOfWeapons) do
        local RarityImage = ReplicatedStorage.Images.Textures["Rarity" .. CurrentWeapon.Rarity]
        local WeaponPreview = CurrentWeapon.Model:Clone()
        local NewWeaponBlock = ReplicatedStorage.GUI.NormalGui.WeaponBlock:Clone()
        local NewImageLabel = Instance.new("ImageButton")
        local Constraint = Instance.new("UIAspectRatioConstraint", NewWeaponBlock)
        NewImageLabel.Size = UDim2.new(1, 0, 1, 0)
        NewImageLabel.BackgroundTransparency = 1
        NewImageLabel.Image = RarityImage.Image
        NewImageLabel.ZIndex = 12
        NewImageLabel.Parent = NewWeaponBlock
        NewWeaponBlock.TextButton:Destroy()
        NewWeaponBlock.LayoutOrder = 0
        NewWeaponBlock.Position = UDim2.new(0, 0, 0, 0)
        NewWeaponBlock.Size = UDim2.new(1, 0, 1, 0)
        if WeaponPreview:FindFirstChild("CameraCF") then
            local CameraPre = Instance.new("Camera")
            CameraPre.CFrame = WeaponPreview.CameraCF.Value
            NewWeaponBlock.ViewportFrame.CurrentCamera = CameraPre
        end
        WeaponPreview.Parent = NewWeaponBlock.ViewportFrame
        NewImageLabel.MouseButton1Down:Connect(function()
            local success = Socket:Request("Blacksmith", "ReinforceWeapon", otherWeapon)
            if success == -1 then Hint("Maximum Tier upgrade reached.") return end
            if success == 0 then Hint("Weapon must be upgraded to max might before you can reinforce!") return end
            if success == 1 then
                Play.PlaySound("AnvilClang")
                resetWindow(WS.ReinforceWeapon)
                resetReinforceWindow()
            end
        end)

        NewWeaponBlock.Parent = WS.ReinforceWeapon.Reinforcing.Inventory
        WS.ReinforceWeapon.Reinforcing.Inventory.CanvasSize = UDim2.new(0, 0, 0, WS.ReinforceWeapon.Reinforcing.Inventory.UIGridLayout.AbsoluteContentSize.Y)
    end
end

function resetEnchantWindow()
    WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades.Top.Visible = false
    for _, otherFrame in ipairs(WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades:GetChildren()) do
        if otherFrame:IsA("Frame") and otherFrame.Name ~= "Top" then
            otherFrame:Destroy()
        end
    end

    enchantment = nil
    catalyst = nil

    WS.EnchantWeapon.Enchanting.Visible = true
    WS.EnchantWeapon.MaterialList.Visible = false
    WS.EnchantWeapon.Enchanting.Bottom.Left.GoldCost.Value.Text = "0"
    WS.EnchantWeapon.Enchanting.Bottom.Left.CurrentGold.Value.Text = "0"
    WS.EnchantWeapon.Enchanting.Bottom.Left.Items.Enchant.ItemBlock.TextButton.Image = ""
    WS.EnchantWeapon.Enchanting.Bottom.Left.Items.Enchant.ItemBlock.Border.Image = ""
    WS.EnchantWeapon.Enchanting.Bottom.Left.Items.Catalyst.ItemBlock.TextButton.Image = ""
    WS.EnchantWeapon.Enchanting.Bottom.Left.Items.Catalyst.ItemBlock.Border.Image = ""
    WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades.Top.Desc.Text = "* Weapon cannot gain duplicate effects."
    WS.EnchantWeapon.Enchanting.Bottom.Left.Use.Visible = false
end


--------------------------------- EVENTS
BS:GetPropertyChangedSignal("Enabled"):Connect(function()
    --- Resets blacksmith UI once it is enabled
    if BS.Enabled then
        for _, frame in ipairs(BS:GetChildren()) do
            if frame:IsA("Frame") then
                frame.Visible = false
            end
        end
        BS.MainMenu.Visible = true
    end
end)

BS.BackButton.MouseButton1Down:Connect(function()
    if BS.MainMenu.Visible then
        BS.Enabled = false
        PLAYER.Character.PrimaryPart.Anchored = false
    elseif WS.Visible then
        WS.Visible = false
        BS.MainMenu.Visible = true
    end
end)

WS:GetPropertyChangedSignal("Visible"):Connect(function()
    if not WS.Visible then
        for _, frame in ipairs(WS:GetChildren()) do
            frame.Visible = false
        end
    end
end)

for _, button in ipairs(BS.MainMenu:GetChildren()) do
    if button:IsA("TextButton") then
        button.MouseButton1Down:Connect(function()
            if button.Name == "Temper" then
                Hint("This feature is currently unavailable.")
                return
            end
            local window = WS[string.format("%sWeapon", button.Name)]
            BS.MainMenu.Visible = false
            WS.Visible = true
            window.Visible = true
            resetWindow(window)
        end)
    end
end

WS.UpgradeWeapon:GetPropertyChangedSignal("Visible"):Connect(function()
    if WS.UpgradeWeapon.Visible then
        local WhetstonesCount = Socket:Request("Blacksmith", "Whetstones")
        normal = WhetstonesCount.Normal
        heat = WhetstonesCount.Heat
        thermal = WhetstonesCount.Thermal
        WS.UpgradeWeapon.Upgrading.Normal.Use.Title.Text = string.format("Use (%s)", normal)
        WS.UpgradeWeapon.Upgrading.Heated.Use.Title.Text = string.format("Use (%s)", heat)
        WS.UpgradeWeapon.Upgrading.Thermal.Use.Title.Text = string.format("Use (%s)", thermal)
    end
end)

WS.UpgradeWeapon.Upgrading.Normal.Use.MouseButton1Down:Connect(function()
    if normal < 1 then
        Hint("You do not have enough Normal Whetstones.")
        return
    end
    local success, newCount = Socket:Request("Blacksmith", "UpgradeWeapon", "Normal")
    if success then
        resetWindow(WS.UpgradeWeapon)
    end
    if newCount then
        normal = newCount
        WS.UpgradeWeapon.Upgrading.Normal.Use.Title.Text = string.format("Use (%s)", newCount)
    end
end)

WS.UpgradeWeapon.Upgrading.Heated.Use.MouseButton1Down:Connect(function()
    if heat < 1 then
        Hint("You do not have enough Heated Whetstones.")
        return
    end
    local success, newCount = Socket:Request("Blacksmith", "UpgradeWeapon", "Heated")
    if success then
        resetWindow(WS.UpgradeWeapon)
    end
    if newCount then
        heat = newCount
        WS.UpgradeWeapon.Upgrading.Heated.Use.Title.Text = string.format("Use (%s)", newCount)
    end
end)

WS.UpgradeWeapon.Upgrading.Thermal.Use.MouseButton1Down:Connect(function()
    if thermal < 1 then
        Hint("You do not have enough Thermal Whetstones.")
        return
    end
    local success, newCount = Socket:Request("Blacksmith", "UpgradeWeapon", "Thermal")
    if success then
        resetWindow(WS.UpgradeWeapon)
    end
    if newCount then
        thermal = newCount
        WS.UpgradeWeapon.Upgrading.Thermal.Use.Title.Text = string.format("Use (%s)", newCount)
    end
end)

WS.ReinforceWeapon:GetPropertyChangedSignal("Visible"):Connect(function()
    if WS.ReinforceWeapon.Visible then
        resetReinforceWindow()
    end
end)

WS.EnchantWeapon:GetPropertyChangedSignal("Visible"):Connect(function()
    if WS.EnchantWeapon.Visible then
        resetEnchantWindow()
    end
end)

WS.EnchantWeapon.Enchanting.Bottom.Left.Use:GetPropertyChangedSignal("Visible"):Connect(function()
    if WS.EnchantWeapon.Enchanting.Bottom.Left.Use.Visible then
        if not enchantment then return end
        WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades.Top.Visible = true
        local possibleEnchants = Socket:Request("GetSkill")
        if possibleEnchants then
            for _, otherFrame in ipairs(WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades:GetChildren()) do
                if otherFrame:IsA("Frame") and otherFrame.Name ~= "Top" then
                    otherFrame:Destroy()
                end
            end

            local type = enchantment.info
            local Tier = string.format("Tier%s", math.clamp(math.floor(Wepon.CurrentWeapon.Tier * 0.5), 1, 4))
            for _, infusion in ipairs(possibleEnchants) do
                local category = infusion.Category
                if table.find(type.Attributes, category) then
                    local newEnchant = WS.EnchantWeapon.Enchanting.Bottom.Template.EnchantmentBlock:Clone()
                    local titleText = "%s <b><font color='rgb(142, 216, 255)'><font size='14'>(Min: %s%s, Max: %s%s)</font></font></b>"
                    if infusion.Tier1 then
                        newEnchant.Title.Text = string.format(titleText, infusion.Name, infusion[Tier].Min, infusion.Prefix, infusion[Tier].Max, infusion.Prefix)
                    else
                        newEnchant.Title.Text = infusion.Name
                    end
                    newEnchant.Desc.Text = infusion.Desc
                    newEnchant.Visible = true
                    newEnchant.Parent = WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades
                    WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades.CanvasSize = UDim2.new(0, 0, 0, WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades.UIListLayout.AbsoluteContentSize.Y)
                end
            end
        end
    end
end)

WS.EnchantWeapon.Enchanting.Bottom.Left.Use.MouseButton1Down:Connect(function()
    if enchantment then
        local code = Socket:Request("Blacksmith", "EnchantWeapon", {enchantment, catalyst})
        if code == -1 then Hint("Not enough gold to enchant!") return end
        if code == 0 then Hint("Out of enchantment materials!") return end
        if code == -2 then Hint("You cannot enchant this weapon any further.") return end
        if code == -3 then Hint("Unable to enchant due to having all enchantments possible.") return end
        if code == 1 then
            Play.PlaySound("AnvilClang")
            Hint("Successfully enchanted!")
            resetEnchantWindow()
        end
    end
end)

for _, materialButton in ipairs(WS.EnchantWeapon.Enchanting.Bottom.Left.Items:GetChildren()) do
    if materialButton:IsA("Frame") then
        materialButton.ItemBlock.TextButton.MouseButton1Down:Connect(function()
            WS.EnchantWeapon.Enchanting.Bottom.Left.Use.Visible = false
            for _, old in ipairs (WS.EnchantWeapon.MaterialList.Inventory:GetChildren()) do
                if old:IsA("Frame") then
                    old:Destroy()
                end
            end

            local name = materialButton.Name
            local getEnchantList, newAccInfo = Socket:Request("Blacksmith", string.format("%sList", name))
            if getEnchantList then
                for _, item in ipairs(getEnchantList) do
                    local NewWeaponBlock = materialButton.ItemBlock:Clone()
                    NewWeaponBlock.Border.Image = ""
                    NewWeaponBlock.LayoutOrder = 0
                    NewWeaponBlock.Position = UDim2.new(0, 0, 0, 0)
                    NewWeaponBlock.Size = UDim2.new(1, 0, 1, 0)
                    NewWeaponBlock.TextButton.Image = item.info.Image
                    NewWeaponBlock.TextButton.MouseButton1Down:Connect(function()
                        local currentMight = Wepon.CurrentWeapon.UpLvl
                        local tier = math.clamp(math.floor(Wepon.CurrentWeapon.Tier * 0.5), 1, 4)
                        local price = (15 * Wepon.Object.LevelReq) * tier
                        local description = ""
                        if name == "Enchant" then
                            enchantment = item
                        else
                            catalyst = item
                            description = item.info.SubDescription
                            WS.EnchantWeapon.Enchanting.Bottom.PotentialUpgrades.Top.Desc.Text = string.format("* Weapon cannot gain duplicate effects. %s", description)
                        end
                        if catalyst then
                            price *= 2
                        end
                        DataValues.AccInfo = newAccInfo
                        materialButton.ItemBlock.TextButton.Image = item.info.Image
                        WS.EnchantWeapon.Enchanting.Bottom.Left.GoldCost.Value.Text = FormatInteger(price)
                        WS.EnchantWeapon.Enchanting.Bottom.Left.CurrentGold.Value.Text = FormatInteger(DataValues.AccInfo.Gold)
                        WS.EnchantWeapon.Enchanting.Visible = true
                        WS.EnchantWeapon.Enchanting.Bottom.Left.Use.Visible = true
                        WS.EnchantWeapon.MaterialList.Visible = false
                    end)

                    NewWeaponBlock.Parent = WS.EnchantWeapon.MaterialList.Inventory
                    WS.EnchantWeapon.MaterialList.Inventory.CanvasSize = UDim2.new(0, 0, 0, WS.EnchantWeapon.MaterialList.Inventory.UIGridLayout.AbsoluteContentSize.Y)
                end
                WS.EnchantWeapon.Enchanting.Visible = false
                WS.EnchantWeapon.MaterialList.Visible = true
            else
                Hint(string.format("You do not have any %s materials!", name))
            end
        end)
    end
end


--- initialize
BS.Enabled = false
