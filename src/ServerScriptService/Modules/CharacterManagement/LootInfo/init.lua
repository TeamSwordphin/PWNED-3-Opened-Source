local module = {}

local WeaponRanks = require(script.WeaponRanks)

local LootChart 					= {}
local GemChart						= {}








--[[ PLUGIN USERS README HERE:

If you clicked the question mark and this script popped up, then read here. The correct syntax for gemstones are:

{"IG":true,"IND":0,"ID":0,"R":0,"Q":0}

IG stands for Is-It-A-Gem. Yes, it is a gem, so therefore this will always be true.
IND stands for index of the gem. Make sure all the gems have different IND values, this is a safeguard against duplication glitches. Doesn't matter which number.
ID stands for the ID or type of the gem, as listed below. Match this ID to whatever gem below you like.
R stands for Rarity. 0 = Triangle, 5 = Octagon (max). Self explanatory. Do not set a weird rarity for a gemstone that has a nil rank (ie. Primal Bloodlust will error if you set the rarity to 0).
Q stands for value, should be the same as the rank you set it as.


]]---


local GemTypes = {
				{Name = "ATK Increase", Description = "Increases all damage dealt by ", Prefix = "%.",
					Ranks = {
						2, 3, 5, 7, 9, 12
					},
					ID = 1
				},
				{Name = "DEF Increase", Description = "Reduces all incoming damage by ", Prefix = "%.",
					Ranks = {
						10, 11, 12, 13, 14, 15
					},
					ID = 2
				},
				{Name = "HP Increase", Description = "Increases your maximum HP by ", Prefix = "%.",
					Ranks = {
						10, 12, 14, 16, 18, 20
					},
					ID = 3
				},
				{Name = "Gold Increase", Description = "Increases the amount of gold earned at the end of each map by ", Prefix = "%.",
					Ranks = {
						2, 4, 6, 10, 15, 25
					},
					ID = 4
				},
				{Name = "EXP Increase", Description = "Increases the amount of EXP earned at the end of each map by ", Prefix = "%.",
					Ranks = {
						5, 7, 9, 12, 15, 20
					},
					ID = 5
				},
				{Name = "Critical Increase", Description = "Increases your Crit stat by ", Prefix = ".",
					Ranks = {
						70, 150, 300, 450, 650, 850
					},
					ID = 6
				},
				{Name = "Cry Increase", Description = "Increases Cry Gauge recovery per hit by ", Prefix = "%.",
					Ranks = {
						3, 5, 7, 9, 12, 15
					},
					ID = 7
				},
				{Name = "Primal Curse and Bloodlust", Description = "You take 999,999 (can be lowered or mitigated with stat, skill, gemstones, and buffs) damage per hit in exchange for massively increased damage. Damage is increased by ", Prefix = "%.",
					Ranks = {
						nil, nil, nil, nil, 40, 70
					},
					ID = 8
				},
				{Name = "Combo Score Time Increase", Description = "Increases the duration of combo scores before it resets back to zero by ", Prefix = "%.",
					Ranks = {
						10, 15, 20, 25, 30, 35
					},
					ID = 9
				},
				{Name = "Armor Penetration", Description = "All damaging abilities ignores ", Prefix = "% of the enemy's DEF. Stacks with other armor piercing buffs.",
					Ranks = {
						15, 20, 25, 30, 35, 40
					},
					ID = 10
				},
				{Name = "Parry Window Increase", Description = "Parrying becomes easier as the parry window timer is increased by ", Prefix = "%.",
					Ranks = {
						5, 10, 15, 20, 25, 30
					},
					ID = 11
				},
				{Name = "Gemstone Scavenger", Description = "Upon getting a gemstone drop, there is a ", Prefix = "% chance to gain a duplicate gemstone of the same type and rarity.",
					Ranks = {
						10, 12, 14, 16, 18, 20
					},
					ID = 12
				},
				{Name = "Stamina Use Decrease", Description = "Decreases all stamina usage and stamina taken by blocked damage by ", Prefix = "%.",
					Ranks = {
						10, 15, 20, 25, 30, 35
					},
					ID = 13
				},
				{Name = "Reinforced Armor", Description = "Defense rating is increased by ", Prefix = "%. Effective only at high Defense Ratings.",
					Ranks = {
						6, 7, 8, 9, 10, 11
					},
					ID = 15
				},
				{Name = "Medic", Description = "Upon revival of a nearby player, refund ", Prefix = " Life Force.",
					Ranks = {
						nil, nil, 5, 10, 15, 20
					},
					ID = 16
				},
				{Name = "Life Drain on Crit", Description = "Recover ", Prefix = "% of your Critical Damage as health.\n\nYour Crit stat is also increased, x10 by this current amount.",
					Ranks = {
						0.25, 0.3, 0.35, 0.4, 0.45, 0.5
					},
					ID = 17
				},
				{Name = "Ranger", Description = "Damage dealt to enemies at least 15 studs away from you deals ", Prefix = "% additional damage. 4 Bar Ultimates will automatically gain this damage buff, regardless of distance.",
					Ranks = {
						3, 4, 5, 6, 8, 10
					},
					ID = 18
				},
				{Name = "Close Defense", Description = "CRIT DEF is increased by ", Prefix = "%.",
					Ranks = {
						15, 25, 40, 60, 80, 100
					},
					ID = 19
				},
				{Name = "Muscular Power", Description = "", Prefix = "% of your maximum HP is converted to bonus additional damage. Critical Wounds affects this gemstone.",
					Ranks = {
						4, 6, 8, 10, 12, 15
					},
					ID = 20
				},
				{Name = "Gold Digger", Description = "Each won map gives an additional ", Prefix = " gold.",
					Ranks = {
						50, 75, 100, 125, 175, 250
					},
					ID = 21
				},
				{Name = "Under Pressure", Description = "The lower the current Lifeforce is, the more damage you will do, up to ", Prefix = "% at 1 Lifeforce.",
					Ranks = {
						14, 16, 18, 20, 22, 25
					},
					ID = 22
				},
				{Name = "Critical Wounds Decrease", Description = "Lowers the amount of Critical Wounds you take by ", Prefix = "%.",
					Ranks = {
						15, 20, 25, 30, 35, 40
					},
					ID = 23
				},
				{Name = "Giant Slayer", Description = "You deal increased damage against enemies higher than your current health. This damage is increased by ", Prefix = "%.",
					Ranks = {
						nil, nil, nil, 8, 12, 17
					},
					ID = 24
				},
				{Name = "Persistent", Description = "", Prefix = "% of your current Combo Score is dealt as additional damage.",
					Ranks = {
						10, 15, 20, 25, 30, 35
					},
					ID = 25
				},
				{Name = "Swift Attacks", Description = "Your light attacks deal ", Prefix = "% increased damage.",
					Ranks = {
						8, 12, 15, 18, 21, 30
					},
					ID = 26
				},
				{Name = "Friendship Charm", Description = "For every friend that is in your server, gain ", Prefix = "% additional EXP at the end of each map.\n\nThe player must be in your Roblox Friends list to count.",
					Ranks = {
						nil, nil, 2, 3, 4, 5
					},
					ID = 27
				},
				{Name = "Parry Expert", Description = "Your Parry Cooldowns are decreased by ", Prefix = "%.",
					Ranks = {
						10, 20, 30, 40, 50, 60
					},
					ID = 28
				},
				{Name = "Fortitude", Description = "Upon taking damage, any damage you take within the next second is reduced by ", Prefix = "%. Damaging debuffs like Bleed and Poison are not affected by this gemstone.",
					Ranks = {
						30, 33, 36, 40, 45, 50
					},
					ID = 29
				},
				{Name = "Counterattack", Description = "Every dodged attack will consume that damage. Your next Light Attack will deal an additional ", Prefix = "% of all consumed damage. Deflecting projectiles also contributes to consummation.\n\nNormal damage will be consumed, regardless if Primal Curse and Bloodlust is equipped.",
					Ranks = {
						4, 5, 6, 7, 8, 9
					},
					ID = 30
				},
				{Name = "HP Regen on Hit", Description = "", Prefix = "% of any damage dealt will be recovered back as health. Additionally, HP regeneration will be slightly increased by the same amount.",
					Ranks = {
						0.15, 0.2, 0.25, 0.3, 0.35, 0.4
					},
					ID = 31
				},
				{Name = "Battle Scars", Description = "Taking damage will instantly amplify your passive HP regeneration. Heal an additional 1% of your maximum HP per second for ", Prefix = " seconds. Can stack multiple times.",
					Ranks = {
						5, 8, 11, 14, 17, 20
					},
					ID = 32
				},
				{Name = "Knockout Master", Description = "The rate you knockdown applicable bosses has a ", Prefix = "% increased efficacy.\n\nHigher Knockdown rates gives you a more likely chance to stagger or stun the boss.",
					Ranks = {
						10, 13, 15, 20, 25, 30
					},
					ID = 33
				},
				{Name = "CP Increase", Description = "CP regeneration per hit on applicable characters is increased by ", Prefix = "%.",
					Ranks = {
						10, 15, 20, 25, 30, 35
					},
					ID = 34
				},
				{Name = "Taunt Up", Description = "Dealing damage to bosses in Hero difficulty or higher will increase the likelihood of them targeting you by ", Prefix = "%.", ---NOT DONE
					Ranks = {
						30, 60, 90, 120, 150, 200
					},
					ID = 35
				},
				{Name = "Memory Accelerator", Description = "EXP gains are increased by ", Prefix = "%. Each incapacitation will erase 25% of your current character's EXP. Incapacitations from or caused by other players will not affect your EXP.", 
					Ranks = {
						nil, nil, nil, nil, nil, 50
					},
					ID = 36
				},
				{Name = "Shadow Step", Description = "Your dodges no longer gives invulnerability and will consume 5% of your current HP per use in exchange for infinite dashes and farther dodge distances. Dodging will instantly move your character ", Prefix = " studs in the direction you are facing. \n\nSky kicking towards a locked on enemy will teleport you to them instead.", 
					Ranks = {
						nil, nil, nil, nil, nil, 20
					},
					ID = 37
				}
			}

