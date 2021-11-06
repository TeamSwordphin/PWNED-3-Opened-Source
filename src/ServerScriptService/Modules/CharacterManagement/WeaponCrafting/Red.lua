local module = {}

local WeaponDataBase = {
	{
		ID = 1,
		WeaponName = "Default",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 1,
		LevelReq = 1,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 15,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 2,
		WeaponName = "Red Strident",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 1,
		LevelReq = 5,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 25,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 3,
		WeaponName = "The Calling",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 2,
		LevelReq = 5,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 35,
			DEF = 0,
			STAM = 10,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 4,
		WeaponName = "Piercing Shot",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 1,
		LevelReq = 15,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 45,
			DEF = 0,
			STAM = 10,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 5,
		WeaponName = "Transcendence",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 2,
		LevelReq = 15,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 60,
			DEF = 0,
			STAM = 20,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 6,
		WeaponName = "Pulverizing Quickshot",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 2,
		LevelReq = 15,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 70,
			DEF = 0,
			STAM = 50,
			CRIT = 5,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 7,
		WeaponName = "The Last Magnitude",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 3,
		LevelReq = 15,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 80,
			DEF = 0,
			STAM = 50,
			CRIT = 10,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 8,
		WeaponName = "Stargazer",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 2,
		LevelReq = 30,
		MaxUpgrades = 3,
		MaxEnchantments = 3,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 80,
			DEF = 0,
			STAM = 50,
			CRIT = 25,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 9,
		WeaponName = "Animosity",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 3,
		LevelReq = 35,
		MaxUpgrades = 3,
		MaxEnchantments = 3,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 90,
			DEF = 0,
			STAM = 45,
			CRIT = 35,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 10,
		WeaponName = "Ray Tracer",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 4,
		LevelReq = 200,
		MaxUpgrades = 40,
		MaxEnchantments = 4,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 1900,
			DEF = 0,
			STAM = 100,
			CRIT = 250,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 11,
		WeaponName = "Cosmos Engulfer",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 5,
		LevelReq = 200,
		MaxUpgrades = 60,
		MaxEnchantments = 4,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 2100,
			DEF = 0,
			STAM = 100,
			CRIT = 400,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 12,
		WeaponName = "Temporal Animosity",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 4,
		LevelReq = 200,
		MaxUpgrades = 60,
		MaxEnchantments = 5,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 2300,
			DEF = 0,
			STAM = 100,
			CRIT = 460,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 13,
		WeaponName = "Glitched Animosity",
		Description = "A sword that can transform into a plasma rifle.",
		Rarity = 5,
		LevelReq = 200,
		MaxUpgrades = 80,
		MaxEnchantments = 5,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.RedWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 2500,
			DEF = 0,
			STAM = 150,
			CRIT = 500,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	}
}

local LootList = {
	{
		MissionName = "Riukaya-Hara: A Journey's Start",
		NormalLoots = {
			["Nothing"] = 0,
			[2] = 30,
			[3] = 20
		},
		HeroLoots = {
			["Nothing"] = 30,
			[6] = 40,
			[7] = 25
		},
		EMDLoots = {
			["Nothing"] = 60,
			[10] = 30,
			[11] = 5
		}
	},
	{
		MissionName = "City Roads: The Streets are Silent",
		NormalLoots = {
			["Nothing"] = 10,
			[4] = 30,
			[5] = 20
		},
		HeroLoots = {
			["Nothing"] = 10,
			[8] = 30,
			[9] = 25
		},
		EMDLoots = {
			["Nothing"] = 60,
			[12] = 30,
			[13] = 5
		}
	}
}

function module:ReturnMapLootList(MapName, Difficulty)
	--- Rarity Weight / Total WEight
	if typeof(MapName) == "string" and typeof(Difficulty) == "string" then
		for i = 1, #LootList do
			if LootList[i].MissionName == MapName then
				local Total = 0
				local NewList = {}
				if Difficulty == "HeroesMustDie" then
					for b,v in pairs(LootList[i].EMDLoots) do
						Total = Total + v
						local NewItem = {}
						NewItem.ID = b
						NewItem.Chance = v
						table.insert(NewList, NewItem)
					end
					return NewList, Total
				elseif Difficulty == "Hero" then
					for b,v in pairs(LootList[i].HeroLoots) do
						Total = Total + v
						local NewItem = {}
						NewItem.ID = b
						NewItem.Chance = v
						table.insert(NewList, NewItem)
					end
					return NewList, Total
				else
					for b,v in pairs(LootList[i].NormalLoots) do
						Total = Total + v
						local NewItem = {}
						NewItem.ID = b
						NewItem.Chance = v
						table.insert(NewList, NewItem)
					end
					return NewList, Total
				end
			end
		end
	end
end

function module:ReturnWeaponList()
	return WeaponDataBase
end

return module
