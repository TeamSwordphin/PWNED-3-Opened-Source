local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootPlan = require(ReplicatedStorage.Scripts.Modules.LootPlan)

----
local materialPlan = LootPlan.new("single")
materialPlan:AddLoot("Unknown Shard", 10)
materialPlan:AddLoot("Dented Metal", 20)
materialPlan:AddLoot("Nothing", 100)
----
local gemPlan = LootPlan.new("single")
gemPlan:AddLoot("1", 60)
gemPlan:AddLoot("Nothing", 30)
----

return {
    MissionName = "City Guard: Turbo Vengeance",
    MapName = "CityRoads",
    MissionImage = "rbxassetid://3517229952",
    Type = "Event",
    EndTime = 0,
    Available = true,
    Replayable = true,
    TypeProperties = {
        Type = "Wave",
        Wave = 3,
        StartingEnemies = 1,
        Objectives = {
        },
        SummonableNPCS = {}
    },
    ActiveEventGoal = 10,
    UIEffects = {"Lightning"},
    MaxPlayers = 6,
    MinLevel = 30,
    MaxLevel = 35,
    MinLevelHero = 40,
    MaxLevelHero = 45,
    ReleaseDate = 0,
    RequiredMapCompletions = {
        "2",
        "Riukaya-Hara: A Journey's Start"
    },
    MaterialDrops = materialPlan,
    GemDrops = gemPlan,
    runLogic = script:FindFirstChild("Mission_Logic") and script.Mission_Logic,
    Description = "A lengthy road full of shops and tourist-friendly views. This pathway connects Riuykaya-Hara and the capital of this province, better known as the Heart of Atlas. More powerful security units are expected to show up here.",
    Hints = {
        {"Potion", "Potions can help mitigate damage and regen some lost HP."},
        {"StaminaPotion", "Stamina Potions regenerates lost energy over 1 minute."},
        {"Gemstone", "Knockdown Master is recommended for more frequent boss staggers."},
        {"Gemstone", "Armor Penetration is recommended for increased damage against resilient enemies."},
    }
}