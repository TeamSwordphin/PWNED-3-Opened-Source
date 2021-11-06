-- << Services >> --
local ReplicatedStorage 	= game:GetService("ReplicatedStorage")
local Players 				= game:GetService("Players")
local TweenService			= game:GetService("TweenService")
local GuiService			= game:GetService("GuiService")
local ContextActionService 	= game:GetService("ContextActionService")
local Teams                 = game:GetService("Teams")

-- << Constants >> --
local CLIENT    = script.Parent.Parent.Parent
local BINDABLES = CLIENT.Bindables
local PLAYER 	= Players.LocalPlayer
local GUI 		= PLAYER:WaitForChild("PlayerGui")
local NEWMENU 	= GUI:WaitForChild("DesktopPauseMenu").Base.Mask
local EDIT      = NEWMENU.EditWindow

-- << Modules >> --
--local OpenMenu = require(script.Parent.Parent.TabMenuHandler)

-- << Variables >> --
local Buttons = {}


-------------------------
BINDABLES.ControllerClose.Event:Connect(function()
    if not EDIT.Visible and NEWMENU.Size.Y.Scale > 0 then
 --       OpenMenu()
    end
end)

for _, DisplayButtons in ipairs(NEWMENU.OuterFrame.Buttons:GetChildren()) do
    if DisplayButtons:IsA("ImageButton") then
        Buttons[DisplayButtons.Name] = function()
            ReplicatedStorage.Sounds.SFX.UI.Click:Play()
            for _,DisplayButtons2 in ipairs(NEWMENU.OuterFrame.Buttons:GetChildren()) do
                if DisplayButtons2:IsA("ImageButton") then
                    TweenService:Create(DisplayButtons2,TweenInfo.new(0.25),{ImageColor3 = Color3.fromRGB(134, 134, 134)}):Play()
                    if NEWMENU.OuterFrame.ContentWindow:FindFirstChild(DisplayButtons2.Name) then
                        NEWMENU.OuterFrame.ContentWindow[DisplayButtons2.Name].Visible = false
                    end
                end
            end
            NEWMENU.OuterFrame.Texter.NavButtonSelection.Text = DisplayButtons.Name
            TweenService:Create(DisplayButtons,TweenInfo.new(0.25),{ImageColor3 = Color3.fromRGB(255, 246, 146)}):Play()
            if NEWMENU.OuterFrame.ContentWindow:FindFirstChild(DisplayButtons.Name) then
                NEWMENU.OuterFrame.ContentWindow[DisplayButtons.Name].Visible = true
            end
        end
        DisplayButtons.MouseButton1Down:Connect(function()
            Buttons[DisplayButtons.Name]()
        end)
    end
end

function getActiveMenu()
    for _, menu in ipairs(NEWMENU.OuterFrame.ContentWindow:GetChildren()) do
        if menu:IsA("Frame") and menu.Visible then
            return menu, NEWMENU.OuterFrame.Buttons[menu.Name]
        end
    end
end

function selection(actionName, inputState, inputObject)
    if EDIT.Visible then return end

    if NEWMENU.Size.Y.Scale > 0 and inputState == Enum.UserInputState.Begin and PLAYER.TeamColor == Teams.Lobby.TeamColor then
        local menu, button = getActiveMenu()
        if actionName == "SelectLeft" then
            if button.NextSelectionLeft then
                Buttons[button.NextSelectionLeft.Name]()
            end
        elseif actionName == "SelectRight" then
            if button.NextSelectionRight then
                Buttons[button.NextSelectionRight.Name]()
            end
        end
    end
end

ContextActionService:BindActionAtPriority("SelectLeft", selection, false, 1, Enum.KeyCode.ButtonL1, Enum.KeyCode.Q)
ContextActionService:BindActionAtPriority("SelectRight", selection, false, 1, Enum.KeyCode.ButtonR1, Enum.KeyCode.E)
----------
return nil