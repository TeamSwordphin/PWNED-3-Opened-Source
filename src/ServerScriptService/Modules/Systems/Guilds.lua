--[[
	
	TO DO: Solve save issues (having everytthing in one data store makes it so we can only have about 2k guilds!)
	Brainstorm: Have different scopes per 1500 guilds
	
	
	
	OrderedDataStore
	
	Save Key with GuildID as it's Value
	If game needs someone's guild, GetASync Guild ID, and cache it in the Guild Folder
	--- but then figure out how to do names??
		
		
	GUILDXP
	Players can contribute to their guild's XP, but leader must be in the same server for the guild xp to update and save
	
	
	Leaving Guild
	Leaving a guild will forfeit all Guild EXP Contributions and any Guild Skills that the guild has acquired. You will still be listed on the guild members page until the owner kicks you, but you are able to
	join another guild.
	
	Guild Teleport
	-Teleport guild members to a new place for easy matchmaking
	
	Guild Megaphone
	-You cannot use the Guild Megaphone for another 10 seconds!
--]]

local GuildPerkList = {
	{
		Name = "Guild EXP Increase",
		Desc = "Increases EXP earned to all Guild Members by 15% for 1 hour.",
		Duration = 3600,
		PtsCost = 30000,
		GuildLevelReq = 10
	},
	{
		Name = "Guild Gold Increase",
		Desc = "Increases Gold earned to all Guild Members by 30% for 1 hour.",
		Duration = 3600,
		PtsCost = 30000,
		GuildLevelReq = 20
	},
	{
		Name = "Guild Durability Increase",
		Desc = "Decreases damage taken to all Guild Members by 10% for 1 hour.",
		Duration = 3600,
		PtsCost = 30000,
		GuildLevelReq = 30
	},
	{
		Name = "Guild Attack Increase",
		Desc = "Increases damage for all Guild Members by 5% for 1 hour.",
		Duration = 3600,
		PtsCost = 30000,
		GuildLevelReq = 40
	},
	{
		Name = "Guild Token Rewards",
		Desc = "Every completed dungeon on Hero Difficulty rewards 1 Enchantment Token for 1 hour.",
		Duration = 3600,
		PtsCost = 100000,
		GuildLevelReq = 70
	}
}

local module = {}

local TextService = game:GetService("TextService")
local DataStore = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local HTTPService = game:GetService("HttpService")

local Scope = "RealGuilds" ----Change soon to 123
local Guilds = {}
local GuildLeaderboard = {}
local SaveGuilds = true
local CanPublish = true

local RequestsPerMinute = 10 -- +5 per player
local LastUpdated = 0

local MaxRequests = RequestsPerMinute

local l = string.lower

function module:GetGuildData(Name, Save)
	local SaveToTable = Save and Save or true
	local Guild = module:GetGuild(Name)
	if Guild == nil then
		if os.time() - LastUpdated >= 60 then
			LastUpdated = os.time()
			RequestsPerMinute = MaxRequests+#game.Players:GetPlayers()
		end
		if RequestsPerMinute > 0 then
			RequestsPerMinute = RequestsPerMinute - 1
			local success, JSON = pcall(function()
				local scope = DataStore:GetDataStore(Scope)
				local ScopeName = l(Name)
				return scope:GetAsync(ScopeName)
			end)
			if success then
				print(JSON)
				if JSON == nil then
					return nil
				else
					Guild = HTTPService:JSONDecode(JSON)
					if SaveToTable then
						table.insert(Guilds, Guild)
					end
					Guild.Last = os.time()
					Guild.TPTimer = 0
					Guild.TPQueue = {}
					return Guild
				end
			else
				print("error: " .. JSON)
				return "error"
			end
		else
			return "Requests Throttled"
		end
	else
		print("Already Pre-existing guild!")
		return Guild
	end
end

function module:SaveGuildData(Name, Force)
	local ForceSave = Force and Force or false
	if SaveGuilds then
		local Guild = module:GetGuild(Name)
		if Guild then
			if ForceSave or module:GetOwner(Guild) then
				local JSON = HTTPService:JSONEncode(Guild)
				local success, errorMessage = pcall(function()
					local scope = DataStore:GetDataStore(Scope)
					local ScopeName = l(Name)
					scope:UpdateAsync(ScopeName, function(oldJSON)
						local newJSON 	= oldJSON or nil
						local CanUpdate = true
						if CanUpdate then
							newJSON = JSON
						end
						return 			newJSON
					end)
				end)
				if not success then
					print("error saving guild")
					return "errored guild list"
				else
					print("saved guild list " ..Guild.Name.. "(" .. string.len(JSON).. "/ 260000)")
					return "saved guild list " ..Guild.Name
				end
			else
				print("Owner not in the game!")
			end
		else
			print("No guilds with that name!")
		end
	else
		print("Saving Guilds was down!")
	end
