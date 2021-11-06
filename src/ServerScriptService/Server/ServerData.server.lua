local SoloTest = script.Parent.Values.DEBUG_VARIABLES.SoloTest.Value
local IsPVPTest	= script.Parent.Values.DEBUG_VARIABLES.IsPVPTest.Value
local CanSave = script.Parent.Values.DEBUG_VARIABLES.CanSave.Value


local ScopeVersion = "LIVETEST2" --"AlphatestServer512"

--[[ Main Variables ]]--

local BadgeService					= game:GetService("BadgeService")
local CollectionService				= game:GetService("CollectionService")
local DataStoreService 				= require(script.Parent.Parent.TestScripts.DataStoreService)
local Debris						= game:GetService("Debris")
local GamePassService				= game:GetService("GamePassService")
local HttpService 					= game:GetService("HttpService")
local MarketplaceService			= game:GetService("MarketplaceService")
local MessagingService				= game:GetService("MessagingService")
local Players 						= game:GetService("Players")
local PathfindingService 			= game:GetService("PathfindingService")
local PhysicsService 				= game:GetService("PhysicsService")
local ReplicatedStorage 			= game:GetService("ReplicatedStorage")
local ScriptContext					= game:GetService("ScriptContext")
local ServerStorage 				= game:GetService("ServerStorage")
local Teams 						= game:GetService("Teams")
local TeleportService				= game:GetService("TeleportService")
local TextService					= game:GetService("TextService")
local TweenService					= game:GetService("TweenService")
local RunService 					= game:GetService("RunService")

local EnemiesFolder 				= game.Workspace:WaitForChild("Enemies"); EnemiesFolder:ClearAllChildren()

local FS							= require(ReplicatedStorage.Scripts.Modules.FastSpawn)
local GameObjectHandler				= require(script.Parent.SharedModules.GameObjectHandler)

local Modules 						= script.Parent.Parent.Modules
local Sockets 						= require(Modules.Utility["server"])
local Achievements					= require(Modules.Systems["Achievements"])
local LootInfo 						= require(Modules.CharacterManagement["LootInfo"])
local CacheAnimations				= require(Modules.Utility["CacheAnimationList"])
local ClassInfo 					= require(Modules.CharacterManagement["ClassInfo"])
local DatabaseService				= require(Modules.Utility["DatabaseService"])
local DataCompressor				= require(Modules.Utility.DataCompressor)
local Guilds						= require(Modules.Systems["Guilds"])
local ItemboxModule					= require(Modules.CharacterManagement["ItemBox"])
local PlayerManager					= require(Modules.PlayerStatsObserver)
local MatchMaking					= require(Modules.Systems["Matchmaking"])
local Shop							= require(Modules.Systems["Shop"])
local WeaponCraft					= require(Modules.CharacterManagement["WeaponCrafting"])
local TerrainSaveLoad				= require(Modules.Utility["TerrainSaveLoad"])
local Titles						= require(Modules.Systems["Titles"])
local Vestiges						= require(Modules.Systems.Vestiges)
local GameLogic						= require(script.Parent.GameLogic)
local RewardAchievement				= require(script.Parent.SharedModules.RewardAchievement)
local Morpher 						= require(ReplicatedStorage.Scripts.Modules.Morpher)
local Raven 						= require(Modules.Utility.Raven)
local RavenClient					= Raven:Client("https://450fe3e995ff440897c72849a97e6ff3:9469860ee4ea4164a2ed065514f3f2a9@sentry.io/1845296")
local ChatService 					= require(script.Parent.Parent:WaitForChild("ChatServiceRunner").ChatService)
local WorldEvents					= require(Modules.Systems.WorldEventsMain)

local ProfileService 				= require(Modules.Utility.ProfileService)

local GlobalDatabase				= DatabaseService:GetDatabase("Global") --google spreadsheets

local ServerStartTime				= tick()

local ContributorUpdate				= 0
local ContributorTimer				= 0

local ContributorTemp				= nil
local Contributors					= {}

local TeleportQueues				= {}
local Bullets						= {}
local ScopeVersionForCodes			= ScopeVersion.."Codes"
local GuildsScopeVersion			= ScopeVersion.."Guilds"
local PurchaseHistoryScope			= ScopeVersion.."DevProduct"
local PlayerCollisionGroupName 		= "Players"

local ListOfDodges					= {}
local ListOfBlocks 					= {}
local ListOfUlts					= {}
local ListOfLight					= {}
local ListOfHeavy					= {}
local ListOfKnockBacks				= {}
local ListOfKnockUps				= {}
local ListOfKnockDowns				= {}
local BlacklistAnimations			= {}



local GlobalThings = {
	MaxGemDrops						= 2,
	MaxLootDrops					= 10,
	GlobalParryWindow				= .08, --.08
	GlobalParryCooldown				= 3,
	GlobalBlockSpeed				= 35,
	GlobalBlockModifier				= .1,
	GlobalComboAmount				= 1,
	GlobalComboCooldown				= 3,
	GlobalComboDamageModifier		= .002,
	GlobalLobbyTimer				= 95,
	GlobalFatigueAmount				= .4,
	GlobalUltimateCounter			= 0
}

local Host							= nil
local Difficulty					= nil
local Map							= nil
local PVP							= nil
local ReservedServer				= false

local CF = CFrame.new
local Vec3 = Vector3.new
local tbi = table.insert
local tbr = table.remove
local abs = math.abs
local Rand = Random.new()
local Floor = math.floor

if not CanSave then
	FS.spawn(function()
		while wait(10) do
			Sockets:Emit("SendMessage", nil, nil, "Saving is disabled by the developer. If this message is appearing on official builds, we forgot to turn it back on! Please let us know!", true)
		end
	end)
end

ListOfDodges, ListOfBlocks, ListOfUlts, ListOfLight, ListOfHeavy, ListOfKnockBacks, ListOfKnockUps, ListOfKnockDowns, BlacklistAnimations = CacheAnimations:Cache()
		
if (game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0) or SoloTest then
	ReservedServer = true
	ReplicatedStorage.SERVER_STATS.IsPrivateServer.Value = true
	if SoloTest then
		TerrainSaveLoad:Load(ReplicatedStorage.Environments.Terrains.TrainStation)
		if IsPVPTest then
			PVP = {RedTeam = {"Player1", "Player3"}, BlueTeam = {"Player2"}}
		end
	end
end

if game.PlaceId == 785484984 or game.PlaceId == 563493615 then
	ReservedServer = true
end

local xsix = workspace:FindFirstChild("Quick Export (RIGHT CLICK |xsixx FILES, SAVE TO ROBLOX)")
if xsix then
	xsix:Destroy()
end

--[[ Main Functions ]]--

function setCollisionGroupRecursive(object)
	if object:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(object, PlayerCollisionGroupName)
	end
	for _, child in next, object:GetChildren() do
		setCollisionGroupRecursive(child)
	end
end

function getAssets()
	local ids = {}
	for _,folders in ipairs(ServerStorage.Assets:GetChildren()) do
		for _,items in ipairs(folders:GetChildren()) do
			if items:IsA("Animation") then
				tbi(ids,items.AnimationId)
				print("Inserted Animation: " ..items.AnimationId)
			elseif items:IsA("Sound") then
				tbi(ids,items.SoundId)
				print("Inserted Sound: " ..items.SoundId)
			elseif items:IsA("Decal") then
				tbi(ids,items.Texture)
				print("Inserted Texture: " ..items.Texture)
			end
		end
	end
	return ids
end

local SyncTime = require(game.ServerScriptService.Modules.Systems.SyncedTime)
SyncTime.init()

--[[ Data Management ]]--

ScriptContext.Error:Connect(function(message, trace, script)
	--[[
		Send to our database error checking
	--]]
	
	if CanSave then
		RavenClient:SendException(Raven.ExceptionType.Server, message, trace)
		--local Message = "Fatal: " .. script:GetFullName() .. " : " .. message.. " [".. trace .."]"
		--RavenClient:SendMessage(Message)
	end
end)

function WebHookTalk(msg)
	local date = os.date("!*t")
	local Data = {
		--["content"] = ":watch: **"..date.month.."/"..date.day.."/"..date.year.."**\n```diff\nThe game is now down for maintenance. Estimated Maintenance time: 15 Hours```"
		["content"] = ":watch: **"..date.month.."/"..date.day.."/"..date.year.."**\n\n" ..msg
	}
	Data = HttpService:JSONEncode(Data)
	HttpService:PostAsync("", Data)
end
--WebHookTalk()

local function GetBaseTemplate()
	--[[ Will add player data depending on this ]]--
	
	local data 						= {}
	data.UploadedToSheets		= 0
	data.Gold 					= 1000
	data.Tears 					= 0
	data.Tokens					= 0
	data.Potions				= 0
	data.PotionsStamina			= 0
	data.WeaponLevel 			= 0
	data.ArmorLevel 			= 0
	data.InventorySpace 		= 30
	data.OutfitSlots			= 3
	data.LastReserveCode		= nil
	data.Options				= nil
	data.LastReserveTime		= 0
	data.PremiumExpiration		= 0
	data.Guild 					= ""
	data.GuildXP				= 0
	data.CurrentClass 			= "Null"
	data.ChatTitle				= ""
	data.ProfileBackground 		= "DefBan"	--- Banners
	data.PlayerCardBackground	= ""
	data.CurrentPet				= ""
	data.Pets					= {}
	data.TotalHours				= 0
	data.BossesKilled			= 0
	data.DungeonNormalCompleted	= 0
	data.DungeonHeroCompleted	= 0
	data.DungeonHMDCompleted	= 0
	data.DungeonPVPCompleted	= 0
	data.HighestCombo			= 0
	data.HighestDamage			= 0
	data.Helpers				= {}
	data.UnclaimedAchievements = {}
	data.DailyAchievements = {}
	data.WeeklyAchievements = {}
	data.DailyDay = 0
	data.WeeklyDay = 0
	data.CharacterPlayCount = {}
	data.CardBackgrounds	= {}
	data.WeaponAuras		= {}
	data.CharacterAuras		= {}
	data.Achievements		= {}
	data.Titles 			= {"DefBan"}	--- Banners too
	data.Vestiges			= {}
	data.ChatTitles			= {}
	data.Recipes 			= {}
	data.Inventory			= {}
	data.Codex	 			= {}
	data.Purchases 			= {}
	data.Characters 		= {}
	data.ItemBox			= {}
	data.StoryProgression	= {}
	data.Infusions			= {2, 3, 12, 6, 7, 8, 11}
	data.BuiltFacilities	= {
		{
			ID = 1,
			Active = false,
			Level = 1,
		},
		{
			ID = 3,
			Active = true,
			Level = 1,
		}
	}
	return data
end

--[[
Acc1 = {
			Name = "Wings",
			Attachment = "BodyBackAttachment",
			Position = {X = 0, Y = 0, Z = 0},
			Rotation = {X = 0, Y = 0, Z = 0},
			Colors = {
				color1 = {R = 0, G = 0, B = 0},
				color2 = {R = 0, G = 0, B = 0},
				color3 = {R = 0, G = 0, B = 0},
			}
		}
--]]

