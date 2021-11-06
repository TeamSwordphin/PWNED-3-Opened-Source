local Players = game:GetService("Players")

local Modules = script.Parent.Parent.Parent.Modules
local PlayerManager	= require(Modules.PlayerStatsObserver)
local Sockets = require(Modules.Utility["server"])
local Vestiges = require(Modules.Systems.Vestiges)
local ChatTitles = require(Modules.Systems.Titles)
local WeaponCraft = require(Modules.CharacterManagement.WeaponCrafting)

local function AddReward(index, value)
    return {
        Type = index,
        Value = value
    }
end

return function(id)
    local Stats = PlayerManager:GetPlayerStat(id)
	
    if Stats then
        local InformationList = {}
        for Index, Value in pairs(Stats.UnclaimedAchievements) do
            if Stats[Index] then
                if Index == "Tears" or Index == "Gold" then
                    Stats[Index] += Value
                    table.insert(InformationList, AddReward(Index, Value))
                else
                    for _, ID in ipairs(Value) do
                        if Index == "Vestiges" and not table.find(Stats[Index], ID) then
                            table.insert(Stats[Index], ID)
                            local Vestige = Vestiges:GetVestigeFromID(ID)
                            table.insert(InformationList, AddReward(Index, Vestige.Name))
                        elseif Index == "Infusions" and not table.find(Stats[Index], ID) then
                            table.insert(Stats[Index], ID)
                            local infusion = WeaponCraft:GetSkillFromID(ID)
                            table.insert(InformationList, AddReward(Index, infusion.Name))
                        elseif Index == "ChatTitles" then
                            local chatTitle = ChatTitles:GetTitleFromID(ID)
                            if not table.find(Stats[Index], chatTitle.Name) then
                                table.insert(InformationList, AddReward(Index, chatTitle.Name))
                                table.insert(Stats[Index], chatTitle.Name)
                            end
                        elseif Index == "Titles" then --- Banners
                            table.insert(InformationList, AddReward(Index, ID))
                            --- TBA
                        end
                    end
                end
            end
        end
        Stats.UnclaimedAchievements = {}
        
        return #InformationList >= 1 and InformationList or nil
    end
end
