--how to remove from scoreboard: 
--game:GetService("DataStoreService"):GetOrderedDataStore("MAPNAMENormal"):SetAsync("USERID-LingeringForce", 9999)

local dungeonID = game.PlaceId == 4666288269 and 6092300236 or 6092293455
local returnID = game.PlaceId == 6092300236 and 4666288269 or 5228777299

local module 			= {}
local Rooms 			= {}

local HttpService 			= game:GetService("HttpService")
local TS 					= game:GetService("TeleportService")
local DataStoreService 		= game:GetService("DataStoreService")
local Players				= game:GetService("Players")
local TextService			= game:GetService("TextService")
local ServerScriptService 	= game:GetService("ServerScriptService")
local ScopeVersion			= "2"

local FS 			= require(game.ReplicatedStorage.Scripts.Modules.FastSpawn)
local ChatService 	= require(ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)
local Promise       = require(game.ReplicatedStorage.Scripts.Modules.Promise)
local Sockets 		= require(script.Parent.Parent.Utility["server"])

local RequestsPerMinute = 20
local Updated = 0

local MaxRequests = RequestsPerMinute

local MapInformation = {}

function AllocateServer()
	if not ServerScriptService.Server.Values.DEBUG_VARIABLES.CanSave.Value then
		return -1, -2
	end

	local ID, PrivateID = TS:ReserveServer(dungeonID) 
	return ID, PrivateID
end

function module:GetMap(name)
	for i = 1, #MapInformation do
		local Map = MapInformation[i]
		if Map.MissionName == name then
			return Map
		end
	end
	return nil
end

function GetMapRequirements(Map, StoryProgression, Difficulty)
	if Map.RequiredMapCompletions == nil then
		return
	end
	
	if #Map.RequiredMapCompletions < 1 then
		return true
	else
		if Map.Available == false then
			return false
		else
			local Count = 0
			local CompletionRate = Difficulty == "Hero" and #Map.RequiredMapCompletions+1 or #Map.RequiredMapCompletions
			for v = 1, #Map.RequiredMapCompletions do
				local RequiredMap = Map.RequiredMapCompletions[v]
				if string.len(RequiredMap) > 4 and typeof(Difficulty) == "string" and Difficulty == "Hero" then
					RequiredMap = Map.RequiredMapCompletions[v].."H"
				end
				for _, CompletedStories in ipairs(StoryProgression) do
					if CompletedStories == RequiredMap then
						Count = Count + 1
					end
					if Difficulty == "Hero" then
						if CompletedStories == Map.MissionName then
							Count = Count + 1
						end
					end
				end
				if Count >= CompletionRate then
					return true
				end
			end
		end
	end
	return false
end

function module:PostToHighScore(MapObject, PlayerID, Class, Time, Difficulty)
	local success, errorMessage = pcall(function()
		local scope = DataStoreService:GetOrderedDataStore(MapObject.MissionName..""..Difficulty..""..ScopeVersion) ---add matchmakingscope to this later
		local Previous = scope:GetAsync(PlayerID.."-"..Class)
		if Previous == nil or Time < Previous then
			scope:UpdateAsync(PlayerID.."-"..Class, function(old)
				local new	= old or 0
				new 		= Time
				return new
			end)
		else
			print("There is already a quicker time available from this player")
		end
	end)
	if not success then
		print("Could not save to High score for Map:", MapObject.MissionName, " | Reason:", errorMessage)
	end
end

local TopCache = {}