local function GetCharacterTemplate()
	--[[ Only applicable to new characters (when purchased too). ]]--
	
	local data 						= {}
	data.CurrentClass 			= "" --- Used internally for saves
	data.CurrentWeapon		 	= "Default"
	data.CurrentTrophy			= nil
	data.CurrentLevel 			= -1
	data.CurrentAccessories		= {
	}
	data.CurrentSkinLoadout = {Slot1 = {}, Slot2 = {}, Slot3 = {}, Slot4 = {}, Slot5 = {}, Slot6 = {}, Slot7 = {}, Slot8 = {}, Slot9 = {}, Slot10 = {}}
	data.CurrentSkinPieces		= {
		Head = {N = "", P = {}, S = {}, T = {}, Q = {}},
		UpperTorso = {N = "", P = {}, S = {}, T = {}, Q = {}},
		LowerTorso = {N = "", P = {}, S = {}, T = {}, Q = {}},
		LeftUpperArm = {N = "", P = {}, S = {}, T = {}, Q = {}},
		LeftLowerArm = {N = "", P = {}, S = {}, T = {}, Q = {}},
		LeftHand = {N = "", P = {}, S = {}, T = {}, Q = {}},
		RightUpperArm = {N = "", P = {}, S = {}, T = {}, Q = {}},
		RightLowerArm = {N = "", P = {}, S = {}, T = {}, Q = {}},
		RightHand = {N = "", P = {}, S = {}, T = {}, Q = {}},
		LeftUpperLeg = {N = "", P = {}, S = {}, T = {}, Q = {}},
		LeftLowerLeg = {N = "", P = {}, S = {}, T = {}, Q = {}},
		LeftFoot = {N = "", P = {}, S = {}, T = {}, Q = {}},
		RightUpperLeg = {N = "", P = {}, S = {}, T = {}, Q = {}},
		RightLowerLeg = {N = "", P = {}, S = {}, T = {}, Q = {}},
		RightFoot = {N = "", P = {}, S = {}, T = {}, Q = {}}
	}
	data.EXP 					= 0
	data.EXPUsed				= 0
	data.SkillPoints			= 0
	data.SkillPointsUsed		= 0
	data.HP 					= 1
	data.Damage 				= 1
	data.Defense 				= 1
	data.Stamina				= 1
	data.Crit					= 1
	data.CritDef				= 1
	data.UpgradeLevels			= { ---Amount of times HP was upgraded
		HP = 0, ATK = 0, DEF = 0, STA = 0, CRT = 0, CRD = 0
	}
	data.Gemstone1 				= nil
	data.Gemstone2 				= nil
	data.Gemstone3 				= nil
	data.Skins 					= {}
	--tb[class].WeaponSkins 			= {class.."Weapon"}
	data.Skills 				= {}
	data.SkillsLoadOut			= {
		C1 = {}, C2 = {}, C3 = {}
	}
	data.AurasLoadout			= {
		Weapon = {},
		Character = {}
	}
	data.CharacterLoadout		= {
		Sup1 = "",
		Sup2 = ""
	}
	data.WeaponInventory		= {}
	data.TrophyInventory		= {}
	data.GemInventory			= {}
	return data
end

local accountProfileTemplate = ProfileService.GetProfileStore(
    "Account_ProfileStore_Suffix_3",
    GetBaseTemplate()
)

local characterProfileTemplate = ProfileService.GetProfileStore(
    "Character_ProfileStore_Suffix_3",
    GetCharacterTemplate()
)

local CheckGamePass = require(script.Parent.SharedModules.CheckGamePass)

function getClassData(id, currentClass)
	local player = Players:GetPlayerByUserId(id)
	local profile = characterProfileTemplate:LoadProfileAsync(
		string.format("%s_SaveData_Character_%s", id, currentClass),
		"Steal"
	)

	if profile then
		print(profile)
		print("CHARACTER PROFILE ^^^^")

		profile:Reconcile()
		profile:ListenToRelease(function()
			--- Save some space by removing the data and replacing it. Sometimes this is not guaranteed as the
			--- player's account profile may have already been released
			local playerStat = PlayerManager:GetPlayerStat(id)

			if playerStat then
				playerStat.Characters[currentClass] = currentClass
			end

			print("Character profile released successfully")
		end)

		if player:IsDescendantOf(Players) then
			return profile
		else
			profile:Release()
		end
	end


	--[[
	local success, JSON = pcall(function()
		local scope = DataStoreService:GetDataStore(ScopeVersion)
		local Data = scope:GetAsync(id.."SaveData"..currentClass)
		return Data
	end)
	if success then
		if JSON == nil then
			return nil
		else
			local JSONLoaded = DataCompressor.decompress(JSON)
			local Character = HttpService:JSONDecode(JSONLoaded)

			local CharacterTemplate = GetCharacterTemplate()
			for Namer, StatData in pairs(CharacterTemplate) do
				if not Character[Namer] then
					print(id, " User ", currentClass, "did not have", Namer, "| Installing...")
					Character[Namer] = StatData
				end
				
				if Character.WeaponInventory ~= nil and Namer == "CurrentWeapon" then
					for WeaponTableI, WeaponGoodies in pairs(Character.WeaponInventory) do
						if WeaponGoodies["Tier"] == nil then
							WeaponGoodies.Tier = 1
							WeaponGoodies.Locked = false
							local FetchedWeapon = WeaponCraft:GetWeaponFromID(currentClass, Character[Namer].ID)
							if Character[Namer].CID == WeaponGoodies.CID then
								Character[Namer] = WeaponGoodies
								print("Created Tier")
							end
						end
					end
				end
			end
			
			if Character["CurrentSkin"] ~= "" then
				for name, _ in pairs(Character["CurrentSkinPieces"]) do
					Character["CurrentSkinPieces"][name] = {N = Character["CurrentSkin"].Name, P = {}, S = {}, T = {}, Q = {}}
				end
			end

			if Character.HP < 10 then
				local ClassStuff = ClassInfo:GetClassInfo(currentClass, "StartStats")
				Character.HP 					= ClassStuff[1]
				Character.Damage 				= ClassStuff[2]
				Character.Defense 				= ClassStuff[3]
				Character.Stamina				= ClassStuff[4]
				Character.Crit					= ClassStuff[5]
				Character.CritDef				= ClassStuff[6]
				print("Player had zero HP!")
			end

			if not Character["Has_Reset"] then
				Character["Has_Reset"] = true
				local ClassStuff = ClassInfo:GetClassInfo(currentClass, "StartStats") --- resets to default
				Character.CurrentLevel			= 1
				Character.HP 					= ClassStuff[1]
				Character.Damage 				= ClassStuff[2]
				Character.Defense 				= ClassStuff[3]
				Character.Stamina				= ClassStuff[4]
				Character.Crit					= ClassStuff[5]
				Character.CritDef				= ClassStuff[6]
				Character.UpgradeLevels.HP = 0
				Character.UpgradeLevels.ATK = 0
				Character.UpgradeLevels.DEF = 0
				Character.UpgradeLevels.CRT = 0
				Character.UpgradeLevels.CRD = 0
				Character.UpgradeLevels.STA = 0
				Character.EXP += Character.EXPUsed
				Character.EXPUsed = 0
				Character.SkillPoints = 0
				for i = 1, #Character.Skills do
					local Skill = Character.Skills[i]
					local SkillData = ClassInfo:GetSkillInfo(Skill.Name)
					if SkillData then
						if Skill.Name == SkillData.Name and Skill.Unlocked then
							if SkillData.PercentageIncrease == nil then
								print("Character Trait")
							else
								Skill.Rank = 0
								print("Resetted skill")
							end
						end
					end
				end
				print("SOFT RESET")
			end


			if game.PlaceId ~= 563493615 then
				local CharacterSkills = Character.Skills
				Character.Skills = ClassInfo:UpdateClassSkills(CharacterSkills, currentClass)
			end

			print("Loaded " ..currentClass)
			return Character
		end
	else
		print("Error getting ClassData -", JSON)
		return "error"
	end
	--]]
end

function getData(id, forceLoad)
	local player = Players:GetPlayerByUserId(id)
	local profile = accountProfileTemplate:LoadProfileAsync(
		string.format("%s_SaveData_Account", id),
		"ForceLoad"
	)

	if profile then
		print(profile)
		print("ACCOUNT PROFILE ^^^^")

		profile:Reconcile()
		profile:ListenToRelease(function()
			--- Releases the active class data
			if player then
				player:Kick("Another server has loaded your save. Please rejoin the game.")
			end
		end)

		if player:IsDescendantOf(Players) then
			local resultOfClassProfile = getClassData(id, profile.Data.CurrentClass)
	
			if resultOfClassProfile then
				profile.Data.Characters[profile.Data.CurrentClass] = resultOfClassProfile.Data

				return profile, resultOfClassProfile
			else
				if player then
					player:Kick("Your character data could not be loaded. Try again later.")
				end
			end
        else
            -- Player left before the profile loaded:
            profile:Release()
        end
	else
		if player then
			player:Kick("Your account data could not be loaded. Try again later.")
		end
	end

	

	--[[
	local success, JSON = pcall(function()
		local scope = DataStoreService:GetDataStore(ScopeVersion)
		local Data = scope:GetAsync(id.."SaveData")
		return Data
	end)
	if success then
		if JSON == nil then
			return nil
		else
			local JSONLoaded = DataCompressor.decompress(JSON)
			local NewJSON = HttpService:JSONDecode(JSONLoaded)
			local ClassData = getClassData(id, NewJSON.CurrentClass)
			if ClassData == "error" then
				return "error"
			else
				if ClassData ~= nil then
					NewJSON.Characters[NewJSON.CurrentClass] = ClassData		
					return NewJSON
				else
					return NewJSON, "No Character Found"
				end
			end
		end
	else
		print("Error getting Data -", JSON)
		return "error"
	end
	--]]
end

