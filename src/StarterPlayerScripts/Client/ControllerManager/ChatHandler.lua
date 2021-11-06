-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players 			= game:GetService("Players")
local TweenService		= game:GetService("TweenService")
local Debris			= game:GetService("Debris")
local Teams				= game:GetService("Teams")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local NEWMENU 	= GUI:WaitForChild("DesktopPauseMenu").Base.Mask
local Chat 		= GUI:WaitForChild("Chat")

-- << Modules >> --
local Socket 		= require(MODULES.socket)
local DataValues 	= require(CLIENT.DataValues)
local FS 		  	= require(ReplicatedStorage.Scripts.Modules.FastSpawn)

-- << Variables >> --
local Camera	= workspace.Camera
local bools 	= DataValues.bools


-------------------------------------

--[[
Socket:Listen("SendMessage", function(ElapsedTime, PlayerName, FilteredMsg, sy, gam, guild)
	local IsSystem = sy or false
	local IsGame = gam or false
	local IsGuild = guild or false
	if DataValues.WatchedIntro or IsSystem then
		TweenService:Create(ChatBox.ChatLabel, TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0), {CanvasPosition = Vector2.new(0,999)}):Play()
		local count = 0
		for _,v in next, ChatBox.ChatLabel:GetChildren() do
			if v:IsA("Frame") then
				v.Name = (18-count).."ChatLine"
				if v.Name == "0ChatLine" then
					v.Parent["17ChatLine"]:Destroy()
				end
			end
			count = count + 1
		end
		local TextLine = ReplicatedStorage.GUI.NormalGui.ChatLine1:clone()
		if IsSystem then
			TextLine.Namer.Text = "[SYSTEM] "
			TextLine.Namer.TextColor3 = Color3.fromRGB(255, 169, 169)
			TextLine.Chat.TextColor3 = Color3.fromRGB(255, 76, 76)
			if PLAYER.TeamColor == Teams.Lobby.TeamColor then
				FS.spawn(function()
					wait(1)
					if Camera.PlayerHPs:FindFirstChild(PLAYER.Name) then
						Camera.PlayerHPs[PLAYER.Name].Player.Namer.Text = PLAYER.Name
					end
				end)
			end
		elseif IsGame then
			TextLine.Namer.Text = "[GAME] "
			TextLine.Namer.TextColor3 = Color3.fromRGB(236, 255, 24)
			TextLine.Chat.TextColor3 = Color3.fromRGB(255, 255, 158)
		elseif IsGuild then
			TextLine.Namer.Text = "[" ..ElapsedTime.. "][Guild] " ..PlayerName.. ": "
			TextLine.Namer.TextColor3 = Color3.fromRGB(211, 107, 255)
			TextLine.Chat.TextColor3 = Color3.fromRGB(232, 55, 255)
		else
			if ElapsedTime then
				TextLine.Title.Text = "[" .. ElapsedTime.Text .. "] "
				TextLine.Title.TextColor3 = ElapsedTime.TextColor3
				TextLine.Title.Visible = true
			end
		end
		TextLine.Parent = ChatBox -- temp
		local spacesName = {}
		for  i = 1,(TextLine.Title.TextBounds.X)/3 do
			table.insert(spacesName, " ")
		end
		if TextLine.Namer.Text == "" then
			TextLine.Namer.Text = table.concat(spacesName).. "" ..PlayerName.. ": "
		end
		local spaces = {}
		for  i = 1,(TextLine.Namer.TextBounds.X)/3 do
			table.insert(spaces, " ")
		end
		TextLine.Chat.Text = table.concat(spaces).. "" ..FilteredMsg
		local YSize = .001
		for i = 1, 500 do
			if TextLine.Chat.TextFits == false then
				TextLine.Size = UDim2.new(1,0,YSize,0)
				YSize = YSize + .001
			else
				break
			end
		end
		TextLine.Parent = ChatBox.ChatLabel
	end
end)
--]]
return nil