end

function module:RemoveGuild(Name)
	local Guild = module:GetGuild(Name)
	if Guild then
		for i = 1, #Guilds do
			if Guilds[i].Name == Guild then
				table.remove(Guilds, i)
				print("Remove Guild")
				break
			end
		end
	end
end


---if someone is in the guild and was kicked, when kicked player joins game, iterate thru guild list and member from their GuildName and see if they are missing, if they are, remove
--Msg: This player has been removed from the guild. Their status will update the next time they join the game.
---test with friends on creating guild on one server while the other waits for the other guild to pop up in anothe server
--[[
local SubscribeSuccess, SubscribeError = pcall(function()
	MessagingService:SubscribeAsync("UpdateGuild", function(ServiceData)
		if Guilds then
			local GuildToUpdate = HTTPService:JSONDecode(ServiceData.data)
			local SentTick = ServiceData.sent
			local Found = module:GetGuild()
			if Found then
				for i = 1, #Guilds do
					local Guild = Guilds[i]
					if string.lower(Guild.Name) == string.lower(GuildToUpdate.Name) and Guild.Last < GuildToUpdate.Last then
						Guild = GuildToUpdate
						break
					end
				end
			end
		else
			print("Guild Services are down!")
		end
	end)
end)

if not SubscribeSuccess then
	warn(SubscribeError)
	SaveGuilds = false
end

function module:UpdateGuild(GuildSettings)
	if CanPublish then
		local PublishSuccess, PublishResult = pcall(function()
			local EncodeGuildSettings = HTTPService:JSONEncode(GuildSettings)
			MessagingService:PublishAsync("UpdateGuild", EncodeGuildSettings)
		end)
		return PublishSuccess, PublishResult
	end
end--]]

function module:GetGuild(Name, L)
	local Load = L and L or false
	if Load then
		return module:GetGuildData(Name)
	end
	for i = 1, #Guilds do
		local Guild = Guilds[i]
		if l(Guild.Name) == l(Name) then
			return Guild
		end
	end
	return nil
end

function module:GetOwner(GuildObject)
	local Players = game.Players:GetPlayers()
	for i = 1, #Players do
		if Players[i].UserId == GuildObject.Owner then
			return true
		end
	end
	return false
end

function module:UpdateMembers(GuildName, PlayerID, Mode)
	if module:GetGuild(GuildName) then
		for i = 1, #Guilds do
			local Guild = Guilds[i]
			if l(GuildName) == l(Guild.Name) and module:GetOwner(Guild) then
				if Mode == "Add" then
					if #Guild.Members < Guild.MaxM then
						local FoundID = false
						for v = 1, #Guild.Members do
							if Guild.Members[v].ID == PlayerID then
								FoundID = true
								return "Found player in guild already!"
							end
						end
						if not FoundID then
							table.insert(Guild.Members, module:CreatePlayerObj(PlayerID))
							return "Added Player!"
						end
					else
						return "Max members"
					end
				elseif Mode == "Remove" and PlayerID ~= Guild.Owner then
					for v = 1, #Guild.Members do
						print(PlayerID, Guild.Members[v].ID)
						if Guild.Members[v].ID == PlayerID then
							table.remove(Guild.Members, v)
							return "Removed player!"
						end
					end
					return "No player found with that name!"
				end
			end
		end
	else
		return "There are no guilds with that name!"
	end
end

function module:UpdateGuildEXP(GuildName, ID, EXP)    ----should for loop all the players on the team so it gets called once and not per player
	if module:GetGuild(GuildName) then
		for i = 1, #Guilds do
			local Guild = Guilds[i]
			if l(GuildName) == l(Guild.Name) then
				if module:GetOwner(Guild) then
					Guild.XP = Guild.XP + EXP
					Guild.Pts = Guild.Pts + EXP*1.2
					for v = 1, #Guild.Members do
						if Guild.Members[v].ID == ID then
							Guild.Members[v].EXPContributions = Guild.Members[v].EXPContributions + EXP
						end
					end
					local newLv = 0.05 * math.sqrt(Guild.XP)
					if Guild.CurLvl < math.floor(newLv+.5) then
						Guild.CurLvl = math.floor(newLv+.5)
					end
					if os.time()-Guild.Last >= 60 then
						Guild.Last = os.time()
						module:SaveGuildData(Guild.Name)
					end
					return "Updated EXP!"
				else
					return "No Owner"
				end
			end
		end
	else
		return "There are no guilds with that name!"
	end
