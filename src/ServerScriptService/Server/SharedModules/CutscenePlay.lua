local Modules = script.Parent.Parent.Parent.Modules
local Sockets = require(Modules.Utility["server"])

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cutscenes = ReplicatedStorage.Models.Cutscenes

----

return function(cutsceneName)
    local cutscene = Cutscenes:FindFirstChild(cutsceneName)

    if cutscene then
        Sockets:Emit("CutscenePlay", cutsceneName)
    end
end