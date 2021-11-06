return {
    MissionName = "Book of Memories",
    MapName = "BookOfMemories",
    MissionImage = "rbxassetid://3639232673",
    Type = "Event",
    EndTime = -1,
    Available = false,
    Replayable = true,
    TypeProperties = {
        Type = "Dungeon",
        Wave = 0,
        StartingEnemies = 0, --15
        Objectives = {
            {"Collect the Book of Memories Vol. 1", 1},
            {"Collect the Book of Memories Vol. 2", 1}
        },
        SummonableNPCS = {}
    },
    MaxPlayers = 6,
    MinLevel = 100, ---Can be used for LayoutOrder
    MaxLevel = 160,
    MinLevelHero = 180,
    MaxLevelHero = 400, 
    ReleaseDate = 0, ---Premium Membership's release date in seconds. Normal users gets access to this 1-week later (or +604800 seconds)
    RequiredMapCompletions = {
        "Riukaya-Hara: A Journey's Start"
    },
    MaterialDrops = { ---100% drop chance
    }
}