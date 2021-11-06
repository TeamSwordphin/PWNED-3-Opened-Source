--[[

    RunLogic runs every second or less.

--]]

-- << Services >>
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- << Constants >>
local SERV_MODULES = ServerScriptService.Modules
local MODULES   = ReplicatedStorage.Scripts.Modules
local SHARED   = ServerScriptService.Server.SharedModules

-- << Modules >>
local Promise           = require(MODULES.Promise)
local CreateEnemy       = require(SHARED.CreateEnemy)
local GameObjectHandler = require(SHARED.GameObjectHandler)
local cutscenePlay		= require(SHARED.CutscenePlay)
local Sockets           = require(SERV_MODULES.Utility.server)


----
return function(Lvl)
    local GameData  = GameObjectHandler:GameData()
    local Enemies   = GameObjectHandler:GetEnemies()
    local Map       = workspace.Map
    ----

    if GameData.CurrentWave < 5 then
        GameData.CurrentWave = GameData.CurrentWave + 1
    end
    if GameData.CurrentWave == 5 then
        GameData.CurrentWave = GameData.CurrentWave + 1
        cutscenePlay("HighVigilsBlacksmithMeet")
    end
    --[[

    if GameData.CurrentWave == 5 then
        GameData.CurrentWave = GameData.CurrentWave + 1
        local BossData;
        if GameData.HeroMode then
            BossData = CreateEnemy(Lvl, 
                205000 + (3050 * Lvl), 
                400 + (5 * Lvl), 
                4 * Lvl, 
                0, 
                Lvl * 0.5, 
                nil, nil, nil, false,   
                ServerStorage.Bosses.HighVigils.DistressSignal["Corrupted Golem"]
            )
        else
            BossData = CreateEnemy(Lvl, 
                85000 + (2850 * Lvl), 
                200 + (3 * Lvl), 
                2 * Lvl, 
                0, 
                Lvl * 0.5, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.HighVigils.DistressSignal["Corrupted Golem"]
            )
        end
        BossData.Model.Bindables.Died.Event:Connect(function()
            cutscenePlay("HighVigilsBlacksmithMeet")
        end)

        local Num = #Enemies+1
        Enemies[Num] = BossData
        Sockets:Emit("EnemyStatus", BossData, "Spawn")
    end--]]
end