local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Promise = require(ReplicatedStorage.Scripts.Modules.Promise)
local Matchmaking = require(ServerScriptService.Modules.Systems.Matchmaking)
local UniverseEvent = require(ServerScriptService.Modules.Utility.UniverseEvent)
local ProfileService = require(ServerScriptService.Modules.Utility.ProfileService)
local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)

local WorldProfile
local WorldProfileSystem = {}
local worldProfileDatastoreKey = "WorldEventTest5"
local worldProfileTemplate = ProfileService.GetProfileStore(
    "WorldEventData",
    {
        CurrentActiveEvents = {},
        UpcomingEventConditions = {}
    }
)

local worldEventNotifier = UniverseEvent.new("WorldEventStart")

local function handleWorldEvent(dataToBeHandled)
    local missionName = dataToBeHandled[1]
    local endTime = dataToBeHandled[2]
    local map = Matchmaking:GetMap(missionName)

    map.EndTime = endTime
    
    local eventSpeaker = ChatService:GetSpeaker("EVENT")
    eventSpeaker:SayMessage(string.format("A powerful foe awaits you in '%s'! Available now in the Events tab for 6 hours!", missionName), "All")
end

if not game:GetService("RunService"):IsStudio() then
    worldEventNotifier.Event:Connect(handleWorldEvent)
end

local function handleLockedUpdates(globalUpdates, update, worldEventData)
    local id = update[1]
    local data = update[2]
    local map = Matchmaking:GetMap(data.missionName)
    local activeMission = worldEventData.CurrentActiveEvents[data.missionName]

    if map and map.ActiveEventGoal and not activeMission then
        local foundMap = worldEventData.UpcomingEventConditions[data.missionName]

        if not foundMap then
            worldEventData.UpcomingEventConditions[data.missionName] = 0
        end

        worldEventData.UpcomingEventConditions[data.missionName] += 1

        if worldEventData.UpcomingEventConditions[data.missionName] >= map.ActiveEventGoal then
            --- Event started!
            local currentDate = os.date("*t")
            local endTime = os.time({hour = currentDate.hour + 6, day = currentDate.day, month = currentDate.month, year = currentDate.year})
            local dataToBeSent = {data.missionName, endTime}

            worldEventData.CurrentActiveEvents[data.missionName] = endTime
            worldEventData.UpcomingEventConditions[data.missionName] = nil

            worldEventNotifier:Fire(dataToBeSent)
            handleWorldEvent(dataToBeSent)
        end
    end

    globalUpdates:ClearLockedUpdate(id)
end

function WorldProfileSystem:OnServerStartup(steal)
    local profile = worldProfileTemplate:LoadProfileAsync(
        worldProfileDatastoreKey,
        steal and "Steal" or "ForceLoad"
    )

    if profile then
        profile:Reconcile()
        profile:ListenToRelease(function()
            WorldProfile = nil
        end)

        WorldProfile = profile

        local currentTime = os.time()
        local globalUpdates = profile.GlobalUpdates

        for missionName, missionEndTime in pairs(profile.Data.CurrentActiveEvents) do
            if missionEndTime - currentTime <= 0 then
                profile.Data.CurrentActiveEvents[missionName] = nil
                local map = Matchmaking:GetMap(missionName)
                if map then
                    map.EndTime = 0
                end
            else
                handleWorldEvent({missionName, missionEndTime})
            end
        end

        for index, update in pairs(globalUpdates:GetActiveUpdates()) do
            globalUpdates:LockActiveUpdate(update[1])
        end

        for index, update in pairs(globalUpdates:GetLockedUpdates()) do
            handleLockedUpdates(globalUpdates, update, profile.Data)
        end

        globalUpdates:ListenToNewActiveUpdate(function(id, data)
            globalUpdates:LockActiveUpdate(id)
        end)

        globalUpdates:ListenToNewLockedUpdate(function(id, data)
            handleLockedUpdates(globalUpdates, {id, data}, profile.Data)
        end)

        print("World Event Profile loaded")
    else
        WorldProfileSystem:OnServerStartup()
    end
end

function WorldProfileSystem:Fetch()
    return WorldProfile and WorldProfile.Data
end

function WorldProfileSystem:GetProfileStore()
    return worldProfileTemplate
end

function WorldProfileSystem:AddEvent(missionName)
    worldProfileTemplate:GlobalUpdateProfileAsync(
        worldProfileDatastoreKey,
        function(globalUpdates)
            globalUpdates:AddActiveUpdate(
                {
                    missionName = missionName,
                    sendTime = os.time()
                }
            )
        end
    )
end

return WorldProfileSystem