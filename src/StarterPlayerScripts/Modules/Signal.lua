local Signal = { }
Signal.__index = Signal
Signal.ClassName = "Signal"

local setmetatable = setmetatable
local running = coroutine.running

function Signal.new() return setmetatable({ }, Signal) end

function Signal:Fire(...)
	for Index = 1, #self do
		local Thread = coroutine.create(self[Index])
		coroutine.resume(Thread, ...)
	end
end

function Signal:Wait()
	local Thread = running()

	local function Yield(...)
		self:Disconnect(Yield)
		coroutine.resume(Thread, ...)
	end

	self[#self + 1] = Yield
	return coroutine.yield()
end

function Signal:Connect(Function)
    self[#self + 1] = Function
    return self[#self + 1]
end

function Signal:Disconnect(Function)
	local Length = #self

	for Index = 1, Length do
		if Function == self[Index] then
			self[Index] = self[Length]
			self[Length] = nil
			break
		end
	end
end

function Signal:Destroy()
	for Index = 1, #self do
		self[Index] = nil
	end
end

return Signal