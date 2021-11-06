local module = {Name = "Simulated Battle III"}

local WeaponDataBase = { ---NEVER USE ID 1
	{
		ID = 0, --- Zero Index or under is for costumes only, not trophies
		WeaponName = "Executioner Costume",
		Description = "Highly advanced armor for an intelligent security unit.",
		Rarity = 5,
		LevelReq = 0,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 0,
		Model = game.ReplicatedStorage.Models.Armor.TheExecutionerSuit,
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
	}
}

local LootList = {
	NormalLoots = {
		["Nothing"] = 70,
		[0] = 10
	},
	HeroLoots = {
		["Nothing"] = 70
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
