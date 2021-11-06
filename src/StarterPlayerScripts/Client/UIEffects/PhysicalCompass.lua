-- << Services >>
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- << Constants >>
local PLAYER = Players.LocalPlayer
local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local CAMERA = workspace.Camera
local GUI = PLAYER:WaitForChild("PlayerGui")

-- << Variables >>
local CFNew = CFrame.new
local Vec3 = Vector3.new
local Terrain = workspace.Terrain
local lobby


-------------------
local compassModule = {}
local compasses = {}
local ring

local ringTexture = Instance.new("Decal")
ringTexture.Texture = "http://www.roblox.com/asset/?id=169199350"
ringTexture.Face = "Top"
ringTexture.Transparency = 0.4

local ring_offset = Vec3(0, 1, 0)

local function characterAdded(newCharacter)
    CHARACTER = newCharacter or PLAYER.CharacterAdded:Wait()
end

function compassModule:new(part, isStory)
    lobby = workspace:FindFirstChild("Lobby")

    if not lobby then return end

    local newCompassObject = {}
    local newAttachment = Instance.new("Attachment", Terrain)

    local newCompassUI = ReplicatedStorage.GUI.BillboardGui.Compass:Clone()
    newCompassUI.Adornee = newAttachment
    newCompassUI.Enabled = true
    newCompassUI.Parent = GUI

    local newObject = ReplicatedStorage.GUI.BillboardGui.ViewportFrameIcons[isStory and "StoryIcon" or part.Name]:Clone()
    newObject.Parent = newCompassUI.ViewportFrame
    newCompassUI.TextLabel.Text = newObject.OutletName.Value

    local newCamera = Instance.new("Camera", newCompassUI)
    newCamera.CFrame = newObject.CameraCF.Value
    newCompassUI.ViewportFrame.CurrentCamera = newCamera

    newCompassObject.Attachment = newAttachment
    newCompassObject.CompassUI = newCompassUI
    newCompassObject.Part = part

    if part.Name == "DungeonEntrance" then
        local newModel = Instance.new("Model", workspace.Interactables)
        newModel.Name = part.Name
        newModel.PrimaryPart = part
        part.Parent = newModel
    end

    table.insert(compasses, newCompassObject)

    if not ring then
        ring = Instance.new("Part")
        ring.Name = "Ring"
        ring.CastShadow = false
        ring.Massless = true
        ring.Anchored = false
        ring.CanCollide = false
        ring.Transparency = 1
        ring.FormFactor = "Plate"
        ring.Size = Vec3(10, 0.1, 10)
        ringTexture:Clone().Parent = ring
        ring.Parent = CHARACTER

        local weld = CHARACTER.CompassWeld:Clone()
        weld.Part0 = CHARACTER.PrimaryPart
        weld.Part1 = ring
        weld.Parent = CHARACTER.PrimaryPart
    end

    return newCompassUI.TextLabel
end

function compassModule:run()
    if not lobby or not ring then return end

    local DISTANCE = 5

    for _, compass in ipairs(compasses) do
        local part = compass.Part
        local direction = part.Position - CHARACTER.PrimaryPart.Position
        local directionProject = direction:Dot(ring_offset)
        local finalDirectionOffset = (direction - (ring_offset * directionProject)).Unit

        compass.Attachment.WorldPosition = (ring.Position + ring_offset) + finalDirectionOffset * DISTANCE
    end
end

PLAYER.CharacterAdded:Connect(characterAdded)

return compassModule