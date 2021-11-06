--<< Services >>--
local RunService 		= game:GetService("RunService")
local CollectionService	= game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage		= game:GetService("ServerStorage")
local Teams 			= game:GetService("Teams")
local Debris 			= game:GetService("Debris")
local Players 			= game:GetService("Players")
local BadgeService 		= game:GetService("BadgeService")
local HttpService		= game:GetService("HttpService")
local TweenService 		= game:GetService("TweenService")
local MessagingService 	= game:GetService("MessagingService")
local TextService 		= game:GetService("TextService")

--<< Constants >>--
local SERVER_FOLDER = script.Parent.Parent
local MODULES 		= SERVER_FOLDER.Parent.Modules

--<< Modules >>--
local PlayerManager	= require(MODULES.PlayerStatsObserver)
local Sockets 		= require(MODULES.Utility["server"])
local MatchMaking 	= require(MODULES.Systems["Matchmaking"])
local WeaponCraft 	= require(MODULES.CharacterManagement["WeaponCrafting"])
local LootInfo		= require(MODULES.CharacterManagement.LootInfo)

--<< Variables >>--
local logic = {}

local Vec3, CF = Vector3.new, CFrame.new
local tbi, tbr = table.insert, table.remove
local Rand = Random.new()
local Floor = math.floor

--<< Functions >>--
local function saveData(id, Player, bool)
	return SERVER_FOLDER.Bindables.SaveDataOfPlayer:Invoke(id, Player, bool)
end




--<< Socket Init >>--

