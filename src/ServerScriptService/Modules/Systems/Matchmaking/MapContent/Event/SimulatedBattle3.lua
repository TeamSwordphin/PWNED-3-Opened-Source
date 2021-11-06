local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootPlan = require(ReplicatedStorage.Scripts.Modules.LootPlan)

----
local materialPlan = LootPlan.new("single")
materialPlan:AddLoot("Thermal Whetstone", 50)
materialPlan:AddLoot("Nothing", 5)
----
local gemPlan = LootPlan.new("single")
gemPlan:AddLoot("1", 70)
gemPlan:AddLoot("Nothing", 40)
----

return {
    MissionName = "Simulated Battle III",
    MapName = "SimulatedBattle3",
    MissionImage = "rbxassetid://5837439039",
    Type = "Event",
    EndTime = -1,
    Available = true,
    Replayable = true,
    TypeProperties = {
        Type = "Wave",
        Wave = 8,
        StartingEnemies = 14,
        Objectives = {"Defend", "Simulated"},
        SummonableNPCS = {}
    },
    MaxPlayers = 6,
    MinLevel = 35,
    MaxLevel = 40,
    MinLevelHero = -1,
    MaxLevelHero = -1,
    ReleaseDate = 0,
    RequiredMapCompletions = {
        "Simulated Battle II"
    },
    MaterialDrops = materialPlan,
    GemDrops = gemPlan,
    Description = "A simulated battle drill that allows one to practice and defend vital zones. Yields precious whetstones that can be used for strengthening weapons.",
    Hints = {
        {"Potion", "Potions can help mitigate damage and regen some lost HP."},
        {"StaminaPotion", "Stamina Potions regenerates lost energy over 1 minute."},
        {"Gemstone", "Knockdown Master is recommended for more frequent boss staggers."},
        {"Gemstone", "Combo Score Time Increase is recommended for increasing Combo Score downtime window."},
    }
}