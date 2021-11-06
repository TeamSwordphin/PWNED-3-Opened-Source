local module = {Name = "Null"}

local WeaponDataBase = {
	{
		ID = 1,
		WeaponName = "Proof of Awakening",
		Description = "The idea of awakening is conceptual. There is no physical form to show.",
		Rarity = 1,
		LevelReq = 1,
		MaxUpgrades = 0,
		MaxEnchantments = 0,
		SellPrice = 0,
		Model = nil,
		Skills = { --up to 5
		},
		Stats = {
			HP = 2,
			ATK = 0,
			DEF = 1,
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
		["Nothing"] = 0
	},
	HeroLoots = {
		["Nothing"] = 0
	},
	EMDLoots = {
		["Nothing"] = 0
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