function logic:Init(Socket)
	local Player = Socket.Player
	local id = Player.UserId
	
	Socket:Listen("MatchmakePVP", function(Action, tbl)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		if Action == "GetMaps" then
			return MatchMaking:GetMapList(nil, false, tbl, true)
		elseif Action == "CreateRoom" then
			local MaxPlayers = 2
			if tbl.GameMode == "1v1" then
				MaxPlayers = 2
			elseif tbl.GameMode == "2v2" then
				MaxPlayers = 4
			else
				tbl.GameMode = "3v3"
				MaxPlayers = 6
			end
			if not table.find(tbl, PlayerStat.CurrentClass) then
				tbi(tbl, PlayerStat.CurrentClass)
			end
			local Room, Success = MatchMaking:CreateRoom(Player, PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel, PlayerStat.CurrentClass, MaxPlayers, tbl.Map, false, false, tbl.Name, nil, false, nil, tbl)
			if Success then
				Sockets:Emit("SendMessage", nil, nil, Player.Name.. " has created a PVP arena.", nil, true)
			end
			return Room
		elseif Action == "JoinTeam" then
			local Room, Message = MatchMaking:JoinTeam(Player)
			if Room then
				for _, Player in ipairs(Room.Players) do
					Sockets:GetSocket(Player.PlayerObject):Emit("MatchmakePVP", "PlayerJoin", Room)
				end
			end
			return Room, Message
		elseif Action == "LeaveRoom" then
			local Leaving, Host_Left = MatchMaking:LeaveRoom(Player)
			for _, LeavingPlayer in ipairs(Leaving.Players) do
				if Host_Left then
					Sockets:GetSocket(LeavingPlayer.PlayerObject):Emit("MatchmakePVPHost_Left")
				else
					Sockets:GetSocket(LeavingPlayer.PlayerObject):Emit("MatchmakePVP", "PlayerJoin", Leaving)
				end
			end
		elseif Action == "GetRooms" then
			return MatchMaking:GetRooms(Player, {}, false, 0, true)
		elseif Action == "JoinRoom" then
			local Room = MatchMaking:GetCurrentRoom(tbl)
			if Room then
				if table.find(Room.BannedCharacters, PlayerStat.CurrentClass) then
					Socket:Emit("Hint", "Unable to join as the host has banned your character from their arena.")
					return
				end

				local Joining = MatchMaking:JoinRoom(tbl, Player, PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel, PlayerStat.CurrentClass)
				if typeof(Joining) == "table" then
					for i = 1, #Joining.Players do
						if Joining.Players[i].PlayerObject ~= Player then
							Sockets:GetSocket(Joining.Players[i].PlayerObject):Emit("MatchmakePVP", "PlayerJoin", Joining)
						end
					end
				end
				return Joining
			end
		elseif Action == "StartDungeon" then
			local Room = MatchMaking:GetCurrentRoom(Player)
			if Room and Room.PVP then
				if Room.StartReady and Player == Room.Host.PlayerObject then
					if #Room.PVP.RedTeam < 1 or #Room.PVP.BlueTeam < 1 then
						for _,Players in ipairs(Room.Players) do
							Sockets:GetSocket(Players):Emit("Hint", "Both teams must have at least one player!")
						end
					else
						local ReserveTime = os.time()
						local RoomPlayers = {}
						local Errors = {}
						for i = 1, #Room.Players do
							local Player = Room.Players[i]
							local id = Player.PlayerObject.UserId
							local CurrLvl = PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel
							tbi(RoomPlayers, Player)
						end
						for i = 1, #RoomPlayers do
							local Player = RoomPlayers[i]
							Sockets:GetSocket(Player.PlayerObject):Emit("StartingDungeon")
							local TargetPlayerStat = PlayerManager:GetPlayerStat(Player.PlayerObject.UserId)
							local CombatState = PlayerManager:GetCombatState(Player.PlayerObject.UserId)
							TargetPlayerStat.LastReserveCode = tostring(Room.PrivateID)
							TargetPlayerStat.LastReserveTime = ReserveTime
							CombatState.LastSave = 0
							PlayerManager:UpdateCombatState(Player.PlayerObject.UserId, CombatState)
							local data = saveData(Player.PlayerObject.UserId, Player.PlayerObject, true)
							if data == "saved" then
								PlayerManager:RemovePlayerStat(id)
								PlayerManager:RemoveCombatState(id)
							end
						end
						print("Is host! Now transitioning!")
						MatchMaking:StartDungeon(Player, Room.ReserveCode, ReserveTime, Room.PrivateID)
					end
				else
					print("Room is not ready!")
				end
			else
				print("Room not found!")
			end
		end
	end)
	
	Socket:Listen("Matchmake", function(Action, tbl)
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		local function IsPremium()
			local TimeLeft = ((PlayerStat.PremiumExpiration-os.time())/86400)
			if TimeLeft > 0 then
				return true
			end
			return false
		end

		if Action == "CreateRoom" then
			local StoryProgression = PlayerStat.StoryProgression
			local Room, Success = MatchMaking:CreateRoom(Player, PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel, PlayerStat.CurrentClass, tbl.MaxPlayers, tbl.Map, tbl.Difficulty, tbl.Local, tbl.Name, StoryProgression, IsPremium(), tbl.EMD)
			if Success then
				local Diff = "Normal"
				if Room.Difficulty then
					Diff = "Hero"
				end
				if Room.EveryoneMustDie then
					Diff = "Heroes Must Die"
				end
				if Room.PlayerLimit > 1 then
					Sockets:Emit("SendMessage", nil, nil, Player.Name.. " has created " ..Room.Map.MissionName.. " on " ..Diff.. " difficulty.", nil, true)
				end
			end
			return Room
		elseif Action == "GetLevel" then
			return PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel
		elseif Action == "JoinRoom" then
			local Joining = MatchMaking:JoinRoom(tbl, Player, PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel, PlayerStat.CurrentClass)
			if typeof(Joining) == "table" then
				for i = 1, #Joining.Players do
					if Joining.Players[i].PlayerObject ~= Player then
						Sockets:GetSocket(Joining.Players[i].PlayerObject):Emit("Matchmake", "PlayerJoin", Joining)
					end
				end
			end
			return Joining
		elseif Action == "LeaveRoom" then
			local Leaving = MatchMaking:LeaveRoom(Player)
			if typeof(Leaving) == "table" then
				for i = 1, #Leaving.Players do
					Sockets:GetSocket(Leaving.Players[i].PlayerObject):Emit("Matchmake", "PlayerLeft", Leaving) --Check if player == new host
				end
			end
		elseif Action == "GetRooms" then
			return MatchMaking:GetRooms(Player, PlayerStat.StoryProgression, IsPremium(), PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel)
		elseif Action == "GetMaps" then
			return MatchMaking:GetMapList(PlayerStat.StoryProgression, IsPremium(), tbl), IsPremium()
		elseif Action == "GetHighScore" then
			return MatchMaking:GetTop50(tbl[1], tbl[2])
		elseif Action == "GetCurrentRoom" then
			return MatchMaking:GetCurrentRoom(Player)
		elseif Action == "KickPlayer" then
			local Kicked = MatchMaking:KickPlayer(Player, tbl)
			if typeof(Kicked) == "table" then
				for i = 1, #Kicked.Players do
					if Kicked.Players[i].PlayerObject ~= Player then
						Sockets:GetSocket(Kicked.Players[i].PlayerObject):Emit("Matchmake", "PlayerLeft", Kicked) --Check if player == new host
					end
				end
			end
			return Kicked
		elseif Action == "StartDungeon" then
			local Room = MatchMaking:GetCurrentRoom(Player)
			if Room then
				if Room.StartReady and Player == Room.Host.PlayerObject then 
					local ReserveTime = os.time()
					local RoomPlayers = {}
					local Errors = {}
					local CanProceed = true
					for i = 1, #Room.Players do
						local Player = Room.Players[i]
						local id = Player.PlayerObject.UserId
						local CurrLvl = PlayerStat.Characters[PlayerStat.CurrentClass].CurrentLevel
						if Room.Difficulty then
							if CurrLvl < Room.Map.MinLevelHero then
								CanProceed = false
								Player.Level = CurrLvl
								tbi(Errors, Player)
							end
						end
						if Room.EveryoneMustDie then
							if CurrLvl < 200 then
								CanProceed = false
								Player.Level = CurrLvl
								tbi(Errors, Player)
							end
						end
						tbi(RoomPlayers, Player)
					end
					for i = 1, #RoomPlayers do
						local Player = RoomPlayers[i]
						if CanProceed then
							Sockets:GetSocket(Player.PlayerObject):Emit("StartingDungeon")
							local TargetPlayerStat = PlayerManager:GetPlayerStat(Player.PlayerObject.UserId)
							local TCombatState = PlayerManager:GetCombatState(Player.PlayerObject.UserId)
							TargetPlayerStat.LastReserveCode = tostring(Room.PrivateID)
							TargetPlayerStat.LastReserveTime = ReserveTime
							TCombatState.LastSave = 0
							PlayerManager:UpdateCombatState(Player.PlayerObject.UserId, TCombatState)
							local data = saveData(Player.PlayerObject.UserId, Player.PlayerObject, true)
							if data == "saved" then
								PlayerManager:RemovePlayerStat(Player.PlayerObject.UserId)
								PlayerManager:RemoveCombatState(Player.PlayerObject.UserId)
							end
						else
							Sockets:GetSocket(Player.PlayerObject):Emit("ErrorDungeon", Room, Errors)
						end
					end
					if CanProceed then
						print("Is host! Now transitioning!")
						MatchMaking:StartDungeon(Player, Room.ReserveCode, ReserveTime, Room.PrivateID)
					else
						print("Error! Some players are low level!")
					end
				else
					print("Room is not ready!")
				end
			else
				print("Room not found!")
			end
		elseif Action == "GetLootInfos" then
			if typeof(tbl.Difficulty) == "boolean" then
				local EMD = tbl.EveryoneMustDie and tbl.EveryoneMustDie or false
				local Diff = tbl.Difficulty and "Hero" or "Normal"
				if EMD == true then
					Diff = "HeroesMustDie"
				end
				local NewLootStuff = WeaponCraft:PreviewLootLists(tbl.Map.MissionName, Diff)
				local NewMaterialStuff = {}
				for gemRarity, _ in pairs(tbl.Map.GemDrops.Loot) do
					local chosen = LootInfo:GetGemPlaceholderFromRarity(tonumber(gemRarity))
					table.insert(NewMaterialStuff, chosen)
				end
				for name, _ in pairs(tbl.Map.MaterialDrops.Loot) do
					local chosen = LootInfo:GetLootFromName(false, name)
					table.insert(NewMaterialStuff, chosen)
				end
				return NewLootStuff, NewMaterialStuff
			end
			return nil
		end
	end)
	
end

return logic
