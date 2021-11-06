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
local ANALYZE   = EDIT.NotHide.AnalyzeWindow

-- << Modules >> --
local DataValues = require(CLIENT.DataValues)

-- << Variables >> --
local closeBindable 


-------------------------
function determineActiveWindow()
    for _, window in ipairs(EDIT:GetChildren()) do
        if window:IsA("Frame") and window.Visible then
            return window
        end
    end
end

EDIT:GetPropertyChangedSignal("Visible"):Connect(function()
    if closeBindable then
        closeBindable:Disconnect()
    end

    if DataValues.ControllerType == "Controller" and EDIT.Visible then
        local window = determineActiveWindow()
        if window then
            closeBindable = BINDABLES.ControllerClose.Event:Connect(function()
                GuiService.SelectedObject = ANALYZE.Buttons.BackButton
            end)
            local scrollingFrame = window:FindFirstChildOfClass("ScrollingFrame")
            if scrollingFrame then
                GuiService.SelectedObject = scrollingFrame
            end
        end
    end
end)

----------
return nil