--[[
Quick syntax:
    ---
    local CountMaterials = require(...)
    local requiredMaterials = {
        {"Ingredient 1", REQUIRED_COUNT},
        {"Ingredient 2", 10}
    }
    CountMaterials(PLAYER_ID, requiredMaterials, canRemoveMats)
--]]

-- << Constants >>
local SERVER_FOLDER = script.Parent.Parent
local MODULES       = SERVER_FOLDER.Parent.Modules

-- << Modules >>
local PlayerManager	= require(MODULES.PlayerStatsObserver)
local LootInfo      = require(MODULES.CharacterManagement["LootInfo"])

---
return function(id, listOfMaterials, canRemoveMats)
    local PlayerStat = PlayerManager:GetPlayerStat(id)
    
    if listOfMaterials then
        local Items = {}
        for i = 1, #listOfMaterials do
            if listOfMaterials[i][1] ~= "Gold" then
                local LootInfo = LootInfo:GetLootFromName(false, listOfMaterials[i][1])
                local Ingredient = {}
                Ingredient.Info = LootInfo
                Ingredient.ID = LootInfo.ID
                Ingredient.Maximum = listOfMaterials[i][2] --- Required Material costs
                Ingredient.OriginalMaximum = listOfMaterials[i][2] --- For the counter
                Ingredient.Quantity = 0 --- Only for counting totals
                for _, inventoryItem in ipairs(PlayerStat.Inventory) do
                    if inventoryItem.ID == Ingredient.ID then
                        Ingredient.Quantity += inventoryItem.Q
                    end
                end
                table.insert(Items, Ingredient)
            end
        end
        local HasMats = true

        for _, ReqItem in ipairs(Items) do
            if ReqItem.Quantity < ReqItem.Maximum then
                HasMats = false
            end
        end

        if HasMats then
            if canRemoveMats then
                local ItemsToBeRemoved = {}
                local completedBill = false
                for index, inventoryItem in ipairs(PlayerStat.Inventory) do
                    for _, cachedItem in ipairs(Items) do
                        if cachedItem.ID == inventoryItem.ID then
                            if inventoryItem.Q > cachedItem.Maximum then
                                inventoryItem.Q -= cachedItem.Maximum
                                completedBill = true
                                break
                            else
                                cachedItem.Maximum -= inventoryItem.Q
                                table.remove(PlayerStat.Inventory, index)
                            end
                        end
                    end
                    if completedBill then
                        break
                    end
                end

                --- Finalize counter
                for _, item in ipairs(Items) do
                    item.Quantity -= item.OriginalMaximum
                end
            end
        end

        print(Items, HasMats)
        return Items, HasMats
    end
end