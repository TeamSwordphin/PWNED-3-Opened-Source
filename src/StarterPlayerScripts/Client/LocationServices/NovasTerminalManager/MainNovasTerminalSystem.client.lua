-- << Services >> --
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local NT        = GUI:WaitForChild("NovasTerminalGUI")

-- << Modules >> --
local Socket 	    = require(MODULES.socket)
local Hint          = require(CLIENT.UIEffects.Hint)
local FormatInteger = require(CLIENT.UIEffects.FormatInteger)
local DataValues    = require(CLIENT.DataValues)
local animateText   = require(CLIENT.UIEffects.TextScrolling)
local Play          = require(MODULES.Effects.CommonModules.SoundManager)
local Promise       = require(ReplicatedStorage.Scripts.Modules.Promise)
local toClock       = require(CLIENT.UIEffects.SecondsToClock)

-- << Variables >> --
local outerFrame = NT.OuterFrame
local animatable = outerFrame.TitleAnimatable
local content = animatable.Content
local management = content.Management
local right = management.Right.Side
local facilitiesInformation
local powerButton, upgradeButton, destroyButton, buildButton

local facilities


---------------------

if not NT then return end

local function resetNovasTerminal()
    outerFrame.Position = UDim2.new(0.025, 0, 0.5, 0)
    outerFrame.Size = UDim2.new(0.95, 0, 0, 0)

    animatable.Size = UDim2.new(0, 0, 0, 0)
    animatable.BorderSizePixel = 0
    animatable.Title.TextTransparency = 1

    for _, rune in ipairs(animatable.Runic:GetChildren()) do
        if rune:IsA("ImageLabel") then
            rune.ImageTransparency = 1
        end
    end

    content.Size = UDim2.new(1, 0, 0, 0)
    management.Visible = false
    
    for _, title in ipairs(content:GetDescendants()) do
        if title.Name == "Title" then
            title.Text = ""
            title.Parent.Size = UDim2.new(0, 0, 0, 0)
            title.Parent.Parent.Visible = true
        end
    end
end

