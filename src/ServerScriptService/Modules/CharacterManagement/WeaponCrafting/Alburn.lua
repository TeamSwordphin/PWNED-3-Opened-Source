local module = {}

local WeaponDataBase = {
	{
		ID = 1,
		WeaponName = "Default",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 1,
		LevelReq = 1,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 30,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 5,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		},
	},
	{
		ID = 2,
		WeaponName = "Impactful Wave",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 1,
		LevelReq = 5,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 40,
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
		WeaponName = "Clenching Blade",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 2,
		LevelReq = 5,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 50,
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
		ID = 4,
		WeaponName = "Demonic Impulses",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 1,
		LevelReq = 15,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
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
			CRIT = 0,
			CRITDEF = 0
		},
	},
	{
		ID = 5,
		WeaponName = "Sword of Darkness",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 2,
		LevelReq = 15,
		MaxUpgrades = 2,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 70,
			DEF = 0,
			STAM = 25,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 0,
			CRITDEF = 0
		},
	},
	{
		ID = 6,
		WeaponName = "Flames of the Guard",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 2,
		LevelReq = 15,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 80,
			DEF = 0,
			STAM = 30,
			CRIT = 25,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 0,
			CRITDEF = 0
		},
	},
	{
		ID = 7,
		WeaponName = "Flames of the Blade",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 3,
		LevelReq = 20,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 90,
			DEF = 0,
			STAM = 30,
			CRIT = 0,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 0,
			STAM = 1,
			CRIT = 0,
			CRITDEF = 0
		},
	},
	{
		ID = 8,
		WeaponName = "Ruinshock",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 2,
		LevelReq = 30,
		MaxUpgrades = 3,
		MaxEnchantments = 3,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 100,
			DEF = 0,
			STAM = 70,
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
		ID = 9,
		WeaponName = "Heart of Power",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 3,
		LevelReq = 35,
		MaxUpgrades = 3,
		MaxEnchantments = 3,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 105,
			DEF = 0,
			STAM = 80,
			CRIT = 20,
			CRITDEF = 0
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 1,
			DEF = 1,
			STAM = 1,
			CRIT = 1,
			CRITDEF = 0
		},
	},
	{
		ID = 10,
		WeaponName = "Curse of the Sword",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 4,
		LevelReq = 200,
		MaxUpgrades = 40,
		MaxEnchantments = 4,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 1770,
			DEF = 0,
			STAM = 140,
			CRIT = 90,
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
		WeaponName = "Curse of the Shield",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 5,
		LevelReq = 200,
		MaxUpgrades = 60,
		MaxEnchantments = 4,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 2070,
			DEF = 0,
			STAM = 160,
			CRIT = 120,
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
		WeaponName = "Fallen Juggernaut",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 4,
		LevelReq = 200,
		MaxUpgrades = 50,
		MaxEnchantments = 5,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 2770,
			DEF = 0,
			STAM = 160,
			CRIT = 150,
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
		WeaponName = "Curse of the Demon",
		Description = "A sword and shield imbued with demonic energy.",
		Rarity = 5,
		LevelReq = 200,
		MaxUpgrades = 80,
		MaxEnchantments = 5,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Weapons.AlburnWeapon,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 3870,
			DEF = 0,
			STAM = 160,
			CRIT = 200,
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
