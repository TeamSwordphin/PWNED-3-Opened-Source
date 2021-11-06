-- << Services >>
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- << Constants >>
local REMOTE_FOLDER = ReplicatedStorage:WaitForChild("Sockets")
local PLAYER_JOIN_REMOTE = REMOTE_FOLDER:WaitForChild("Initialization")
local PLAYER = Players.LocalPlayer

-- << Modules >>
local Promise = require(ReplicatedStorage.Scripts.Modules.Promise)
local SignalService = require(script.Parent.Signal)

-- << Variables >>
local initialized = false
local remoteFolders = {}


-----------------------------------------------------------------

local socket = {}
socket.__index = socket
socket.ClassName = "Socket"

function socket:Listen(functionName, listener)
    self.Listeners[functionName] = self.ListenerSignal:Connect(listener)

    if not remoteFolders[functionName] then
        local folder = REMOTE_FOLDER:WaitForChild(functionName)
        local event = folder:WaitForChild("RemoteEvent", 10)

        event.OnClientEvent:Connect(function(player, ...)
            self.Listeners[functionName]:Fire(...)
        end)

        remoteFolders[functionName] = folder
    end

    return self.Listeners[functionName]
end

function socket:Request(functionName, ...)
    local folder = remoteFolders[functionName]
    local remoteFunction = folder:WaitForChild("RemoteFunction", 10)
    local args = {remoteFunction:InvokeServer(...)}

    return table.unpack(args)
end

-----------------------------------------------------------------

local userSocket = setmetatable({
    Player = Players.LocalPlayer,
    ListenerSignal = SignalService.new(),
    Listeners = {}
}, socket)

if not initialized then
    initialized = true
    PLAYER_JOIN_REMOTE:FireServer()
    PLAYER.ChildAdded:Wait()
end

return userSocket