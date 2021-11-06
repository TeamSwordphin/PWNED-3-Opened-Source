local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootPlan = require(ReplicatedStorage.Scripts.Modules.LootPlan)

----
local materialPlan = LootPlan.new("single")
materialPlan:AddLoot("Wrinkled Leather", 15)
materialPlan:AddLoot("Iron Hook", 15)
materialPlan:AddLoot("Copper Fragment", 15)
materialPlan:AddLoot("Nothing", 50)
----
local gemPlan = LootPlan.new("single")
gemPlan:AddLoot("0", 10)
gemPlan:AddLoot("Nothing", 60)
----

return {
    MissionName = "High Vigils: Mysterious Distress Signal",
    MapName = "HighVigils",
    MissionImage = "rbxassetid://3699876573",
    Type = "Story",
    Available = true,
    Replayable = true,
    TypeProperties = {
        Type = "Dungeon",
        Wave = 0,
        StartingEnemies = 0,
        Objectives = {
            {"Locate the distress signal", 1}
        },
        SummonableNPCS = {}
    },
    MaxPlayers = 1,
    MinLevel = 25, -- 25
    MaxLevel = 30, -- 30
    MinLevelHero = 45, -- 45
    MaxLevelHero = 50, -- 50
    ReleaseDate = 0,
    RequiredMapCompletions = {
        "3",
        "City Roads: The Streets are Silent"
    },
    MaterialDrops = materialPlan,
    GemDrops = gemPlan,
    Description = "A beautiful hillside cliff looking over the sea and the sun. Due to the increased wild daemon activities, enemy sightings have been reported here. This is where the help signal was coming from.",
    Hints = {
        {"Potion", "Potions can help mitigate damage and regen some lost HP."},
        {"StaminaPotion", "Stamina Potions regenerates lost energy over 1 minute."},
        {"Gemstone", "DEF Increase is recommended for increased resistant against damage."},
    },
    runLogic = script:FindFirstChild("Mission_Logic") and script.Mission_Logic
}