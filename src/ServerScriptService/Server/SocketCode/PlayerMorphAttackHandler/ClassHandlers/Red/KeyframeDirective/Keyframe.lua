-- << Services >>
local Debris 			= game:GetService("Debris")
local TweenService 		= game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")

-- << Constants >>
local SERVER_FOLDER = script.Parent.Parent.Parent.Parent.Parent.Parent
local MODULES       = SERVER_FOLDER.Parent.Modules

-- << Modules >>
local Sockets       = require(MODULES.Utility["server"])
local PlayerManager	= require(MODULES.PlayerStatsObserver)


------------------------------------
return function (humanoid, model)
    --[[
	humanoid.AnimationPlayed:Connect(function(animTrack)
        local id = animTrack.Animation.AnimationId
		
		animTrack.KeyframeReached:Connect(function(keyFrame)
            --- General Effects
		end)
    end)
    --]]
end