function module:GetWeaponRank(Number)
	for i = 1, #WeaponRanks do
		local R = WeaponRanks[i]
		if R.Rank == Number then
			return R
		end
	end
	return nil
end

local Item = {}
function Item.new(Gem, Rarity, Name, Index, Quantity)
	return setmetatable({IG = Gem, R = Rarity, ID = Name, IND = Index, Q = Quantity or 1}, Item)
end

function GetIndex(MaxSize,Inventory)
	local AvailableIndexes = {}
	for i = 1, MaxSize do
		table.insert(AvailableIndexes, i)
	end
	for i = 1, #Inventory do
		local Item = Inventory[i]
		if Item ~= nil and Item.IND > 0 then
			for v = 1, #AvailableIndexes do
				if AvailableIndexes[v] == Item.IND then
					table.remove(AvailableIndexes, v)
				end
			end
		end
	end
	return AvailableIndexes[1] or 1
end

function module:MakeItem(ID, Inv, quantity)
	local Index = GetIndex(999, Inv)
	return Item.new(false, 0, ID, Index, quantity and quantity or 1)
end

function module:ReturnGems()
	return GemTypes, GemChart
end

function module:GetItemInfo(nam, isGem, Rarity)
	if isGem then
		for i = 1, #GemTypes do
			local Gem = GemTypes[i]
			if Gem.Name == nam then
				for v = 1, #GemChart do
					local GemInfo = GemChart[v]
					if GemInfo.Rarity == Rarity then
						local FoundGem = {}
						FoundGem.IsGem = isGem
						FoundGem.Rarity = Rarity
						FoundGem.Image = GemInfo.Image
						FoundGem.Name = Gem.Name
						FoundGem.Value = Gem.Ranks[Rarity+1]
						FoundGem.Description = Gem.Description.. "" .. tostring(FoundGem.Value).. "" ..Gem.Prefix
						FoundGem.SellPrice = GemInfo.SellPrice
						FoundGem.Color = GemInfo.Color
						return FoundGem
					end
				end
			end
		end
	else
		for i = 1, #LootChart do
			local Loot = LootChart[i]
			if Loot.Name == nam then
				local FoundGem = {}
				FoundGem.IsGem = false
				FoundGem.Rarity = Loot.Rarity
				FoundGem.Image = Loot.Image
				FoundGem.Name = Loot.Name
				FoundGem.Description = Loot.Description
				FoundGem.SellPrice = Loot.SellPrice
				FoundGem.Color = Loot.Color
				return FoundGem
			end
		end
	end
	return nil
