return {
    ID = 2,
    Style = "P O W E R",
    Name = "Power Plant",
    Model = game.ReplicatedStorage.Models.Facilities.Powerplant,
    MaxLevels = 3,
    PowerRequired = 0,
    SecondsToCreate = 5,
    UpgradeSecondsPerRank = 200, --- This * (Facility.Level + 1)
    Levels = {
        {
            Description = "Generates 1 Power Cell to the base.",
            Value = 1,
            CraftingMaterialsRequired = {
                {"Gold", 100},
            }
        },
        {
            Description = "Generates 3 Power Cells to the base.",
            Value = 3,
            MaterialsRequired = {
                {"Gold", 30000},
                {"Broken Metal", 10},
                {"Tinfoil", 50},
                {"Dented Metal", 25},
            }
        },
        {
            Description = "Generates 5 Power Cells to the base.",
            Value = 5,
            MaterialsRequired = {
                {"Gold", 80000},
                {"Plexiglass", 15},
                {"Iron Hook", 10},
                {"Silver Fragment", 25},
                {"Cobalt Alloy", 5}
            }
        }
    }
}