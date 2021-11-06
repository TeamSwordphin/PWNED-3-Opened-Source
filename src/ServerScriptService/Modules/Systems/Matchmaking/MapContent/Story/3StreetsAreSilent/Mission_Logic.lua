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

local Rand = Random.new()


----
return function(Lvl)
    local GameData  = GameObjectHandler:GameData()
    local Enemies   = GameObjectHandler:GetEnemies()
    local Map       = workspace.Map
    ----

    local WorldEvent = require(SERV_MODULES.Systems.WorldEventsMain)
    local BossSpawner = false
    local EnemyData

    if (GameData.CurrentWave == 1) then
        BossSpawner = true
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
                70000 + (2000 * Lvl), 
                80 + (6 * Lvl), 
                3 * Lvl, 
                0, 
                Lvl*.5, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.CityRoads["City Guard (Hero)"]
            )
        else
            BossData = CreateEnemy(Lvl, 
                35000 + (400 * Lvl), 
                70 + (2 * Lvl), 
                Lvl, 
                0, 
                0, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.CityRoads["City Guard"]
            )
        end
        BossData.Model.Bindables.Died.Event:Connect(function()
            WorldEvent:AddEvent("City Guard: Turbo Vengeance")
        end)

        local Num = #Enemies + 1
        Enemies[Num] = BossData
        Sockets:Emit("EnemyStatus", BossData, "Spawn")
    elseif (GameData.CurrentWave == 10) then
        BossSpawner = true
        GameData.EnemiesToSpawn = 0
        Promise.try(function()
            Sockets:Emit("Warning", true)
            wait(2.5)
            Sockets:Emit("MusicChange", "Play", "CityRoads_Boss2Theme")
        end) 
        local BossData;
        if GameData.HeroMode then
            BossData = CreateEnemy(Lvl, 
                60000 + (1600 * Lvl), 
                70 + (4 * Lvl), 
                3 * Lvl, 
                0, 
                Lvl * 0.5, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.CityRoads["Voltket (Hero)"]
            )
        else
            BossData = CreateEnemy(Lvl, 
                30000 + (100 * Lvl), 
                35 + (2 * Lvl), 
                Lvl, 
                0, 
                0, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.CityRoads["Voltket"]
            )
        end
        local Num = #Enemies+1
        Enemies[Num] = BossData
        Sockets:Emit("EnemyStatus", BossData, "Spawn")
    elseif (GameData.CurrentWave == 15) then
        BossSpawner = true
        GameData.EnemiesToSpawn = 0
        Promise.try(function()
            wait(1)
            Sockets:Emit("MusicChange", "Stop")
            wait(5)
            Sockets:Emit("Warning", true)
            wait(2)
            Sockets:Emit("MusicChange", "Play", "CityRoads_Boss3Theme")
        end) 
        local BossData;
        if GameData.HeroMode then
            BossData = CreateEnemy(Lvl, 
                65000 + (2250 * Lvl), 
                80 + (3 * Lvl), 
                3 * Lvl, 
                0, 
                Lvl * 0.5, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.CityRoads["Shadowharst (Hero)"]
            )
        else
            BossData = CreateEnemy(Lvl, 
                33000 + (300 * Lvl), 
                70 + (2 * Lvl), 
                Lvl, 
                0, 
                Lvl * 0.2, 
                nil, nil, nil, false, 
                ServerStorage.Bosses.CityRoads["Shadowharst"]
            )
        end
        local Num = #Enemies+1
        Enemies[Num] = BossData
        Sockets:Emit("EnemyStatus", BossData, "Spawn")
    end

    if not BossSpawner then
        local Rnd = Rand:NextInteger(1,100)
        if GameData.CurrentWave >= 5 and Rnd <= 20 then
            if GameData.HeroMode then
                EnemyData = CreateEnemy(Lvl, 1750 + (30 * Lvl), 65 + (3 * Lvl), 0, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.CityRoads["CityRoadsRanged"])
            else
                EnemyData = CreateEnemy(Lvl, 700 + (20 * Lvl), 30 + (2 * Lvl), 0, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.CityRoads["CityRoadsRanged"])
            end
        else
            if GameData.HeroMode then
                EnemyData = CreateEnemy(Lvl, 1080 + (35 * Lvl), 40 + (3 * Lvl), 0, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.CityRoads["CityRoadsMob"])
            else
                EnemyData = CreateEnemy(Lvl, 380 + (20 * Lvl), 20 + (2 * Lvl), 0, 0, 0, nil, nil, nil, false, ServerStorage.Mobs.CityRoads["CityRoadsMob"])
            end
        end
    end

    return EnemyData
end