function saveData(id, Player, RemoveGuild, i)
	local PlayerStat = PlayerManager:GetPlayerStat(id)
	if PlayerStat and Check(PlayerStat.StoryProgression, "1") then
		local CombatState = PlayerManager:GetCombatState(id)
		if CanSave and not PVP then
			local Ply 		= Player or nil
			local Remove = RemoveGuild and RemoveGuild or false
			local CanUpload = false
			if tick()-CombatState.LastSave > 30 then
				CombatState.LastSave = tick()
				if PlayerStat.Guild ~= "" then
					local Guild = Guilds:GetGuild(PlayerStat.Guild)
					if Guild then
						local GuildName = Guild.Name
						if Guild.Owner == id then
							Guilds:SaveGuildData(GuildName, true)
							if Remove then
								Guilds:RemoveGuild(GuildName)
							end
						end
					end
					if Ply then
						FS.spawn(function()
							for i = 1, #TeleportQueues do
								if TeleportQueues[i] and TeleportQueues[i].Name == PlayerStat.Guild then
									for v = 1, #TeleportQueues[i].Members do
										local Member = TeleportQueues[i].Members[v]
										if Member.Name == Ply.Name then
											tbr(TeleportQueues.Members, v)
											break
										end
									end
								end
							end
						end)
					end
				end
				
				local CurrentClassInfo = PlayerStat.Characters[PlayerStat.CurrentClass]
				local CompressedString1 = HttpService:JSONEncode(CurrentClassInfo)
				local ClassJSON = DataCompressor.compress(CompressedString1)
				
				local TempClassNameRepository = {}
				
				for ClassName, ClassData in pairs(PlayerStat.Characters) do
					local Dat = {} 
					Dat.Name = ClassName
					Dat.Data = ClassData
					tbi(TempClassNameRepository, Dat)
				end
				
				PlayerStat.Characters = {}

				for _,TempClass in ipairs(TempClassNameRepository) do
					PlayerStat.Characters[TempClass.Name] = TempClass.Name
				end
				
				local CompressedString2 = HttpService:JSONEncode(PlayerStat)
				local JSON = DataCompressor.compress(CompressedString2)
				
				local JSONCount = string.len(JSON)
				
				local ClassJSONCount = string.len(ClassJSON)
				
				print("Account Data capacity: " ..JSONCount.. " / 260k\t\t Compression Rate: " .. Floor(JSONCount/string.len(CompressedString2) * 100) .. "%")
				print("Character (" ..PlayerStat.CurrentClass.. ") Data capacity: " ..ClassJSONCount.. " / 260k\t\t Compression Rate: " .. Floor(ClassJSONCount/string.len(CompressedString1) * 100).."%")
				
				PlayerStat.Characters = {}
				
				for i = 1, #TempClassNameRepository do
					PlayerStat.Characters[TempClassNameRepository[i].Name] = TempClassNameRepository[i].Data
				end
				
				if Ply ~= nil and CanUpload then
					local success, mess = pcall(function()
						GlobalDatabase:PostAsync(Ply.Name, JSON)
					end)
					if success then
						print("Successfully uploaded user " ..Ply.Name.. " to Google Spreadsheets")
					else
						print(mess)
					end
				end
				
				if JSONCount and ClassJSONCount <= 260000 then
					local success, errorMessage = pcall(function()
						local scope = DataStoreService:GetDataStore(ScopeVersion)
						scope:UpdateAsync(id.."SaveData", function(oldJSON)
							local newJSON 	= oldJSON or nil
							newJSON 		= JSON
							return 			newJSON
						end)
					end)
					local success2, errorMessage2 = pcall(function()
						local scope = DataStoreService:GetDataStore(ScopeVersion)
						scope:UpdateAsync(id.."SaveData"..PlayerStat.CurrentClass, function(oldJSON)
							local newJSON 	= oldJSON or nil
							newJSON 		= ClassJSON
							return 			newJSON
						end)
					end)
					if not success or not success2 then
						Sockets:Emit("SendMessage", nil, nil, "Error in saving User " ..id.. " data: " ..errorMessage, true)
						print(errorMessage)
						return "error"
					else
						print("saved to " ..id.. "SaveData for scope version " ..ScopeVersion)
						return "saved"
					end
				else
					Sockets:Emit("SendMessage", nil, nil, "Error in saving User " ..id.. ". Save exceeds 260k limit! Please contact the developer!", true)
				end
				
				PlayerManager:UpdateCombatState(id, CombatState)
			else
				Sockets:Emit("SendMessage", nil, nil, "User " ..id.. " already saved their progress within 30 seconds. Please try again later!", true)
				print("Already saved within 30 seconds!")
			end
		else
			warn("Saving is disabled!")
		end
	else
		Sockets:Emit("SendMessage", nil, nil, "Error: No saved data found for User " ..id, true)
		return "no saved data found"
	end
end

script.Parent.Bindables.ForceSaveAll.Event:Connect(function()
	---
end)

script.Parent.Bindables.SaveDataOfPlayer.OnInvoke = function(id, playerObject, bool)
	---
end

function NewCostume(name)
	local Suit = {}
	Suit.Name = name
	return Suit
end

function requestNewCharacter(tb, class, id)
	--[[ Only applicable to new characters. ]]--
	
	local ClassStuff = ClassInfo:GetClassInfo(class, "StartStats")
	local Costume = NewCostume(class.."Suit")
	local FetchedWeapon = WeaponCraft:GetWeapon(class, "Default")
	tb[class] 						= GetCharacterTemplate()
	tb[class].CurrentSkinPieces		= {
		Head = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		UpperTorso = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		LowerTorso = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		LeftUpperArm = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		LeftLowerArm = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		LeftHand = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		RightUpperArm = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		RightLowerArm = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		RightHand = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		LeftUpperLeg = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		LeftLowerLeg = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		LeftFoot = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		RightUpperLeg = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		RightLowerLeg = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}},
		RightFoot = {N = class.."Suit", P = {}, S = {}, T = {}, Q = {}}
	}
	tb[class].CurrentClass			= class
	tb[class].CurrentLevel 			= 1
	tb[class].EXP 					= 0
	tb[class].SkillPoints			= 0
	tb[class].EXPUsed				= 0
	tb[class].SkillPointsUsed		= 0
	tb[class].HP 					= ClassStuff[1]
	tb[class].Damage 				= ClassStuff[2]
	tb[class].Defense 				= ClassStuff[3]
	tb[class].Stamina				= ClassStuff[4]
	tb[class].Crit					= ClassStuff[5]
	tb[class].CritDef				= ClassStuff[6]
	tb[class].Gemstone1 			= nil
	tb[class].Gemstone2 			= nil
	tb[class].Gemstone3 			= nil
	tb[class].Skins 				= {Costume}
	tb[class].Skills 				= ClassStuff[7]
	tb[class].Inventory				= {}
	tb[class].WeaponInventory		= {}
	tb[class].TrophyInventory		= {}
	
	local NewWeapon = WeaponCraft:CreateWeapon(FetchedWeapon, tb[class].WeaponInventory)
	tbi(tb[class].WeaponInventory, NewWeapon)
	tb[class].CurrentWeapon		 	= NewWeapon

	local NewTrophy = WeaponCraft:CreateWeapon(WeaponCraft:GetTrophyFromID("Null", 1), tb[class].TrophyInventory)
	NewTrophy.Map = "Null"

	tbi(tb[class].TrophyInventory, NewTrophy)
	tb[class].CurrentTrophy			= NewTrophy
	tb[class].GemInventory			= {}
	tb[class].Poses					= {}
	print("Created new character data class: " ..class.. " for user ID " ..id)
end

function AwardBadge(PlayerId, BadgeId)
	--table.insert(PlayerStats[PlayerId].Achievements, BadgeId)
	local success, message = pcall(function()
		BadgeService:AwardBadge(PlayerId, BadgeId)
	end)
	if message then
		print(message)
	end
end

function CheckBadge(PlayerId, BadgeId)
	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(PlayerId, BadgeId)
	end)
	if success then
		return hasBadge
	end
end

script.Parent.Bindables.RewardAchievement.Event:Connect(function(tbl, id)
	RewardAchievement(tbl, id)
end)

function ObjectiveUpdate(ObjectiveName)
	script.ObjectiveUpdate:Fire(ObjectiveName)
end

function Check(List, StoryElement)
	for _,Element in ipairs(List) do
		if typeof(Element) == typeof(StoryElement) then
			if Element == StoryElement then
				return true
			end
		end
	end
	return false
end

--[[ Script Init ]]--

PhysicsService:CreateCollisionGroup(PlayerCollisionGroupName)
PhysicsService:CollisionGroupSetCollidable(PlayerCollisionGroupName, PlayerCollisionGroupName, false)

game:BindToClose(function()
	local PlayerStats = PlayerManager:FetchPlayerStats()
	while #PlayerStats > 0 do
		forceSaveAll()
		wait()
	end
end)
					
local SubscribeSuccess, SubscribeError = pcall(function()
	MessagingService:SubscribeAsync("TeleportQueueUpdate", function(ServiceData)
		local PlayObj = HttpService:JSONDecode(ServiceData.Data)
		local SentTick = ServiceData.Sent
		if PlayObj then
			for i = 1, #TeleportQueues do
				local Guild = TeleportQueues[i]
				if Guild.Name == PlayObj.Guild then
					local NotFound = true
					for v = 1, #Guild.Members do
						local Member = Guild.Members[v]
						if Member.Name == PlayObj.Name then
							NotFound = false
							break
						end
					end
					if NotFound then
						Guild.Timer = 30
						tbi(Guild.Members, PlayObj)
						for v = 1, #Guild.Members do
							local Member = Guild.Members[v]
							if Member.PlayerObj then
								Sockets:GetSocket(Member.PlayerObj):Emit("TeleportQueueUpdate", Guild.Members)
							end
						end
					end
					break
				end
			end
		end
	end)
end)
local SubscribeSuccess2, SubscribeError2 = pcall(function()
	MessagingService:SubscribeAsync("TeleportQueueMake", function(ServiceData)
		local PlayObj = HttpService:JSONDecode(ServiceData.Data)
		local SentTick = ServiceData.Sent
		if PlayObj then
			local NotFound = true
			for i = 1, #TeleportQueues do
				local Guild = TeleportQueues[i]
				if Guild then
					if Guild.Name == PlayObj.Name then
						NotFound = false
						break
					end
				end
			end
			if NotFound then
				tbi(TeleportQueues, PlayObj)
			end
		end
	end)
end)
local SubscribeSuccess3, SubscribeError3 = pcall(function()
	MessagingService:SubscribeAsync("TeleportQueueRemove", function(ServiceData)
		local PlayObj = HttpService:JSONDecode(ServiceData.Data)
		local SentTick = ServiceData.Sent
		local NotFound = true
		if PlayObj then
			for i = 1, #TeleportQueues do
				local Guild = TeleportQueues[i]
				if Guild.Name == PlayObj.Guild then
					for v = 1, #Guild.Members do
						local Member = Guild.Members[v]
						if Member.Name == PlayObj.Name and PlayObj.PlayerObj == nil then
							tbr(Guild.Members, v)
						end
					end
					for v = 1, #Guild.Members do
						local Member = Guild.Members[v]
						if Member.PlayerObj then
							Sockets:GetSocket(Member.PlayerObj):Emit("TeleportQueueUpdate", Guild.Members)
						end
					end
					break
				end
			end
		end
	end)
end)
MarketplaceService.ProcessReceipt = function(receiptInfo)
	-- Determine if the product was already granted by checking the data store  
	local purchaseHistoryStore = DataStoreService:GetDataStore(PurchaseHistoryScope)
	
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	-- If purchase was recorded, the product was already granted
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	-- Find the player who made the purchase in the server
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- The player probably left the game
		-- If they come back, the callback will be called again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Look up handler function from 'productFunctions' table above
	local handler = function(receipt, player)
		local PlayerStat = PlayerManager:GetPlayerStat(player.UserId)
		if PlayerStat and CanSave then
			local Amnt = 0
			if receipt.ProductId == 81178418 then
				 Amnt = 500
			elseif receipt.ProductId == 53289603 then
				Amnt = 1000
			elseif receipt.ProductId == 53289647 then
				Amnt = 2100
			elseif receipt.ProductId == 53289672 then
				Amnt = 4400
			elseif receipt.ProductId == 53289710 then
				Amnt = 9200
			elseif receipt.ProductId == 53289778 then
				Amnt = 19200
			elseif receipt.ProductId == 53289820 then
				Amnt = 40000
			end
			if Amnt > 0 then
				local Found = false
				for i = 1, #Contributors do
					if Contributors[i].ID == player.UserId then
						Contributors[i].Amnt = Contributors[i].Amnt + Amnt
						Found = true
					end
				end
				if not Found then
					local New = {}
					New.ID = player.UserId
					New.Amnt = Amnt
					tbi(Contributors, New)
				end
				PlayerStat.Tears += Amnt
				Sockets:GetSocket(player):Emit("DeveloperProductSuccess", PlayerStat, Amnt)
				return true
			end
		end
	end
 
	-- Call the handler function and catch any errors
	local success, result = pcall(handler, receiptInfo, player)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", player)
		Sockets:GetSocket(player):Emit("Hint", "Error occurred while processing a product purchase.")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		-- Record transaction in data store so it isn't granted again
		local success, errorMessage = pcall(function()
			purchaseHistoryStore:SetAsync(playerProductKey, true)
		end)
		if not success then
			error("Cannot save purchase data: " .. errorMessage)
		end
	 
		-- IMPORTANT: Tell Roblox that the game successfully handled the purchase
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end


