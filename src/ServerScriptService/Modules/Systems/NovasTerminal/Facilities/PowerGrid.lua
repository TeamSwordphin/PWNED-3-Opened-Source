return {
    ID = 3,
    Style = "G R I D",
    Name = "Power Grid",
    Model = game.ReplicatedStorage.Models.Facilities.Powerplant,
    MaxLevels = 3,
    PowerRequired = 0,
    SecondsToCreate = 15,
    UpgradeSecondsPerRank = 300,
    Levels = {
        {
            Description = "Increases the maximum Power Cell capacity by 4.",
            Value = 4,
            CraftingMaterialsRequired = {
                {"Gold", 100},
            }
        },
        {
            Description = "Increases the maximum Power Cell capacity by 5.",
            Value = 6,
            MaterialsRequired = {
                {"Gold", 30000},
                {"Broken Metal", 10},
                {"Tinfoil", 50},
                {"Dented Metal", 25},
            }
        },
        {
            Description = "Increases the maximum Power Cell capacity by 6.",
            Value = 8,
            MaterialsRequired = {
                {"Gold", 70000},
            }
        }
    }
}