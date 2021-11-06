--[[ PLUGIN USERS README HERE:

If you clicked the question mark and this script popped up, then read here. The numbers in the editor symbolizes the "ID" of the weapon skills (or infusions) defined below.
You can add/remove the specific IDs according to which skill you like to use below. 




]]---


local module = {}

local WeaponCraftingDatabase = {}
local TrophyLootDatabase = {}

local WeaponSkillsDatabase = {
	{
		ID = 1,
		ReqLevel = 1,
		Name = "Attack Up",
		Desc = "Increases your overall attack damage.",
		Category = "Stat Boosts",
		Tier1 = {Min = 1, Max = 3},
		Tier2 = {Min = 2, Max = 5},
		Tier3 = {Min = 4, Max = 7},
		Tier4 = {Min = 5, Max = 8},
		Prefix = "%"
	},
	{
		ID = 2,
		ReqLevel = 1,
		Name = "Armor Piercer",
		Desc = "Ignores a percentage of the enemy's defense.",
		Category = "Stat Boosts",
		Tier1 = {Min = 5, Max = 7},
		Tier2 = {Min = 6, Max = 9},
		Tier3 = {Min = 8, Max = 12},
		Tier4 = {Min = 10, Max = 15},
		Prefix = "%"
	},
	{
		ID = 3,
		ReqLevel = 1,
		Name = "Defense Up",
		Desc = "Reduces all incoming damage taken.",
		Category = "Stat Boosts",
		Tier1 = {Min = 2, Max = 4},
		Tier2 = {Min = 3, Max = 5},
		Tier3 = {Min = 4, Max = 6},
		Tier4 = {Min = 6, Max = 8},
		Prefix = "%"
	},
	{
		ID = 4,
		ReqLevel = 1,
		Name = "Stamina Decrease",
		Desc = "Reduces your overall stamina consumption.",
		Category = "Resists",
		Tier1 = {Min = 2, Max = 4},
		Tier2 = {Min = 3, Max = 5},
		Tier3 = {Min = 4, Max = 7},
		Tier4 = {Min = 5, Max = 8},
		Prefix = "%"
	},
	{
		ID = 5,
		ReqLevel = 1,
		Name = "Bandit",
		Desc = "Critical hits rewards Gold.",
		Category = "Utility",
		Tier1 = {Min = 1, Max = 2},
		Tier2 = {Min = 1, Max = 3},
		Tier3 = {Min = 1, Max = 4},
		Tier4 = {Min = 1, Max = 5},
		Prefix = " Gold"
	},
	{
		ID = 6,
		ReqLevel = 1,
		Name = "Bleed Resist",
		Desc = "Decreases Bleed debuff duration. Stacks with other debuff resist buffs.",
		Category = "Resists",
		Tier1 = {Min = 25, Max = 28},
		Tier2 = {Min = 30, Max = 40},
		Tier3 = {Min = 32, Max = 50},
		Tier4 = {Min = 35, Max = 70},
		Prefix = "%"
	},
	{
		ID = 7,
		ReqLevel = 1,
		Name = "Debuff Resist",
		Desc = "Decreases all negative debuff durations. Stacks with other debuff resist buffs.",
		Category = "Resists",
		Tier1 = {Min = 15, Max = 20},
		Tier2 = {Min = 18, Max = 25},
		Tier3 = {Min = 20, Max = 32},
		Tier4 = {Min = 25, Max = 40},
		Prefix = "%"
	},
	{
		ID = 8,
		ReqLevel = 1,
		Name = "Wounds Resist",
		Desc = "Decreases the amount of Critical Wounds taken. Stacks with other Critical Wounds resist buffs.",
		Category = "Resists",
		Tier1 = {Min = 7, Max = 12},
		Tier2 = {Min = 8, Max = 15},
		Tier3 = {Min = 10, Max = 20},
		Tier4 = {Min = 12, Max = 25},
		Prefix = "%"
	},
	{
		ID = 9,
		ReqLevel = 10,
		Name = "Tumble Master",
		Desc = "Has a 50% chance of not getting knocked back if a large attack hits.",
		Category = "Resists"
	},
	{
		ID = 10,
		ReqLevel = 10,
		Name = "Potion Addict",
		Desc = "Potions lasts for another few seconds.",
		Category = "Resists",
		Tier1 = {Min = 1, Max = 2},
		Tier2 = {Min = 1, Max = 3},
		Tier3 = {Min = 2, Max = 4},
		Tier4 = {Min = 2, Max = 5},
		Prefix = " Seconds"
	},
	{
		ID = 11,
		ReqLevel = 10,
		Name = "Tactician",
		Desc = "Every dodged attack replenishes your stamina.",
		Category = "Utility",
		Tier1 = {Min = 2, Max = 3},
		Tier2 = {Min = 2, Max = 4},
		Tier3 = {Min = 3, Max = 5},
		Tier4 = {Min = 3, Max = 6},
		Prefix = "%"
	},
	{
		ID = 12,
		ReqLevel = 20,
		Name = "Fatal Strike",
		Desc = "Your damage against any enemy cannot go under a limit, regardless of their defense.",
		Category = "Stat Boosts",
		Tier1 = {Min = 10, Max = 20},
		Tier2 = {Min = 12, Max = 25},
		Tier3 = {Min = 25, Max = 60},
		Tier4 = {Min = 60, Max = 200},
		Prefix = " DMG"
	},
	{
		ID = 13,
		ReqLevel = 50,
		Name = "Critical Act",
		Desc = "Increases your Critical Chance cap of 50% to something higher.",
		Category = "Utility",
		Tier1 = {Min = 51, Max = 60},
		Tier2 = {Min = 52, Max = 65},
		Tier3 = {Min = 58, Max = 70},
		Tier4 = {Min = 60, Max = 75},
		Prefix = "%"
	},
	{
		ID = 14,
		ReqLevel = 30,
		Name = "Draw Attack",
		Desc = "If Combo Score is zero, your next attack will deal double damage.",
		Category = "Stat Boosts"
	},
	{
		ID = 15,
		ReqLevel = 20,
		Name = "Critical Up",
		Desc = "Ignores a percentage of the enemy's CRIT DEF.",
		Category = "Stat Boosts",
		Tier1 = {Min = 16, Max = 20},
		Tier2 = {Min = 17, Max = 30},
		Tier3 = {Min = 18, Max = 40},
		Tier4 = {Min = 22, Max = 55},
		Prefix = "%"
	},
	{
		ID = 16,
		ReqLevel = 30,
		Name = "Resistant Fighter",
		Desc = "If HP is full, the next damaging hit dealt towards you has a chance of being reduced to 1.",
		Category = "Resists",
		Tier1 = {Min = 15, Max = 18},
		Tier2 = {Min = 16, Max = 20},
		Tier3 = {Min = 18, Max = 25},
		Tier4 = {Min = 20, Max = 30},
		Prefix = "%"
	},
	{
		ID = 17,
		ReqLevel = 100,
		Name = "Indecisive Preparation",
		Desc = "Life Force loss when you are incapacitated is reduced.",
		Category = "Utility",
		Tier1 = {Min = 4, Max = 7},
		Tier2 = {Min = 5, Max = 8},
		Tier3 = {Min = 7, Max = 14},
		Tier4 = {Min = 10, Max = 20},
		Prefix = "%"
	},
	{
		ID = 18,
		ReqLevel = 50,
		Name = "Critical Exploit",
		Desc = "Critical Hit Damage is increased.",
		Category = "Stat Boosts",
		Tier1 = {Min = 1, Max = 2},
		Tier2 = {Min = 2, Max = 4},
		Tier3 = {Min = 2, Max = 7},
		Tier4 = {Min = 4, Max = 10},
		Prefix = "%"
	},
	{
		ID = 19,
		ReqLevel = 120,
		Name = "Fatigue Immune",
		Desc = "Damage will no longer be decreased when fatigued.",
		Category = "Utility"
	},
	{
		ID = 20,
		ReqLevel = 60,
		Name = "Unfazed Resolve",
		Desc = "Gain increased damage below 25% HP.",
		Category = "Stat Boosts",
		Tier1 = {Min = 5, Max = 10},
		Tier2 = {Min = 5, Max = 12},
		Tier3 = {Min = 6, Max = 14},
		Tier4 = {Min = 7, Max = 16},
		Prefix = "%"
	},
	{
		ID = 21,
		ReqLevel = 40,
		Name = "Dented Blow",
		Desc = "Automatically Critical Hit when Combo Score is zero.",
		Category = "Utility"
	},
	{
		ID = 22,
		ReqLevel = 200,
		Name = "Missile Barrage",
		Desc = "Attacks will spawn 3 projectiles that deals 20% damage each and seeks nearby targets.",
		Category = "Stat Boosts"
	},
	{
		ID = 23,
		ReqLevel = 100,
		Name = "Quick Hands",
		Desc = "Attack speed is increased. Capped at 100%.",
		Category = "Utility",
		Tier1 = {Min = 1, Max = 4},
		Tier2 = {Min = 2, Max = 8},
		Tier3 = {Min = 3, Max = 15},
		Tier4 = {Min = 4, Max = 20},
		Prefix = "%"
	},
	{
		ID = 24,
		ReqLevel = 50,
		Name = "Incineration",
		Desc = "Dodging leaves behind a fire trail that damages enemies.",
		Category = "Stat Boosts",
		Tier1 = {Min = 25, Max = 35},
		Tier2 = {Min = 30, Max = 50},
		Tier3 = {Min = 35, Max = 75},
		Tier4 = {Min = 40, Max = 100},
		Prefix = "%"
	},
	{
		ID = 25,
		ReqLevel = 50,
		Name = "Lightning Shackles",
		Desc = "Hitting enemies has a 25% chance to damage 3 additional enemies in a 40 stud range.",
		Category = "Stat Boosts",
		Tier1 = {Min = 40, Max = 50},
		Tier2 = {Min = 45, Max = 60},
		Tier3 = {Min = 50, Max = 70},
		Tier4 = {Min = 60, Max = 80},
		Prefix = "%"
	},
	{
		ID = 26,
		ReqLevel = 50,
		Name = "Backup Targeter",
		Desc = "Hitting enemies has a 10% chance to launch missiles that deals damage.",
		Category = "Stat Boosts",
		Tier1 = {Min = 180, Max = 200},
		Tier2 = {Min = 190, Max = 230},
		Tier3 = {Min = 200, Max = 260},
		Tier4 = {Min = 220, Max = 300},
		Prefix = "%"
	},
	{
		ID = 27,
		ReqLevel = 50,
		Name = "Maskful Scourge",
		Desc = "Damaging enemies gives a decaying shield equal to a percent of your MAX HP that blocks damage.",
		Category = "Resists",
		Tier1 = {Min = 1, Max = 1},
		Tier2 = {Min = 1, Max = 2},
		Tier3 = {Min = 1, Max = 3},
		Tier4 = {Min = 1, Max = 4},
		Prefix = "%"
	},
	{
		ID = 28,
		ReqLevel = 1,
		Name = "Spiked Edges",
		Desc = "Taking damage will reflect 5% of the damage back towards the attacker.",
		Category = "Resists"
	},
	{
		ID = 29,
		ReqLevel = 1,
		Name = "Third Strike Fallacy",
		Desc = "Your third light attack will summon rotating swords that damages enemies for 4.5 seconds.",
		Category = "Stat Boosts"
	},
	{
		ID = 30,
		ReqLevel = 1,
		Name = "Mechanical Wings",
		Desc = "Jump slightly higher.",
		Category = "Utility"
	},
	{
		ID = 31,
		ReqLevel = 1,
		Name = "Mechanical Wings II",
		Desc = "Jump much higher.",
		Category = "Utility"
	},
	{
		ID = 32,
		ReqLevel = 1,
		Name = "Mechanical Discharge",
		Desc = "Jumping near enemies will release an electrical discharge, damaging nearby enemies.",
		Category = "Stat Boosts"
	},
	{
		ID = 33,
		ReqLevel = 1,
		Name = "Solid Mass",
		Desc = "Become immune to staggers and critical wounds.",
		Category = "Resists"
	},
	{
		ID = 34,
		ReqLevel = 1,
		Name = "Solid Mass II",
		Desc = "Become immune to staggers, critical wounds, and reduce damage taken by 15%.",
		Category = "Resists"
	},
	{
		ID = 35,
		ReqLevel = 1,
		Name = "Portal Hook",
		Desc = "When locked onto enemies, your block will teleport you instantly to the enemy.",
		Category = "Resists"
	},
	{
		ID = 36,
		ReqLevel = 1,
		Name = "Piercing Lasers",
		Desc = "Dealing damage has a 15% chance of firing a laser towards the nearest enemy.",
		Category = "Stat Boosts"
	},
	{
		ID = 37,
		ReqLevel = 1,
		Name = "Spectral Blades",
		Desc = "Summon swords that will automatically target nearby enemies.",
		Category = "Stat Boosts"
	},
	{
		ID = 38,
		ReqLevel = 1,
		Name = "Counter Break",
		Desc = "Parrying will deal 120% damage to countered enemies.",
		Category = "Utility"
	}
}

