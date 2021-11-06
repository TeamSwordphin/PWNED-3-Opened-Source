local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootPlan = require(ReplicatedStorage.Scripts.Modules.LootPlan)

----
local materialPlan = LootPlan.new("single")
materialPlan:AddLoot("Normal Whetstone", 50)
materialPlan:AddLoot("Nothing", 5)
----
local gemPlan = LootPlan.new("single")
gemPlan:AddLoot("0", 60)
gemPlan:AddLoot("Nothing", 40)
----

return {
    MissionName = "Simulated Battle I",
    MapName = "SimulatedBattle1",
    MissionImage = "rbxassetid://5813351663",
    Type = "Event",
    EndTime = -1,
    Available = true,
    Replayable = true,
    TypeProperties = {
        Type = "Wave",
        Wave = 5,
        StartingEnemies = 10,
        Objectives = {"Defend", "Simulated"},
        SummonableNPCS = {}
    },
    MaxPlayers = 6,
    MinLevel = 15,
    MaxLevel = 20,
    MinLevelHero = -1,
    MaxLevelHero = -1,
    ReleaseDate = 0,
    RequiredMapCompletions = {
        "Riukaya-Hara: A Journey's Start"
    },
    MaterialDrops = materialPlan,
    GemDrops = gemPlan,
    Description = "A simulated battle drill that allows one to practice and defend vital zones. Yields precious whetstones that can be used for strengthening weapons.",
    Hints = {
        {"Potion", "Potions can help mitigate damage and regen some lost HP."},
        {"StaminaPotion", "Stamina Potions regenerates lost energy over 1 minute."},
        {"Gemstone", "Combo Score Time Increase is recommended for increasing Combo Score downtime window."},
    }
}