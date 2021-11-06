local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootPlan = require(ReplicatedStorage.Scripts.Modules.LootPlan)

----
local materialPlan = LootPlan.new("single")
materialPlan:AddLoot("Silver Fragment", 10)
materialPlan:AddLoot("Copper Fragment", 20)
materialPlan:AddLoot("Looking Glass", 15)
materialPlan:AddLoot("Titanium Chip", 5)
materialPlan:AddLoot("Nothing", 30)
----
local gemPlan = LootPlan.new("single")
gemPlan:AddLoot("0", 25)
gemPlan:AddLoot("1", 15)
gemPlan:AddLoot("Nothing", 60)
----

return {
    MissionName = "The Heart of Atlas: Compendium",
    MapName = "HeartOfAtlas",
    MissionImage = "rbxassetid://4072989037",
    Type = "Story",
    Dates = {
        StartDate = {Year = 0, Month = 0, Day = 0},
        EndDate = {Year = 0, Month = 0, Day = 0},
        Wday = {}
    },
    Available = true,
    Replayable = true,
    TypeProperties = {
        Type = "Dungeon",
        Wave = 0,
        StartingEnemies = 0,
        Objectives = {
            {"Investigate why the robots are hostile", 1}
        },
        SummonableNPCS = {"Althea"}
    },
    MaxPlayers = 6,
    MinLevel = 40, -- 45
    MaxLevel = 45,
    MinLevelHero = -1,
    MaxLevelHero = -1,
    ReleaseDate = 0,
    RequiredMapCompletions = {
        "2.5",
        "City Roads: The Streets are Silent"
    },
    MaterialDrops = materialPlan,
    GemDrops = gemPlan,
    runLogic = script:FindFirstChild("Mission_Logic") and script.Mission_Logic,
    Description = "The province's capital, Heart of Atlas. Business headquarters, mass tourism areas, and the creation of security bots all originate from here. It will be best to prepare for whatever is coming. (Recommended party size of 3+).",
    Hints = {
        {"Potion", "Potions can help mitigate damage and regen some lost HP."},
        {"StaminaPotion", "Stamina Potions regenerates lost energy over 1 minute."},
        {"Whetstone", "Recommended weapon level of 30 upgraded to at least +50."},
        {"Gemstone", "Fortitude is recommended for mitigating rapid-repeated damage in a short amount of time."},
        {"Gemstone", "Knockdown Master is recommended for more frequent boss staggers."},
        {"Gemstone", "Combo Score Time Increase is recommended for increasing Combo Score downtime window."},
        {"Gemstone", "Ranger is recommended for increased damage against far away units."}
    }
}