for _, Class in ipairs(script:GetChildren()) do
	if Class:IsA("ModuleScript") then
		WeaponCraftingDatabase[Class.Name] = require(Class)
	end
end

for _,TrophyData in ipairs(script.MapLoots:GetChildren()) do
	local mapTrophiesData = require(TrophyData)
	TrophyLootDatabase[mapTrophiesData.Name] = mapTrophiesData
end

function GetIndex(MaxSize,Inventory)
	local AvailableIndexes = {}
	for i = 1, MaxSize do
		table.insert(AvailableIndexes, i)
	end
	for i = 1, #Inventory do
		local Item = Inventory[i]
		if Item ~= nil and Item.CID > 0 then
			for v = 1, #AvailableIndexes do
				if AvailableIndexes[v] == Item.CID then
					table.remove(AvailableIndexes, v)
				end
			end
		end
	end
	return AvailableIndexes[1] or 1
end

local HttpService = game:GetService("HttpService")

function module:CreateWeapon(Wep, Inven)
	local NewWeapon = {}
	NewWeapon.ID = Wep.ID
	NewWeapon.CID = GetIndex(999, Inven)   --HttpService:GenerateGUID()
	NewWeapon.Skls = {}
	for i = 1, #Wep.Skills do
		local NewSkill = {}
		NewSkill.I = Wep.Skills[i]
		NewSkill.V = nil
		table.insert(NewWeapon.Skls, NewSkill)
	end
	NewWeapon.UpLvl = 0
	return NewWeapon
