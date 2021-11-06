return {
    ID = 5,
    Style = "D R I L L",
    Name = "Underground Drill",
    Model = game.ReplicatedStorage.Models.Facilities.Powerplant,
    MaxLevels = 3,
    PowerRequired = 3,
    SecondsToCreate = 600,
    UpgradeSecondsPerRank = 300,
    Levels = {
        {
            Description = "Gain a random 3-star rarity gem to your current character every 24 hours.",
            Value = 4,
            CraftingMaterialsRequired = {
                {"Gold", 100},
            }
        },
        {
            Description = "Gain a random 3-star rarity gem to your current character every 18 hours.",
            Value = 6,
            MaterialsRequired = {
                {"Gold", 30000},
            }
        },
        {
            Description = "Gain a random 3-star rarity gem to your current character every 12 hours.",
            Value = 8,
            MaterialsRequired = {
                {"Gold", 70000},
            }
        }
    }
}