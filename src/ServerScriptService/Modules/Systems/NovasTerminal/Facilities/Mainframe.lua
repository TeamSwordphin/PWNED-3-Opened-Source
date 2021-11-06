return {
    ID = 1,
    Style = "M A I N F R A M E",
    Name = "Mainframe",
    Model = game.ReplicatedStorage.Models.Facilities.Mainframe,
    MaxLevels = 6,
    PowerRequired = 0,
    SecondsToCreate = 0,
    UpgradeSecondsPerRank = 1800,
    Levels = {
        {
            Description = "Can build up to 5 facilities. Required for basic functionality like electricity and thermals.",
            Value = 5
        },
        {
            Description = "Can build up to 7 facilities.",
            Value = 7,
            MaterialsRequired = {
                {"Gold", 50000},
            }
        },
        {
            Description = "Can build up to 10 facilities.",
            Value = 10,
            MaterialsRequired = {
                {"Gold", 120000},
            }
        },
        {
            Description = "Can build up to 15 facilities.",
            Value = 15,
            MaterialsRequired = {
                {"Gold", 200000},
            }
        },
        {
            Description = "Can build up to 25 facilities.",
            Value = 25,
            MaterialsRequired = {
                {"Gold", 500000},
            }
        },
        {
            Description = "Can build up to 40 facilities.",
            Value = 40,
            MaterialsRequired = {
                {"Gold", 1000000},
            }
        }
    }
}