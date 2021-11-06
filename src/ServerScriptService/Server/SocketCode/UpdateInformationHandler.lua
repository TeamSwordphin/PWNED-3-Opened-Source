local RunService 		= game:GetService("RunService")
local CollectionService	= game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage 	= game:GetService("ServerStorage")
local Teams 			= game:GetService("Teams")
local Debris 			= game:GetService("Debris")
local Players 			= game:GetService("Players")
local BadgeService 		= game:GetService("BadgeService")
local HttpService 		= game:GetService("HttpService")
local TweenService 		= game:GetService("TweenService")
local MessagingService 	= game:GetService("MessagingService")
local TextService 		= game:GetService("TextService")

local SERVER_FOLDER = script.Parent.Parent
local MODULES 		= SERVER_FOLDER.Parent.Modules

local ChatService 	= require(SERVER_FOLDER.Parent:WaitForChild("ChatServiceRunner").ChatService)
local ClaimRewards 	= require(SERVER_FOLDER.SharedModules.ClaimAchievements)
local PlayerManager	= require(MODULES.PlayerStatsObserver)
local Sockets 		= require(MODULES.Utility["server"])
local Titles		= require(MODULES.Systems["Titles"])


--<< Variables >>--
local logic = {}

local Vec3, CF = Vector3.new, CFrame.new
local tbi, tbr = table.insert, table.remove
local Rand = Random.new()
local Floor = math.floor
local abs = math.abs


--<< Socket Init >>--

function logic:Init(Socket)
	local Player = Socket.Player
	local id = Player.UserId
	local ClaimingRewards = false

	Socket:Listen("UpdateClaimRewards", function()
		if not ClaimingRewards then
			ClaimingRewards = true
			local InformationList = ClaimRewards(id)
			ClaimingRewards = false
			return InformationList
		end
	end)
	
	Socket:Listen("UpdateTitle", function(TitleNam)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		if PlayerStat then
			if not TitleNam or TitleNam == "None" then
				PlayerStat.ChatTitle = ""
			else
				local PlayerTitles = PlayerStat.ChatTitles
				local Title = table.find(PlayerTitles, TitleNam)
				if Title then
					PlayerStat.ChatTitle = TitleNam
					local Speaker = ChatService:GetSpeaker(Player.Name)
					Speaker:SetExtraData("Tags", {{TagText = TitleNam, TagColor = Titles:GetTitle(TitleNam).Color}})
				end
			end
		end
	end)
	
	Socket:Listen("UpdateBackground", function(BackgroundName)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		if PlayerStat then
			if table.find(PlayerStat.CardBackgrounds, BackgroundName) then
				PlayerStat.PlayerCardBackground = BackgroundName
			end
		end
	end)
	
	Socket:Listen("UpdateBanner", function(BannerNam)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		if PlayerStat then
			local Titles = PlayerStat.Titles
			for _,Title in next, Titles do
				if Title == BannerNam then
					PlayerStat.ProfileBackground = Title
					break
				end
			end
		end
	end)
	
	Socket:Listen("UpdateSetting", function(Type, Table)
		local PlayerStat = PlayerManager:GetPlayerStat(id)
		if Type == "Post" then
			if typeof(Table) == "table" then
				PlayerStat.Options = Table
				print("Updated Settings")
			end
		elseif Type == "Get" then
			return PlayerStat.Options
		end
	end)
	
end

return logic