end

function module:GetLootList(Classe, MapName, Difficulty)
	local Class = Classe
	if WeaponCraftingDatabase[Class] ~= nil then
		return WeaponCraftingDatabase[Class]:ReturnMapLootList(MapName, Difficulty)
	end
end

function module:PreviewLootLists(MapName, Difficulty)
	local Items = {}
	
	if TrophyLootDatabase[MapName] ~= nil then
		local Loots, Totals = TrophyLootDatabase[MapName]:ReturnMapLootList(MapName, Difficulty)
		if Loots then
			for _,LootObj in ipairs(Loots) do
				local LootName = LootObj.ID
				local Chance = LootObj.Chance
				if LootName ~= "Nothing" then
					local Item = {}
					Item.MapName = MapName
					Item.Object = module:GetTrophyFromID(MapName, LootName)
					Item.Chance = math.floor(((Chance / Totals) * 100)+ .5)
					if Item.Object then
						table.insert(Items, Item)
					end
				end
			end
		end
	end
	
	for _, Classes in ipairs(script:GetChildren()) do
		if Classes:IsA("ModuleScript") then
			local ClassName = Classes.Name
			local Loots, Totals = module:GetLootList(ClassName, MapName, Difficulty)
			if Loots then
				for v = 1, #Loots do
					local LootObj = Loots[v]
					local LootName = LootObj.ID
					local Chance = LootObj.Chance
					if LootName ~= "Nothing" then
						local Ownership = ClassName
						local Item = {}
						Item.Object = module:GetWeaponFromID(ClassName, LootName)
						if Ownership == "Darwin" then
							Ownership = "Darwin / DarwinB"
						end
						Item.Ownership = Ownership
						Item.WeaponSkills = {}
						for i = 1, #Item.Object.Skills do
							table.insert(Item.WeaponSkills, module:GetSkillFromID(Item.Object.Skills[i]))
						end
						Item.Chance = math.floor(((Chance / Totals) * 100)+ .5)
						if Item.Object then
							table.insert(Items, Item)
						end
					end
				end
			end
		end
	end
	return Items