function module:GetTop50(MapObject, Difficulty)
	if os.time()-Updated >= 60 then
		Updated = os.time()
		RequestsPerMinute = MaxRequests + #game.Players:GetPlayers()
	end
	local success, PlayerScores, MissionName = pcall(function()
		local scope = DataStoreService:GetOrderedDataStore(MapObject.MissionName..""..Difficulty..""..ScopeVersion)
		local Found = false
		for i = 1, #TopCache do
			local MapScore = TopCache[i]
			if MapScore.Name == MapObject.MissionName..""..Difficulty then
				if os.time()-MapScore.Refresh >= 60 and RequestsPerMinute > 0 then
					table.remove(TopCache, i)
					print("Updated!")
					break
				else
					Found = true
					print("Refresh not updated!")
					return MapScore.Members, MapObject.MissionName
				end
			end
		end
		if Found == false and RequestsPerMinute > 0 then
			RequestsPerMinute = RequestsPerMinute - 1
			local getSorted = scope:GetSortedAsync(true, 50)
			local pages = getSorted:GetCurrentPage()
			local MapScore = {}
			MapScore.Name = MapObject.MissionName..""..Difficulty
			MapScore.Refresh = os.time()
			MapScore.Members = {}
			
			for _, entry in ipairs(pages) do
				local PlayerID = tonumber(string.match(entry.key, "%d+"))
				local Class	= nil
				local Count = 0
				for word in entry.key:gmatch("[^-]*-*") do
					if #word > 0 then
						if Count >= 1 then
							Class = word
							break
						else
							Count = Count + 1
						end
					end
				end
				local success, PlayerName = pcall(function()
					return Players:GetNameFromUserIdAsync(PlayerID)
				end)
				table.insert(MapScore.Members, {PlayerName = success and PlayerName or "Unable to fetch name", Class = Class, Time = entry.value})
			end

			table.insert(TopCache, MapScore)
			return MapScore.Members, MapObject.MissionName
		end
	end)
	if success then
		return PlayerScores, MissionName
	else
		print(Pages)
	end
end

function module:GetMapList(StoryProgression, IsPremium, Difficulty, IsPVP)
	local ViableMaps = {}
	for _, Map in ipairs(MapInformation) do
		if IsPVP == nil then
			if Map.RequiredMapCompletions then
				local CanAdd = GetMapRequirements(Map, StoryProgression, Difficulty)
				local currentTime = os.time()
				if Difficulty == "Hero" or Difficulty == "EMD" or Difficulty == "HMD" then
					if Map.MinLevelHero < 0 and Map.MaxLevelHero < 0 then
						CanAdd = false
					end
				end
				if currentTime - Map.ReleaseDate < 604800 then
					if not IsPremium then
						CanAdd = false
					end
				end
				if Map.Type == "Event" and Map.EndTime then
					if Map.EndTime ~= -1 then
						if Map.EndTime - currentTime <= 0 then
							CanAdd = false
						end
					end
				end
				if Map.Available == false then
					CanAdd = false
				end
				if CanAdd then
					table.insert(ViableMaps, Map)
				end
			end
		else
			if Map.Type == "PVP" then
				table.insert(ViableMaps, Map)
			end
		end
	end
	return ViableMaps
end

function module:GetRooms(ThisPlayer, StoryProgression, IsPremium, Level, IsPvP)
	local ViableRooms = {}
	for i = 1, #Rooms do
		local Room = Rooms[i]
		if Room ~= nil then
			local CanAdd = false
			if Room.PVP == nil then
				if GetMapRequirements(Room.Map, StoryProgression) == true then
					CanAdd = true
					if os.time()-Room.Map.ReleaseDate < 604800 then
						if not IsPremium then
							CanAdd = false
						end
					end
				end
				if Room.Local and Room.Host ~= nil and Room.Host.PlayerObject then
					CanAdd = Room.Host.PlayerObject:IsFriendsWith(ThisPlayer.UserId) 
				end
				if Room.Difficulty == true and Level < Room.Map.MinLevelHero then
					CanAdd = false
				end
				if Room.EveryoneMustDie == true and Level < 200 then
					CanAdd = false
				end
				if Room.Host == nil then
					CanAdd = false
					module:RemoveRoom(Rooms.ID)
				end
			else
				if IsPvP then
					CanAdd = true
					if Room.Local and Room.Host ~= nil and Room.Host.PlayerObject then
						CanAdd = Room.Host.PlayerObject:IsFriendsWith(ThisPlayer.UserId) 
					end
				end
			end
			if CanAdd then
				table.insert(ViableRooms, Room)
			end
		end
	end
	return ViableRooms