--[[ Socket Init ]]--

local SuspiciousPlyrs = {}
local SocketCodes = {}
local MaxPlayers = 40

for _, socketCode in ipairs(script.Parent.SocketCode:GetChildren()) do
	table.insert(SocketCodes, require(socketCode))
end

Sockets.Connected:Connect(function(Socket)
	local Player 	 	= Socket.Player
	local id 		 	= Player.UserId
	
	PlayerManager:UpdateCombatState(id)
	
	for _, logic in ipairs(SocketCodes) do
		logic:Init(Socket)
	end
	
	--[[Gameplay functions]]--

	
	Socket:Listen("Quit", function()
		Player:Kick("We kicked you cause the game did not work properly :(")			
	end)
	
	Socket:Listen("PreloadAssets", function()
		return getAssets()
	end)
	
	--[[Stat management]]--
	
	Socket:Listen("Story", function(val)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local storyElement = tostring(val)

		if not table.find(PlayerStat.StoryProgression, storyElement) then
			tbi(PlayerStat.StoryProgression, storyElement)
			print(#PlayerStat.StoryProgression)
		end

		print(#PlayerManager:GetPlayerProfile(id).Data.StoryProgression)
	end)
	
	local function CheckForItem(Namer)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		for _, Item in ipairs(PlayerStat.ItemBox) do
			if Item.Name == Namer then
				return true
			end
		end
		return false
	end
	local function RemoveItem(Namer, AlsoRemoveFromPurchase)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local PurchaseToo = AlsoRemoveFromPurchase or false
		for i, Item in ipairs(PlayerStat.ItemBox) do
			print(Item)
			if Item.Name == Namer then
				tbr(PlayerStat.ItemBox, i)
				break
			end
		end
		if PurchaseToo and PlayerStat.Purchases[Namer] then
			PlayerStat.Purchases[Namer] = nil
		end
	end
	
	Socket:Listen("RedeemItem", function(Name, DeleteMode)
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local currentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
		
		if DeleteMode then
			RemoveItem(Name)
		else
			if CombatState.Redeeming == false and typeof(Name) == "string" and CheckForItem(Name) and os.time()-CombatState.MailboxSwap >= 1 then
				CombatState.MailboxSwap = os.time()
				CombatState.Redeeming = true
				PlayerManager:UpdateCombatState(id, CombatState)

				if Name == "Shipment Received: Whetstones" then
					local new1 = LootInfo:MakeItem(18, PlayerStat.Inventory, 99)
					local new2 = LootInfo:MakeItem(19, PlayerStat.Inventory, 99)
					local new3 = LootInfo:MakeItem(20, PlayerStat.Inventory, 99)
					tbi(PlayerStat.Inventory, new1)
					tbi(PlayerStat.Inventory, new2)
					tbi(PlayerStat.Inventory, new3)
					Socket:Emit("Hint", "Obtained whetstones!")
					CombatState.Redeeming = false
				end

				if Name == "Shipment Received: Early Access Costumes" then
					local hasCostumes = false
					for _, Costume in ipairs(PlayerStat.Characters[PlayerStat.CurrentClass].Skins) do
						if Costume.Name == "FMoltenValianceArmor" then
							hasCostumes = true
						end
					end
					if not hasCostumes then
						local Costume = NewCostume("FMoltenValianceArmor")
						tbi(currentClass.Skins, Costume)
						local Costume = NewCostume("MMoltenValianceArmor")
						tbi(currentClass.Skins, Costume)
						local Costume = NewCostume("FValianceArmor")
						tbi(currentClass.Skins, Costume)
						local Costume = NewCostume("MValianceArmor")
						tbi(currentClass.Skins, Costume)
						Socket:Emit("Hint", "Obtained Early Access costumes!")
					else
						Socket:Emit("Hint", "Cannot obtain this reward on the same character!")
					end
					CombatState.Redeeming = false
				elseif Name == "Shipment Received: Strongback Perk" then
					PlayerStat.InventorySpace = PlayerStat.InventorySpace + 50
					RemoveItem(Name)
					CombatState.Redeeming = false
					Socket:Emit("Hint", "Strongback Perk has been added.")
				elseif Name == "Shipment Received: Character Stat Reset Scroll" then
					if currentClass.CurrentLevel >= 10 then
						local ClassStuff = ClassInfo:GetClassInfo(PlayerStat.CurrentClass, "StartStats") --- resets to default
						currentClass.CurrentLevel			= 1
						currentClass.HP 					= ClassStuff[1]
						currentClass.Damage 				= ClassStuff[2]
						currentClass.Defense 				= ClassStuff[3]
						currentClass.Stamina				= ClassStuff[4]
						currentClass.Crit					= ClassStuff[5]
						currentClass.CritDef				= ClassStuff[6]
						
						currentClass.UpgradeLevels.HP = 0
						currentClass.UpgradeLevels.ATK = 0
						currentClass.UpgradeLevels.DEF = 0
						currentClass.UpgradeLevels.CRT = 0
						currentClass.UpgradeLevels.CRD = 0
						currentClass.UpgradeLevels.STA = 0
						
						currentClass.EXP += currentClass.EXPUsed
						currentClass.EXPUsed = 0
						
						currentClass.SkillPoints = 0
						
						for i = 1, #currentClass.Skills do
							local Skill = currentClass.Skills[i]
							local SkillData = ClassInfo:GetSkillInfo(Skill.Name)
							if Skill.Name == SkillData.Name and Skill.Unlocked then
								if SkillData.PercentageIncrease == nil then
									print("Character Trait")
								else
									Skill.Rank = 0
									print("Resetted skill")
								end
							end
						end
						
						RemoveItem(Name, true)
						Socket:Emit("Hint", "Your character stats has been reset.")
					else
						Socket:Emit("Hint", "Your character is too low level to stat reset!")
					end
					CombatState.Redeeming = false
				elseif Name == "Shipment Received: Early Access Headstart Tome" or Name == "Shipment Received: Starter Kit Learning Tome" then
					if currentClass.EXP >= 100000 then
						CombatState.Redeeming = false
						Socket:Emit("Hint", "Cannot use Tome on a character over 100,000 EXP!")
						return
					end
					
					if currentClass.CurrentLevel >= 30 then
						Socket:Emit("Hint", "Cannot use Tome on a character over Lv.30!")
					else
						currentClass.EXP = currentClass.EXP + 476600
						RemoveItem(Name)
						Socket:Emit("Hint", "Headstart Tome consumed!")
					end
					CombatState.Redeeming = false
				elseif Name == "Shipment Received: Unlock Characters Advanced Tome" then
					if currentClass.EXP >= 450000 then
						CombatState.Redeeming = false
						Socket:Emit("Hint", "Cannot use Tome on a character over 450,000 EXP!")
						return
					end
					
					if currentClass.CurrentLevel >= 60 then
						Socket:Emit("Hint", "Cannot use Tome on a character over Lv.60!")
					else
						currentClass.EXP = currentClass.EXP + 1572000
						RemoveItem(Name)
						Socket:Emit("Hint", "Headstart Tome consumed!")
					end
					CombatState.Redeeming = false
				elseif Name == "Shipment Received: Early Access Banner" then
					table.insert(PlayerStat.Titles, "EarlyAccessAni")
					RemoveItem(Name)
					CombatState.Redeeming = false
					Socket:Emit("Hint", "New Banner Obtained: Early Access Animated")
				elseif Name == "Shipment Received: Early Access Money Bags" then
					PlayerStat.Gold += 100000
					PlayerStat.Tears += 3500
					RemoveItem(Name)
					CombatState.Redeeming = false
					Socket:Emit("Hint", "3,500 Tears and 100,000 Gold Obtained!")
				elseif Name == "Shipment Received: Starter Kit Tear Bag" then
					PlayerStat.Tears += 1500
					RemoveItem(Name)
					CombatState.Redeeming = false
					Socket:Emit("Hint", "1,500 Tears Obtained!")
				elseif Name == "Shipment Received: Unlock Characters Tear Bag" then
					PlayerStat.Tears += 13000
					RemoveItem(Name)
					CombatState.Redeeming = false
					Socket:Emit("Hint", "13,000 Tears Obtained!")
				elseif Name == "Shipment Received: Early Access Chat Title" then
					if not table.find(PlayerStat.ChatTitles, "Trailblazer") then
						tbi(PlayerStat.ChatTitles, "Trailblazer")
					end
					RemoveItem(Name)
					CombatState.Redeeming = false
					Socket:Emit("Hint", "New Title Obtained: Trailblazer")
				end
				
				PlayerManager:UpdateCombatState(id, CombatState)
				return PlayerStat, PlayerStat.Characters[PlayerStat.CurrentClass]
			end
		end
	end)
	
	Socket:Listen("NewGameButtonPress", function()
		--- If save already found, teleport directly to the lobby
		local PlayerStat = PlayerManager:GetPlayerProfile(id)
		PlayerStat.Data.LastReserveCode = "Returning"
		PlayerStat.Data.LastReserveTime = os.time()
		PlayerStat:Release()
		TeleportService:Teleport(game.PlaceId == 563493615 and 5228777299 or 4666288269, Player)
	end)
	
	Socket:Listen("PCallLoadStats", function()
		--[[
			This function is important. It is first called whenever a player joins the place.
			It will also retry if something errors, such as datastores being down.
		--]]
		
		script.Parent.SecurityCheck.SecurityConfirm:Fire(Player)
		if script.Maintenance.Value and Player.Name ~= "Player1" and Player.Name ~= "Swordphin123" then
			return "maintenance"
		else
			if script.DataDebug.Value == false then
				print("PCallLoad Called!")
				
				local FindPlayerID = id -- == -1 and 1225259 or id == -2 and 20118200 or 297701
				
				if CanSave and (game.PlaceId == 563493615 or game.PlaceId == 5228777299 or game.PlaceId == 6092293455) then
					FindPlayerID = id
				end

				local values = ReplicatedStorage.PlayerValues:FindFirstChild(Player.Name)

				if not values then
					local newValues = ReplicatedStorage.PlayerValues["Default_CharacterValues"]:Clone()
					newValues.Name = Player.Name
					newValues.Parent = ReplicatedStorage.PlayerValues
				end

				local Achievementer = Achievements:GetAchievementList()
				local profile, characterProfile = getData(FindPlayerID)	
				local data = profile.Data
				local CombatState = PlayerManager:GetCombatState(id) --- Creates a new combat state
				local LoadInstantly = {IsReserved = false, BackFromBattle = false}

				CombatState.ActiveCharacterProfile = characterProfile

				if data and (profile.Data.CurrentClass == "" or profile.Data.CurrentClass == "Null" or not table.find(profile.Data.StoryProgression, "1")) then 
					---- For new players 

					--- Makes sure the player hasn't been teleported back to the main menu somehow...
					local JoinData = Player:GetJoinData()
					if JoinData.TeleportData == nil and (game.PlaceId == 785484984 or game.PlaceId == 563493615) then
						print("In Solo Place")

						--- Create new temporary 'Null' introduction character
						local newData = GetBaseTemplate()
						newData.CurrentClass = "Null"
						requestNewCharacter(newData.Characters, newData.CurrentClass, id)

						profile.Data = newData
						profile:Reconcile()

						PlayerManager:UpdatePlayerStat(id, profile) --- bake the profile
						
						--- Launch the Introduction sequences
						Map = MatchMaking:GetMap("Introduction")
						MaxPlayers = 1
						Difficulty = false
						script.Parent.Bindables.SelectMapPrefix:Fire(Map)

						CombatState.Ready = true
						local PlyChar = Player.Character or Player.CharacterAdded:Wait()
						PlyChar.Parent = workspace.Players
						setCollisionGroupRecursive(PlyChar)
					end

					return nil, LoadInstantly, 0
				end

				if characterProfile then
					if characterProfile.Data.CurrentLevel < 0 then
						print("Created new character")
						requestNewCharacter(profile.Data.Characters, profile.Data.CurrentClass, id)
						CombatState.ActiveCharacterProfile.Data = profile.Data.Characters[profile.Data.CurrentClass]
					end
				end

				--- Fill in any new achievements
				for _, Ach in ipairs(Achievementer) do
					local Found = false

					for i = 1, #profile.Data.Achievements do
						local Current = profile.Data.Achievements[i]
						if Current.I == Ach.ID then
							Found = true
							break
						end
					end
					
					if not Found then
						local NewAch = Achievements:CreateAchievement(Ach.ID)

						print(string.format("Installed Achievement ID %s", NewAch.I))
						tbi(profile.Data.Achievements, NewAch)
					end
				end
				
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				
				---- put these stuff in their own functions if we want to see if they purchased mid-game
				
				if CheckBadge(id, 706883002) then
					if data.Purchases["Shipment Received: Early Access Costumes"] == nil then
						data.Purchases["Shipment Received: Early Access Costumes"] = true
						tbi(data.ItemBox, ItemboxModule:GiveItem("Shipment Received: Early Access Costumes"))
					end

					if data.Purchases["Shipment Received: Early Access Banner"] == nil then
						data.Purchases["Shipment Received: Early Access Banner"] = true
						local item = ItemboxModule:GiveItem("Shipment Received: Early Access Banner")
						tbi(data.ItemBox, item)
					end
					
					if data.Purchases["Shipment Received: Early Access Headstart Tome"] == nil then
						data.Purchases["Shipment Received: Early Access Headstart Tome"] = true
						local item = ItemboxModule:GiveItem("Shipment Received: Early Access Headstart Tome")
						tbi(data.ItemBox, item)
					end
					
					if data.Purchases["Shipment Received: Early Access Money Bags"] == nil then
						data.Purchases["Shipment Received: Early Access Money Bags"] = true
						local item = ItemboxModule:GiveItem("Shipment Received: Early Access Money Bags")
						tbi(data.ItemBox, item)
					end
					
					if data.Purchases["3 Character Resets"] == nil then
						data.Purchases["3 Character Resets"] = true
						for i = 1, 3 do
							local item = ItemboxModule:GiveItem("Shipment Received: Character Stat Reset Scroll")
							tbi(data.ItemBox, item)
						end
					end
					
					if data.Purchases["Shipment Received: Early Access Chat Title"] == nil then
						data.Purchases["Shipment Received: Early Access Chat Title"] = true
						local item = ItemboxModule:GiveItem("Shipment Received: Early Access Chat Title")
						tbi(data.ItemBox, item)
					end
				end
				
				if CheckGamePass(Player, 2059326) then
					if data.Purchases["SKLT"] == nil then -- Starter Kit Learning Tome
						data.Purchases["SKLT"] = true
						local item = ItemboxModule:GiveItem("Shipment Received: Starter Kit Learning Tome")
						tbi(data.ItemBox, item)
					end
					
					if data.Purchases["SKTB"] == nil then -- Starter Kit Tear Bag
						data.Purchases["SKTB"] = true
						local item = ItemboxModule:GiveItem("Shipment Received: Starter Kit Tear Bag")
						tbi(data.ItemBox, item)
					end
				end
				
				if CheckGamePass(Player, 2229858) then
					if data.Purchases["UANCTB"] == nil then -- Unlock All Normal Characters Tear Bag
						data.Purchases["UANCTB"] = true
						local item = ItemboxModule:GiveItem("Shipment Received: Unlock Characters Tear Bag")
						tbi(data.ItemBox, item)
					end
					
					if data.Purchases["UANCAT"] == nil then -- Unlock All Normal Characters Advanced Tome
						data.Purchases["UANCAT"] = true
						local item = ItemboxModule:GiveItem("Shipment Received: Unlock Characters Advanced Tome")
						tbi(data.ItemBox, item)
					end
				end
				
				if CheckGamePass(Player, 6845594) then
					if data.Purchases["Shipment Received: Strongback Perk"] == nil then
						local StrongBackItem = ItemboxModule:GiveItem("Shipment Received: Strongback Perk")
						data.Purchases["Shipment Received: Strongback Perk"] = true
						tbi(data.ItemBox, StrongBackItem)
					end
				end

				local LoginItemboxes = {						
				}
				for x = 1, #LoginItemboxes do
					local NewItem = LoginItemboxes[x]
					if data.Purchases[NewItem] == nil then						----- should remove the item from Purchases if they redeem it from mailbox
						local ItemBox = ItemboxModule:GiveItem(NewItem)
						data.Purchases[NewItem] = true
						tbi(data.ItemBox, ItemBox)
						print("Gave player: ", NewItem)
					end
				end
				
				
				if id == 297701 or id == 1225259 or id == 20118200 then
					data.Tears = 9999
				end
				
				
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------------------
				
				pcall(function()
					if Player:IsInGroup(3451727) or Player:IsInGroup(448936) then
						AwardBadge(id,709408319)
					end
				end)
				
				if ReservedServer then
					if data.LastReserveCode == "TeleportQueue" and os.time()-data.LastReserveTime <= 600 then
						LoadInstantly.IsReserved = true
						LoadInstantly.BackFromBattle = true
						--Socket:Emit("SendMessage", nil, nil, "This is a private Guild Server. No new users will join.", true)
						Map = nil
						script.Parent.Bindables.SelectMapPrefix:Fire(Map)
					else
						local ReserveServer = MatchMaking:GetReserveDetails(data.LastReserveCode, data.LastReserveTime)
						if ReserveServer ~= nil then
							if Map == nil then
								TerrainSaveLoad:Load(ReplicatedStorage.Environments.Terrains.TrainStation)
							end
							print("Found Server!")
							Map = ReserveServer.Map
							script.Parent.Bindables.SelectMapPrefix:Fire(Map)
							MaxPlayers = ReserveServer.MaxPlayers
							Difficulty = ReserveServer.EveryoneMustDie and "EveryoneMustDie" or ReserveServer.Difficulty
							GameLogic:Difficulty_Change(Difficulty)
							PVP = ReserveServer.PVP and ReserveServer.PVP or nil
							script.Parent.Bindables.AddPVPTable:Fire(PVP)
							LoadInstantly.IsReserved = true
						end
					end
				end
				
				PlayerManager:UpdatePlayerStat(id, profile) --- bake the profile

				local PlayerStat = PlayerManager:GetPlayerStat(id)			
				if PlayerStat.LastReserveCode == "Returning" and os.time()-PlayerStat.LastReserveTime <= 600 then
					LoadInstantly.IsReserved = true
					LoadInstantly.BackFromBattle = true
				end
				PlayerStat.LastReserveCode = nil
				PlayerStat.LastReserveTime = 0
				if SoloTest then
					LoadInstantly.IsReserved = true
					LoadInstantly.BackFromBattle = false
				end

				--- Daily / Weekly missions
				local hourOffset = -3
				local offset = (60 * 60 * hourOffset) 
				local day = math.floor((SyncTime.time() + offset) / (60 * 60 * 24)) 
				local week = math.floor((SyncTime.time() + offset) / (60 * 60 * 24 * 7)) 

				if PlayerStat.DailyDay ~= day then
					PlayerStat.DailyDay = day
					table.clear(PlayerStat.DailyAchievements)
					local maxDailies = 3
					local availableDailies = {} do
						for _, achievement in ipairs(Achievementer) do
							for _, playerAch in ipairs(PlayerStat.Achievements) do
								if achievement.Attributes and achievement.ID == playerAch.I then
									if table.find(achievement.Attributes, "Daily") then
										table.insert(availableDailies, achievement.ID)
									end
								end
							end
						end
					end

					while #PlayerStat.DailyAchievements < maxDailies do
						local randomIndex = Rand:NextInteger(1, #availableDailies)
						local randomAchievementID = availableDailies[randomIndex]
						for _, playerAch in ipairs(PlayerStat.Achievements) do
							if playerAch.I == randomAchievementID then
								playerAch.V = 0
								playerAch.C = 0
							end
						end

						table.insert(PlayerStat.DailyAchievements, randomAchievementID)
						table.remove(availableDailies, randomIndex)
					end
				end

				if PlayerStat.WeeklyDay ~= week then
					PlayerStat.WeeklyDay = week
					table.clear(PlayerStat.WeeklyAchievements)
					local maxWeeklies = 3
					local availableWeeklies = {} do
						for _, achievement in ipairs(Achievementer) do
							for _, playerAch in ipairs(PlayerStat.Achievements) do
								if achievement.Attributes and achievement.ID == playerAch.I then
									if table.find(achievement.Attributes, "Weekly") then
										table.insert(availableWeeklies, achievement.ID)
									end
								end
							end
						end
					end

					while #PlayerStat.WeeklyAchievements < maxWeeklies do
						local randomIndex = Rand:NextInteger(1, #availableWeeklies)
						local randomAchievementID = availableWeeklies[randomIndex]
						for _, playerAch in ipairs(PlayerStat.Achievements) do
							if playerAch.I == randomAchievementID then
								playerAch.V = 0
								playerAch.C = 0
							end
						end

						table.insert(PlayerStat.WeeklyAchievements, randomAchievementID)
						table.remove(availableWeeklies, randomIndex)
					end
				end
				
				if PVP then
					PlayerStat.Characters[PlayerStat.CurrentClass].Gemstone1 = nil
					PlayerStat.Characters[PlayerStat.CurrentClass].Gemstone2 = nil
					PlayerStat.Characters[PlayerStat.CurrentClass].Gemstone3 = nil
					local FetchedWeapon = WeaponCraft:GetWeapon(PlayerStat.CurrentClass, "Default")
					local NewWeapon = WeaponCraft:CreateWeapon(FetchedWeapon, {})
					local NewTrophy = WeaponCraft:CreateWeapon(WeaponCraft:GetTrophyFromID("Null", 1), {})
					PlayerStat.Characters[PlayerStat.CurrentClass].CurrentWeapon = NewWeapon
					NewTrophy.Map = "Null"
					PlayerStat.Characters[PlayerStat.CurrentClass].CurrentTrophy = NewTrophy
				end

				if PlayerStat.ChatTitle ~= "" then
					local Speaker = ChatService:GetSpeaker(Player.Name)
					Speaker:SetExtraData("Tags", {{TagText = PlayerStat.ChatTitle, TagColor = Titles:GetTitle(PlayerStat.ChatTitle).Color}})
				end

				PlayerManager:UpdateCombatState(id, CombatState)
				RewardAchievement({}, id, true)

				return true, LoadInstantly, PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel
			end

			return "error"
		end
	end)

	Socket:Listen("ResetPlayer", function()
		Player.TeamColor = Teams.Lobby.TeamColor
		Player:LoadCharacter()
	end)
	
	Socket:Listen("RequestNewGame", function(choice)
		if choice == "A" or choice == "B" or choice == "C" then
			local class = ""
			local data = GetBaseTemplate()
			if choice == "A" then class = "DarwinB"
			elseif choice == "B" then class = "Valeri" 
			else class = "Red"end
			data.Gold = 0
			data.Tears = 0
			data.WeaponLevel = 0
			data.ArmorLevel = 0
			data.PremiumExpiration = os.time() + 2592000 --formula to get premium days: ((data.PremiumExpiration-os.time())/86400)
			data.CurrentClass = class

			if id == 20118200 or Player.Name == "Swordphin123" then
				data.Titles = {"DefBan", "EpiAni", "EpiPersona"}
				data.ChatTitles = {"Developer", "Trailblazer"}
			else
				data.Titles = {"DefBan"}
			end

			requestNewCharacter(data.Characters, class, id)

			local PlayerStat = PlayerManager:GetPlayerProfile(id)
			PlayerStat.Data = data
			PlayerStat:Reconcile()

		--	AwardBadge(id,706883002)  ---- EARLY ACCESS BADGE
			print("New Game generated for user " ..id)

			workspace.Interactables.Lootbox1.Parent = workspace
			workspace.Interactables.Lootbox2.Parent = workspace
			workspace.Interactables.Lootbox3.Parent = workspace
			workspace.Door.Main.CanCollide = false
			workspace.Door.Door2.CanCollide = false
			workspace.Door.Door1.CanCollide = false
		else
			Player:Kick("Something went wrong!")
		end
	end)
	
	Socket:Listen("Guild", function(Action, tbl)
		if PVP then
			return
		end
		
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		if Action == "Filter" and tbl[1] then
			return Guilds:FilterNameForPreview(tbl[1], id)
		elseif Action == "CreateGuild" and typeof(tbl) == "table" then
			if PlayerStat.Guild == "" then
				local Success, GuildSettings = Guilds:CreateGuild(tbl, Player)
				if Success == "Success" then
					PlayerStat.Guild = GuildSettings.Name
				end
				return Success, PlayerStat
			end
		elseif Action == "Info" then
			return Guilds:GetGuild(PlayerStat.Guild, true)
		elseif Action == "Perks" then
			return Guilds:GetPerks()
		elseif Action == "LeaveGuild" then
			local Guild = Guilds:GetGuild(PlayerStat.Guild)
			if Guild then
				if Guild.Owner ~= id then ----Owners can't leave for now
					local RemovingUser = Guilds:UpdateMembers(PlayerStat.Guild, id, "Remove")
					if RemovingUser == "Removed player!" then
						PlayerStat.Guild = ""
						PlayerStat.GuildXP = 0
						Socket:Emit("SendMessage", nil, nil, "You have left the guild.", true)
						return true, PlayerStat
					end
					print(RemovingUser)
				else
					if #Guild.Members <= 1 then
						Guild.Owner = -1
						Guild.Members = {}
						PlayerStat.Guild = ""
						PlayerStat.GuildXP = 0
						Guilds:SaveGuildData(Guild.Name, true)
						Socket:Emit("SendMessage", nil, nil, "You have disbanded the guild.", true)
						return true, PlayerStat
					else
						return "DisbandFirst"
					end
				end
			end
		elseif Action == "AskPlayer" then
			if Guilds:GetGuild(PlayerStat.Guild).Owner == id then
				local FetchedPlayers = Players:GetPlayers()
				for _, Plyr in ipairs(Players:GetPlayers()) do
					local Nam = string.lower(Plyr.Name)
					local OurName = string.lower(Player.Name) 
					if Nam == tbl[1] and tbl[1] ~= OurName then
						local Pid = Plyr.UserId
						local PlayerStatTarget = PlayerManager:GetPlayerStat(Pid)
						local CombatStateTarget = PlayerManager:GetCombatState(Pid)
						if PlayerStatTarget then
							if PlayerStatTarget.Guild == "" and CombatStateTarget.GuildAccept == "" then
								CombatStateTarget.GuildAccept = PlayerStat.Guild
								PlayerManager:UpdateCombatState(Pid, CombatStateTarget)
								Sockets:GetSocket(Plyr):Emit("AskToJoin", CombatStateTarget.GuildAccept)
								return true
							end
						end
					end
				end
			end
			return false
		elseif Action == "AcceptJoin" then
			if PlayerStat.Guild == "" and CombatState.GuildAccept ~= "" then
				local AddingUser = Guilds:UpdateMembers(CombatState.GuildAccept, Player.UserId, "Add")
				if AddingUser == "Added Player!" then
					PlayerStat.Guild = CombatState.GuildAccept
					CombatState.GuildAccept = ""
					PlayerManager:UpdateCombatState(id, CombatState)
					local Object = {}
					Object.Name = "[SERVICES]"
					Object.Guild = PlayerStat.Guild
					Object.Message = Player.Name.. " has joined the guild!"
					local Encoded = HttpService:JSONEncode(Object)
					local PublishSuccess, PublishResult = pcall(function()
						MessagingService:PublishAsync("GuildChat", Encoded)
					end)
				elseif AddingUser == "Max members" then
					--
				end
				print(AddingUser) --- debug message
			end
		elseif Action == "IgnoreJoin" then
			CombatState.GuildAccept = ""
			PlayerManager:UpdateCombatState(id, CombatState)
		elseif Action == "RemoveUser" then
			if Guilds:GetGuild(PlayerStat.Guild).Owner == id then
				local RemovingUser = Guilds:UpdateMembers(PlayerStat.Guild, tbl[1], "Remove")
				if RemovingUser == "Removed player!"then
					return true
				end
				print(RemovingUser) --- debug message
			end
			return false
		elseif Action == "TeleportJoin" and PlayerStat.Guild ~= "" then
			local Success, Room;
			if os.time()-CombatState.TPCD >= 60 then
				local Found = false
				for i = 1, #TeleportQueues do
					if TeleportQueues[i].Name == PlayerStat.Guild then
						if TeleportQueues[i].Timer > 0 and #TeleportQueues[i].Members < 20 then
							local FoundPlayer = false
							for v = 1, #TeleportQueues[i].Members do
								local Member = TeleportQueues[i].Members[v]
								if Member.Name == Player.Name then
									FoundPlayer = true
									Found = true
									break
								end
							end
							if not FoundPlayer then
								CombatState.TPCD = os.time()
								PlayerManager:UpdateCombatState(id, CombatState)
								Found = true
								local PlayObj = {}
								PlayObj.PlayerObj = nil
								PlayObj.Name = Player.Name
								PlayObj.Guild = PlayerStat.Guild
								local EncodeGuildSettings = HttpService:JSONEncode(PlayObj)
								TeleportQueues[i].Timer = 30
								PlayObj.PlayerObj = Player
								tbi(TeleportQueues[i].Members, PlayObj)
								local PublishSuccess, PublishResult = pcall(function()
									MessagingService:PublishAsync("TeleportQueueUpdate", EncodeGuildSettings)
								end)
								Success = true
								Room = TeleportQueues[i].Members
							else
								print("Player already in queue!")
							end
						else
							Found = true
							Success = "Full"
						end
						break
					end
				end
				if not Found then
					CombatState.TPCD = os.time()
					PlayerManager:UpdateCombatState(id, CombatState)
					local Suc, Results = pcall(function()
						local ID, PrivateID = TeleportService:ReserveServer(game.PlaceId)
						local NewQueue = {
							Name = PlayerStat.Guild,
							Members = {},
							Timer = 30,
							ReserveID = ID,
							PrivateID = PrivateID
						}
						local PlayObj = {}
						PlayObj.PlayerObj = nil
						PlayObj.Name = Player.Name
						PlayObj.Guild = PlayerStat.Guild
						local EncodeGuildSettings = HttpService:JSONEncode(PlayObj)
						PlayObj.PlayerObj = Player
						local EncodeGuildSettings2 = HttpService:JSONEncode(NewQueue)
						tbi(NewQueue.Members, PlayObj)
						tbi(TeleportQueues, NewQueue)
						Success = true
						Room = NewQueue.Members
						local PublishSuccess2, PublishResult2 = pcall(function()
							MessagingService:PublishAsync("TeleportQueueMake", EncodeGuildSettings2)
							MessagingService:PublishAsync("TeleportQueueUpdate", EncodeGuildSettings)
						end)
					end)
					if Suc then
						Success = true
					else
						Success = false
					end
				end
			else
				Success = "TPCooldown"
			end
			return Success, Room
		elseif Action == "TeleportRemove" and PlayerStat.Guild ~= "" then
			CombatState.TPCD = os.time()
			PlayerManager:UpdateCombatState(id, CombatState)
			for i = 1, #TeleportQueues do
				if TeleportQueues[i].Name == PlayerStat.Guild then
					for v = 1, #TeleportQueues[i].Members do
						local Member = TeleportQueues[i].Members[v]
						if Member.Name == Player.Name then
							tbr(TeleportQueues[i].Members, v)
							return true
						end
					end
					local PlayObj = {}
					PlayObj.Name = Player.Name
					PlayObj.Guild = PlayerStat.Guild
					local EncodeGuildSettings = HttpService:JSONEncode(PlayObj)
					local PublishSuccess, PublishResult = pcall(function()
						MessagingService:PublishAsync("TeleportQueueRemove", EncodeGuildSettings)
					end)
					break
				end
			end
		end
	end)
	
	local function BuyIt(item)
		--[[
			This function calls once player funds are confirmed and taken.
			Shop only.
		--]]
		
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local CurrentChar = PlayerStat.CurrentClass
		local typ = item.Type
		
		if typ == "Class" then
			if PlayerStat.Characters[item.Name] == nil then
				PlayerStat.Characters[item.Name] = item.Name
				print(PlayerStat.Characters[item.Name])
			end
		elseif typ == "Inventory" then
			PlayerStat.InventorySpace += 5
			return string.format("Purchased successfully! Your new maximum inventory space is %s.", PlayerStat.InventorySpace)
		elseif typ == "OutfitSlot" then
			PlayerStat.OutfitSlots += 1
			return string.format("Outfit Slot %s purchased successfully.", PlayerStat.OutfitSlots)
		elseif typ == "Item" then
			if item.Name == "Potion" then
				PlayerStat.Potions += 1
				Socket:Emit("Hint", "Purchased. You now own " ..PlayerStat.Potions.. " potions.")
			elseif item.Name == "Stamina Invigorator" then
				PlayerStat.PotionsStamina += 1
				Socket:Emit("Hint", "Purchased. You now own " ..PlayerStat.PotionsStamina.. " stamina potions.")
			else
				local Found = false
				for i = 1, #PlayerStat.Purchases do
					local Stuff = PlayerStat.Purchases[i]
					if Stuff.Name == item.Name then
						Stuff.Q = Stuff.Q + 1
						Found = true
						break
					end
				end
				if not Found then
					local Ite = {}
					Ite.Name = item.Name
					Ite.Q = 1
					table.insert(PlayerStat.Purchases, Ite)
				end
			end
		elseif typ == "Pet" then
			tbi(PlayerStat.Pets, item.PreviewModel.Name)
			return string.format("Purchased %s! This pet can be found in the Pets tile.", item.Name)
		elseif typ == "Costume" then
			local Costume = NewCostume(item.PreviewModel.Name)
			tbi(PlayerStat.Characters[CurrentChar].Skins, Costume)
			if (item.Name == "Forgotten Hero" or item.Name == "Forgotten Hero F") and not table.find(PlayerStat.Titles, "ForgottenHero") then
				tbi(PlayerStat.Titles, "ForgottenHero")
				Socket:Emit("Hint", "New Banner Obtained: Forgotten Hero")
			end
			return string.format("Purchased %s! This costume can be found in the Skins tile.", item.Name)
		elseif typ == "Gemstone" then
			local TypeFind = item.Name
			local GemDrop = LootInfo:MakeGem(PlayerStat.InventorySpace, PlayerStat.Characters[CurrentChar].GemInventory, 0, TypeFind)
			tbi(PlayerStat.Characters[CurrentChar].GemInventory, GemDrop)
			Socket:Emit("LootFound", {LootInfo:GetItemInfoFromID(GemDrop.ID, GemDrop.IG, GemDrop.R)})
			return string.format("Gemstone Obtained: %s", item.Name)
		elseif typ == "Reset" then
			local NewItemName = string.format("Shipment Received: %s", item.Name)
			local Item = ItemboxModule:GiveItem(NewItemName)
			PlayerStat.Purchases[NewItemName] = true
			tbi(PlayerStat.ItemBox, Item)
			return string.format("New Mail: %s", item.Name)
		elseif typ == "Banner" then
			tbi(PlayerStat.Titles, item.Thumb.Name)
			Socket:Emit("Hint", "New Banner Obtained: " ..item.Name)
		elseif typ == "ProfileBackground" then
			tbi(PlayerStat.CardBackgrounds, item.Thumb.Name)
			Socket:Emit("Hint", "New Background: " ..item.Name.. ". Can be found in your settings.")
		end
	end
	
	Socket:Listen("Shop", function(cmd, w, currency)
		--[[
			Function that pertains to everything shop, from getting the current stock, sales and buying.
		--]]
		
		if PVP then
			return
		end
		
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local command = cmd or nil
		local word = w or nil
		
		if command ~= nil and typeof(word) == "table" then
			if command == "Upgrade" then
				return LootInfo:GetWeaponRank(PlayerStat.WeaponLevel), PlayerStat.Inventory, PlayerStat.WeaponLevel
			elseif command == "UpgradeGale" then
				if PlayerStat.WeaponLevel < 15 and CombatState.Redeeming == false then
					CombatState.Redeeming = true
					local Rank = LootInfo:GetWeaponRank(PlayerStat.WeaponLevel)
					if Rank ~= nil then
						local Cost = currency == "Gold" and Floor((PlayerStat.WeaponLevel * 1000) ^ 1.15) or Floor((PlayerStat.WeaponLevel * 50) ^ 1.2)
						if PlayerStat[currency] and PlayerStat[currency] >= Cost then
							PlayerStat[currency] = PlayerStat[currency] - Cost
							local Items = {}
							local Inventory = PlayerStat.Inventory
							for i = 1, #Rank.ItemsToGoNext do
								local Ingredient = {}
								Ingredient.Name = Rank.ItemsToGoNext[i][1]
								Ingredient.Maximum = Rank.ItemsToGoNext[i][2]
								Ingredient.Quantity = 0
								for i = 1, #Inventory do
									local Item = Inventory[i]
									if LootInfo:GetLootFromID(false, Item.ID).Name == Ingredient.Name then
										Ingredient.Quantity = Ingredient.Quantity + Item.Q
									end
								end
								tbi(Items, Ingredient)
							end
							local HasMats = true
							for i = 1, #Items do
								local ReqItem = Items[i]
								if ReqItem.Quantity < ReqItem.Maximum then
									HasMats = false
								end
							end
							if HasMats then
								local ItemsToBeRemoved = {}
								for i = 1, #PlayerStat.Inventory do
									local CheckedItem = PlayerStat.Inventory[i]
									for v = 1, #Items do
										local RequiredItem = Items[v]
										if LootInfo:GetLootFromID(false, CheckedItem.ID).Name == RequiredItem.Name then
											if CheckedItem.Q > RequiredItem.Maximum then
												CheckedItem.Q = CheckedItem.Q - RequiredItem.Maximum
											else
												RequiredItem.Maximum = RequiredItem.Maximum - CheckedItem.Q
												CheckedItem.Q = 0
											end									
											if CheckedItem.Q < 1 then
												local NewItem = {}
												NewItem.IND = CheckedItem.IND
												NewItem.ID = CheckedItem.ID
												tbi(ItemsToBeRemoved, NewItem)
											end
										end
									end
								end
								for i = 1, #ItemsToBeRemoved do
									local ITBR = ItemsToBeRemoved[i]
									for v = 1, #Inventory do
										local IT = Inventory[v]
										if ITBR.ID == IT.ID and ITBR.IND == IT.IND then
											tbr(Inventory, i)
											break
										end
									end
								end
								local Outcome = ""
								local Chance = Rand:NextNumber(0.01,1) <= Rank.SucceedChance
								if Chance or currency == "Tears" then
									PlayerStat.WeaponLevel = PlayerStat.WeaponLevel + 1
									RewardAchievement({10}, id)
									Outcome = "Success"
									AwardBadge(id, 706678715)
								else
									local Setback = Rand:NextNumber(0.01,1) <= Rank.SetbackChance
									if Setback then
										PlayerStat.WeaponLevel = PlayerStat.WeaponLevel - Rank.SetbackLevels
										Outcome = "This upgrade failed and your BIOS level was set back by " ..Rank.SetbackLevels.. "!"
									else
										Outcome = "This upgrade failed!"
									end
								end
								CombatState.Redeeming = false
								PlayerManager:UpdateCombatState(id, CombatState)
								return Outcome, LootInfo:GetWeaponRank(PlayerStat.WeaponLevel), PlayerStat.Inventory, PlayerStat.WeaponLevel
							else
								CombatState.Redeeming = false
								PlayerManager:UpdateCombatState(id, CombatState)
								return "Some Materials are missing!"
							end
						else
							CombatState.Redeeming = false
							PlayerManager:UpdateCombatState(id, CombatState)
							return "You do not have enough money!"
						end
					else
						CombatState.Redeeming = false
						PlayerManager:UpdateCombatState(id, CombatState)
						return "Rank not found"
					end
				else
					CombatState.Redeeming = false
					PlayerManager:UpdateCombatState(id, CombatState)
					return "Max weapon level!"
				end
			elseif command == "Category" then
				local Things = Shop:GetCategory(word)
				if word[1] == "Characters" then
					for i = 1, #Things do
						if CheckGamePass(Player, 2057535) then
							if Things[i].Name == "Alburn" or Things[i].Name == "Natsuko" then
								if PlayerStat.Characters[Things[i].Name] == nil then
									PlayerStat.Characters[Things[i].Name] = Things[i].Name
								end
							end
						end
						if CheckGamePass(Player, 2059326) then
							if Things[i].Name == "Red" or Things[i].Name == "Darwin" or Things[i].Name == "Valeri" then
								if PlayerStat.Characters[Things[i].Name] == nil then
									PlayerStat.Characters[Things[i].Name] = Things[i].Name
								end
							end
						end
						if CheckGamePass(Player, 2229858) then
							if Things[i].Name ~= "Alburn" and Things[i].Name ~= "Natsuko" then
								if PlayerStat.Characters[Things[i].Name] == nil then
									PlayerStat.Characters[Things[i].Name] = Things[i].Name
								end
							end
						end
					end
				end
				if word[2] == "TopContributors" then
					if os.time() - ContributorTimer >= 60 then
						ContributorTimer = os.time()
						print("Updated Contributor Page")
						local success, Pages = pcall(function()
							local Date = os.date("*t")
							local scope = DataStoreService:GetOrderedDataStore("Contributors"..Date.month..""..Date.year)
							local Found = false
							return scope:GetSortedAsync(true, 50)
						end)
						if success then
							ContributorTemp = Pages:GetCurrentPage()
							return ContributorTemp
						else
							print(Pages)
						end
					else
						return ContributorTemp
					end
				end
				return Things, PlayerStat
			elseif command == "Item" then
				return Shop:GetItemInfo(word)
			elseif command == "BuyWGold" then
				if CombatState.Redeeming == false then
					CombatState.Redeeming = true
					PlayerManager:UpdateCombatState(id, CombatState)
					local Item = Shop:GetItemInfo(word[1])
					if Item.Type == "Costume" then
						for _, Costume in ipairs(PlayerStat.Characters[PlayerStat.CurrentClass].Skins) do
							if Costume.Name == Item.PreviewModel.Name then
								CombatState.Redeeming = false
								return "You already own this costume!"
							end
						end
					elseif Item.Type == "Gemstone" then
						local currentClass = PlayerStat.Characters[PlayerStat.CurrentClass]
						local TotalInventorySpace = 0
						for i = 1, #currentClass.GemInventory do
							local Item = currentClass.GemInventory[i]
							if Item ~= nil then
								TotalInventorySpace = TotalInventorySpace + 1
							end
						end
						for i = 1, #currentClass.WeaponInventory do
							local Item = currentClass.WeaponInventory[i]
							if Item ~= nil and Item.ID ~= 1 then
								TotalInventorySpace = TotalInventorySpace + 1
							end
						end
						for i = 1, #currentClass.TrophyInventory do
							local Item = currentClass.TrophyInventory[i]
							if Item ~= nil and Item.ID ~= 1 then
								TotalInventorySpace = TotalInventorySpace + 1
							end
						end
						if TotalInventorySpace >= PlayerStat.InventorySpace then
							return "Inventory full! Please sell weapons, trophies, or gemstones to make room!"
						end
					elseif Item.Type == "Banner" then
						if table.find(PlayerStat.Titles, Item.Thumb.Name) then
							CombatState.Redeeming = false
							return "You already own this banner!"
						end
					elseif Item.Type == "ProfileBackground" then
						if table.find(PlayerStat.CardBackgrounds, Item.Thumb.Name) then
							CombatState.Redeeming = false
							return "You already own this background!"
						end
					end
					if Item ~= nil and Item.Available then
						local TPrice = Item.GoldPrice
						if Item.OnSale > 0 then
							TPrice = TPrice * (1-Item.OnSale)
						end
						if Item.GoldPrice > 0 and PlayerStat.Gold >= Floor(TPrice) then
							PlayerStat.Gold = PlayerStat.Gold - Floor(TPrice)
							local Msg = BuyIt(Item)
							CombatState.Redeeming = false
							PlayerManager:UpdateCombatState(id, CombatState)
							return PlayerStat, Msg
						else
							CombatState.Redeeming = false
							PlayerManager:UpdateCombatState(id, CombatState)
							return "Not enough gold!"
						end
					else
						CombatState.Redeeming = false
						PlayerManager:UpdateCombatState(id, CombatState)
						return "Item not found"
					end
				else
					return "Going too fast!"
				end
			elseif command == "BuyWTears" then
				if CombatState.Redeeming == false then
					CombatState.Redeeming = true
					PlayerManager:UpdateCombatState(id, CombatState)
					local Item = Shop:GetItemInfo(word[1])
					if Item ~= nil and Item.Available  then
						if Item.Type == "Inventory" then
							local Cap = 80
							if PlayerStat.Purchases["Shipment Received: Strongback Perk"] == true then
								Cap = 130
							end
							if PlayerStat.InventorySpace >= Cap then
								CombatState.Redeeming = false
								return Cap < 130 and "Maximum inventory limit! Redeem Strongback for further increases." or "Maximum inventory limit reached!"
							end
						elseif Item.Type == "OutfitSlot" then
							local Cap = 10
							if PlayerStat.OutfitSlots >= Cap then
								CombatState.Redeeming = false
								return "Maximum Outfit Slots reached!"
							end
						elseif Item.Type == "Pet" then
							if table.find(PlayerStat.Pets, Item.PreviewModel.Name) then
								CombatState.Redeeming = false
								return "You already own this pet!"
							end
						elseif Item.Type == "Costume" then
							for _, Costume in ipairs(PlayerStat.Characters[PlayerStat.CurrentClass].Skins) do
								if Costume.Name == Item.PreviewModel.Name then
									CombatState.Redeeming = false
									return "You already own this costume!"
								end
							end
						elseif Item.Type == "Banner" then
							if table.find(PlayerStat.Titles, Item.Thumb.Name) then
								CombatState.Redeeming = false
								return "You already own this banner!"
							end
						elseif Item.Type == "ProfileBackground" then
							if table.find(PlayerStat.CardBackgrounds, Item.Thumb.Name) then
								CombatState.Redeeming = false
								return "You already own this background!"
							end
						end
						local TPrice = Item.TearsPrice
						if Item.OnSale > 0 then
							TPrice = TPrice * (1-Item.OnSale)
						end
						if Item.TearsPrice > 0 and PlayerStat.Tears >= Floor(TPrice) then
							PlayerStat.Tears = PlayerStat.Tears - Floor(TPrice)
							local Msg = BuyIt(Item)
							CombatState.Redeeming = false
							PlayerManager:UpdateCombatState(id, CombatState)
							return PlayerStat, Msg
						else
							CombatState.Redeeming = false
							PlayerManager:UpdateCombatState(id, CombatState)
							return "Not enough tears!"
						end
					else
						CombatState.Redeeming = false
						PlayerManager:UpdateCombatState(id, CombatState)
						return "item not found"
					end
				else
					return "Going too fast!"
				end
			elseif command == "Equip" then --class thing for now
				local Room = MatchMaking:GetCurrentRoom(Player)
				if Room then
					return "You cannot change characters while in a room."
				end
				if os.time()-CombatState.CharChange >= 60 then
					local class = Shop:GetItemInfo(word[1])
					if class ~= nil then
						CombatState.CharChange = os.time()
						PlayerManager:UpdateCombatState(id, CombatState)
						local CanEquip = true
						if class.Name == "Natsuko" or class.Name == "Alburn" then
							if not CheckGamePass(Player, 2057535) then
								CanEquip = false
							end
						end
						
						if PlayerStat.Characters[class.Name] ~= nil and CanEquip then
							CombatState.LastSave = 0 ---Bypass the CD
							PlayerManager:UpdateCombatState(id, CombatState)

							--- Save and check if the character save exists
							if CombatState.ActiveCharacterProfile then
								if typeof(PlayerStat.Characters[PlayerStat.CurrentClass]) == "table" then
									if PlayerStat.Characters[PlayerStat.CurrentClass].CurrentClass == CombatState.ActiveCharacterProfile.Data.CurrentClass then
										CombatState.ActiveCharacterProfile.Data = PlayerStat.Characters[PlayerStat.CurrentClass]
									end
								end
								CombatState.ActiveCharacterProfile:Release()

								--- Overwrite table with just the class name to save on space, then change currentClass to the new chosen one
								PlayerStat.Characters[PlayerStat.CurrentClass] = PlayerStat.CurrentClass
								PlayerStat.CurrentClass = class.Name

								local newClassProfile = getClassData(id, class.Name)
								if newClassProfile then
									if newClassProfile.Data.CurrentClass ~= class.Name then
										print("Created new character in shop")
										requestNewCharacter(PlayerStat.Characters, class.Name, id)
									else
										PlayerStat.Characters[class.Name] = newClassProfile.Data
									end

									CombatState.ActiveCharacterProfile = newClassProfile

									local CharacterSkills = PlayerStat.Characters[class.Name].Skills
									local skin = PlayerStat.Characters[class.Name].CurrentSkinPieces

									PlayerStat.Characters[class.Name].Skills = ClassInfo:UpdateClassSkills(CharacterSkills, class.Name)

									for i,v in ipairs(Player.Character:GetChildren()) do
										if v:IsA("Model") and v.Name ~= "Weapon" then
											v:Destroy()
										end
									end
									
									Morpher:morph(Player.Character, skin)

									if Player.Character:FindFirstChild("Class") then
										Player.Character.Class.Value = class.Name
									end

									print(string.format("Changed to %s", class.Name))
									return PlayerStat
								end
							end

							return "error"
							--[[
							local Saved = saveData(id)
							if Saved == "saved" then
								PlayerStat.Characters[PlayerStat.CurrentClass] = PlayerStat.CurrentClass
								PlayerStat.CurrentClass = class.Name

								if typeof(PlayerStat.Characters[PlayerStat.CurrentClass]) == "string" then
									local ClassData = getClassData(id, PlayerStat.CurrentClass)
									if typeof(ClassData) == "table" then
										PlayerStat.Characters[PlayerStat.CurrentClass] = ClassData
									elseif ClassData == nil then ---New Character
										print("Created new character")
										requestNewCharacter(PlayerStat.Characters, PlayerStat.CurrentClass, id)
									elseif ClassData == "error" then
										return "Data Store returned error! Try again later!"
									end
								end
								
								local CharacterSkills = PlayerStat.Characters[class.Name].Skills
								PlayerStat.Characters[class.Name].Skills = ClassInfo:UpdateClassSkills(CharacterSkills, class.Name)
								for i,v in ipairs(Player.Character:GetChildren()) do
									if v:IsA("Model") and v.Name ~= "Weapon" then
										v:Destroy()
									end
								end
								local skin = PlayerStat.Characters[PlayerStat.CurrentClass].CurrentSkinPieces
								Morpher:morph(Player.Character, skin)
								if Player.Character:FindFirstChild("Class") then
									Player.Character.Class.Value = class.Name
								end
								print("Changed to " ..class.Name)
								return PlayerStat
							else
								return "error"
							end
							--]]
						else
							return "You don't own this character!"
						end
					else
						return "Character not found!"
					end
				else
					return "CD", Floor(60 - (os.time()-CombatState.CharChange))
				end
			end
		end
		return nil
	end)	
	
	--[[ Disconnecting Methods ]]--
	
    Socket.Disconnected:Connect(function ()
		local Saving = true
		local PlayerStat = PlayerManager:GetPlayerProfile(id)
		local CombatState = PlayerManager:GetCombatState(id)
		
		if PlayerStat then
			PlayerStat.Data.TotalHours += (os.time() - CombatState.HoursPlaying)
			CombatState.LastSave = 0

			if typeof(PlayerStat.Data.Characters[PlayerStat.Data.CurrentClass]) == "table" then
				if PlayerStat.Data.Characters[PlayerStat.Data.CurrentClass].CurrentClass == CombatState.ActiveCharacterProfile.Data.CurrentClass then
					CombatState.ActiveCharacterProfile.Data = PlayerStat.Data.Characters[PlayerStat.Data.CurrentClass]
				end
			end

			CombatState.ActiveCharacterProfile:Release()

			if PlayerStat.Data and PlayerStat.Data.CurrentClass ~= "Null" then
				for name, data in pairs(PlayerStat.Data.Characters) do
					PlayerStat.Data.Characters[name] = name
				end 
			end

			PlayerStat:Release()

			PlayerManager:RemovePlayerStat(id)
			PlayerManager:RemoveCombatState(id)

			print(Player, "has disconnected and profile has been successfully released")
		end

		local Leaving = MatchMaking:PlayerLeftGame(Player)
		if typeof(Leaving) == "table" then
			for i = 1, #Leaving.Players do
				Sockets:GetSocket(Leaving.Players[i]):Emit("Matchmake", "PlayerLeft", Leaving) --Check if player == new host
			end
		end

		if ReplicatedStorage.PlayerValues:FindFirstChild(Player.Name) then
			ReplicatedStorage.PlayerValues[Player.Name]:Destroy()
		end
	end)
	
	local HasConnected = Instance.new("Folder")
	HasConnected.Name = "Connected"
	HasConnected.Parent = Player
	print(Player, "has connected")
end)

local AwaitingPlayers = true
while AwaitingPlayers do
	local PlayerStats = PlayerManager:FetchPlayerStats()
	for i,v in pairs(PlayerStats) do
		if i ~= 0 then
			AwaitingPlayers = false
		end
	end
	wait(2)
end

if ReservedServer and (Map or SoloTest) then
	GameLogic:Game_Start()
else
	WorldEvents:OnServerStartup()
	
	while wait(1) do
		if #Contributors > 0 and os.time() - ContributorTimer >= 60 then
			ContributorTimer = os.time()
			local Date = os.date("*t")
			local scope = DataStoreService:GetOrderedDataStore("Contributors"..Date.month..""..Date.year)
			for i = 1, #Contributors do
				local success = pcall(function()
					scope:IncrementAsync(Contributors[i].ID, Contributors[i].Amnt)
				end)
				print("Updated Value")
			end
			Contributors = {}
		end
	
		local TPCount = #TeleportQueues
		if TPCount > 0 then
			FS.spawn(function()
				for i = 1, TPCount do
					local Guild = TeleportQueues[i]
					if Guild then
						local MemberCount = #Guild.Members
						if MemberCount < 1 then
							table.remove(TeleportQueues, i)
						else
							if Guild.Timer > 0 then
								Guild.Timer = Guild.Timer - 1
								for v = 1, MemberCount do
									local Plyr = Guild.Members[v]
									if Plyr.PlayerObj then
										Sockets:GetSocket(Plyr.PlayerObj):Emit("TeleportQueueUpdate", Guild.Members, Guild.Timer)
									end
								end
							else
								local PlayersToTP = {}
								for _, Plyr in ipairs(Guild.Members) do
									if Plyr.PlayerObj then
										local id = Plyr.PlayerObj.UserId
										local PlayerStat = PlayerManager:GetPlayerStat(id)
										local CombatState = PlayerManager:GetCombatState(id)
										Sockets:GetSocket(Plyr.PlayerObj):Emit("StartingDungeon")
										PlayerStat.LastReserveCode = "TeleportQueue"
										PlayerStat.LastReserveTime = os.time()
										CombatState.LastSave = 0
										PlayerManager:UpdateCombatState(id, CombatState)
										local data --saveData(id, Plyr.PlayerObj)
										if data == "saved" then
											PlayerManager:RemovePlayerStat(id)
											PlayerManager:RemoveCombatState(id)
										end
										tbi(PlayersToTP, Plyr.PlayerObj)
									end
								end
								if #PlayersToTP > 0 then
									FS.spawn(function()
										wait(1)
										TeleportService:TeleportToPrivateServer(game.PlaceId, Guild.ReserveID, PlayersToTP, nil)
									end)
								end
								tbr(TeleportQueues, i)
							end
						end
					end
				end
			end)
		end
	end
end
