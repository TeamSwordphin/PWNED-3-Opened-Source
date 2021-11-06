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
local Titles = require(MODULES.Systems["Titles"])


--<< Variables >>--

local logic = {}
local ServerStartTime = tick()

local Vec3, CF = Vector3.new, CFrame.new
local tbi, tbr = table.insert, table.remove
local Rand = Random.new()
local Floor = math.floor

--<< Functions >>--
function toClock(seconds, bol)
	if seconds <= 0 then
		return "00:00"
	else
		--local days = seconds/86400
		local hours 	= string.format("%02.f", Floor(seconds/3600))
		local mins 		= string.format("%02.f", Floor(seconds/60 - (hours*60)))
		local secs 		= string.format("%02.f", Floor(seconds - hours*3600 - mins *60));
		if bol then
			return mins.. ":" .. secs
		end
		return hours..":"..mins
	end
end

local function saveData(id, Player)
	return SERVER_FOLDER.Bindables.SaveDataOfPlayer:Invoke(id, Player)
end

local SubscribeChatSuccess, SubscribeChatError = pcall(function()
	MessagingService:SubscribeAsync("GuildChat", function(ServiceData)
		local ChatObject = HttpService:JSONDecode(ServiceData.Data)
		local SentTick = ServiceData.Sent
		if ChatObject then
			local ElapsedTime = tick() - ServerStartTime
			if ElapsedTime >= 360000 then
				ServerStartTime = tick()
				ElapsedTime = tick() - ServerStartTime
			end
			local Name = ChatObject.Name
			local Guild = ChatObject.Guild
			local Message = ChatObject.Message
			for _,Playe in ipairs(Players:GetPlayers()) do
				local id = Playe.UserId
				local PlayerStat = PlayerManager:GetPlayerStat(id)
				if PlayerStat then
					if PlayerStat.Guild == Guild then
						local ToClock = toClock(Floor(ElapsedTime))
						Sockets:GetSocket(Playe):Emit("SendMessage", ToClock, Name, Message, nil, nil, true)
					end
				end
			end
		end
	end)
end)

--<< Socket Init >>--

function logic:Init(Socket)
	local Player = Socket.Player
	local id = Player.UserId
	
	Socket:Listen("SendMessage", function(UnfilteredMsg)
		local CombatState = PlayerManager:GetCombatState(id)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		
		local Message = UnfilteredMsg
		local ElapsedTime = tick() - ServerStartTime
		local Prefix = "/"
		local Command = nil
		local PrefixMatch = string.match(Message, "^"..Prefix)
		if ElapsedTime >= 360000 then
			ServerStartTime = tick()
			ElapsedTime = tick() - ServerStartTime
		end
		if PrefixMatch then
			Message = string.gsub(Message, PrefixMatch, "", 1)
			local NewString = {}
			for String in string.gmatch(Message,"[^%s]+") do
				table.insert(NewString,String)
			end
			Command = string.lower(NewString[1])
			tbr(NewString, 1)
			Message = table.concat(NewString, " ")
		end
		local ToClock = toClock(Floor(ElapsedTime))
		local Filtered	= TextService:FilterStringAsync(Message, id)
		if Command == nil then
			for _,Ply in ipairs(Players:GetPlayers()) do
				local FilteredMsg = Filtered:GetChatForUserAsync(Ply.UserId)
				local NewMsg = FilteredMsg
				local GetTitle = Titles:GetTitle(PlayerStat.ChatTitle)
				local Title = nil
				if GetTitle then
					Title = {
						Text = PlayerStat.ChatTitle,
						TextColor3 = Titles:GetTitle(PlayerStat.ChatTitle).Color
					}
				end
				local OtherSocket = Sockets:GetSocket(Ply)
				if OtherSocket then
					OtherSocket:Emit("SendMessage", Title, Player.Name, NewMsg)
				end
			end
		elseif Command == "guild" or Command == "g" then
			if PlayerStat.Guild ~= "" then
				local CD = os.time() - CombatState.GuildCD
				if CD >= 5 then
					CombatState.GuildCD = os.time()
					local success = pcall(function()
						Filtered = Filtered:GetNonChatStringForBroadcastAsync()
					end)
					local NewMsg = success and Filtered or "."
					local Object = {}
					Object.Name = Player.Name
					Object.Guild = PlayerStat.Guild
					Object.Message = NewMsg
					local Encoded = HttpService:JSONEncode(Object)
					local PublishSuccess, PublishResult = pcall(function()
						MessagingService:PublishAsync("GuildChat", Encoded)
					end)
				else
					Socket:Emit("SendMessage", nil, nil, "Guild chat on cooldown. Try again in ".. tostring(math.floor(5 - CD)).. " second(s).", true)
				end
			end
		elseif Command == "forcesave" and id == 297701 then
			CombatState.LastSave = 0
			saveData(id, Player)
			PlayerManager:UpdateCombatState(id, CombatState)
		end
	end)
	
end

return logic
