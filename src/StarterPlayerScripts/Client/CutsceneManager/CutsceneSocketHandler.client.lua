-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- << Constants >> -- 
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local CUT_FOLD  = ReplicatedStorage.Models:WaitForChild("Cutscenes")


-- << Modules >> --
local SOCKET    = require(MODULES.socket)
local CUTSCENES = require(script.Parent.CutsceneEngine)


--------------------

SOCKET:Listen("CutscenePlay", function(cutsceneName)
    local newScene = CUTSCENES:Prepare(CUT_FOLD[cutsceneName]:Clone())
    newScene:Play()
end)