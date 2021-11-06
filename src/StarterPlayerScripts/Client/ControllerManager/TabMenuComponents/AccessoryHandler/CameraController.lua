-- ========================================
-- GLOBAL VARIABLES
-- ========================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- The camera used by the LocalPlayer
local camera = game.Workspace.CurrentCamera

local players = game:GetService("Players")
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local torso = character:WaitForChild("HumanoidRootPart")
local playerPosition = torso.Position

local default_CameraPosition = torso.Position
local default_CameraRotation = Vector2.new(0,math.rad(-60))
local default_CameraZoom = 8

local cameraPosition = default_CameraPosition
local cameraRotation = default_CameraRotation
local cameraZoom = default_CameraZoom

local cameraRotationBounds = {math.rad(-81),math.rad(20)}
local cameraZoomBounds = nil --{10,200}
local touchDragSpeed = 0.15
local cameraSpeed = 0.1
local cameraRotateSpeed = 10
local cameraMouseRotateSpeed = 0.08
local cameraTouchRotateSpeed = 10
-- ========================================
-- ========================================
function characterAdded(character)
	character = character
	torso = character:WaitForChild("HumanoidRootPart")
	playerPosition = torso.Position
	default_CameraPosition = torso.Position
end

player.CharacterAdded:Connect(characterAdded)


-- ========================================
-- UTILITY FUNCTIONS
-- ========================================
local function SetCameraMode()
	camera.CameraType = "Scriptable"
	camera.FieldOfView = 80
	camera.CameraSubject = nil
end

local function UpdateCamera()
	SetCameraMode()
	local cameraRotationCFrame = CFrame.Angles(0, cameraRotation.X, 0) * CFrame.Angles(-0.2, 0, 0)
	camera.CFrame = cameraRotationCFrame + cameraPosition + cameraRotationCFrame * Vector3.new(0, 0, cameraZoom)
	camera.Focus = camera.CFrame - Vector3.new(0, camera.CFrame.p.Y, 0)
end
-- ========================================
-- ========================================




-- ========================================
-- MOBILE CAMERA EVENTS
-- ========================================
-- Events used to control the camera for players using a mobile device

-- ====================
-- CAMERA MOVE
-- ====================
-- Fired by UserInputService.TouchPan
local lastTouchTranslation = nil
local function TouchMove(touchPositions, totalTranslation, velocity, state)
	if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
		local difference = totalTranslation - lastTouchTranslation
		cameraPosition = cameraPosition + Vector3.new(difference.X, 0, difference.Y)
		UpdateCamera()
	end
	lastTouchTranslation = totalTranslation
end

-- ====================
-- CAMERA ROTATE
-- ====================
-- Fired by UserInputService.TouchRotate
local lastTouchRotation = nil
local function TouchRotate(touchPositions, rotation, velocity, state)
	if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
		local difference = rotation - lastTouchRotation
		cameraRotation = cameraRotation + Vector2.new(-difference,0)*math.rad(cameraTouchRotateSpeed*cameraRotateSpeed)
		UpdateCamera()
	end
	lastTouchRotation = rotation
end

-- ====================
-- CAMERA ZOOM
-- ====================
-- Fired by UserInputService.TouchPinch
local lastTouchScale = nil
local function TouchZoom(touchPositions, scale, velocity, state)
	if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
		local difference = scale - lastTouchScale
		cameraZoom = cameraZoom * (1 + difference)
		if cameraZoomBounds ~= nil then
			cameraZoom = math.min(math.max(cameraZoom, cameraZoomBounds[1]), cameraZoomBounds[2])
		else
			cameraZoom = math.max(cameraZoom, 0)
		end
		UpdateCamera()
	end
	lastTouchScale = scale
end

local function Input()
	UpdateCamera()
end
-- ========================================





-- ========================================
-- NON-MOBILE CAMERA EVENTS
-- ========================================

local function Input(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		if inputObject.UserInputState == Enum.UserInputState.Begin then						
			-- ====================
			-- CAMERA ZOOM
			-- ====================
			-- (I) Zoom In
			if inputObject.KeyCode == Enum.KeyCode.I then
				cameraZoom = cameraZoom - 15
			elseif inputObject.KeyCode == Enum.KeyCode.O then
				cameraZoom = cameraZoom + 15
			end
			
			-- (O) Zoom Out
			if cameraZoomBounds ~= nil then
				cameraZoom = math.min(math.max(cameraZoom, cameraZoomBounds[1]), cameraZoomBounds[2])
			else
				cameraZoom = math.max(cameraZoom, 0)
			end
			
			UpdateCamera()
		end
	end
	
	-- ====================
	-- CAMERA ROTATE
	-- ====================
	local pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	if pressed then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		local rotation = UserInputService:GetMouseDelta()
		cameraRotation = cameraRotation + rotation*math.rad(cameraMouseRotateSpeed)
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

-- ====================
-- CAMERA MOVE
-- ====================
local function PlayerChanged()
	local movement = torso.Position - playerPosition
	cameraPosition = cameraPosition + movement
	playerPosition = torso.Position
	
	UpdateCamera()
end
-- ========================================
-- ========================================






-- ========================================
-- DEVICE CHECK
-- ========================================
-- Determine whether the user is on a mobile device

local cameraControl = {}
local connections   = {}

local CLIENT 	    = script.Parent.Parent.Parent.Parent
local DataValues    = require(CLIENT.DataValues)

function cameraControl:Disable()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    DataValues.CameraEnabled = true
end

function cameraControl:Enable()
	print(1)
    if UserInputService.TouchEnabled then
        -- The user is on a mobile device, use Touch events
        table.insert(connections, UserInputService.TouchPan:Connect(TouchMove))
        table.insert(connections, UserInputService.TouchRotate:Connect(TouchRotate))
        table.insert(connections, UserInputService.TouchPinch:Connect(TouchZoom))
    else
        
        -- The user is not on a mobile device use Input events
        table.insert(connections, UserInputService.InputBegan:Connect(Input))
        table.insert(connections, UserInputService.InputChanged:Connect(Input))
        table.insert(connections, UserInputService.InputEnded:Connect(Input))
        
        -- Camera controlled by player movement
		table.insert(connections, RunService.RenderStepped:Connect(PlayerChanged))
    end
	DataValues.CameraEnabled = false
end
-- ========================================
-- ========================================

return cameraControl