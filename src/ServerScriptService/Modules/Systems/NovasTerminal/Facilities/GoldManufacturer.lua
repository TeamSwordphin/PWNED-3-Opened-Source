return {
    ID = 4,
    Style = "G O L D",
    Name = "Gold Generator",
    Model = nil,
    MaxLevels = 5,
    PowerRequired = 2,
    SecondsToCreate = 1500,
    UpgradeSecondsPerRank = 300,
    Levels = {
        {
            Description = "Generates up to 80 gold per hour, even when offline.",
            CraftingMaterialsRequired = {
                {"Gold", 50000},
            }
        },
        {
            Description = "Generates up to 150 gold per hour, even when offline.",
            MaterialsRequired = {
                {"Gold", 100000},
            }
        },
        {
            Description = "Generates up to 230 gold per hour, even when offline.",
            MaterialsRequired = {
                {"Gold", 150000},
            }
        },
        {
            Description = "Generates up to 350 gold per hour, even when offline.",
            MaterialsRequired = {
                {"Gold", 210000},
            }
        },
        {
            Description = "Generates up to 500 gold per hour, even when offline.",
            MaterialsRequired = {
                {"Gold", 320000},
            }
        }
    }
}