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
local CheckGamePass = require(SERVER_FOLDER.SharedModules.CheckGamePass)
local Morpher = require(ReplicatedStorage.Scripts.Modules.Morpher)


--<< Variables >>--

local logic = {}
local PVP = nil

local Vec3, CF = Vector3.new, CFrame.new
local tbi, tbr = table.insert, table.remove
local Rand = Random.new()
local Floor = math.floor
local abs = math.abs

--<< Functions >>--
SERVER_FOLDER.Bindables.AddPVPTable.Event:Connect(function(PVPTable)
	PVP = PVPTable
end)

local function AwardBadge(PlayerId, BadgeId)
	BadgeService:AwardBadge(PlayerId,BadgeId)
end

local function CheckBadge(PlayerId, BadgeId)
	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(PlayerId, BadgeId)
	end)
	if success then
		return hasBadge
	end
end

local function Check(List, StoryElement)
	for _,Element in ipairs(List) do
		if typeof(Element) == typeof(StoryElement) then
			if Element == StoryElement then
				return true
			end
		end
	end
	return false
end

--<< Socket Init >>--

function logic:Init(Socket)
	local Player = Socket.Player
	local id = Player.UserId
	
	Socket:Listen("ModifySkill", function(SkillTable)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		if PlayerStat then
			local Skill = SkillTable[1]
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			local LevelTable = {
				{Level = 60, B = 1, I = 2}, {Level = 90, B = 1, I = 3}, {Level = 70, B = 2, I = 2}, {Level = 100, B = 2, I = 3}, {Level = 120, B = 3, I = 2}, {Level = 140, B = 3, I = 3}, {Level = 0, B = 1, I = 1}, {Level = 0, B = 2, I = 1}, {Level = 0, B = 3, I = 1}
			}
			
			local function CheckForDuplicates(SkillName, List)
				for _, SkillList in pairs(List) do
					if SkillList == SkillName then
						return true
					end
				end
				return false
			end
			
			for _,Skills in ipairs(CurrentClass.Skills) do
				if Skills.Name == Skill.Name then
					if Skills.Unlocked then
						for _,Lvls in ipairs(LevelTable) do
							if Lvls.B == SkillTable[2] and Lvls.I == SkillTable[3] then
								if CurrentClass.CurrentLevel >= Lvls.Level then
									if Lvls.I == 3 then
										if CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] == Skills.Name then
											CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] = nil
											return "Removed", "h", Lvls.I
										end
										
										if CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I-2] == nil then			---- Checks for empty
											if CheckForDuplicates(Skills.Name, CurrentClass.SkillsLoadOut["C"..Lvls.B]) then
												return "Duplicate"
											end
											CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I-2] = Skills.Name
											return "Equipped", ClassInfo:GetSkillInfo(Skills.Name), Lvls.I-2
										elseif CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I-1] == nil then		---- Checks for empty
											if CheckForDuplicates(Skills.Name, CurrentClass.SkillsLoadOut["C"..Lvls.B]) then
												return "Duplicate"
											end
											CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I-1] = Skills.Name
											return "Equipped", ClassInfo:GetSkillInfo(Skills.Name), Lvls.I-1
										else
											if CheckForDuplicates(Skills.Name, CurrentClass.SkillsLoadOut["C"..Lvls.B]) then
												return "Duplicate"
											end
											CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] = Skills.Name
											return "Equipped", ClassInfo:GetSkillInfo(Skills.Name), Lvls.I
										end
									elseif Lvls.I == 2 then
										if CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] == Skills.Name then
											CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] = nil
											return "Removed", "h", Lvls.I
										end
										
										if CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I-1] == nil then			---- Checks for empty
											if CheckForDuplicates(Skills.Name, CurrentClass.SkillsLoadOut["C"..Lvls.B]) then
												return "Duplicate"
											end
											CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I-1] = Skills.Name
											return "Equipped", ClassInfo:GetSkillInfo(Skills.Name), Lvls.I-1
										else
											if CheckForDuplicates(Skills.Name, CurrentClass.SkillsLoadOut["C"..Lvls.B]) then
												return "Duplicate"
											end
											CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] = Skills.Name
											return "Equipped", ClassInfo:GetSkillInfo(Skills.Name), Lvls.I
										end
									else
										if CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] == Skills.Name then
											CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] = nil
											return "Removed", "h", Lvls.I
										end
										
										if CheckForDuplicates(Skills.Name, CurrentClass.SkillsLoadOut["C"..Lvls.B]) then
											return "Duplicate"
										end
										CurrentClass.SkillsLoadOut["C"..Lvls.B][Lvls.I] = Skills.Name
										return "Equipped", ClassInfo:GetSkillInfo(Skills.Name), Lvls.I
									end
								else
									return "Locked", "HEHEHE", Lvls.Level
								end
							end
						end
					end
				end
			end
		end
	end)
	
	Socket:Listen("LearnSkill", function(SkillName)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local Success = false
		local CurGold = 0
		local Skil = ClassInfo:GetSkillInfo(SkillName)
		
		if Skil ~= nil and PlayerStat then
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			for _,Skills in next, CurrentClass.Skills do
				if Skills.Name == Skil.Name then
					if Skills.Unlocked == false and PlayerStat.Gold >= Skil.Cost then
						if CurrentClass.CurrentLevel >= Skil.LevelReq then
							PlayerStat.Gold = PlayerStat.Gold - Skil.Cost
							Skills.Unlocked = true
							CurGold = PlayerStat.Gold
							Success = Skills.Unlocked
							break
						else
							return "LowLevel"
						end
					else
						return "NoGold"
					end
				end
			end
		end
		return Success, CurGold
	end)	
	
	Socket:Listen("UpgradeSkill", function(SkillName)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local Success = false
		local CurrentRank = nil
		local CurFP = nil
		local Skil = ClassInfo:GetSkillInfo(SkillName)
		
		if Skil ~= nil and PlayerStat then
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			for _,Skills in ipairs(CurrentClass.Skills) do
				if Skills.Name == Skil.Name then
					local UpgradeAmnt = (4*(Skills.Rank+1))
					if Skills.Unlocked and CurrentClass.SkillPoints >= UpgradeAmnt then
						if Skills.Rank < 23 then
							if Skills.Rank >= 8 and not Check(PlayerStat.StoryProgression, PlayerStat.CurrentClass) then
								return false, "Trials", PlayerStat.CurrentClass.. " Mastery Trials must be completed"
							else
								CurrentClass.SkillPoints = CurrentClass.SkillPoints - UpgradeAmnt
								CurrentClass.SkillPointsUsed += UpgradeAmnt
								Skills.Rank = Skills.Rank + 1
								CurrentRank = Skills.Rank
								RewardAchievement({59}, id)
								if Skills.Rank >= 9 then
							--		if not Check(PlayerStat.StoryProgression, PlayerStat.CurrentClass.."T") then
							--			tbi(PlayerStat.StoryProgression, PlayerStat.CurrentClass.."T")
							--		end
									RewardAchievement({60}, id)
								end
								if Skills.Rank >= 15 then
									RewardAchievement({61}, id)
								end
								if Skills.Rank >= 23 then
									RewardAchievement({62}, id)
								end
								CurFP = CurrentClass.SkillPoints
							end
						end
						Success = true
						break
					else
						return false, "FP"
					end
				end
			end
		end
		return Success, CurrentRank, CurFP, PlayerStat.Characters[PlayerStat.CurrentClass]
	end)
	
	Socket:Listen("UpgradeStat", function(ButtonName)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local Success = false
		
		if PlayerStat then
			local currentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			local RequiredEXP = Floor(((currentClass.CurrentLevel + 1) ^ 1.6 + (currentClass.CurrentLevel + 1)) / 2 * 100 - ((currentClass.CurrentLevel + 1) * 100))
			
			if currentClass.EXP >= RequiredEXP then
				currentClass.EXP = currentClass.EXP - RequiredEXP
				currentClass.CurrentLevel = currentClass.CurrentLevel + 1
				local SkillPointsAmnt = abs((5 + (Floor(currentClass.CurrentLevel * .1))))
				currentClass.SkillPoints = currentClass.SkillPoints + Floor(SkillPointsAmnt + .5)
				local LevelRates = ClassInfo:GetLevelRates()
				local CurrentLevels = currentClass.UpgradeLevels
				local HPAdd = Floor(LevelRates.HP.Start * (LevelRates.HP.Decay) ^ CurrentLevels.HP)
				local DmgAdd = Floor(LevelRates.ATK.Start * (LevelRates.ATK.Decay) ^ CurrentLevels.ATK)
				local DEFAdd = LevelRates.DEF.Start * (LevelRates.DEF.Decay) ^ CurrentLevels.DEF
				local CRTAdd = Floor(LevelRates.CRT.Start * (LevelRates.CRT.Decay) ^ CurrentLevels.CRT)
				local CRDAdd = Floor(LevelRates.CRD.Start * (LevelRates.CRD.Decay) ^ CurrentLevels.CRD)
				local STAAdd = Floor(LevelRates.STA.Start * (LevelRates.STA.Decay) ^ CurrentLevels.STA)
				if HPAdd <= LevelRates.HP.Minimum then
					HPAdd = LevelRates.HP.Minimum
				end
				if DmgAdd <= LevelRates.ATK.Minimum then
					DmgAdd = LevelRates.ATK.Minimum
				end
				if DEFAdd <= LevelRates.DEF.Minimum then
					DEFAdd = LevelRates.DEF.Minimum
				end
				if CRTAdd <= LevelRates.CRT.Minimum then
					CRTAdd = LevelRates.CRT.Minimum
				end
				if CRDAdd <= LevelRates.CRD.Minimum then
					CRDAdd = LevelRates.CRD.Minimum
				end
				if STAAdd <= LevelRates.STA.Minimum then
					STAAdd = LevelRates.STA.Minimum
				end
				currentClass.EXPUsed = currentClass.EXPUsed + RequiredEXP
				if ButtonName == "HP" then
					currentClass.HP = currentClass.HP + HPAdd
					currentClass.UpgradeLevels.HP = currentClass.UpgradeLevels.HP + 1
				elseif ButtonName == "Damage" then
					currentClass.Damage = currentClass.Damage + DmgAdd
					currentClass.UpgradeLevels.ATK = currentClass.UpgradeLevels.ATK + 1
				elseif ButtonName == "DEF" then
					currentClass.Defense = currentClass.Defense + DEFAdd
					currentClass.UpgradeLevels.DEF = currentClass.UpgradeLevels.DEF + 1	
				elseif ButtonName == "Crit" then
					currentClass.Crit = currentClass.Crit + CRTAdd
					currentClass.UpgradeLevels.CRT = currentClass.UpgradeLevels.CRT + 1
				elseif ButtonName == "CritDEF" then
					currentClass.CritDef = currentClass.CritDef + CRDAdd
					currentClass.UpgradeLevels.CRD = currentClass.UpgradeLevels.CRD + 1
				elseif ButtonName == "Stamina" then
					currentClass.Stamina = currentClass.Stamina + STAAdd
					currentClass.UpgradeLevels.STA = currentClass.UpgradeLevels.STA + 1
				end
				
				if currentClass.CurrentLevel >= PlayerManager.PLAYER_LEVEL_CAP then
					currentClass.EXP = 0
					Socket:Emit("Hint", "You have reached the Level Cap!")
				end
				
				Success = true
			end
		end
		return Success
	end)
	
	Socket:Listen("EquipWeapon", function(Obj)
		local Success = false
		local NewCharInfo;
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		if PVP then
			return "You cannot change weapons in PVP!"
		end
		
		if PlayerStat then
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			local Inventory = Obj.Map == nil and CurrentClass.WeaponInventory or CurrentClass.TrophyInventory
			for _,Item in ipairs(Inventory) do
				if Obj.CurrentWeapon and Obj.CurrentWeapon.ID == Item.ID and Obj.CurrentWeapon.CID == Item.CID and (Obj.Map == Item.Map) then
					local Weapon = Obj.Map == nil and WeaponCraft:GetWeaponFromID(PlayerStat.CurrentClass, Item.ID) or WeaponCraft:GetTrophyFromID(Item.Map, Item.ID)
					if Weapon then
						if CurrentClass.CurrentLevel >= Weapon.LevelReq then
							if Obj.Map == nil then
								CurrentClass.CurrentWeapon = Item
							else
								CurrentClass.CurrentTrophy = Item
							end
							
							Success = true
						else
							Success = "Low Level"
						end
					end
					NewCharInfo = CurrentClass
					break
				end
			end
		end
		return Success, NewCharInfo
	end)
	
	Socket:Listen("SellWeapon", function(ObjsOfTable)
		local Success = false
		local NewCharInfo;
		local NewAccInfo;
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		if PlayerStat then
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			local Inventory = #CurrentClass.WeaponInventory
			for b = 1, #ObjsOfTable do
				local Obj = ObjsOfTable[b].Object
				if Obj then
					if Obj.Map ~= nil then
						Inventory = #CurrentClass.TrophyInventory
					end
					for i = 1, Inventory do
						local Item = Obj.Map == nil and CurrentClass.WeaponInventory[i] or CurrentClass.TrophyInventory[i]
						if Obj.CurrentWeapon and Obj.CurrentWeapon.ID == Item.ID and Obj.CurrentWeapon.CID == Item.CID and (Obj.Map == Item.Map) then
							if Item.ID ~= 1 and (Obj.Map == nil and (Item.CID ~= CurrentClass.CurrentWeapon.CID) or (Item.CID ~= CurrentClass.CurrentTrophy.CID)) then --we don't want to sell their default weapon or their equipped!
								local Weapon = Obj.Map == nil and WeaponCraft:GetWeaponFromID(PlayerStat.CurrentClass, Item.ID) or WeaponCraft:GetTrophyFromID(Item.Map, Item.ID)
								if Weapon then
									PlayerStat.Gold = PlayerStat.Gold + Weapon.SellPrice
									tbr(Obj.Map == nil and CurrentClass.WeaponInventory or CurrentClass.TrophyInventory, i)
									Success = true
									NewCharInfo = CurrentClass
									NewAccInfo = PlayerStat
								end
								break
							end
						end
					end
				end
			end
		end
		return Success, NewCharInfo, NewAccInfo
	end)
	
	Socket:Listen("EquipGem", function(Obj)
		local Success = false
		local NewCharInfo;
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		if PVP then
			return "You cannot change gems in PVP!"
		end
		
		if PlayerStat and tick() - CombatState.GemSwap >= .5 then
			CombatState.GemSwap = tick()
			PlayerManager:UpdateCombatState(id, CombatState)
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			local Inventory = #CurrentClass.GemInventory
			for i = 1, Inventory do
				local Item = CurrentClass.GemInventory[i]
				if Item.IG and Item.IND == Obj.IND and Item.R == Obj.R and Item.ID == Obj.ID then --makes sure its actually in the player's inventory
					print("In Inventory!")
					if (CurrentClass.Gemstone1 ~= nil and CurrentClass.Gemstone1.IND == Item.IND) or (CurrentClass.Gemstone2 ~= nil and CurrentClass.Gemstone2.IND == Item.IND) or (CurrentClass.Gemstone3 ~= nil and CurrentClass.Gemstone3.IND == Item.IND) then --If found in one of the slots, destroy
						print("Destroy!")
						if (CurrentClass.Gemstone1 ~= nil and CurrentClass.Gemstone1.IND == Item.IND) then
							CurrentClass.Gemstone1 = nil
						elseif (CurrentClass.Gemstone2 ~= nil and CurrentClass.Gemstone2.IND == Item.IND) then
							CurrentClass.Gemstone2 = nil
						elseif (CurrentClass.Gemstone3 ~= nil and CurrentClass.Gemstone3.IND == Item.IND) then
							CurrentClass.Gemstone3 = nil
						end
						NewCharInfo = CurrentClass
						Success = "Destroy"
						break
					else ---if not found in one of the gem slots, equip it in an empty one
						if CurrentClass.Gemstone1 == nil or CurrentClass.Gemstone2 == nil or CurrentClass.Gemstone3 == nil then ---make sure one of the slots are empty
							print("Has empty slots!")
							local NoDup = true
							if (CurrentClass.Gemstone1 ~= nil and CurrentClass.Gemstone1.ID == Item.ID) or (CurrentClass.Gemstone2 ~= nil and CurrentClass.Gemstone2.ID == Item.ID) or (CurrentClass.Gemstone3 ~= nil and CurrentClass.Gemstone3.ID == Item.ID) then
								NoDup = false
							end
							if NoDup then
								if CurrentClass.Gemstone1 == nil then
									CurrentClass.Gemstone1 = Item
									print("Equipped to Gem 1!")
								elseif CurrentClass.Gemstone2 == nil then
									CurrentClass.Gemstone2 = Item
									print("Equipped to Gem 2!")
								elseif CurrentClass.Gemstone3 == nil then
									CurrentClass.Gemstone3 = Item
									print("Equipped to Gem 3!")
								end
							else
								print('Dupped!')
								Success = "Duplicate"
								break
							end
						else
							print("Full!")
							Success = "Full slots!"
							break
						end
					end
					
					NewCharInfo = CurrentClass
					Success = true
					break
				end
			end
		else
			Success = "Quick"
		end
		return Success, NewCharInfo
	end)
	
	Socket:Listen("SellGem", function(ObjOfTable)
		local Success = false
		local NewCharInfo;
		local gone = 0
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		if PlayerStat and tick() - CombatState.GemSwap >= 0 then
			CombatState.GemSwap = tick()
			PlayerManager:UpdateCombatState(id, CombatState)
			
			local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
			local GemInventory = #CurrentClass.GemInventory
			local MatInventory = #PlayerStat.Inventory
			local IsItaGem = false
			for _, OfTable in ipairs(ObjOfTable) do
				local Obj = OfTable.Object
				if Obj then
					for i = 1, MatInventory do
						local Item = PlayerStat.Inventory[i]
						local ItemInfo = LootInfo:GetItemInfoFromID(Item.ID, Item.IG, Item.R)
						if ItemInfo ~= nil and Item.IND == Obj.IND and Item.R == Obj.R and Item.ID == Obj.ID then --makes sure its actually in the player's inventory
							print("In Inventory!")
							if Item.IG then
								break
							else
								if Item.Q <= 1 then
									tbr(PlayerStat.Inventory, i)
								else
									Item.Q = Item.Q - 1
									gone = Item.Q
								end
								PlayerStat.Gold = PlayerStat.Gold + ItemInfo.SellPrice
							end
							NewCharInfo = PlayerStat
							Success = true
							break
						end
					end
				end
			end
			for _, OfTable in ipairs(ObjOfTable) do
				local Obj = OfTable.Object
				if Obj then
					for i = 1, GemInventory do
						local Item = CurrentClass.GemInventory[i]
						local ItemInfo = LootInfo:GetItemInfoFromID(Item.ID, Item.IG, Item.R)
						if ItemInfo ~= nil and Item.IND == Obj.IND and Item.R == Obj.R and Item.ID == Obj.ID then --makes sure its actually in the player's inventory
							print("In Inventory!")
							if Item.IG then
								if (CurrentClass.Gemstone1 ~= nil and CurrentClass.Gemstone1.IND == Item.IND) or (CurrentClass.Gemstone2 ~= nil and CurrentClass.Gemstone2.IND == Item.IND) or (CurrentClass.Gemstone3 ~= nil and CurrentClass.Gemstone3.IND == Item.IND) then
									print("Can't sell, is equipped!")
									Success = "Is equipped!"
									break
								else ---if not found in one of the gem slots, sell
									tbr(CurrentClass.GemInventory, i)
									PlayerStat.Gold = PlayerStat.Gold + ItemInfo.SellPrice
								end
							else
								break
							end
							NewCharInfo = PlayerStat
							Success = true
							break
						end
					end
				end
			end
		else
			Success = "Quick"
		end
		return Success, NewCharInfo, gone
	end)
	
	Socket:Listen("ReforgeGem", function(Queue)
		local Success = false
		local TargetIndex = {}
		local AvgRarity = {}
		local GemNames = {}
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local CurrentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
		local Inventory = CurrentClass.GemInventory
		
		if #Queue == 5 then
			for _, Obj in ipairs(Queue) do
				for _, Item in ipairs(Inventory) do
					local ItemInfo = LootInfo:GetItemInfoFromID(Item.ID, Item.IG, Item.R)
					if ItemInfo ~= nil and Item.IND == Obj.IND and Item.R == Obj.R and Item.ID == Obj.ID then --makes sure its actually in the player's inventory
						print("In Inventory!")
						if Item.IG then
							print("Is a gem!")
							if (CurrentClass.Gemstone1 ~= nil and CurrentClass.Gemstone1.IND == Item.IND) or (CurrentClass.Gemstone2 ~= nil and CurrentClass.Gemstone2.IND == Item.IND) or (CurrentClass.Gemstone3 ~= nil and CurrentClass.Gemstone3.IND == Item.IND) then
								print("Is a gem equipped!")
							else
								local NotSameIndex = true
								for b = 1, #TargetIndex do
									if Item.IND == TargetIndex[b] then
										NotSameIndex = false
										break
									end
								end
								if NotSameIndex then
									tbi(TargetIndex, Item.IND)
									tbi(AvgRarity, Item.R)
									tbi(GemNames, ItemInfo.Name)
									print("Table inserted!")
								else
									print("Had the same index? Wat?")
								end
							end
						end
					end
				end
			end
		end
		if #TargetIndex == 5 then
			local IsSameRarity = true
			local IsSameType = true
			local CumulativeNumber = 0
			for i = 1, #AvgRarity do
				if AvgRarity[i] ~= AvgRarity[1] then
					IsSameRarity = false
				end
				if GemNames[i] ~= GemNames[1] then
					IsSameType = false
				end
				CumulativeNumber = CumulativeNumber + AvgRarity[i]
			end
			if IsSameRarity and AvgRarity[1] ~= 5 then
				for i = 1, #TargetIndex do
					for v = 1, #CurrentClass.GemInventory do
						if CurrentClass.GemInventory[v].IND == TargetIndex[i] then
							tbr(CurrentClass.GemInventory, v)
							print("Removed Gem")
							break
						end
					end
				end
				--reward gem 1 tier higher
				local TypeFind = (IsSameType and GemNames[1] or nil)
				local GemDrop = LootInfo:MakeGem(PlayerStat.InventorySpace,CurrentClass.GemInventory, AvgRarity[1]+1, TypeFind)
				tbi(CurrentClass.GemInventory, GemDrop)
				Socket:Emit("LootFound", {LootInfo:GetItemInfoFromID(GemDrop.ID, GemDrop.IG, GemDrop.R)})
				Success = true
			else
				local RealRarity = Floor(CumulativeNumber / 5)
				for i = 1, #TargetIndex do
					for v = 1, #CurrentClass.GemInventory do
						if CurrentClass.GemInventory[v].IND == TargetIndex[i] then
							tbr(CurrentClass.GemInventory, v)
							print("Removed Gem")
							break
						end
					end
				end
				--reward random gem of the average tier
				local gems = {}
				for i = 1, 2 do
					local GemDrop = LootInfo:MakeGem(PlayerStat.InventorySpace,CurrentClass.GemInventory, RealRarity)
					tbi(CurrentClass.GemInventory, GemDrop)
					tbi(gems, LootInfo:GetItemInfoFromID(GemDrop.ID, GemDrop.IG, GemDrop.R))
				end
				Socket:Emit("LootFound", gems)
				Success = true
			end
		end
		if Success then
			RewardAchievement({45, 46, 47, 48, 49, 50, 51}, id)
		end
		return Success, CurrentClass
	end)

	Socket:Listen("OutfitManage", function(Mode, SlotName)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local Character = PlayerStat.Characters[PlayerStat.CurrentClass]
		local UnlockedSlots = PlayerStat.OutfitSlots
		local slotNumber = tonumber(SlotName:match("(%d+)$"))

		if slotNumber > UnlockedSlots then return end

		local function deepCopy(original)
			local copy = {}
			for k, v in pairs(original) do
				if type(v) == "table" then
					v = deepCopy(v)
				end
				copy[k] = v
			end
			return copy
		end

		local slot = Character.CurrentSkinLoadout[SlotName]
		if slot then
			if Mode == "Save" then
				local clone = deepCopy(Character.CurrentSkinPieces)
				Character.CurrentSkinLoadout[SlotName] = clone
				return true, Character
			elseif Mode == "Load" then
				if not slot.Head then
					return -1
				end

				local clone = deepCopy(Character.CurrentSkinLoadout[SlotName])
				Character.CurrentSkinPieces = clone

				for i,v in ipairs(Player.Character:GetChildren()) do
					if v:IsA("Model") and v.Name ~= "Trophy" then
						v:Destroy()
					end
				end

				Morpher:morph(Player.Character, Character.CurrentSkinPieces)

				return true
			end
		end
	end)

	Socket:Listen("ChangeColour", function(limbTable)
		if CheckGamePass(Player, 7052268) then
			local PlayerStat = PlayerManager:GetPlayerStat(id)
			local Character = PlayerStat.Characters[PlayerStat.CurrentClass]
			local SkinPieces = Character.CurrentSkinPieces

			local colourInitials = {
					Primary = "P",
					Secondary = "S",
					Tertiary = "T",
					Quaternary = "Q"
				}

			for limb, colourInformation in pairs(limbTable) do
				for colourGroup, color3 in pairs(colourInformation) do
					if colourInitials[colourGroup] and SkinPieces[limb] then
						if color3 ~= -1 and typeof(color3.R) == "number" and typeof(color3.G) == "number" and typeof(color3.B) == "number" then --- sanity check
							SkinPieces[limb][colourInitials[colourGroup]] = {math.clamp(color3.R, 0, 1), math.clamp(color3.G, 0, 1), math.clamp(color3.B, 0, 1)}
						elseif color3 == -1 then
							SkinPieces[limb][colourInitials[colourGroup]] = {}
						end
					end
				end
			end

			for i,v in ipairs(Player.Character:GetChildren()) do
				if v:IsA("Model") and v.Name ~= "Trophy" then
					v:Destroy()
				end
			end

			Morpher:morph(Player.Character, SkinPieces)
		end
	end)
	
end

return logic
