-- << Services >> --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService 		= game:GetService("TweenService")
local Players			= game:GetService("Players")

-- << Constants >> --
local CLIENT 	= script.Parent.Parent
local MODULES 	= CLIENT.Parent:WaitForChild("Modules")
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")

-- << Modules >> --
local Socket 		= require(MODULES.socket)
local DataValues 	= require(CLIENT.DataValues)
local animateText 	= require(CLIENT.UIEffects.TextScrolling)
local FS 			= require(ReplicatedStorage.Scripts.Modules.FastSpawn)


-- << Functions >> --
function Dialogue(MSG, CharacterName)
	FS.spawn(function()
		local SideDialogue = GUI.MainDialogue.SideDialogue
		if DataValues.ControllerType == "Touch" then
			SideDialogue.Size = UDim2.new(0.8, 0, 0.4, 0)
		end
		for _, Dialogues in ipairs(SideDialogue:GetChildren()) do
			if Dialogues:IsA("Frame") then
				TweenService:Create(Dialogues, TweenInfo.new(.5), {Position = UDim2.new(0, 0, Dialogues.Position.Y.Scale - 0.15, Dialogues.Position.Y.Offset - 10), Size = UDim2.new(0.9, 0, 0.15, 0)}):Play()
				TweenService:Create(Dialogues.DialoguePosition, TweenInfo.new(.5), {Size = UDim2.new(0, 170, 1, 0)}):Play()
			end
		end
		local NewDialogue = SideDialogue.Parent.Templates.DialogueBar:Clone()
		local CharacterImage = ReplicatedStorage.GUI.NPCFaceCloseUp[CharacterName].Neutral.DialoguePosition:Clone()
		CharacterImage.Parent = NewDialogue
		NewDialogue.Visible = true
		NewDialogue.Parent = SideDialogue
		
		TweenService:Create(NewDialogue, TweenInfo.new(.5), {Position = UDim2.new(0, 0, 0.8, 0)}):Play()
		animateText(true, NewDialogue.Dialogue, MSG)
	
		wait(9)
		TweenService:Create(CharacterImage, TweenInfo.new(1), {BackgroundTransparency = 1, ImageTransparency = 1}):Play()
		TweenService:Create(NewDialogue.Dialogue, TweenInfo.new(1), {TextTransparency = 1}):Play()
		TweenService:Create(NewDialogue.Misc.BaseBG, TweenInfo.new(1), {ImageTransparency = 1}):Play()
		TweenService:Create(NewDialogue.Misc.Gradient, TweenInfo.new(1), {ImageTransparency = 1}):Play()
		wait(1)
		NewDialogue:Destroy()
	end)
end

Socket:Listen("Dialogue", function(MSG, CharacterName)
	Dialogue(MSG, CharacterName)
end)

return Dialogue