end

function module:GetTrophies(Map)
	if TrophyLootDatabase[Map] ~= nil then
		return TrophyLootDatabase[Map]:ReturnTrophyList()
	end
end

function module:GetTrophyFromID(Map, ID)
	local Trophy = module:GetTrophies(Map)
	if Trophy then
		for v = 1, #Trophy do
			if Trophy[v].ID == ID then
				return Trophy[v]
			end
		end
	end
end

function module:GetClassWeapons(Classe)
	local Class = Classe
	if WeaponCraftingDatabase[Class] then
		return WeaponCraftingDatabase[Class]:ReturnWeaponList()
	end
end

function module:GetWeapon(Classe, Name)
	local Class = Classe
	local Weapons = module:GetClassWeapons(Class)
	if Weapons then
		for v = 1, #Weapons do
			if Weapons[v].WeaponName == Name then
				return Weapons[v]
			end
		end
	end
end

function module:GetWeaponFromID(Classe, ID)
	local Class = Classe
	local Weapons = module:GetClassWeapons(Class)
	if Weapons then
		for v = 1, #Weapons do
			if Weapons[v].ID == ID then
				return Weapons[v]
			end
		end
	end
end

function randomLoot(OldChart, MaxProb)
	local Chart = OldChart
	local lootType 		= 1
	local randomValue 	= Random.new():NextNumber(1,MaxProb)
	table.sort(Chart, function(a,b) return a.Chance < b.Chance end)
	while Chart[lootType].Chance <= randomValue do
		if lootType < #Chart then
			lootType = lootType + 1
		else
			break
		end
	end
	return Chart[lootType]
