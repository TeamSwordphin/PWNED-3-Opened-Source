local RunService = game:GetService("RunService")
local CollectionService	= game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local MessagingService = game:GetService("MessagingService")
local TextService = game:GetService("TextService")

local SERVER_FOLDER = script.Parent.Parent
local MODULES = SERVER_FOLDER.Parent.Modules

local PlayerManager	= require(MODULES.PlayerStatsObserver)
local Sockets = require(MODULES.Utility["server"])
local Achievements = require(MODULES.Systems["Achievements"])
local ItemboxModule	= require(MODULES.CharacterManagement["ItemBox"])
local WeaponCraft = require(MODULES.CharacterManagement["WeaponCrafting"])
local Shop = require(MODULES.Systems["Shop"])
local LootInfo = require(MODULES.CharacterManagement["LootInfo"])
local RewardAchievement	= require(SERVER_FOLDER.SharedModules.RewardAchievement)
local Guilds = require(MODULES.Systems["Guilds"])
local ClassInfo = require(MODULES.CharacterManagement["ClassInfo"])
local Titles = require(MODULES.Systems["Titles"])
local Vestiges = require(MODULES.Systems.Vestiges)
local CountMaterials = require(SERVER_FOLDER.SharedModules.CountMaterials)
local Facilities = require(MODULES.Systems.NovasTerminal.MainFacilityHandler)


--<< Variables >>--

local logic = {}
local ReservedServer = false

local Vec3, CF = Vector3.new, CFrame.new
local tbi, tbr = table.insert, table.remove
local Rand = Random.new()
local Floor = math.floor

--<< Functions >>--
if (game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0) then
	ReservedServer = true
end

local function AwardBadge(PlayerId, BadgeId)
	BadgeService:AwardBadge(PlayerId,BadgeId)
end

--<< Socket Init >>--

