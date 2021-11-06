
-- << Services >>
local Debris 			= game:GetService("Debris")
local TweenService 		= game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local Players           = game:GetService("Players")

-- << Constants >>
local SERVER_FOLDER = script.Parent.Parent.Parent.Parent.Parent.Parent
local MODULES       = SERVER_FOLDER.Parent.Modules

-- << Modules >>
local Sockets       = require(MODULES.Utility["server"])
local PlayerManager	= require(MODULES.PlayerStatsObserver)
local ClassInfo     = require(MODULES.CharacterManagement["ClassInfo"])
local EffectFinder	= require(MODULES.Combat.EffectFinder)


------------------------------------
local logic = {}

function logic:Init(Socket)
	local Player = Socket.Player
    local id = Player.UserId
    
    local function checkIs()
        local PlayerStat = PlayerManager:GetPlayerStat(id)
        if PlayerStat.CurrentClass == script.Parent.Parent.Name then
            return PlayerStat
        end
    end


end

return logic