end

function module:GetItemInfoFromID(ID, isGem, Rarity)
	if isGem then
		for i = 1, #GemTypes do
			local Gem = GemTypes[i]
			if Gem.ID == ID then
				for v = 1, #GemChart do
					local GemInfo = GemChart[v]
					if GemInfo.Rarity == Rarity then
						local FoundGem = {}
						FoundGem.IG = isGem
						FoundGem.R = Rarity
						FoundGem.Image = GemInfo.Image
						FoundGem.ID = Gem.ID
						FoundGem.Name = Gem.Name
						FoundGem.Value = Gem.Ranks[Rarity+1]
						FoundGem.Description = Gem.Description.. "" .. tostring(FoundGem.Value).. "" ..Gem.Prefix
						FoundGem.SellPrice = GemInfo.SellPrice
						FoundGem.Color = GemInfo.Color
						return FoundGem
					end
				end
			end
		end
	else
		for i = 1, #LootChart do
			local Loot = LootChart[i]
			if Loot.ID == ID then
				local FoundGem = {}
				FoundGem.IG = false
				FoundGem.R = Loot.Rarity
				FoundGem.Image = Loot.Image
				FoundGem.Name = Loot.Name
				FoundGem.ID = Loot.ID
				FoundGem.Description = Loot.Description
				FoundGem.SellPrice = Loot.SellPrice
				FoundGem.Color = Loot.Color
				return FoundGem
			end
		end
	end
	return nil