end

function module:PlayerLeftGame(player)
	if module:GetCurrentRoom(player) ~= false then
		return module:LeaveRoom(player)
	end
end

function module:CreatePlayerObject(Player, Level, Class)
	local Obj = {}
	Obj.PlayerObject = Player
	Obj.Level = Level
	Obj.Class = Class
	return Obj
end

function module:CreateRoom(Player, Level, Class, MaxP, Map, Difficulty, Local, Name, StoryProgression, IsPremium, HeroesMustDie, PvPTable)
	if module:GetCurrentRoom(Player) == false then
		local Room = {}
		local MaxPlayers = MaxP > 6 and 6 or MaxP
		local Naim = Name
		local Filtered, FilteredMsg = TextService:FilterStringAsync(Naim, Player.UserId)
		local success, _ = pcall(function()
			FilteredMsg = Filtered:GetNonChatStringForBroadcastAsync()
		end)
		local Ply = module:CreatePlayerObject(Player, Level, Class)
		local Map = module:GetMap(Map)
		Room.Players = {}
		Room.Name = success and (string.len(FilteredMsg) > 0 and FilteredMsg or "Come Join my Party!") or "Come Join my Party!"
		Room.Host = Ply
		Room.Map = Map and Map or (PvPTable and module:GetMap("Arena: Riukaya-Hara") or module:GetMap("Riukaya-Hara: A Journey's Start"))
		if StoryProgression and GetMapRequirements(Room.Map, StoryProgression) == false then ---Did this guy spoof his map settings?
			Room.Map = module:GetMap("Riukaya-Hara: A Journey's Start")
		end
		if StoryProgression and os.time()-Room.Map.ReleaseDate < 604800 then
			if not IsPremium then ----also spoofed if they access a map that isn't ready to release yet
				Room.Map = module:GetMap("Riukaya-Hara: A Journey's Start")
			end
		end
		if MaxPlayers < 0 then
			MaxPlayers = 1
		elseif MaxPlayers > Map.MaxPlayers then
			MaxPlayers = Map.MaxPlayers
		end
		if PvPTable then
			Room.BannedCharacters = typeof(PvPTable.Banned) == "table" and PvPTable.Banned or {}
			Room.PVP = {
				RedTeam = {Player.Name},
				BlueTeam = {}
			}
			Room.GameMode = PvPTable.GameMode
		end
		Room.PlayerLimit = MaxPlayers
		Room.Difficulty = PvPTable == nil and (Level < 50 and false or Difficulty) or false
		Room.EveryoneMustDie = PvPTable == nil and (Level < 200 and false or HeroesMustDie) or false
		Room.Local = typeof(Local) == "boolean" and Local or false
		Room.ID = HttpService:GenerateGUID()
		Room.Starting = false
		Room.StartReady = false
		Room.ReserveCode = nil
		Room.PrivateID = nil
		Room.ChatChannel = nil
		
		---- Chat Stuff
		local channelName = string.format("Room-%s", Player.UserId)
		for i = 1, 99 do
			if not ChatService:GetChannel(channelName .. i) then
				channelName = channelName .. i
				break
			end
		end

		local roomChannel = ChatService:AddChannel(channelName)
		roomChannel.Private = true
		roomChannel.Joinable = false
		roomChannel.Leavable = false
		roomChannel.SpeakerJoined:Connect(function(speakerName)
			if speakerName == Player.Name then
				roomChannel:SendSystemMessage(string.format("%s %s", speakerName, "has started a new party."))
			else
				local RandomMessage = {
					"has joined your struggle.",
					"has been summoned.",
					"has entered the fray."
				}
				roomChannel:SendSystemMessage(string.format("%s %s", speakerName, Random.new():NextInteger(1, #RandomMessage)))
			end
		end)
		roomChannel.SpeakerLeft:Connect(function(speakerName)
			roomChannel:SendSystemMessage(speakerName .. " has left the party.")
		end)

		Room.ChatChannel = channelName
		local Speaker = ChatService:GetSpeaker(Player.Name)
		Speaker:JoinChannel(roomChannel.Name)

		table.insert(Room.Players, Ply)
		table.insert(Rooms, Room)

		FS.spawn(function()
			local RoomUnReady = true
			while RoomUnReady do
				local NewRoom = module:GetCurrentRoom(Player)
				local Time = os.time()
				if NewRoom then
					if NewRoom.ID == Room.ID then
						local ID, PrivateID = AllocateServer()
						NewRoom.ReserveCode = ID
						NewRoom.PrivateID = PrivateID
						NewRoom.StartReady = true
						RoomUnReady = false
						break
					end
				else
					print("Room doesn't exist for player!")
				end
				wait()
			end
		end)
		return Room, true
	else
		print("Already have a room!")
		return nil, false
	end
end

function module:JoinTeam(Player)
	local Room = module:GetCurrentRoom(Player)
	if Room then
		local FindInRed = table.find(Room.PVP.RedTeam, Player.Name)
		local FindInBlue = table.find(Room.PVP.BlueTeam, Player.Name)
		if FindInRed then
			if #Room.PVP.BlueTeam < #Room.PVP.RedTeam then
				table.remove(Room.PVP.RedTeam, FindInRed)
				table.insert(Room.PVP.BlueTeam, Player.Name)
			else
				return Room, "Unable to join Blue Team as they have more players."
			end
		elseif FindInBlue then
			if #Room.PVP.RedTeam < #Room.PVP.BlueTeam then
				table.remove(Room.PVP.BlueTeam, FindInBlue)
				table.insert(Room.PVP.RedTeam, Player.Name)
			else
				return Room, "Unable to join Red Team as they have more players."
			end
		end
		return Room
	end
end

function module:JoinRoom(Player, ThisPlayer, Level, Character)
	local FoundPlayer = false
	local msg = "Room not found! Host might have disbanded, or left!"
	if module:GetCurrentRoom(ThisPlayer) ~= false then
		FoundPlayer = true
		msg = "Player was found in another room!"
	end
	if FoundPlayer == false then
		for i = 1, #Rooms do
			if Rooms[i] ~= nil and Rooms[i].Host and Rooms[i].Host.PlayerObject == Player and Rooms[i].Starting == false then
				local RemainingPlyers = 0
				for v = 1, #Rooms[i].Players do
					RemainingPlyers = RemainingPlyers + 1
				end
				
				if not Rooms[i].PVP and ((Level < Rooms[i].Map.MinLevel) or (Rooms[i].Difficulty and Level < Rooms[i].Map.MinLevelHero)) then
					return "You are too low level to join this room!"
				end
				if RemainingPlyers < Rooms[i].PlayerLimit then
					if Rooms[i].PVP then
						if table.find(Rooms[i].BannedCharacters, Character) then
							return "Unable to join because the host has banned your character."
						end
						if #Rooms[i].PVP.RedTeam < #Rooms[i].PVP.BlueTeam then
							table.insert(Rooms[i].PVP.RedTeam, ThisPlayer.Name)
						else
							table.insert(Rooms[i].PVP.BlueTeam, ThisPlayer.Name)
						end
					end
					local Speaker = ChatService:GetSpeaker(ThisPlayer.Name)
					Speaker:JoinChannel(Rooms[i].ChatChannel)
					table.insert(Rooms[i].Players, module:CreatePlayerObject(ThisPlayer, Level, Character))
					return Rooms[i]
				else
					msg = "Full room"
				end
			else
				msg = "Room no longer exists."
			end
		end
	end
	return msg
end

function module:KickPlayer(ThisPlayer, requestedPlayer)
	for i = 1, #Rooms do
		local Room = Rooms[i]
		if Room ~= nil and Room.Host.PlayerObject == ThisPlayer and Rooms[i].Starting == false then
			return module:LeaveRoom(requestedPlayer)
		end
	end
end

function module:LeaveRoom(ThisPlayer)
	local Room;
	local Host_Left = nil
	for i = 1, #Rooms do
		if Rooms[i] ~= nil then
			local RemainingPlyers = 0
			for v = 1, #Rooms[i].Players do
				local Plyr = Rooms[i].Players[v]
				if Plyr then
					if Plyr.PlayerObject == ThisPlayer and Rooms[i].Starting == false then
						if Rooms[i].PVP then
							local FindInRed = table.find(Rooms[i].PVP.RedTeam, ThisPlayer.Name)
							local FindInBlue = table.find(Rooms[i].PVP.BlueTeam, ThisPlayer.Name)
							if FindInRed then
								table.remove(Rooms[i].PVP.RedTeam, FindInRed)
							end
							if FindInBlue then
								table.remove(Rooms[i].PVP.BlueTeam, FindInBlue)
							end
						end
						local Speaker = ChatService:GetSpeaker(ThisPlayer.Name)
						Speaker:LeaveChannel(Rooms[i].ChatChannel)
						table.remove(Rooms[i].Players, v)
						Room = Rooms[i]
						print("Successfully left the room!")
					else
						RemainingPlyers = RemainingPlyers + 1
					end
				end
			end
			if RemainingPlyers <= 0 then
				module:RemoveRoom(Rooms[i].ID)
			else
				--- Change host if the original host left the lobby
				if ThisPlayer == Rooms[i].Host.PlayerObject then
					if Rooms[i].PVP then
						Host_Left = true
						Rooms[i].Starting = true
						for _, Plyr in ipairs(Rooms[i].Players) do
							module:LeaveRoom(Plyr)
						end
					else
						Rooms[i].Host = Rooms[i].Players[1] --- change host to the next first player on list
						print("Switched hosts")
					end
				end
			end
		end
	end
	return Room, Host_Left
end

function module:GetCurrentRoom(ThisPlayer)
	for i = 1, #Rooms do
		local Room = Rooms[i]
		if Room.Host ~= nil and Room.Host.PlayerObject == ThisPlayer then
			return Room
		else
			for v = 1, #Room.Players do
				local Plyr = Room.Players[v]
				if Plyr ~= nil and Plyr.PlayerObject == ThisPlayer then
					return Room
				end
			end
		end
	end
	return false --"Error! No room with player found!"
end

--[[ Server Commands only ]]--

function module:RemoveRoom(ID)
	for i = 1, #Rooms do
		local Room = Rooms[i]
		if Room ~= nil and Room.ID == ID then
			ChatService:RemoveChannel(Room.ChatChannel)
			table.remove(Rooms, i)
			print("Successfully removed room!")
			break
		end
	end
end

function module:StartDungeon(Player, ReserveID, ReserveTime, PrivateID)
	for i = 1, #Rooms do
		local Room = Rooms[i]
		if Room ~= nil and Room.Host.PlayerObject == Player and Room.Starting == false and Room.StartReady then
			if module:GetMap(Room.Map.MissionName).Available or Room.Map.MissionName == "Introduction" then
				Room.Starting = true
				local PlayersInRoom = 0
				local BattleInfo = {}
				local PlayersToTP = {}
				local playersAwaiting = {}
				for i = 1, #Room.Players do
					PlayersInRoom = PlayersInRoom + 1
					table.insert(PlayersToTP, Room.Players[i].PlayerObject)
					table.insert(playersAwaiting, Room.Players[i].PlayerObject.Name)
				end
				if Room.Map.Type == "PVP" then
					BattleInfo.PVP = Room.PVP
					BattleInfo.GameMode = Room.GameMode
				end
				BattleInfo.LastReserveTime = ReserveTime
				BattleInfo.MaxPlayers = PlayersInRoom
				BattleInfo.Map = Room.Map
				BattleInfo.Difficulty = Room.PVP and nil or Room.Difficulty
				BattleInfo.EveryoneMustDie = Room.PVP and nil or Room.EveryoneMustDie
				local JSON = HttpService:JSONEncode(BattleInfo)
				local success, errorMessage = pcall(function()
					local scope = DataStoreService:GetDataStore(ScopeVersion)
					scope:UpdateAsync(tostring(PrivateID), function(oldJSON)
						local newJSON 	= oldJSON or nil
						newJSON 		= JSON
						return 			newJSON
					end)
				end)
				if success then
					print("TELEPORTING!")
					TS:TeleportToPrivateServer(dungeonID, ReserveID, PlayersToTP, nil, {Map = BattleInfo.Map})

					wait(5)

					local function onTeleportFailBackup(delayTime)
						return Promise.new(function(resolve, reject)
							wait(delayTime)

							local foundPlayers = {}
							for _, player in ipairs(playersAwaiting) do
								local target = Players:FindFirstChild(player)
								if target then
									table.insert(foundPlayers, player)
									TS:TeleportToPrivateServer(dungeonID, ReserveID, {target}, nil, {Map = BattleInfo.Map})
								end
							end

							if #foundPlayers > 0 then
								reject(foundPlayers)
							else
								resolve()
							end
						end)
					end

					local DELAY_BETWEEN_RETRIES = 5
					local MAX_RETRIES = 30
					local result = Promise.retry(onTeleportFailBackup, MAX_RETRIES, DELAY_BETWEEN_RETRIES)

					if result then
						for _, player in ipairs(result) do
							local target = Players:FindFirstChild(player)
							Sockets:GetSocket(target):Emit("Hint", "Oh, looks like Roblox did not teleport you! Try again perhaps?")
							Sockets:GetSocket(target):Emit("Hint", "Hold on, let us reset you since something did go wrong!")
							Promise.delay(7):andThen(function()
								TS:Teleport(returnID, target, {"Returning"})
							end)
						end
					end

					module:RemoveRoom(Room.ID)

					return true
				else
					print("Teleportation Failed! - " ..errorMessage)
				end
			end
			break
		end
	end
	return false
end

local LastReserveDetails = nil

function module:GetReserveDetails(PrivateID, ReserveTime)
	local Time = os.time()
	if LastReserveDetails and Time - LastReserveDetails.LastReserveTime <= 600 and Time - ReserveTime <= 600 then
		return LastReserveDetails
	else
		local success, JSON = pcall(function()
			local scope = DataStoreService:GetDataStore(ScopeVersion)
			return scope:GetAsync(PrivateID)
		end)
		if success then
			if JSON ~= nil then
				local Data = HttpService:JSONDecode(JSON)
				if Time - Data.LastReserveTime <= 600 and Time - ReserveTime <= 600 then
					LastReserveDetails = Data
					return Data
				end
			end
		end
	end
end

function module:TeleportBack(ListOfPlys)
	local success, result = pcall(function()
		return TS:TeleportPartyAsync(returnID, ListOfPlys)
	end)
	if success then
		print("Players teleported!")
	else
		print("Teleport Party failed, teleporting individuals!")
		local Plyrs = ListOfPlys
		for i = 1, #Plyrs do
			local Player = Plyrs[i]
			TS:Teleport(returnID, Player, {"Returning"})
		end
	end
end

for _, type in ipairs(script.MapContent:GetChildren()) do
	for _, mission in ipairs(type:GetChildren()) do
		table.insert(MapInformation, require(mission))
	end
end

return module
