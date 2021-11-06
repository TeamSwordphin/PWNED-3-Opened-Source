local module = {Name = "City Roads: The Streets are Silent"}

local WeaponDataBase = { ---NEVER USE ID 1
	{
		ID = 0, --- Zero Index or under is for costumes only, not trophies
		WeaponName = "City Guard Costume",
		Description = "Armor wore by the security of a road.",
		Rarity = 4,
		LevelReq = 0,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 0,
		Model = game.ReplicatedStorage.Models.Armor.CityGuardSuit,
		Skills = { --up to 5
		},
		Stats = {
			HP = 0,
			ATK = 0,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0 ---- IFRAME DURATIONS PERCENTAGE
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 0,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		}
	},
	{
		ID = 2,
		WeaponName = "Shadow Swords",
		Description = "Blades imbued with demonic energy. Wielded by a corrupted foe.",
		Rarity = 3,
		LevelReq = 15,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Trophies.ShadowSwordTrophy,
		Skills = { --up to 5
			29
		},
		Stats = {
			HP = 960,
			ATK = 0,
			DEF = 2,
			STAM = 0,
			CRIT = 0,
			CRITDEF = .20 ---- IFRAME DURATIONS PERCENTAGE
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 2,
			DEF = 1,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		}
	},
	{
		ID = 3,
		WeaponName = "Fallen Wings",
		Description = "Extremely heavy wings, not actually made for flying.",
		Rarity = 2,
		LevelReq = 15,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Trophies.WingedTrophy,
		Skills = { --up to 5
			30
		},
		Stats = {
			HP = 870,
			ATK = 0,
			DEF = 25,
			STAM = 0,
			CRIT = 0,
			CRITDEF = -.20 ---- IFRAME DURATIONS PERCENTAGE
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 2,
			DEF = 1,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		}
	},
	{
		ID = 4,
		WeaponName = "Corrupted Wings",
		Description = "Extremely heavy wings, not actually made for flying.",
		Rarity = 3,
		LevelReq = 50,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Trophies.CorruptedWingedTrophy,
		Skills = { --up to 5
			31
		},
		Stats = {
			HP = 1860,
			ATK = 0,
			DEF = 22,
			STAM = 0,
			CRIT = 0,
			CRITDEF = -.20 ---- IFRAME DURATIONS PERCENTAGE
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 2,
			DEF = 1,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		}
	}
}

local LootList = {
	NormalLoots = {
		["Nothing"] = 60,
		[2] = 10,
		[3] = 30
	},
	HeroLoots = {
		["Nothing"] = 70,
		[0] = 10,
		[4] = 30
	},
	EMDLoots = {
		["Nothing"] = 60
	}
}


function module:ReturnMapLootList(MapName, Difficulty)
	--- Rarity Weight / Total WEight
	if typeof(MapName) == "string" and typeof(Difficulty) == "string" then
		local Total = 0
		local NewList = {}
		if Difficulty == "HeroesMustDie" then
			for b,v in pairs(LootList.EMDLoots) do
				Total = Total + v
				local NewItem = {}
				NewItem.ID = b
				NewItem.Chance = v
				table.insert(NewList, NewItem)
			end
			return NewList, Total
		elseif Difficulty == "Hero" then
			for b,v in pairs(LootList.HeroLoots) do
				Total = Total + v
				local NewItem = {}
				NewItem.ID = b
				NewItem.Chance = v
				table.insert(NewList, NewItem)
			end
			return NewList, Total
		else
			for b,v in pairs(LootList.NormalLoots) do
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

function module:ReturnTrophyList()
	return WeaponDataBase
end

return module