function logic:Init(Socket)
	local Player = Socket.Player
	local id = Player.UserId

	--- Update player's facilities
	local function findFacility(fac_id, strict)
		local PlayerStat = PlayerManager:GetPlayerStat(id)

		for i, facility in ipairs(PlayerStat.BuiltFacilities) do
			if strict then
				if strict.ID == facility.ID and strict.Active == facility.Active and facility.Level == strict.Level then
					return facility, i
				end
			else
				if facility.ID == fac_id then
					return facility, i
				end
			end
		end
	end
	
	Socket:Listen("GetAchievements", function()
		return Achievements:GetAchievementList()
	end)
	
	Socket:Listen("GetItemDescription", function(Name)
		if typeof(Name) == "string" then
			local PlayerStat = PlayerManager:GetPlayerStat(id)
			for _, Item in ipairs(PlayerStat.ItemBox) do
				if Item.Name == Name then
					Item.Seen = true
				end
			end
			
			return ItemboxModule:GetDescription(Name)
		end
	end)

	Socket:Listen("GetFacilitiesInformation", function()
		return Facilities:GetFacilities()
	end)

	Socket:Listen("GetBuildingMaterials", function(materialList)
		if typeof(materialList) == "table" then
			return CountMaterials(id, materialList)
		end
	end)

	Socket:Listen("Facility", function(mode, facility)
		if typeof(facility) ~= "table" then return end

		local PlayerStat = PlayerManager:GetPlayerStat(id)

		if mode ~= "Build" then
			local foundFacility, index = findFacility(_, facility)

			if not foundFacility then return end

			if mode == "PowerToggle" then
				if (not findFacility(1).Active and foundFacility.ID ~= 1) then
					return
				end

				PlayerStat.BuiltFacilities[index].Active = not PlayerStat.BuiltFacilities[index].Active

				local powerSurged = false
				local powerAvailable = 0
				local powerCost = 0
				local powerMax = 0

				for i, realFacility in ipairs(PlayerStat.BuiltFacilities) do
					if not realFacility.BuildDate then
						local information = Facilities:GetFacilityFromID(realFacility.ID)
						local active = realFacility.Active

						powerCost += active and information.PowerRequired or 0
						local value = information.Levels[facility.Level].Value

						if information.Name == "Power Grid" then
							powerMax += active and value or 0
						elseif information.Name == "Power Plant" then
							powerAvailable += active and value or 0
						end
					end
				end
				
				local powerUsed = math.min(powerMax, powerAvailable)
				powerUsed -= powerCost
				
				if powerUsed <= 0 then
					powerSurged = true
				end

				if powerSurged or (not PlayerStat.BuiltFacilities[index].Active and foundFacility.ID == 1) then
					for i, realFacility in ipairs(PlayerStat.BuiltFacilities) do
						PlayerStat.BuiltFacilities[i].Active = false
					end
				end
			elseif mode == "Upgrade" then
				if foundFacility.BuildDate then
					return
				end

				local information = Facilities:GetFacilityFromID(foundFacility.ID)
				local level = foundFacility.Level

				if level < information.MaxLevels then
					local materialsRequired = information.Levels[level + 1].MaterialsRequired
					local _, hasMats = CountMaterials(id, materialsRequired)
					if hasMats and materialsRequired[1][1] == "Gold" then
						if PlayerStat.Gold >= materialsRequired[1][2] then
							PlayerStat.Gold -= materialsRequired[1][2]
						else
							hasMats = false
						end
					end

					if hasMats then
						CountMaterials(id, materialsRequired, true)

						local currentTime = os.time()
						PlayerStat.BuiltFacilities[index].BuildDate = currentTime
						PlayerStat.BuiltFacilities[index].EndDate = currentTime + (information.UpgradeSecondsPerRank * (level + 1))
						PlayerStat.BuiltFacilities[index].Level += 1

						return true, PlayerStat
					end
				end
			elseif mode == "Destroy" then
				local powerGrid = 0
				local powerPlant = 0

				for i, realFacility in ipairs(PlayerStat.BuiltFacilities) do
					local information = Facilities:GetFacilityFromID(realFacility.ID)

					if information.Name == "Power Grid" then
						powerGrid += 1
					elseif information.Name == "Power Plant" then
						powerPlant += 1
					end
				end

				if foundFacility.ID == 2 and powerPlant <= 1 then
					return
				end

				if foundFacility.ID == 3 and powerGrid <= 1 then
					return
				end

				table.remove(PlayerStat.BuiltFacilities, index)
				return true, PlayerStat
			end
		else
			--- Building mode
			if facility.ID ~= 1 then --- Making sure they aren't trying to build another mainframe!
				local mainFrame = findFacility(1)
				local information = Facilities:GetFacilityFromID(mainFrame.ID)
				local level = mainFrame.Level

				local facilitiesBuilt = #PlayerStat.BuiltFacilities
				local facilitiesMax = information.Levels[level].Value

				local materialsRequired = information.Levels[1].CraftingMaterialsRequired
				local items, hasMats = CountMaterials(id, materialsRequired)

				print(items, hasMats)

				if hasMats and materialsRequired[1][1] == "Gold" then
					if PlayerStat.Gold >= materialsRequired[1][2] then
						PlayerStat.Gold -= materialsRequired[1][2]
					else
						hasMats = false
					end
				end

				print(hasMats, facilitiesBuilt, facilitiesMax)

				if hasMats and facilitiesBuilt < facilitiesMax then
					CountMaterials(id, materialsRequired, true)

					--- start da building process!!
					local currentTime = os.time()
					local newFacility = {
						ID = facility.ID,
						Active = false,
						Level = 1,
						BuildDate = currentTime,
						EndDate = currentTime + information.SecondsToCreate
					}

					table.insert(PlayerStat.BuiltFacilities, newFacility)
					return true, PlayerStat
				end
			end
		end
	end)
	
	Socket:Listen("GetMail", function()
		if not ReservedServer then
			local PlayerStat = PlayerManager:GetPlayerStat(id)	
			return PlayerStat.ItemBox
		end
	end)
	
	Socket:Listen("GetPlayerInfo", function(Pid)
		local PlayerStat = PlayerManager:GetPlayerStat(Pid)
		local ShopStock = Shop:GetShop()
		
		if PlayerStat then
			local CurrentClass = PlayerStat.CurrentClass
			local Gemstone1 = PlayerStat.Characters[CurrentClass].Gemstone1
			local Gemstone2 = PlayerStat.Characters[CurrentClass].Gemstone2
			local Gemstone3 = PlayerStat.Characters[CurrentClass].Gemstone3
			local Information = {
				Weapon = WeaponCraft:GetWeaponFromID(CurrentClass, PlayerStat.Characters[CurrentClass].CurrentWeapon.ID),
				Trophy = WeaponCraft:GetTrophyFromID(PlayerStat.Characters[CurrentClass].CurrentTrophy.Map, PlayerStat.Characters[CurrentClass].CurrentTrophy.ID),
				CurrentSkin = PlayerStat.Characters[CurrentClass].CurrentSkinPieces,
				Gemstones = {
					Gemstone1 = Gemstone1 and (Gemstone1.ID and LootInfo:GetItemInfoFromID(Gemstone1.ID, Gemstone1.IG, Gemstone1.R)),
					Gemstone2 = Gemstone2 and (Gemstone2.ID and LootInfo:GetItemInfoFromID(Gemstone2.ID, Gemstone2.IG, Gemstone2.R)),
					Gemstone3 = Gemstone3 and (Gemstone3.ID and LootInfo:GetItemInfoFromID(Gemstone3.ID, Gemstone3.IG, Gemstone3.R))
				}
			}
			
			for _, costume in ipairs(ShopStock.Cosmetics.Costumes) do
				if costume.PreviewModel.Name == PlayerStat.Characters[CurrentClass].CurrentSkin.Name then
					Information.CurrentSkin = costume.Name
				end
			end
			
			return PlayerStat, Information
		end
	end)
	
	Socket:Listen("getCharacterInfo", function(Request)
		local Iid = 0
		if Request ~= nil then
			if Request:IsA("Model") then
				local Pl = game.Players:GetPlayerFromCharacter(Request)
				if Pl then
					Iid = Pl.UserId
				end
			end
		else
			Iid = id
		end
		
		local PlayerStat = PlayerManager:GetPlayerStat(Iid)
		if PlayerStat then		
			local character = PlayerStat.Characters[PlayerStat.CurrentClass]
			if Iid == id then
				if character.CurrentLevel >= 200 then
					RewardAchievement({21}, id)
				end
				if character.CurrentLevel >= 175 then
					RewardAchievement({20}, id)
				end
				if character.CurrentLevel >= 150 then
					RewardAchievement({19}, id)
				end
				if character.CurrentLevel >= 125 then
					RewardAchievement({18}, id)
				end
				if character.CurrentLevel >= 100 then
					AwardBadge(id,706713010)
					RewardAchievement({17}, id)
				end
				if character.CurrentLevel >= 75 then
					RewardAchievement({16}, id)
				end
				if character.CurrentLevel >= 50 then
					AwardBadge(id, 706671620)
					local ach = {15}
					if PlayerStat.CurrentClass == "Darwin" or PlayerStat.CurrentClass == "DarwinB" then
						tbi(ach, 26)
					elseif PlayerStat.CurrentClass == "Red" then
						tbi(ach, 27)
					elseif PlayerStat.CurrentClass == "Valeri" then
						tbi(ach, 28)
					end
					RewardAchievement(ach, id)
				end
				if character.CurrentLevel >= 25 then
					RewardAchievement({14}, id)
				end
			end
			
			return character
		end
		return "error"
	end)
	
	Socket:Listen("getAccountInfo", function(Request)
		AwardBadge(id, 706883002)
		
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local CombatState = PlayerManager:GetCombatState(id)

		--- Autosaves the character data
		if typeof(PlayerStat.Characters[PlayerStat.CurrentClass]) == "table" then
			if PlayerStat.Characters[PlayerStat.CurrentClass].CurrentClass == CombatState.ActiveCharacterProfile.Data.CurrentClass then
				CombatState.ActiveCharacterProfile.Data = PlayerStat.Characters[PlayerStat.CurrentClass]
			end
		end

		
		for i, facility in ipairs(PlayerStat.BuiltFacilities) do
			if not findFacility(1).Active then
				PlayerStat.BuiltFacilities[i].Active = false
			end

			if facility.BuildDate then
				if os.time() > facility.EndDate then
					PlayerStat.BuiltFacilities[i].BuildDate = nil
					PlayerStat.BuiltFacilities[i].EndDate = nil
				end
			end
		end
		
		
		local CharCount = 0
		for _,chars in next, PlayerStat.Characters do
			CharCount = CharCount + 1
		end
		if CharCount >= 10 then
			RewardAchievement({4}, id)
		end
		if CharCount >= 5 then
			RewardAchievement({3}, id)
		end
		if CharCount >= 3 then
			RewardAchievement({2}, id)
		end
		if CharCount >= 2 then
			RewardAchievement({1}, id)
		end
		if PlayerStat.WeaponLevel >= 15 then
			RewardAchievement({13}, id)
		end
		if PlayerStat.WeaponLevel >= 10 then
			RewardAchievement({12}, id)
		end
		if PlayerStat.WeaponLevel >= 5 then
			RewardAchievement({11}, id)
		end
		if PlayerStat.Guild ~= "" then
			local CurrentGuild = Guilds:GetGuildData(PlayerStat.Guild)
			if CurrentGuild and typeof(CurrentGuild) == "table" then
				if ReservedServer then
					for i = 1, #CurrentGuild.Perks do
						local Perk = CurrentGuild.Perks[i]
						if os.time() < Perk.Expiration then
							Socket:Emit("SendMessage", nil, nil, Perk.Name.. " Guild Perk is active for another " ..Perk.Expiration-os.time().. " second(s).", true)
						else
							if os.time()-Perk.Expiration <= 300 then
								Socket:Emit("SendMessage", nil, nil, Perk.Name.. " Guild Perk has expired.", true)
							end
						end
					end
				else
					local WasKicked = true
					if CurrentGuild.Owner == id then
						WasKicked = false
					end
					for i = 1, #CurrentGuild.Members do
						if CurrentGuild.Members[i].ID == id then
							WasKicked = false
							if #CurrentGuild.Members >= 3 then
								RewardAchievement({63}, id)
							end
							if CurrentGuild.Members[i].EXPContributions >= 1000 then
								RewardAchievement({64}, id)
							end
							if CurrentGuild.Members[i].EXPContributions >= 2000 then
								RewardAchievement({65}, id)
							end
							if CurrentGuild.Members[i].EXPContributions >= 5000 then
								RewardAchievement({66}, id)
							end
							if CurrentGuild.Members[i].EXPContributions >= 10000 then
								RewardAchievement({67}, id)
							end
							if CurrentGuild.Members[i].EXPContributions >= 20000 then
								RewardAchievement({68}, id)
							end
							if CurrentGuild.Members[i].EXPContributions >= 100000 then
								RewardAchievement({69}, id)
							end
							break
						end
					end
					if not WasKicked then
						if PlayerStat.GuildXP > 0 then
							local Success = Guilds:UpdateGuildEXP(PlayerStat.Guild, id, PlayerStat.GuildXP)
							if Success == "Updated EXP!" then
								Socket:Emit("SendMessage", nil, nil, "You have deposited " ..math.floor(PlayerStat.GuildXP)..  " EXP to your guild.", true)
								PlayerStat.GuildXP = 0
							elseif Success == "No Owner" then
								Socket:Emit("SendMessage", nil, nil, "You have some leftover Guild EXP contributions. Join a server with the Guild Leader to deposit.", true)
							end
						end
					else
						PlayerStat.Guild = ""
						PlayerStat.GuildXP = 0
						Socket:Emit("SendMessage", nil, nil, "You have been kicked from your guild.", true)
					end
				end
			else
				if CurrentGuild == "error" then
					Socket:Emit("SendMessage", nil, nil, "Guild Services are experiencing technical difficulties. Please try again later.", true)
				elseif CurrentGuild == "Requests Throttled" then
					Socket:Emit("SendMessage", nil, nil, "Guild Services are experiencing Data Store throttling. Please try again later.", true)	
				end
			end
		end
		
		if Request ~= nil then
			if Request:IsA("Model") then
				local Pl = game.Players:GetPlayerFromCharacter(Request)
				if Pl then
					return PlayerManager:GetPlayerStat(Pl.UserId)
				end
			end
		else
			return PlayerStat
		end

		return "error"
	end)
	
	Socket:Listen("getSkillInfo", function(nam, Request)
		local Iid = 0
		if Request ~= nil then
			if Request:IsA("Model") then
				local Pl = game.Players:GetPlayerFromCharacter(Request)
				if Pl then
					Iid = Pl.UserId
				end
			end
		else
			Iid = id
		end
		
		local PlayerStat = PlayerManager:GetPlayerStat(Iid)
		local name = nam or nil
		local SkillInformation = {}
		local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
		if name == nil then
			for _, sk in ipairs(CurrentClass.Skills) do
				local Skill = ClassInfo:GetSkillInfo(sk.Name)
				if Skill ~= nil and sk.Name == Skill.Name then
					Skill.Unlocked = sk.Unlocked
					Skill.Rank = sk.Rank
					tbi(SkillInformation, Skill)
				end
			end
		else
			for _, sk in ipairs(CurrentClass.Skills) do
				if name == sk.Name then
					local Skill = ClassInfo:GetSkillInfo(sk.Name)
					if Skill ~= nil and sk.Name == Skill.Name then
						Skill.Unlocked = sk.Unlocked
						Skill.Rank = sk.Rank
						SkillInformation = Skill
						break
					end
				end
			end
		end
		
		return SkillInformation
	end)

	Socket:Listen("GetMaterials", function()
		return LootInfo:GetMaterials()
	end)
	
	Socket:Listen("getLootInfo", function(obj, InventoryType, Request)
		local Iid = 0
		if Request ~= nil then
			if Request:IsA("Model") then
				local Pl = game.Players:GetPlayerFromCharacter(Request)
				if Pl then
					Iid = Pl.UserId
				end
			end
		else
			Iid = id
		end
		local inven = {}
		local name = obj or nil
		local PlayerStat = PlayerManager:GetPlayerStat(Iid)
		
		if name == nil then
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			local Inventory;
			if InventoryType == "Gems" then
				Inventory = #CurrentClass.GemInventory
			elseif InventoryType == "Mats" then
				Inventory = #PlayerStat.Inventory
			elseif InventoryType == "Weapons" then
				Inventory = #CurrentClass.WeaponInventory
			else
				Inventory = #CurrentClass.TrophyInventory
			end
			for i = 1, Inventory do
				local stuff;
				if InventoryType == "Gems" then
					stuff = CurrentClass.GemInventory[i]
				elseif InventoryType == "Mats" then
					stuff = PlayerStat.Inventory[i]
				elseif InventoryType == "Weapons" then
					stuff = CurrentClass.WeaponInventory[i]
				else
					stuff = CurrentClass.TrophyInventory[i]
				end
				if InventoryType == "Weapons" then
					local Weapon = WeaponCraft:GetWeaponFromID(PlayerStat.CurrentClass, stuff.ID)
					local Ownership = PlayerStat.CurrentClass
					local Item = {}
					Item.Object = Weapon
					if Ownership == "Darwin" then
						Ownership = "DarwinB"
					end
					Item.Ownership = Ownership
					Item.ID = stuff.CID
					Item.Equipped = PlayerStat.Characters[PlayerStat.CurrentClass].CurrentWeapon.CID == stuff.CID and true or false
					Item.CurrentWeapon = stuff
					Item.WeaponSkills = {}
					for i = 1, #Item.CurrentWeapon.Skls do
						tbi(Item.WeaponSkills, WeaponCraft:GetSkillFromID(Item.CurrentWeapon.Skls[i].I))
					end
					tbi(inven, Item)
				elseif InventoryType == "Trophies" then
					local Weapon = WeaponCraft:GetTrophyFromID(stuff.Map, stuff.ID)
					local Item = {}
					Item.Object = Weapon
					Item.Ownership = "Everyone"
					Item.ID = stuff.CID
					if PlayerStat.Characters[PlayerStat.CurrentClass].CurrentTrophy == nil or PlayerStat.Characters[PlayerStat.CurrentClass].CurrentTrophy.CID ~= stuff.CID then
						Item.Equipped = false
					elseif PlayerStat.Characters[PlayerStat.CurrentClass].CurrentTrophy.CID == stuff.CID then
						Item.Equipped = true
					end
					Item.CurrentWeapon = stuff
					Item.WeaponSkills = {}
					Item.Map = stuff.Map
					for i = 1, #Item.CurrentWeapon.Skls do
						tbi(Item.WeaponSkills, WeaponCraft:GetSkillFromID(Item.CurrentWeapon.Skls[i].I))
					end
					tbi(inven, Item)
				else
					local Item = LootInfo:GetItemInfoFromID(stuff.ID, stuff.IG, stuff.R)
					if Item ~= nil and stuff.ID == Item.ID then
						Item.IND = stuff.IND
						Item.Q = stuff.Q
						tbi(inven, Item)
					end
				end
			end
		else
			inven = LootInfo:GetItemInfoFromID(name.ID, name.IG, name.R)
		end
		return inven
	end)
	
	Socket:Listen("GetLevelRates", function()
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		return PlayerStat.Characters[PlayerStat.CurrentClass].UpgradeLevels, ClassInfo:GetLevelRates()
	end)
	
	Socket:Listen("GetSkill", function(ID)
		if ID then
			return WeaponCraft:GetSkillFromID(ID)
		else
			local PlayerStat = PlayerManager:GetPlayerStat(id)
			local Skills = WeaponCraft:GetSkills()
			local NewSkills = {}
			for _, infusion in ipairs(Skills) do
				if table.find(PlayerStat.Infusions, infusion.ID) then
					table.insert(NewSkills, infusion)
				end
			end
			return NewSkills
		end
	end)
	
	Socket:Listen("GetCurrentWeapon", function(FetchTrophyToo)
		local Trophy = nil
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		if FetchTrophyToo then
			local Weapon = WeaponCraft:GetTrophyFromID(PlayerStat.Characters[PlayerStat.CurrentClass].CurrentTrophy.Map, PlayerStat.Characters[PlayerStat.CurrentClass].CurrentTrophy.ID)
			local Ownership = PlayerStat.CurrentClass
			local Item = {}
			Item.Object = Weapon
			Item.Ownership = "Everyone"
			Item.CurrentTrophy = PlayerStat.Characters[PlayerStat.CurrentClass].CurrentTrophy
			Item.WeaponSkills = {}
			for i = 1, #Item.CurrentTrophy.Skls do
				table.insert(Item.WeaponSkills, WeaponCraft:GetSkillFromID(Item.CurrentTrophy.Skls[i].I))
			end
			Trophy = Item
		end

		local Weapon = WeaponCraft:GetWeaponFromID(PlayerStat.CurrentClass, PlayerStat.Characters[PlayerStat.CurrentClass].CurrentWeapon.ID)
		local Ownership = PlayerStat.CurrentClass
		local Item = {}
		Item.Object = Weapon
		Item.Ownership = Ownership
		Item.CurrentWeapon = PlayerStat.Characters[PlayerStat.CurrentClass].CurrentWeapon
		Item.WeaponSkills = {}
		for i = 1, #Item.CurrentWeapon.Skls do
			table.insert(Item.WeaponSkills, WeaponCraft:GetSkillFromID(Item.CurrentWeapon.Skls[i].I))
		end

		return Item, Trophy
	end)

	Socket:Listen("Blacksmith", function(Request, Tuple)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
		local Inventory = CurrentClass.WeaponInventory
		local CurrentWeapon = CurrentClass.CurrentWeapon
		if Request == "Whetstones" then
			local normal, hasN = CountMaterials(id, {{"Normal Whetstone", 1}})
			local heat, hasH = CountMaterials(id, {{"Heated Whetstone", 1}})
			local thermal, hasT = CountMaterials(id, {{"Thermal Whetstone", 1}})
			local whetstoneCount = {
				Normal = hasN and normal[1].Quantity or 0,
				Heat = hasH and heat[1].Quantity or 0,
				Thermal = hasT and thermal[1].Quantity or 0
			}
			return whetstoneCount
		elseif Request == "GetReinforceables" then
			local TableOfWeapons = {}
			local newObject = WeaponCraft:GetWeaponFromID(PlayerStat.CurrentClass, CurrentWeapon.ID)
			for _, weapon in ipairs(Inventory) do
				if weapon.ID == CurrentWeapon.ID and not weapon.Locked and weapon.CID ~= CurrentWeapon.CID then
					table.insert(TableOfWeapons, weapon)
				end
			end
			return TableOfWeapons, newObject
		elseif Request == "EnchantList" or Request == "CatalystList" then
			local getEnchants = Request == "EnchantList"
			local viableEnchantItems = {}
			for _, material in ipairs(PlayerStat.Inventory) do
				local info = LootInfo:GetLootFromID(false, material.ID)
				if table.find(info.Attributes, getEnchants and "Enchant" or "Catalyst") then
					local newInfo = {
						object = material,
						info = info
					}
					table.insert(viableEnchantItems, newInfo)
				end
			end
			return #viableEnchantItems >= 1 and viableEnchantItems or nil, PlayerStat
		elseif Request == "UpgradeWeapon" then
			local MaxMight = CurrentWeapon.Tier * 25
			if CurrentWeapon.UpLvl >= MaxMight then
				Socket:Emit("Hint", "You have reached the maximum might for this weapon tier.")
			else
				local count, success = CountMaterials(id, {{string.format("%s Whetstone", Tuple), 1}}, true)
				local quantity = success and count[1].Quantity or 0
				if success then
					--- Syncs current equipped weapon with the one they have in their weapon inventory
					for _, Item in ipairs(Inventory) do
						if CurrentWeapon.ID == Item.ID and CurrentWeapon.CID == Item.CID then
							local Weapon = WeaponCraft:GetWeaponFromID(PlayerStat.CurrentClass, Item.ID)
							if Item.UpLvl < MaxMight then
								if Tuple == "Normal" then
									Item.UpLvl = math.min(MaxMight, Item.UpLvl + 1)
									RewardAchievement({5, 6, 22, 23, 24}, id)
								elseif Tuple == "Heated" then
									Item.UpLvl = math.min(MaxMight, Item.UpLvl + 5)
									RewardAchievement({5, 6, 22, 23, 24}, id, nil, 5)
								elseif Tuple == "Thermal" then
									Item.UpLvl = math.min(MaxMight, Item.UpLvl + 10)
									RewardAchievement({5, 6, 22, 23, 24}, id, nil, 10)
								end
								CurrentClass.CurrentWeapon = Item
							end
						end
					end
				end
				return success, quantity
			end
		elseif Request == "ReinforceWeapon" then
			local selectedWeapon = Tuple
			local MaxMight = CurrentWeapon.Tier * 25
			local newObject = WeaponCraft:GetWeaponFromID(PlayerStat.CurrentClass, CurrentWeapon.ID)
			for index, weapon in ipairs(Inventory) do
				if not weapon.Locked and weapon.ID == selectedWeapon.ID and weapon.CID ~= CurrentWeapon.CID and weapon.CID == selectedWeapon.CID then
					--- After confirming the selected weapon is not our current equipped one, we will upgrade our equipped one afterwards
					for _, equipped in ipairs(Inventory) do
						if equipped.ID == CurrentWeapon.ID and equipped.CID == CurrentWeapon.CID then
							if equipped.Tier >= newObject.MaxUpgrades then return -1 end
							if equipped.UpLvl >= MaxMight then
								table.remove(Inventory, index)
								equipped.Tier += 1
								CurrentClass.CurrentWeapon = equipped
								Socket:Emit("Hint", string.format("%s has reached Weapon Tier %s!", newObject.WeaponName, equipped.Tier))
								return 1
							end
						end
					end
				end
			end
			return 0
		elseif Request == "EnchantWeapon" then
			if typeof(Tuple) ~= "table" then return end
			local wepInfo = WeaponCraft:GetWeaponFromID(PlayerStat.CurrentClass, CurrentWeapon.ID)
			local enchant, catalyst = LootInfo:GetLootFromID(false, Tuple[1].info.ID), Tuple[2] and LootInfo:GetLootFromID(false, Tuple[2].info.ID)
			local t = math.clamp(math.floor(CurrentWeapon.Tier * 0.5), 1, 4)
			local tier = string.format("Tier%s", t)
			local price = ((15 * wepInfo.LevelReq) * t) * (catalyst and 2 or 1)

			if PlayerStat.Gold >= price then
				if enchant and table.find(enchant.Attributes, "Enchant") then
					if #CurrentWeapon.Skls >= wepInfo.MaxEnchantments then return -2 end
					local _, success = CountMaterials(id, {{enchant.Name, 1}})
					if success then
						local Skills = WeaponCraft:GetSkills()
						local possibleEnchants = {}
						local dontUse = {}
						for _, equippedInfusion in ipairs(CurrentWeapon.Skls) do
							table.insert(dontUse, equippedInfusion.I)
						end
						for _, infusion in ipairs(Skills) do
							if table.find(PlayerStat.Infusions, infusion.ID) and table.find(enchant.Attributes, infusion.Category) and not table.find(dontUse, infusion.ID) then
								table.insert(possibleEnchants, infusion)
							end
						end
						if #possibleEnchants >= 1 then
							CountMaterials(id, {{enchant.Name, 1}}, true)
							PlayerStat.Gold -= price
							local chosenSkill = possibleEnchants[Rand:NextInteger(1, #possibleEnchants)]
							local roll = chosenSkill.Tier1 and Rand:NextInteger(chosenSkill[tier].Min, chosenSkill[tier].Max) or nil
							if catalyst and roll and table.find(catalyst.Attributes, "Catalyst") then
								local _, success2 = CountMaterials(id, {{catalyst.Name, 1}}, true)
								if success2 then
									if catalyst.Name == "Hidden Artifact" then
										roll = chosenSkill[tier].Max
									elseif catalyst.Name == "Emerald Bolt" then
										roll = math.min(chosenSkill[tier].Max, math.floor((roll * 1.2) + 0.5))
									end
								end
							end
							local NewEnchantSkill = {I = chosenSkill.ID, V = roll}
							table.insert(CurrentWeapon.Skls, NewEnchantSkill)
							for i, searchWeapon in ipairs(Inventory) do
								if searchWeapon.CID == CurrentWeapon.CID and searchWeapon.ID == CurrentWeapon.ID then
									table.remove(Inventory, i)
									table.insert(Inventory, CurrentWeapon)
									break
								end
							end
						else
							return -3
						end

						RewardAchievement({7, 8}, id)
						if #CurrentWeapon.Skls >= 5 then
							RewardAchievement({9}, id)
						end
						
						return 1
					end
				else
					return 0
				end
			else
				return -1
			end
		end
	end)
	
	Socket:Listen("GetVestige", function(ID)
		return Vestiges:GetVestigeFromID(ID)
	end)
	
	Socket:Listen("GetVestiges", function()
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		if PlayerStat then
			local VestigeList = {}
			for _,VestigeID in ipairs(PlayerStat.Vestiges) do
				local Vestige = Vestiges:GetVestigeFromID(VestigeID)
				tbi(VestigeList, Vestige)
			end
			return VestigeList
		end
	end)
	
	Socket:Listen("GetTitles", function()
		return Titles:GetTitlesChart()
	end)
	
end

return logic
