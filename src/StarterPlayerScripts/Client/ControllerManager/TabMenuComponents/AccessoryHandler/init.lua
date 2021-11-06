--[[

local accessory = {
    Name = "",
    Attachment = "BodyBackAttachment",
    Position = {X = 0, Y = 0, Z = 0},
    Rotation = {X = 0, Y = 0, Z = 0},
    Colors = {
        color1 = {R = 0, G = 0, B = 0},
        color2 = {R = 0, G = 0, B = 0},
        color3 = {R = 0, G = 0, B = 0},
    }
}

--]]
-- << Services >> --
local ReplicatedStorage     = game:GetService("ReplicatedStorage")
local Players 				= game:GetService("Players")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local MENU   	= GUI:WaitForChild("AccessoriesGUI")
local MAIN      = MENU.Main

-- << Modules >> --
local Socket 		= require(MODULES.socket)
local Hint		  	= require(CLIENT.UIEffects.Hint)
local DataValues 	= require(CLIENT.DataValues)
local cameraControl

-- << Variables >> --
local Folder            = ReplicatedStorage.Models.Accessories
local AccessoryButtons  = {}
local currentTrophy
local currentArmor   


-----------------
function returnButton()
    MENU.Enabled = false
end

function onAccessoryMenuOpen()
    if not cameraControl then
        cameraControl = require(script.CameraController)
    end

    if MENU.Enabled then
        local character = DataValues.CharInfo
        for _, accessory in ipairs(AccessoryButtons) do
            accessory.MainWindow.AccessoryBlock.ViewportFrame:ClearAllChildren()
            local slot = character.CurrentAccessories[accessory.Name]
            if slot then
                local findObject = Folder:FindFirstChild(slot.Name)
                if findObject then
                    local newObject = findObject:Clone()
                    newObject.Parent = accessory.MainWindow.AccessoryBlock.ViewportFrame
                    local cam = Instance.new("Camera")
                    cam.CFrame = CFrame.new(newObject.Handle.Position - Vector3.new(2, 0, 7), newObject.Handle.Position)
                    cam.Parent = accessory.MainWindow.AccessoryBlock.ViewportFrame
                    accessory.MainWindow.AccessoryBlock.ViewportFrame.CurrentCamera = cam
                    
                end
            end
            accessory.Visible = true
        end
        MAIN.Inventory.Visible = false
        cameraControl:Enable()
    else
        cameraControl:Disable()
    end
end

function onInventoryOpen()
    if MAIN.Inventory.Visible then
        for _, stuff in ipairs(MAIN.Inventory:GetChildren()) do
            if stuff:IsA("Frame") then
                stuff:Destroy()
            end
        end
    end
end

function initialize()
    for _, accessorySlot in ipairs(MAIN:GetChildren()) do
        if accessorySlot:FindFirstChild("accessory") then
            table.insert(AccessoryButtons, accessorySlot)
            accessorySlot.MainWindow.AccessoryBlock.TextButton.MouseButton1Down:Connect(function()
                for _, accessory in ipairs(AccessoryButtons) do
                    accessory.Visible = false
                    MAIN.Inventory.Visible = true
                    local accInventory = DataValues.AccInfo.Accessories
                    for _, acc in ipairs(accInventory) do
                        local newBlock = MENU.Template.ItemBlock:Clone()
                        newBlock.TextButton.MouseButton1Down:Connect(function()
                            ---
                        end)
                        newBlock.Parent = MAIN.Inventory
                    end
                end
            end)
        end
    end

    MENU.Enabled = false

    MENU:GetPropertyChangedSignal("Enabled"):Connect(onAccessoryMenuOpen)
    MAIN.Inventory:GetPropertyChangedSignal("Visible"):Connect(onInventoryOpen)
    MENU.BackButton.MouseButton1Down:Connect(returnButton)
end

initialize()
return nil