local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootPlan = require(ReplicatedStorage.Scripts.Modules.LootPlan)

----
local materialPlan = LootPlan.new("single")
materialPlan:AddLoot("Wrinkled Leather", 20)
materialPlan:AddLoot("Plastic Sheet", 20)
materialPlan:AddLoot("Dented Metal", 10)
materialPlan:AddLoot("Broken Metal", 10)
materialPlan:AddLoot("Nothing", 30)
----
local gemPlan = LootPlan.new("single")
gemPlan:AddLoot("0", 60)
gemPlan:AddLoot("Nothing", 30)
----

return {
    MissionName = "City Roads: The Streets are Silent",
    MapName = "CityRoads",
    MissionImage = "rbxassetid://3517229952",
    Type = "Story",
    Available = true,
    Replayable = true,
    TypeProperties = {
        Type = "Wave",
        Wave = 15,
        StartingEnemies = 15, --15
        Objectives = {
        },
        SummonableNPCS = {}
    },
    MaxPlayers = 6,
    MinLevel = 15, ---Can be used for LayoutOrder
    MaxLevel = 20,
    MinLevelHero = 30,
    MaxLevelHero = 35, 
    ReleaseDate = 0, ---Premium Membership's release date in seconds. Normal users gets access to this 1-week later (or +604800 seconds)
    RequiredMapCompletions = {
        "2",
        "Riukaya-Hara: A Journey's Start"
    },
    MaterialDrops = materialPlan,
    GemDrops = gemPlan,
    Description = "A lengthy road full of shops and tourist-friendly views. This pathway connects Riuykaya-Hara and the capital of this province, better known as the Heart of Atlas. More powerful security units are expected to show up here.",
    Hints = {
        {"Potion", "Potions can help mitigate damage and regen some lost HP."},
        {"StaminaPotion", "Stamina Potions regenerates lost energy over 1 minute."},
        {"Gemstone", "Knockdown Master is recommended for more frequent boss staggers."},
        {"Gemstone", "Armor Penetration is recommended for increased damage against resilient enemies."},
    },
    runLogic = script:FindFirstChild("Mission_Logic") and script.Mission_Logic
}