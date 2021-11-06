--[[
	UniverseEvent by 3dsboy08
	
	v1.0.0
--]]

local ESubscriptions = {}
local ECache = {}
local HttpService = game:GetService("HttpService")
local TableRemove = table.remove

if game:GetService("RunService"):IsStudio() then
	return { new = function() end }
end

game:GetService("MessagingService"):SubscribeAsync("ul-master", function(Call)
	local Args = Call.Data
	
	local Guid = TableRemove(Args)
	local Name = TableRemove(Args)
	local Server = TableRemove(Args)
	local FinalArgs = TableRemove(Args)
	
	if ESubscriptions[Name] and Server ~= game.JobId and not ECache[Guid] then
		ECache[Guid] = true
		
		ESubscriptions[Name]:Fire(unpack(FinalArgs))
	end
end)

local UEvent =
{
	__index = function(T, K)
		if string.lower(K) == "fire" then
			return function(T2, ...)
				game:GetService("MessagingService"):PublishAsync("ul-master", { {...}, game.JobId, T2.Channel, HttpService:GenerateGUID(false) })
			end
		end
		
		return T.Native[K]
	end,
	
	__newindex = function(T, K, V)
		T.Native[K] = V
	end
}

local UCreator =
{
	new = function(Name)
		if not ESubscriptions[Name] then
			ESubscriptions[Name] = Instance.new("BindableEvent")
		end
			
		local Ret = 
		{
			Native = ESubscriptions[Name],
			Channel = Name
		}
			
		return setmetatable(Ret, UEvent)
	end
}

return UCreator
