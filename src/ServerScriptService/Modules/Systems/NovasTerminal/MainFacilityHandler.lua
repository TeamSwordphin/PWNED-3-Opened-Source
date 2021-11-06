local facilities = {}
local facilityHandler = {}

local facilitiesFolder = script.Parent.Facilities

for _, facility in ipairs(facilitiesFolder:GetChildren()) do
    table.insert(facilities, require(facility))
end

function facilityHandler:GetFacilities()
    return facilities
end

function facilityHandler:GetFacilityFromID(id)
    for _, facility in ipairs(facilities) do
        if facility.ID == id then
            return facility
        end
    end
end

return facilityHandler 