NT:GetPropertyChangedSignal("Enabled"):Connect(function()
    if NT.Enabled then
        resetNovasTerminal()

        TweenService:Create(outerFrame, TweenInfo.new(0.4), {Size = UDim2.new(0.95, 0, 0.95, 0), Position = UDim2.new(0.025, 0, 0.025, 0)}):Play()
        wait(0.45)
        TweenService:Create(animatable, TweenInfo.new(0.1), {BorderSizePixel = 5}):Play()
        wait(0.2)
        TweenService:Create(animatable, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        wait(0.25)
        TweenService:Create(animatable, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        wait(0.25)

        TweenService:Create(animatable.Title, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
        for _, rune in ipairs(animatable.Runic:GetChildren()) do
            if rune:IsA("ImageLabel") then
                TweenService:Create(rune, TweenInfo.new(0.25), {ImageTransparency = 0}):Play()
            end
        end

        wait(0.25)
        TweenService:Create(content, TweenInfo.new(0.6), {Size = UDim2.new(1, 0, 0.6, 0)}):Play()
        wait(0.4)
        for _, title in ipairs(content:GetDescendants()) do
            if title.Name == "Title" then
                Promise.try(function()
                    TweenService:Create(title.Parent, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    wait(0.15)
                    TweenService:Create(title.Parent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 1, 0)}):Play()
                    wait(0.2)
                    animateText(true, title, title.Parent.Name, 0.03)
                end)
            end
        end
    end
end)

content.ExitFrame:FindFirstChild("TextButton", true).MouseButton1Down:Connect(function()
    NT.Enabled = false
end)

management.Left.Bottom.ExitFrame:FindFirstChild("TextButton", true).MouseButton1Down:Connect(function()
    NT.Enabled = false
end)

local function resetManagementWindow()
    management.Spacer.Spacer.Size = UDim2.new(0, 1, 0, 0)
    management.Facilities.ScrollBarImageTransparency = 1
    management.Facilities.Size = UDim2.new(0.7, 0, 0.95, 0)
    management.Right.Size = UDim2.new(0, 0, 0.95, 0)
    management.Left.Status.TitleMain.TextTransparency = 1

    for _, title in ipairs(management.Left.Bottom:GetDescendants()) do
        if title.Name == "Titler" then
            title.Text = ""
            title.Parent.Size = UDim2.new(0, 0, 0, 0)
        end
    end

    for _, info in ipairs(management.Left.Status:GetChildren()) do
        local information = info:FindFirstChild("Info") 

        if information then
            information.Position = UDim2.new(-2, 0, 0, 0)
            information.BG.BackgroundTransparency = 1
            information.Values.TextLabel.TextTransparency = 1
            information.Values.LogoFrame.Logo.ImageTransparency = 1
        end
    end
end

content.PowerFrame:FindFirstChild("TextButton", true).MouseButton1Down:Connect(function()
    for _, title in ipairs(content:GetDescendants()) do
        if title.Name == "Title" then
            Promise.try(function()
                TweenService:Create(title.Parent, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                wait(0.15)
                TweenService:Create(title.Parent, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                wait(0.15)
                title.Parent.Parent.Visible = false
            end)
        end
    end
    wait(0.15)
    TweenService:Create(content, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    wait(0.5)
    resetManagementWindow()
    management.Visible = true
end)

management:GetPropertyChangedSignal("Visible"):Connect(function()
    if management.Visible then
        for _, oldFacilities in ipairs(management.Facilities:GetChildren()) do
            if oldFacilities.Name ~= "AddMore" and oldFacilities:IsA("Frame") then
                oldFacilities:Destroy()
            end
        end

        TweenService:Create(management.Spacer.Spacer, TweenInfo.new(0.5), {Size = UDim2.new(0, 1, 0.95, 0)}):Play()
        wait(0.4)
        TweenService:Create(management.Facilities, TweenInfo.new(0.5), {ScrollBarImageTransparency = 0}):Play()
        TweenService:Create(management.Left.Status.TitleMain, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

        for _, title in ipairs(management.Left.Bottom:GetDescendants()) do
            if title.Name == "Titler" then
                Promise.try(function()
                    TweenService:Create(title.Parent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    wait(0.25)
                    TweenService:Create(title.Parent, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 1, 0)}):Play()
                    wait(0.2)
                    animateText(true, title, title.Parent.Name, 0.03)
                end)
            end
        end

        for _, info in ipairs(management.Left.Status:GetChildren()) do
            Promise.try(function()
                local information = info:FindFirstChild("Info") 

                if information then
                    TweenService:Create(information, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)}):Play()
                    TweenService:Create(information.BG, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
                    TweenService:Create(information.Values.TextLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                    TweenService:Create(information.Values.LogoFrame.Logo, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
                end
            end)
        end

        if not facilitiesInformation then
            facilitiesInformation = Socket:Request("GetFacilitiesInformation")
        end

        wait(0.5)

        facilities = DataValues.AccInfo.BuiltFacilities

        local function createFacilityState(reset)
            if reset then
                for _, oldFacilities in ipairs(management.Facilities:GetChildren()) do
                    if oldFacilities.Name ~= "AddMore" and oldFacilities:IsA("Frame") then
                        oldFacilities:Destroy()
                    end
                end
            end

            local powerAvailable = 0
            local powerCost = 0
            local powerMax = 0
            local facilitiesBuilt = 0
            local facilitiesMax = 0

            management.Left.Status.Gold.Info.Values.TextLabel.Text = FormatInteger(DataValues.AccInfo.Gold)
            TweenService:Create(management.Facilities, TweenInfo.new(0.25), {Size = UDim2.new(0.7, 0, 0.95, 0)}):Play()
            TweenService:Create(management.Right, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0.95, 0)}):Play()

            local powerGrids = 0
            local powerPlants = 0

            local confirmation = false

            local function findFacility(id)
                for _, facility in ipairs(facilities) do
                    if facility.ID == id then
                        return facility
                    end
                end
            end

            if not findFacility(1).Active then
                for _, facility in ipairs(facilities) do
                    facility.Active = false
                end
            end

            for _, facility in ipairs(facilities) do
                for _, information in ipairs(facilitiesInformation) do
                    if facility.ID == information.ID then
                        local active = facility.Active

                        local newFacilityUI = management.Facilities.Template.Facility:Clone()
                        newFacilityUI.LayoutOrder = information.ID

                        if facility.BuildDate then
                            active = false
                            newFacilityUI.Main.Timer.Visible = true
                            Promise.try(function()
                                while newFacilityUI do
                                    local timeLeft = facility.EndDate - os.time()
                                    newFacilityUI.Main.Timer.Text = toClock(timeLeft, true)

                                    if timeLeft < 0 then
                                        facility.Active = true
                                        newFacilityUI.Main.Timer.Visible = false
                                        break
                                    end
                                    wait(1)
                                end
                            end)
                        end

                        newFacilityUI.Main.Position = UDim2.new(0, 0, -1, 0)
                        newFacilityUI.Main.BorderColor3 = not active and Color3.fromRGB(20, 34, 36) or newFacilityUI.Main.BorderColor3
                        newFacilityUI.Main.BuildingName.Text = information.Style
                        newFacilityUI.Main.BuildingName.TextTransparency = not active and 0.5 or newFacilityUI.Main.BuildingName.TextTransparency

                        if information.Model then
                            local newFacilityModel = information.Model:Clone()
                            newFacilityModel.Parent = newFacilityUI.Main.ViewportFrame.WorldModel

                            local camera = Instance.new("Camera", newFacilityUI)
                            camera.CFrame = newFacilityModel.PrimaryPart.CFrame * CFrame.new(3, 1, -10)
                            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, newFacilityModel.PrimaryPart.Position)

                            newFacilityUI.Main.ViewportFrame.CurrentCamera = camera
                        end

                        newFacilityUI.Main.ViewportFrame.ImageTransparency = not active and 0.75 or newFacilityUI.Main.ViewportFrame.ImageTransparency
                        newFacilityUI.Visible = true
                        newFacilityUI.Parent = management.Facilities

                        if not reset then
                            TweenService:Create(newFacilityUI.Main, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 0)}):Play()
                        else
                            newFacilityUI.Main.Position = UDim2.new(0, 0, 0, 0)
                        end
                        
                        powerCost += active and information.PowerRequired or 0

                        local value = information.Levels[facility.Level].Value

                        if information.Name == "Power Grid" then
                            powerGrids += 1
                            powerMax += active and value or 0
                        elseif information.Name == "Mainframe" then
                            facilitiesMax = value
                        elseif information.Name == "Power Plant" then
                            powerPlants += 1
                            powerAvailable += active and value or 0
                        end

                        newFacilityUI.Main.TextButton.MouseButton1Down:Connect(function()
                            if powerButton then
                                powerButton:Disconnect()
                            end

                            if upgradeButton then
                                upgradeButton:Disconnect()
                            end

                            if destroyButton then
                                destroyButton:Disconnect()
                            end

                            local canUpgrade = true

                            powerButton = right.Bottom.PowerFrame.Power.TextButton.MouseButton1Down:Connect(function()
                                if facility.ID ~= 1 and not findFacility(1).Active then
                                    Hint("This facility requires the Mainframe to be powered on.")
                                    return
                                end

                                Socket:Emit("Facility", "PowerToggle", facility)
                                facility.Active = not facility.Active
                                createFacilityState(true)
                            end)

                            upgradeButton = right.Bottom.UpgradeFrame.Upgrade.TextButton.MouseButton1Down:Connect(function()
                                if not canUpgrade then
                                    Hint("You lack the materials to upgrade this facility.")
                                    return
                                end

                                local success, newAccInfo = Socket:Request("Facility", "Upgrade", facility)
                                if success then
                                    Hint(string.format("%s has been upgraded.", information.Name))
                                    DataValues.AccInfo = newAccInfo
                                    facilities = DataValues.AccInfo.BuiltFacilities
                                    createFacilityState(true)
                                end
                            end)

                            destroyButton = right.Bottom.DestroyFrame.DestroyUI.TextButton.MouseButton1Down:Connect(function()
                                if facility.ID == 1 then
                                    Hint("You cannot destroy the Mainframe facility.")
                                    return
                                end

                                if facility.ID == 3 and powerGrids <= 1 then
                                    Hint("You cannot destroy your only power grid.") 
                                    return
                                end

                                if facility.ID == 2 and powerPlants <= 1 then
                                    Hint("You cannot destroy your only power plant.")
                                    return
                                end

                                if not confirmation then
                                    confirmation = true
                                    right.Bottom.DestroyFrame.DestroyUI.Words.Text = "CONFIRM?"
                                else
                                    right.Bottom.DestroyFrame.DestroyUI.Words.Text = "Destroy"
                                    local success, newAccInfo = Socket:Request("Facility", "Destroy", facility)
                                    if success then
                                        Hint(string.format("%s has been destroyed.", information.Name))
                                        DataValues.AccInfo = newAccInfo
                                        facilities = DataValues.AccInfo.BuiltFacilities
                                        createFacilityState(true)
                                    end
                                end
                            end)

                            right.Bottom.DestroyFrame.DestroyUI.Words.Text = "Destroy"
                            right.Bottom.PowerFrame.Power.TextButton.BorderColor3 = active and Color3.fromRGB(137, 255, 110) or Color3.fromRGB(255, 239, 114)
                            right.Bottom.PowerFrame.Power.Words.TextColor3 = active and Color3.fromRGB(137, 255, 110) or Color3.fromRGB(255, 239, 114)
                            right.Bottom.PowerFrame.Power.Letter.ImageColor3 = active and Color3.fromRGB(55, 255, 165) or Color3.fromRGB(255, 97, 66)
                            right.Bottom.PowerFrame.Power.Words.Text = active and "Power On" or "Power Off"

                            right.Bottom.PowerFrame.Visible = true
                            right.Bottom.UpgradeFrame.Upgrade.Words.Text = "Upgrade"
                            right.Bottom.DestroyFrame.DestroyUI.Visible = true

                            right.Status.StatFrame.Visible = true

                            TweenService:Create(management.Facilities, TweenInfo.new(0.25), {Size = UDim2.new(0.4, 0, 0.95, 0)}):Play()
                            TweenService:Create(management.Right, TweenInfo.new(0.25), {Size = UDim2.new(0.3, 0, 0.95, 0)}):Play()

                            right.Status.StatFrame.PowerRequired.BG.TextLabel.Text = information.PowerRequired
                            right.Status.StatFrame.MaxLevel.BG.TextLabel.Text = string.format("Max Lv.%s", information.MaxLevels)
                            right.Status.TitleFrame.TextLabel.Text = string.format("%s Lv.%s", information.Name, facility.Level)

                            for _, oldMaterial in ipairs(right.Status.Materials:GetChildren()) do
                                if oldMaterial:IsA("Frame") then
                                    oldMaterial:Destroy()
                                end
                            end

                            if facility.Level < information.MaxLevels then
                                right.Status.Materials.Visible = true
                                right.Status.Materials.TextLabel.Text = string.format("Materials Required for Lv.%s", facility.Level + 1)

                                local materialRequired = information.Levels[facility.Level + 1].MaterialsRequired
                                local getMaterialCount = Socket:Request("GetBuildingMaterials", materialRequired)
                                
                                for _, material in ipairs(materialRequired) do
                                    local requiredAmount = material[2]
                                    local materialName = material[1]
                                    local materialImage = ""
                                    local currentAmount = materialName == "Gold" and DataValues.AccInfo.Gold or 0

                                    for _, playerMaterial in ipairs(getMaterialCount) do
                                        if playerMaterial.Info.Name == materialName then
                                            currentAmount = playerMaterial.Quantity
                                            materialImage = playerMaterial.Info.Image
                                            break
                                        end
                                    end

                                    local notEnough = currentAmount < requiredAmount
                                    local currentAmountTextColor = notEnough and "rgb(230,0,0)" or "rgb(245,245,245)"

                                    if canUpgrade and notEnough then
                                        canUpgrade = false
                                    end

                                    local newMaterial = right.Status.Materials.Template.Material:Clone()
                                    newMaterial.Description.Text = string.format(
                                        "<font size='40' color='%s'> <b>%s</b></font><font size='16' color='rgb(147, 147, 147)'> <b>/%s %s</b></font>",
                                        currentAmountTextColor,
                                        currentAmount,
                                        requiredAmount,
                                        materialName
                                    )

                                    newMaterial.ImageLabel.Image = materialName == "Gold" and "http://www.roblox.com/asset/?id=179409544" or materialImage
                                    newMaterial.Visible = true
                                    newMaterial.Parent = right.Status.Materials
                                    right.Status.Materials.CanvasSize = UDim2.new(0, 0, 0, right.Status.Materials.UIListLayout.AbsoluteContentSize.Y + 5)
                                end
                            else
                                right.Status.Materials.Visible = false
                            end

                            animateText(true, right.Status.DescriptionFrame.TextLabel, information.Levels[facility.Level].Description)
                        end)

                        break
                    end
                end

                facilitiesBuilt += 1
            end

            local powerUsed = math.min(powerMax, powerAvailable)
            powerUsed -= powerCost

            management.Left.Status.Power.Info.Values.TextLabel.Text = string.format(
                "<font size='50' color='rgb(245,245,245)'> <b>%s</b></font><font size='24' color='rgb(147, 147, 147)'> <b>/%s</b></font>",
                powerUsed,
                powerMax
            )

            management.Left.Status.Built.Info.Values.TextLabel.Text = string.format(
                "<font size='50' color='rgb(245,245,245)'> <b>%s</b></font><font size='24' color='rgb(147, 147, 147)'> <b>/%s</b></font>",
                facilitiesBuilt,
                facilitiesMax
            )

            management.Facilities.CanvasSize = UDim2.new(0, 0, 0, management.Facilities.UIGridLayout.AbsoluteContentSize.Y)
        end

        if buildButton then
            buildButton:Disconnect()
        end

        buildButton = management.Facilities.AddMore.Main.TextButton.MouseButton1Down:Connect(function()
            for _, oldFacilities in ipairs(management.Facilities:GetChildren()) do
                if oldFacilities.Name == "BuildFacility"then
                    oldFacilities:Destroy()
                end
            end
        
            TweenService:Create(management.Facilities, TweenInfo.new(0.25), {Size = UDim2.new(0.7, 0, 0.95, 0)}):Play()
            TweenService:Create(management.Right, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0.95, 0)}):Play()
        
            for _, availableFacility in ipairs(facilitiesInformation) do
                if availableFacility.ID ~= 1 then
                    local newFacilityBuilder = management.Facilities.Template.BuildFacility:Clone()
                    newFacilityBuilder.LayoutOrder = 999 + availableFacility.ID
                    newFacilityBuilder.Main.Position = UDim2.new(0, 0, -1, 0)
                    newFacilityBuilder.Main.BuildingName.Text = availableFacility.Style
        
                    if availableFacility.Model then
                        local newFacilityModel = availableFacility.Model:Clone()
                        newFacilityModel.Parent = newFacilityBuilder.Main.ViewportFrame.WorldModel
        
                        local camera = Instance.new("Camera", newFacilityBuilder)
                        camera.CFrame = newFacilityModel.PrimaryPart.CFrame * CFrame.new(3, 1, -10)
                        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, newFacilityModel.PrimaryPart.Position)
        
                        newFacilityBuilder.Main.ViewportFrame.CurrentCamera = camera
                    end
        
                    newFacilityBuilder.Main.Position = UDim2.new(0, 0, 0, 0)
                    newFacilityBuilder.Visible = true
                    newFacilityBuilder.Parent = management.Facilities
        
                    newFacilityBuilder.Main.TextButton.MouseButton1Down:Connect(function()
                        if upgradeButton then
                            upgradeButton:Disconnect()
                        end
        
                        upgradeButton = right.Bottom.UpgradeFrame.Upgrade.TextButton.MouseButton1Down:Connect(function()
                            print(1)
                            local success, newAccInfo = Socket:Request("Facility", "Build", availableFacility)
        
                            print(success, newAccInfo)
                            if success then
                                Hint("Commencing construction on facility %s.", availableFacility.Name)
                                DataValues.AccInfo = newAccInfo
                                facilities = DataValues.AccInfo.BuiltFacilities
                                createFacilityState(true)
                            else
                                Hint("Destroy facilities or upgrade your Mainframe to build more facilities.")
                            end
                        end)
        
                        right.Bottom.PowerFrame.Visible = false
                        right.Bottom.UpgradeFrame.Upgrade.Words.Text = "Build"
                        right.Bottom.DestroyFrame.DestroyUI.Visible = false
        
                        for _, oldMaterial in ipairs(right.Status.Materials:GetChildren()) do
                            if oldMaterial:IsA("Frame") then
                                oldMaterial:Destroy()
                            end
                        end
        
                        right.Status.StatFrame.PowerRequired.BG.TextLabel.Text = availableFacility.PowerRequired
                        right.Status.StatFrame.MaxLevel.BG.TextLabel.Text = string.format("Max Lv.%s", availableFacility.MaxLevels)
        
                        right.Status.Materials.Visible = true
                        right.Status.Materials.TextLabel.Text = string.format("Materials Required for Building")
        
                        local materialRequired = availableFacility.Levels[1].CraftingMaterialsRequired
                        local getMaterialCount = Socket:Request("GetBuildingMaterials", materialRequired)
                        
                        for _, material in ipairs(materialRequired) do
                            local requiredAmount = material[2]
                            local materialName = material[1]
                            local materialImage = ""
                            local currentAmount = materialName == "Gold" and DataValues.AccInfo.Gold or 0
        
                            for _, playerMaterial in ipairs(getMaterialCount) do
                                if playerMaterial.Info.Name == materialName then
                                    currentAmount = playerMaterial.Quantity
                                    materialImage = playerMaterial.Info.Image
                                    break
                                end
                            end
        
                            local notEnough = currentAmount < requiredAmount
                            local currentAmountTextColor = notEnough and "rgb(230,0,0)" or "rgb(245,245,245)"
        
                            local newMaterial = right.Status.Materials.Template.Material:Clone()
                            newMaterial.Description.Text = string.format(
                                "<font size='40' color='%s'> <b>%s</b></font><font size='16' color='rgb(147, 147, 147)'> <b>/%s %s</b></font>",
                                currentAmountTextColor,
                                currentAmount,
                                requiredAmount,
                                materialName
                            )
        
                            newMaterial.ImageLabel.Image = materialName == "Gold" and "http://www.roblox.com/asset/?id=179409544" or materialImage
                            newMaterial.Visible = true
                            newMaterial.Parent = right.Status.Materials
                            right.Status.Materials.CanvasSize = UDim2.new(0, 0, 0, right.Status.Materials.UIListLayout.AbsoluteContentSize.Y + 5)
                        end
        
                        TweenService:Create(management.Facilities, TweenInfo.new(0.25), {Size = UDim2.new(0.4, 0, 0.95, 0)}):Play()
                        TweenService:Create(management.Right, TweenInfo.new(0.25), {Size = UDim2.new(0.3, 0, 0.95, 0)}):Play()
        
                        right.Status.TitleFrame.TextLabel.Text = string.format("%s", availableFacility.Name)
                        animateText(true, right.Status.DescriptionFrame.TextLabel, availableFacility.Levels[1].Description)
                    end)
                end
            end
        end)

        createFacilityState()
    end
end)



NT.Enabled = false
