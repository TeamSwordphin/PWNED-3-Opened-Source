local module = {}

local WeaponDataBase = {
	{
		ID = 1,
		WeaponName = "Default",
		Description = "",
		Rarity = 1,
		LevelReq = 1,
		MaxUpgrades = 3,
		MaxEnchantments = 2,
		SellPrice = 0,
		Model = nil,
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
	}
}

local LootList = {
}

function module:ReturnMapLootList(MapName, Difficulty)
	--- Rarity Weight / Total WEight
	return {}
end

function module:ReturnWeaponList()
	return WeaponDataBase
end

return module
