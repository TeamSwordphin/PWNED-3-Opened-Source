return {
	{
		Rank = 0,
		Description = "Your Servare does not have any bonus attributes.",
		GoldPrice = 100,
		SucceedChance = 1, --0 - 1
		SetbackChance = 0, --0 - 1
		SetbackLevels = 0, --amount of levels to setback by
		ItemsToGoNext = { --items needed to get to next rank {name, amount}
			{"Plastic Sheet", 5},
			{"Broken Metal", 2}
		}
	},
	{
		Rank = 1,
		Description = "+2% Weapon Damage, +4% Precision",
		GoldPrice = 200,
		SucceedChance = 1,
		SetbackChance = 0, 
		SetbackLevels = 0, 
		ItemsToGoNext = {
			{"Plastic Sheet", 5},
			{"Broken Metal", 5},
			{"Tinfoil", 1}
		}
	},
	{
		Rank = 2,
		Description = "+3% Weapon Damage, +8% Precision, +1% Armor Penetration",
		GoldPrice = 300,
		SucceedChance = 1,
		SetbackChance = 0, 
		SetbackLevels = 0, 
		ItemsToGoNext = {
			{"Plastic Sheet", 7},
			{"Broken Metal", 10},
			{"Tinfoil", 8},
			{"Copper Fragment", 2}
		}
	},
	{
		Rank = 3,
		Description = "+5% Weapon Damage, +12% Precision, +3% Armor Penetration",
		GoldPrice = 400,
		SucceedChance = 1,
		SetbackChance = 0, 
		SetbackLevels = 0, 
		ItemsToGoNext = {
			{"Plastic Sheet", 8},
			{"Broken Metal", 10},
			{"Tinfoil", 8},
			{"Copper Fragment", 2}
		}
	},
	{
		Rank = 4,
		Description = "+7% Weapon Damage, +16% Precision, +5% Armor Penetration",
		GoldPrice = 500,
		SucceedChance = 1,
		SetbackChance = 0, 
		SetbackLevels = 0, 
		ItemsToGoNext = {
			{"Plastic Sheet", 5},
			{"Broken Metal", 15},
			{"Tinfoil", 10},
			{"Copper Fragment", 5}
		}
	},
	{
		Rank = 5,
		Description = "+9% Weapon Damage, +20% Precision, +7% Armor Penetration",
		GoldPrice = 600,
		SucceedChance = 1,
		SetbackChance = 0, 
		SetbackLevels = 0, 
		ItemsToGoNext = {
			{"Plastic Sheet", 7},
			{"Broken Metal", 15},
			{"Tinfoil", 10},
			{"Copper Fragment", 5}
		}
	},
	{
		Rank = 6,
		Description = "+11% Weapon Damage, +24% Precision, +9% Armor Penetration",
		GoldPrice = 700,
		SucceedChance = .9,
		SetbackChance = 0, 
		SetbackLevels = 0, 
		ItemsToGoNext = {
			{"Broken Metal", 10},
			{"Tinfoil", 10},
			{"Copper Fragment", 10},
			{"Dented Metal", 5}
		}
	},
	{
		Rank = 7,
		Description = "+13% Weapon Damage, +28% Precision, +11% Armor Penetration",
		GoldPrice = 800,
		SucceedChance = .9,
		SetbackChance = 0, 
		SetbackLevels = 0, 
		ItemsToGoNext = {
			{"Broken Metal", 15},
			{"Tinfoil", 15},
			{"Copper Fragment", 15},
			{"Dented Metal", 7}
		}
	},
	{
		Rank = 8,
		Description = "+15% Weapon Damage, +32% Precision, +13% Armor Penetration",
		GoldPrice = 900,
		SucceedChance = .8,
		SetbackChance = 0.2, 
		SetbackLevels = 1, 
		ItemsToGoNext = {
			{"Tinfoil", 15},
			{"Copper Fragment", 15},
			{"Dented Metal", 7},
			{"Iron Hook", 5},
			{"Silver Fragment", 4}
		}
	},
	{
		Rank = 9,
		Description = "+17% Weapon Damage, +36% Precision, +15% Armor Penetration, Cannot go under 10 Damage",
		GoldPrice = 1000,
		SucceedChance = .8,
		SetbackChance = 0.2, 
		SetbackLevels = 1, 
		ItemsToGoNext = {
			{"Tinfoil", 15},
			{"Copper Fragment", 15},
			{"Dented Metal", 7},
			{"Iron Hook", 5},
			{"Silver Fragment", 4}
		}
	},
	{
		Rank = 10,
		Description = "+19% Weapon Damage, +40% Precision, +17% Armor Penetration, Cannot go under 50 Damage",
		GoldPrice = 1100,
		SucceedChance = .7,
		SetbackChance = 0.3, 
		SetbackLevels = 1, 
		ItemsToGoNext = {
			{"Copper Fragment", 20},
			{"Dented Metal", 10},
			{"Iron Hook", 10},
			{"Silver Fragment", 5},
			{"Broken Blade", 5}
		}
	},
	{
		Rank = 11,
		Description = "+21% Weapon Damage, +44% Precision, +19% Armor Penetration, Cannot go under 75 Damage",
		GoldPrice = 1200,
		SucceedChance = .6,
		SetbackChance = 0.4, 
		SetbackLevels = 2, 
		ItemsToGoNext = {
			{"Copper Fragment", 20},
			{"Dented Metal", 10},
			{"Iron Hook", 10},
			{"Silver Fragment", 5},
			{"Broken Blade", 5}
		}
	},
	{
		Rank = 12,
		Description = "+25% Weapon Damage, +48% Precision, +23% Armor Penetration, Cannot go under 100 Damage, Regenerates 0.5% of your HP per hit",
		GoldPrice = 1300,
		SucceedChance = .6,
		SetbackChance = 0.4, 
		SetbackLevels = 2, 
		ItemsToGoNext = {
			{"Dented Metal", 15},
			{"Iron Hook", 15},
			{"Silver Fragment", 10},
			{"Broken Blade", 5},
			{"Looking Glass", 3},
			{"Plexiglass", 2}
		}
	},
	{
		Rank = 13,
		Description = "+30% Weapon Damage, +52% Precision, +28% Armor Penetration, Cannot go under 150 Damage, Regenerates 1% of your HP per hit, Reduces all Stamina costs for dodging, light, and heavy attacks by 10%",
		GoldPrice = 1400,
		SucceedChance = .5,
		SetbackChance = 0.5, 
		SetbackLevels = 2, 
		ItemsToGoNext = {
			{"Iron Hook", 15},
			{"Silver Fragment", 10},
			{"Broken Blade", 9},
			{"Looking Glass", 5},
			{"Cobalt Alloy", 4},
			{"Unknown Shard", 1},
			{"Emerald Bolt", 1}
		}
	},
	{
		Rank = 14,
		Description = "+40% Weapon Damage, +56% Precision, +35% Armor Penetration, Cannot go under 300 Damage, Regenerates 1.5% of your HP per hit, Reduces all Stamina costs for dodging, light, and heavy attacks by 20%",
		GoldPrice = 1500,
		SucceedChance = .4,
		SetbackChance = 0.6, 
		SetbackLevels = 2, 
		ItemsToGoNext = {
			{"Cobalt Alloy", 8},
			{"Unknown Shard", 5},
			{"Emerald Bolt", 2},
			{"Platinum Core", 1},
			{"Titanium Chip", 1},
			{"Hidden Artifact", 1}
		}
	},
	{
		Rank = 15,
		Description = "+50% Weapon Damage, +60% Precision, +50% Armor Penetration, Cannot go under 500 Damage, Regenerates 3% of your HP per hit, Reduces all Stamina costs for dodging, light, and heavy attacks by 30%, EXP gains increased by 20%",
		GoldPrice = 0,
		SucceedChance = 0,
		SetbackChance = 0, 
		SetbackLevels = 0, 
		ItemsToGoNext = {
		}
	}
}