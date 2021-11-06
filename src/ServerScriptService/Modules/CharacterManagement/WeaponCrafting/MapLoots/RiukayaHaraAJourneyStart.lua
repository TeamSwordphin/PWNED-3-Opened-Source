local module = {Name = "Riukaya-Hara: A Journey's Start"}

local WeaponDataBase = { ---NEVER USE ID 1
	{
		ID = 0, --- Zero Index or under is for costumes only, not trophies
		WeaponName = "Red Knight Costume",
		Description = "Armor wore by the security of a city.",
		Rarity = 4,
		LevelReq = 0,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 0,
		Model = game.ReplicatedStorage.Models.Armor.RedKnightPlayerSuit,
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
		WeaponName = "Battery Pack",
		Description = "Augmented with robotic power. Increases user's defense capabilities.",
		Rarity = 2,
		LevelReq = 1,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Trophies.RedKnightTrophy,
		Skills = { --up to 5
			28
		},
		Stats = {
			HP = 440,
			ATK = 0,
			DEF = 40,
			STAM = 0,
			CRIT = 0,
			CRITDEF = -.15 ---- IFRAME DURATIONS PERCENTAGE
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
		ID = 3,
		WeaponName = "Robust Pack",
		Description = "Augmented with robotic power. Increases user's defense capabilities.",
		Rarity = 3,
		LevelReq = 50,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 200,
		Model = game.ReplicatedStorage.Models.Trophies.BlueKnightTrophy,
		Skills = { --up to 5
			28
		},
		Stats = {
			HP = 1900,
			ATK = 0,
			DEF = 40,
			STAM = 0,
			CRIT = 0,
			CRITDEF = -.15 ---- IFRAME DURATIONS PERCENTAGE
		},
		StatsPerLevel = {
			HP = 0,
			ATK = 0,
			DEF = 0,
			STAM = 0,
			CRIT = 0,
			CRITDEF = 0
		}
	}
}

local LootList = {
	NormalLoots = {
		["Nothing"] = 0,
		[0] = 30,
		[2] = 70
	},
	HeroLoots = {
		["Nothing"] = 40
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
