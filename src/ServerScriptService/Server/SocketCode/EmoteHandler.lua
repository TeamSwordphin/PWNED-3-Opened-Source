local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SERVER_FOLDER = script.Parent.Parent
local MODULES = SERVER_FOLDER.Parent.Modules

local FS = require(ReplicatedStorage.Scripts.Modules.FastSpawn)


--<< Variables >>--

local logic = {}

--<< Socket Init >>--

function logic:Init(Socket)
	local Player = Socket.Player
	local id = Player.UserId
	
	Socket:Listen("Emote", function(EmoteName)
		--[[
			Nitro Boosters only.
		--]]
		
		local EmojiIDs = {297701, 7801953, 23622609, 20118200, 396208410, 10786262, 36432851, 102087038}
		local CanEmote = false
		for i = 1, #EmojiIDs do
			if EmojiIDs[i] == id then
				CanEmote = true
				break
			end
		end
		if CanEmote then
			local SelectedEmote = ReplicatedStorage.GUI.Emotes:FindFirstChild(EmoteName)
			if SelectedEmote then
				if Player.Character.PrimaryPart:FindFirstChild("Emote") == nil then
					local MoteObj = ReplicatedStorage.GUI.BillboardGui.Emote:Clone()
					local SelectEmote = SelectedEmote:Clone()
					SelectEmote.Rotation = 360
					SelectEmote.ImageTransparency = 1
					SelectEmote.Size = UDim2.new(0,0,0,0)
					SelectEmote.Position = UDim2.new(.5,0,.5,0)
					SelectEmote.Parent = MoteObj
					MoteObj.Parent = Player.Character.PrimaryPart
					FS.spawn(function()
						TweenService:Create(SelectEmote, TweenInfo.new(.7,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), ImageTransparency = 0}):Play()
						TweenService:Create(SelectEmote, TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0), {Rotation = 0}):Play()
						wait(3)
						TweenService:Create(SelectEmote, TweenInfo.new(.7,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0), ImageTransparency = 1}):Play()
						TweenService:Create(SelectEmote, TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,0), {Rotation = -360}):Play()
					end)
					Debris:AddItem(MoteObj, 4)
				end
			end
		end
	end)
	
end

return logic