end

function module:GetLootFromID(isGem, ID)
	for _, Loot in ipairs(isGem and GemTypes or LootChart) do
		if Loot.ID == ID then
			return Loot
		end
	end
end

function module:GetLootFromName(isGem, Name)
	for _, Loot in ipairs(isGem and GemTypes or LootChart) do
		if Loot.Name == Name then
			return Loot
		end
	end
end

function module:GetGemPlaceholderFromRarity(Rarity)
	for _, Gem in ipairs(GemChart) do
		if Gem.Rarity == Rarity then
			return Gem
		end
	end
end

function module:GetMaterials()
	return LootChart
end

--- For material drops
function module:DropRandomLoot(MaxSize, Inv, MaterialTable)
	local Index = GetIndex(MaxSize,Inv)
	local Chosen = MaterialTable:GetRandomLoot()
	if Chosen ~= "Nothing" then
		local ChosenLoot = module:GetLootFromName(false, Chosen)
		local Loot = Item.new(false, 0, ChosenLoot.ID, Index, 1)
		return Loot
	end
end

--- For gem drops
function module:DropRandomGem(MaxSize, Inv, CurrentClass, HeroMode, GemTable)
	local Index = GetIndex(MaxSize,Inv)
	local Chosen = GemTable:GetRandomLoot()
	local ChosenLoot = module:GetGemPlaceholderFromRarity(tonumber(Chosen))
	if ChosenLoot and ChosenLoot.Name ~= "Nothing" then
		local NewGemTypes = {}
		for i = 1, #GemTypes do
			local Type = GemTypes[i]
			if Type.Ranks[ChosenLoot.Rarity+1] ~= nil then
				--- Checks if the gem has a valid rank
				table.insert(NewGemTypes, Type)
			end
		end
		local RandomGemType = NewGemTypes[math.floor(Random.new():NextNumber(1, #NewGemTypes)+.5)]
		local Loot = Item.new(true, ChosenLoot.Rarity, RandomGemType.ID, Index, RandomGemType.Ranks[ChosenLoot.Rarity+1])
		return Loot
	else
		return "Nothing"
	end
end

function module:MakeGem(MaxSize, Inv, DesiredRarity, TypeFind)
	local Index = GetIndex(MaxSize,Inv)
	local ChosenLoot;
	for i = 1, #GemChart do
		if GemChart[i].Rarity == DesiredRarity then
			ChosenLoot = GemChart[i]
			break
		end
	end
	if ChosenLoot ~= nil and ChosenLoot.Name ~= "Nothing" then
		local NewGemTypes = {}
		for i = 1, #GemTypes do
			local Type = GemTypes[i]
			if Type.Ranks[ChosenLoot.Rarity+1] ~= nil then
				table.insert(NewGemTypes, Type)
			end
		end
		local RandomGemType = NewGemTypes[math.floor(Random.new():NextNumber(1, #NewGemTypes)+.5)]
		if TypeFind ~= nil then
			for i = 1, #NewGemTypes do
				local Type = NewGemTypes[i]
				if Type.Name == TypeFind then
					RandomGemType = Type
					break
				end
			end
		end
		local Loot = Item.new(true, ChosenLoot.Rarity, RandomGemType.ID, Index, RandomGemType.Ranks[ChosenLoot.Rarity+1])		
		return Loot
	else
		return "Nothing"
	end
end

for _, gem in ipairs(script.Loot.Gems:GetChildren()) do
	table.insert(GemChart, require(gem))
end

for _, mat in ipairs(script.Loot.Materials:GetChildren()) do
	local newMat = require(mat)
	newMat.ID = tonumber(mat.Name)
	table.insert(LootChart, newMat)
end

return module
