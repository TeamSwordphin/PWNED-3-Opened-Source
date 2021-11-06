--- << Services >>
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


--- << Constants >>
local PLAYER = Players.LocalPlayer
local PARENT = script.Parent.Parent
local MODULES = PARENT.Parent:WaitForChild("Modules")
local GUI = PLAYER.PlayerGui
local MAIN_DIALOGUE = GUI:WaitForChild("MainDialogue")


--- << Modules >>
local TreeCreator = require(ReplicatedStorage.Scripts.Modules.BehaviorTreeCreator)


-- << Variables >>
local newBehaviour = TreeCreator:Create(script.Parent.Tree)

local resources = {
    DATAVALUES = require(PARENT.DataValues),
    STORY_TELLER = require(MODULES.StoryTeller),
    SOCKET = require(MODULES.socket),
    DIALOGUE = require(PARENT.DialogueSystem.MainExecutorDialogue),
    PROMISE = require(ReplicatedStorage.Scripts.Modules.Promise),
    PLATFORM_TUTORIAL = require(PARENT.UIEffects.TutorialPlatformButtons),
    expressionFolder = MAIN_DIALOGUE.DialoguePortraits.Frame.Expressions,
    CUTSCENE_ENGINE = require(PARENT.CutsceneManager.CutsceneEngine),
    GUI = GUI,
}

local function addStory(storyName)
    if not table.find(resources.DATAVALUES.AccInfo.StoryProgression, storyName) then
        table.insert(resources.DATAVALUES.AccInfo.StoryProgression, storyName)
        resources.SOCKET:Emit("Story", storyName)
    end
end

resources.addStory = addStory

-----------------
repeat wait() until resources.DATAVALUES.WatchedIntro and resources.DATAVALUES.AccInfo

local entity = {entity = PLAYER}
newBehaviour:run(entity, resources)