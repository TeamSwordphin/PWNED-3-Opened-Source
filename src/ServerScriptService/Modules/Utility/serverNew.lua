-- << Services >>
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- << Constants >>
local REMOTE_FOLDER = Instance.new("Folder")
local PLAYER_JOIN_REMOTE = Instance.new("RemoteEvent", REMOTE_FOLDER)

-- << Modules >>
local Promise = require(ReplicatedStorage.Scripts.Modules.Promise)
local SignalService = require(script.Parent.Signal)

-- << Variables >>
local socketModule = {}
local sockets = {}
local remoteFolders = {}


-----------------------------------------------------------------

local socket = {}
socket.__index = socket
socket.ClassName = "Socket"

function socket:Listen(functionName, listener)
    assert(self.Alive, "Socket has disconnected")
    self.Listeners[functionName] = self.ListenerSignal:Connect(listener)

    if not remoteFolders[functionName] then
        local folder = Instance.new("Folder", REMOTE_FOLDER)
        local event = Instance.new("RemoteEvent", folder)
        local reque = Instance.new("RemoteFunction", folder)

        event.OnServerEvent:Connect(function(player, ...)
            self.Listeners[functionName]:Fire(...)
        end)

        reque.OnServerInvoke = function(player, ...)
            local response = self.Listeners[functionName]:Fire(...)
            return response
        end

        folder.Name = functionName
        remoteFolders[functionName] = folder
    end

    return self.Listeners[functionName]
end

function socket:Emit(functionName, ...)
    assert(self.Alive, "Socket has disconnected")
    local targetRemoteFolder = REMOTE_FOLDER[functionName]
    targetRemoteFolder.RemoteEvent:FireClient(self.Player, functionName, ...)
end

-----------------------------------------------------------------

socketModule.Connected = SignalService.new()

function socketModule:GetSocket(player)
    return sockets[player]
end

function socketModule:GetSockets()
    local socks = {}
    for _, sock in pairs(sockets) do
        table.insert(socks, sock)
    end

    return socks
end

function socketModule:Emit(functionName, ...)
    local targetRemoteFolder = REMOTE_FOLDER[functionName]
    targetRemoteFolder.RemoteEvent:FireAllClients(functionName, ...)
end

-----------------------------------------------------------------

PLAYER_JOIN_REMOTE.OnServerEvent:Connect(function(player)
    if sockets[player] then return end

    local newSocket = setmetatable({
        Alive = true,
        Player = player,
        ListenerSignal = SignalService.new(),
        Listeners = {},
        Disconnected = SignalService.new()
    }, socket)

    sockets[player] = newSocket

    local hasConnected = newSocket.Player:FindFirstChild("Connected")

    while not hasConnected do
        if hasConnected then
            hasConnected:Destroy()
            print("Connection restored")
        else
            socketModule.Connected:Fire(newSocket)
            print("Retrying...")
            wait(4)
            hasConnected = newSocket.Player:FindFirstChild("Connected")
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local socket = sockets[player]
    if socket then
        socket.Disconnected:Fire()
        socket:Destroy()
        sockets[player] = nil
    end
end)

PLAYER_JOIN_REMOTE.Name = "Initialization"
REMOTE_FOLDER.Name = "Sockets"
REMOTE_FOLDER.Parent = ReplicatedStorage

return socketModule