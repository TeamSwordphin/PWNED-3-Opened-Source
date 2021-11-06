local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootPlan = require(ReplicatedStorage.Scripts.Modules.LootPlan)

----
local materialPlan = LootPlan.new("single")
materialPlan:AddLoot("Heated Whetstone", 50)
materialPlan:AddLoot("Nothing", 5)
----
local gemPlan = LootPlan.new("single")
gemPlan:AddLoot("0", 60)
gemPlan:AddLoot("Nothing", 40)
----

return {
    MissionName = "Simulated Battle II",
    MapName = "SimulatedBattle2",
    MissionImage = "rbxassetid://5818133430",
    Type = "Event",
    EndTime = -1,
    Available = true,
    Replayable = true,
    TypeProperties = {
        Type = "Wave",
        Wave = 6,
        StartingEnemies = 10,
        Objectives = {"Defend", "Simulated"},
        SummonableNPCS = {}
    },
    MaxPlayers = 6,
    MinLevel = 25,
    MaxLevel = 30,
    MinLevelHero = -1,
    MaxLevelHero = -1,
    ReleaseDate = 0,
    RequiredMapCompletions = {
        "Simulated Battle I"
    },
    MaterialDrops = materialPlan,
    GemDrops = gemPlan,
    Description = "A simulated battle drill that allows one to practice and defend vital zones. Yields precious whetstones that can be used for strengthening weapons.",
    Hints = {
        {"Potion", "Potions can help mitigate damage and regen some lost HP."},
        {"StaminaPotion", "Stamina Potions regenerates lost energy over 1 minute."},
    }
}