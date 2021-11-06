local module = {}

local WeaponDataBase = {
	{
		ID = 1,
		WeaponName = "Default",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 1,
		LevelReq = 1,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 10,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 2,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		},
	},
	{
		ID = 2,
		WeaponName = "Blue Faylar",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 1,
		LevelReq = 5,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 20,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		},
	},
	{
		ID = 3,
		WeaponName = "Blue Seeker",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 2,
		LevelReq = 5,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 25,
			DEF = 0,
			STAM = 10,
			CRIT = 2,
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
		WeaponName = "Destructive Turbulence",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 1,
		LevelReq = 15,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 35,
			DEF = 0,
			STAM = 13,
			CRIT = 6,
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
		WeaponName = "Former Glory",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 2,
		LevelReq = 15,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 40,
			DEF = 0,
			STAM = 21,
			CRIT = 11,
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
		WeaponName = "Sundering Bal",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 2,
		LevelReq = 15,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 50,
			DEF = 0,
			STAM = 25,
			CRIT = 21,
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
		WeaponName = "Eye of Righteousness",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 3,
		LevelReq = 20,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 45,
			DEF = 0,
			STAM = 55,
			CRIT = 32,
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
		WeaponName = "Sword of Evergloom",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 2,
		LevelReq = 30,
		MaxUpgrades = 3,
		MaxEnchantments = 3,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 60,
			DEF = 0,
			STAM = 30,
			CRIT = 30,
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
		WeaponName = "Plundering Sanctuary",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 3,
		LevelReq = 35,
		MaxUpgrades = 3,
		MaxEnchantments = 3,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 65,
			DEF = 0,
			STAM = 35,
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
		WeaponName = "Curse of the Fallen",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 4,
		LevelReq = 200,
		MaxUpgrades = 40,
		MaxEnchantments = 4,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 1810,
			DEF = 0,
			STAM = 280,
			CRIT = 311,
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
		WeaponName = "Pledge of Allegiance",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 5,
		LevelReq = 200,
		MaxUpgrades = 60,
		MaxEnchantments = 4,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 2410,
			DEF = 0,
			STAM = 280,
			CRIT = 220,
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
		WeaponName = "Blue Duskmoor",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 4,
		LevelReq = 200,
		MaxUpgrades = 50,
		MaxEnchantments = 5,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 2520,
			DEF = 0,
			STAM = 80,
			CRIT = 20,
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
		WeaponName = "Swift Hunter",
		Description = "A rod infused with high thermal energy in the shape of a greatsword.",
		Rarity = 5,
		LevelReq = 200,
		MaxUpgrades = 80,
		MaxEnchantments = 5,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.DarwinWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 2620,
			DEF = 0,
			STAM = 80,
			CRIT = 20,
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
