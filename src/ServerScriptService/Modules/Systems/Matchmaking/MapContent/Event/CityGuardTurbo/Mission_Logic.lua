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

    if GameData.CurrentWave < 2 then
        GameData.CurrentWave = GameData.CurrentWave + 1
    end

    if GameData.CurrentWave == 2 then
        GameData.CurrentWave = GameData.CurrentWave + 1
        GameData.EnemiesToSpawn = 0

        Promise.try(function()
            wait(3)
            Sockets:Emit("MusicChange", "Stop")
            wait(6)
            Sockets:Emit("Warning", true)
            wait(2)
            Sockets:Emit("MusicChange", "Play", "CityRoads_Boss1Theme")
        end) 

        local BossData;

        if GameData.HeroMode then
            BossData = CreateEnemy(Lvl, 
                190000 + (6000 * Lvl), 
                200 + (6 * Lvl), 
                3 * Lvl, 
                0, 
                Lvl*.5, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.CityRoads["City Guard Tempo"]
            )
        else
            BossData = CreateEnemy(Lvl, 
                135000 + (3700 * Lvl), 
                120 + (4 * Lvl), 
                Lvl, 
                0, 
                0, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.CityRoads["City Guard Tempo"]
            )
        end

        local Num = #Enemies + 1
        Enemies[Num] = BossData
        Sockets:Emit("EnemyStatus", BossData, "Spawn")
    end
end