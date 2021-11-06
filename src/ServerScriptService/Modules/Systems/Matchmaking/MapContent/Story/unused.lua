return {
    MissionName = "High Vigils: Basic Combat Tutorial",
    MapName = "HighVigils",
    MissionImage = "rbxassetid://3699876573",
    Type = "Story",
    Dates = {
        StartDate = {Year = 0, Month = 0, Day = 0},
        EndDate = {Year = 0, Month = 0, Day = 0},
        Wday = {}
    },
    Available = false,
    Replayable = false,
    TypeProperties = {
        Type = "Dungeon",
        Wave = 0,
        StartingEnemies = 0,
        Objectives = {
            {"Follow Lilah to the center of High Vigils", 1},     --- {description, objectiveValue}
            {"Listen to Lilah", 1},
            {"Use your Light Attack on Lilah 25 times", 25},
            {"Use your Block to withstand 15 attacks", 15},
            {"Use your Dodge and evade 7 attacks", 7},
            {"Defeat Lilah, the Efficacious Leader", 1},
            {"Listen to Lilah", 1}
        },
        SummonableNPCS = {}
    },
    MaxPlayers = 1,
    MinLevel = 0,
    MaxLevel = 1,
    MinLevelHero = 100,
    MaxLevelHero = 100,
    ReleaseDate = 0,
    RequiredMapCompletions = {
--		"1"
    },
    MaterialDrops = { ---Special Drops
    }
}