end

function module:CreatePlayerObj(ID)
	local Play = {}
	Play.ID = ID
	Play.JoinDate = os.date("*t")
	Play.EXPContributions = 0
	return Play
end

function module:GetPerks()
	return GuildPerkList
end

function module:AddPerks(Perks, GuildName)
	--[[
		local Perks = {}
		local NewPerk = {}
		NewPerk.Name = ""
		NewPerk.DurationInSeconds = 0
		table.insert(Perks, NewPerk)
	--]]
	if module:GetGuild(GuildName) then
		for i = 1, #Guilds do
			local Guild = Guilds[i]
			if l(GuildName) == l(Guild.Name) then
				if module:GetOwner(Guild) then 
					if os.time()-Guild.Last >= 60 then
						Guild.Last = os.time()
						for v = 1, #Perks do
							local Found = false
							for b = 1, #Guild.Perks do
								if Guild.Perks[b].Name == Perks[v].Name then
									if os.time() < Guild.Perks[b].Expiration then
										Found = true
										Guild.Perks[b].Expiration = Guild.Perks[b].Expiration + Perks[v].DurationInSeconds
									else
										table.remove(Guild.Perks, b)
									end
								end
							end
							if not Found then
								local Perk = {}
								Perk.Name = Perks[v].Name
								Perk.Expiration = os.time()+Perks[v].DurationInSeconds
								table.insert(Guild.Perks, Perk)
							end
						end
						module:SaveGuildData(Guild.Name)
						break
					else
						return "Throttled"
					end
				end
			end
		end
	end
end

function module:TransferGuildOwnership(GuildName, OwnerID, NewOwnerID) ----MIGHT NOT USE, user might circumvent guild cost prices
	if OwnerID ~= NewOwnerID then
		if module:GetGuild(GuildName) then
			for i = 1, #Guilds do
				local Guild = Guilds[i]
				if l(GuildName) == l(Guild.Name) then
					if module:GetOwner(Guild) and OwnerID == Guild.Owner then
						for v = 1, #Guild.Members do
							if Guild.Members[v].ID == NewOwnerID then
								Guild.Owner = NewOwnerID
							end
						end
						break
					end
				end
			end
		end
	end
end

function module:FilterNameForPreview(name, id)
	local Filtered, FilteredMsg = TextService:FilterStringAsync(name, id)
	local success, _ = pcall(function()
		FilteredMsg = Filtered:GetNonChatStringForBroadcastAsync()
	end)
	local NewMsg = success and FilteredMsg or "Filtered"
	return NewMsg
end

function module:CreateGuild(Settings, Player)
	local name = Settings.Name and Settings.Name or  ""
	local Success = false
	if typeof(Settings.Name) == "string" and Settings.Description and typeof(Settings.Description) == "string" then
		if string.len(Settings.Name) >= 3 and string.len(Settings.Name) <= 20 then
			if os.time() - LastUpdated >= 60 then
				LastUpdated = os.time()
				RequestsPerMinute = MaxRequests+(#game.Players:GetPlayers()*3)
			end
			if module:GetGuildData(name, false) == nil then
				if RequestsPerMinute > 0 then
					RequestsPerMinute = RequestsPerMinute - 1
					local GuildSettings = {
						Name = "",
						GuildDesc = "",
						Owner = 0, --usserid
						Last = os.time(),
						MaxM = 10,
						CurLvl = 1,
						XP = 400,
						Pts = 0,
						Members = {},
						Perks = {},
						TPTimer = 0,
						TPQueue = {}
					}
					local id = Player.UserId
					local Filtered, FilteredMsg = TextService:FilterStringAsync(name, id)
					local success, _ = pcall(function()
						FilteredMsg = Filtered:GetNonChatStringForBroadcastAsync()
					end)
					GuildSettings.Name = success and FilteredMsg or "...."
					local Filtered2, FilteredMsg2 = TextService:FilterStringAsync(Settings.Description, id)
					local success2, _ = pcall(function()
						FilteredMsg2 = Filtered:GetNonChatStringForBroadcastAsync()
					end)
					GuildSettings.GuildDesc = success2 and FilteredMsg2 or "No information about this guild."
					GuildSettings.Owner = id
					table.insert(GuildSettings.Members, module:CreatePlayerObj(id))
					table.insert(Guilds, GuildSettings)
					module:SaveGuildData(GuildSettings.Name)
					return "Success", GuildSettings
				else
					return "Throttled"
				end
			else
				return "There is already a guild name with that!"
			end
		else
			return "Mismatched string length"
		end
	end
end


return module
