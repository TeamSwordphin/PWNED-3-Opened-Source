local TweenService      = game:GetService("TweenService")
local Players	        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- << RenderStepped >> --
local renderStep = game:GetService("RunService").RenderStepped

-- << Constants >> --
local CLIENT    = script.Parent.Parent
local CAMERA    = workspace.Camera
local PLAYER 	= Players.LocalPlayer
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local MAINMENU  = GUI:WaitForChild("MainMenu").CharSelect

-- << Modules >> --
local dataValues    = require(CLIENT.DataValues)
local MusicPlayer   = require(MODULES.MusicPlayer)
local Socket        = require(MODULES.socket)
local Promise       = require(ReplicatedStorage.Scripts.Modules.Promise)

-- << Variables >> --
local CFRAME_OFFSET = CFrame.new(0, -0.75, -1)
local DEFAULT_FOV   = 50



-- << Meat >> --
local scene = {}
scene.__index = scene

function scene.Fire(func)
    local newThread = coroutine.create(func)
	coroutine.resume(newThread)
end

function scene:Create()
    local self = setmetatable({}, scene)
    self.ACTIVE_SCENE = nil
    self.ACTIVE_CAMERA_OBJECT = nil
    self.ACTIVE_CAMERA_STEP = nil
    self.ACTIVE_ANIMATIONS = {}
    self.DEFAULT_FOV = DEFAULT_FOV
    self.PLAYING = false
    self.ENDED = Instance.new("BindableEvent")

	return self
end

function scene:Play()
    if self.PLAYING then return end

    local function onPlay()
        self.PLAYING = true
        TweenService:Create(MAINMENU.BG, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()

        Promise.try(function()
            MusicPlayer:Stop()
        end)

        for _, animation in ipairs(self.ACTIVE_ANIMATIONS) do
            animation:AdjustSpeed(1)
            animation:Play()
            animation.TimePosition = 0

            animation:GetMarkerReachedSignal("FadeOut"):Connect(function() --- Only camera should have this
                wait(3.5)
                self:Destroy()
            end)
        end

        if self.ACTIVE_CAMERA_OBJECT then
            dataValues.CameraEnabled = false

            --- Makes sure the camera rig is transparent
            for _, part in ipairs(self.ACTIVE_CAMERA_OBJECT:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
            end

            self.ACTIVE_CAMERA_STEP = renderStep:Connect(function()
                if not self.ACTIVE_CAMERA_OBJECT or not self.PLAYING then
                    self.ACTIVE_CAMERA_STEP:Disconnect()
                    return
                end

                CAMERA.FieldOfView = self.DEFAULT_FOV
				CAMERA.CFrame = self.ACTIVE_CAMERA_OBJECT.CamPart.CFrame * CFRAME_OFFSET
            end)
        end
    end

	scene.Fire(onPlay)
end

function scene:Stop()
    if not self.PLAYING then return end

    local function onStop()
        dataValues.CameraEnabled = self.ACTIVE_CAMERA_OBJECT and true
        self.PLAYING = false
        self.ENDED:Fire()

        for _, animation in ipairs(self.ACTIVE_ANIMATIONS) do
            animation:Stop()
        end

        for _, player in ipairs(ReplicatedStorage.TemporaryPlayerFolder:GetChildren()) do
            player.Parent = workspace.Players
        end

        for _, enemy in ipairs(ReplicatedStorage.TemporaryEnemiesFolder:GetChildren()) do
            enemy.Parent = workspace.Enemies
        end
    end
    
    scene.Fire(onStop)
end

function scene:Destroy()
    self:Stop()
    self.ACTIVE_SCENE:Destroy()
    self.ENDED:Destroy()

    GUI.MainDialogue.Dialogue.Visible = false
    MAINMENU.Parent.Intro.Visible = false
    MAINMENU.Parent.Enabled = false
    TweenService:Create(MAINMENU.BG, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    
    setmetatable(self, nil)
end

return scene