end
--[[
local tb = {}
local NewItem  = {}
NewItem.Name = "Sword 1"
NewItem.Chance = 5
table.insert(tb, NewItem)
local NewItem  = {}
NewItem.Name = "Diamond Sword"
NewItem.Chance = 15
table.insert(tb, NewItem)
local NewItem  = {}
NewItem.Name = "Emeral Sword"
NewItem.Chance = 30
table.insert(tb, NewItem)
local NewItem  = {}
NewItem.Name = "Nothing"
NewItem.Chance = 50
table.insert(tb, NewItem)
local Total = 0
for i = 1, #tb do
	Total = Total + tb[i].Chance
end
local RarityList = {}
for i = 1, 150 do
	local Loot = randomLoot(tb, Total)
	table.insert(RarityList, Loot and ((Loot.Name=="Nothing" and "Gold" or Loot.Name) or "Less Gold"))
end
print("Total: ", Total)
local Sword1 = 0
local Diam = 0
local Emera = 0
local Nothing = 0
local LessGold = 0
Total = 0
for i = 1, #RarityList do
	local R = RarityList[i]
	if R == "Sword 1" then
		Sword1 = Sword1 + 1
		Total = Total + 1
	elseif R == "Diamond Sword" then
		Diam = Diam + 1
		Total = Total + 1
	elseif R == "Emeral Sword" then
		Emera = Emera + 1
		Total = Total + 1
	elseif R == "Gold" then
		Nothing = Nothing + 1
		Total = Total + 1
	else
		LessGold = LessGold + 1
		Total = Total + 1
	end
end
print( Sword1/Total*100, "\n", Diam/Total*100, "\n", Emera/Total*100, "\n", Nothing/Total*100, "\n", LessGold/Total*100 )
--]]

function module:DropRandomWeapon(Classe, MapName, Difficulty, Inven)
	local LootList, Total = module:GetLootList(Classe, MapName, Difficulty)
	if LootList then
		local ChosenLoot = randomLoot(LootList, Total)
		local Loot = {}
		Loot.WeaponObj = nil
		Loot.Object = nil
		Loot.Name = -1
		if ChosenLoot ~= nil then
			Loot.Name = ChosenLoot.ID
			if Loot.Name == "Nothing" then
				Loot.Name = "Gold"
			else
				local NewWeapon = module:GetWeaponFromID(Classe, Loot.Name)
				Loot.WeaponObj = module:CreateWeapon(NewWeapon, Inven)
				Loot.Object = NewWeapon
				Loot.Ownership = Classe
			end
		else
			Loot.Name = "LesserGold"
		end
		return Loot
	end
end

function module:DropRandomTrophy(MapName, Difficulty, Inven)
	if not TrophyLootDatabase[MapName] then return end

	local LootList, Total = TrophyLootDatabase[MapName]:ReturnMapLootList(MapName, Difficulty)
	if LootList then
		local ChosenLoot = randomLoot(LootList, Total)
		local Loot = {}
		Loot.IsSkin = false
		Loot.Object = nil
		if ChosenLoot ~= nil then
			Loot.Name = ChosenLoot.ID
			if Loot.Name == "Nothing" then
				Loot.Name = "Gold"
			else
				local NewTrophy = module:GetTrophyFromID(MapName, ChosenLoot.ID)
				Loot.Object = NewTrophy
				if ChosenLoot.ID >= 1 then ---Drops a trophy
					Loot.WeaponObj = module:CreateWeapon(NewTrophy, Inven)
					Loot.WeaponObj.Map = MapName
				else --- Drops a costume
					Loot.IsSkin = true
				end
			end
		else
			Loot.Name = "LesserGold"
		end
		return Loot
	end
end

function module:GetSkillFromID(ID)
	for _, Skill in ipairs(WeaponSkillsDatabase) do
		if Skill.ID == ID then
			return Skill
		end
	end
end

function module:GetSkills()
	return WeaponSkillsDatabase
end

return module
