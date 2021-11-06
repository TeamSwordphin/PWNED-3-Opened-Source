--[[
    API Usage

    local cutsceneModule = require(this.module)

    local scene = cutsceneModule:Prepare(FOLDER_CUTSCENE_LOCATION)
    scene:Play()
--]]


-- << Services >> --
local ContentProvider   = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService 		= game:GetService("TweenService")
local Players			= game:GetService("Players")


-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local MAINMENU  = GUI:WaitForChild("MainMenu").CharSelect


-- << Modules >> --
local sceneCreator  = require(script.Parent.SceneObject)
local dataValues    = require(CLIENT.DataValues)
local Socket        = require(MODULES.socket)
local MusicPlayer   = require(MODULES.MusicPlayer)
local morpher       = require(ReplicatedStorage.Scripts.Modules.Morpher)
local Promise       = require(ReplicatedStorage.Scripts.Modules.Promise)


-- << Main Food >> --
local cutsceneMain = {}


function cutsceneMain:Prepare(FOLDER)
    local actors = FOLDER:FindFirstChild("Actors")
    local effects = FOLDER:FindFirstChild("Effects")
    local resources = FOLDER:FindFirstChild("Resources")

    if actors and effects then
        MAINMENU.Parent.Intro.Visible = false
        MAINMENU.Parent.Enabled = true
        TweenService:Create(MAINMENU.BG, TweenInfo.new(0.7), {BackgroundTransparency = 0}):Play()

        Promise.try(function()
            MusicPlayer:Stop()
        end)
        wait(0.7)

        local scene = sceneCreator:Create()
        scene.ACTIVE_SCENE = FOLDER
        scene.ACTIVE_SCENE.Parent = workspace

        ---Preloading is required to keep the animations in sync
        ContentProvider:PreloadAsync({scene.ACTIVE_SCENE})
        
        for _, player in ipairs(workspace.Players:GetChildren()) do
            local temp = ReplicatedStorage:FindFirstChild("TemporaryPlayerFolder")
            if not temp then
                temp = Instance.new("Folder", ReplicatedStorage)
                temp.Name = "TemporaryPlayerFolder"
            end
            player.Parent = temp
        end

        for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
            local temp = ReplicatedStorage:FindFirstChild("TemporaryEnemiesFolder")
            if not temp then
                temp = Instance.new("Folder", ReplicatedStorage)
                temp.Name = "TemporaryEnemiesFolder"
            end
            enemy.Parent = temp
        end

        for _, actor in ipairs(actors:GetChildren()) do
            local actor_animation = actor:FindFirstChildOfClass("Animation")
            local animation_controller = actor:FindFirstChildOfClass("Humanoid") or actor:FindFirstChildOfClass("AnimationController")
            
            actor.PrimaryPart.Anchored = true
            actor.PrimaryPart.CanCollide = false

            if actor_animation and animation_controller then

                local oldAnimator = animation_controller:FindFirstChild("Animator")
                local newAnimator = Instance.new("Animator", animation_controller)
                local loaded_animation = newAnimator:LoadAnimation(actor_animation)

                if oldAnimator then
                    oldAnimator:Destroy()
                end

                if actor.Name == "Camera" then
                    scene.ACTIVE_CAMERA_OBJECT = actor
                end

                if actor.Name == "MainCharacter" then
                    if not dataValues.CharInfo then
                        dataValues.CharInfo = Socket:Request("getCharacterInfo")
                    end
                    morpher:morph(actor, dataValues.CharInfo.CurrentSkinPieces)
                end

                for _, effect in ipairs(effects:GetChildren()) do
                    if effect.Name == actor.Name then
                        require(effect):monitor(resources, loaded_animation)
                    end
                end

                table.insert(scene.ACTIVE_ANIMATIONS, loaded_animation)
            else
                warn(string.format("%s does not have a valid animation or a valid animation controller.", actor.Name))
            end
        end

        return scene
    else
        error("Actors or Effects folder is missing from cutscene!")
    end
end

return cutsceneMain