local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootPlan = require(ReplicatedStorage.Scripts.Modules.LootPlan)

----
local materialPlan = LootPlan.new("single")
materialPlan:AddLoot("Wrinkled Leather", 20)
materialPlan:AddLoot("Plastic Sheet", 20)
materialPlan:AddLoot("Dented Metal", 10)
materialPlan:AddLoot("Nothing", 30)
----
local gemPlan = LootPlan.new("single")
gemPlan:AddLoot("0", 50)
gemPlan:AddLoot("Nothing", 50)
----

return {
    MissionName = "Riukaya-Hara: A Journey's Start",
    MapName = "Riukaya-Hara",
    MissionImage = "rbxassetid://3517219261",
    Type = "Story",
    Available = true,
    Replayable = true,
    TypeProperties = {
        Type = "Wave",
        Wave = 5,
        StartingEnemies = 5,
        Objectives = {
        },
        SummonableNPCS = {}
    },
    MaxPlayers = 6,
    MinLevel = 1,
    MaxLevel = 10,
    MinLevelHero = 25,
    MaxLevelHero = 30,
    ReleaseDate = 0,
    RequiredMapCompletions = {
        "1"
    },
    MaterialDrops = materialPlan,
    GemDrops = gemPlan,
    Description = "A once-prosperous city located on the outskirts of the InCrypt region, it became desolate after the sudden disappearance of all its citizens. Security bots roam the metropolis, defending what is left of the nation.",
    Hints = {
        {"Potion", "Potions can help mitigate damage and regen some lost HP."},
        {"StaminaPotion", "Stamina Potions regenerates lost energy over 1 minute."},
    }
}