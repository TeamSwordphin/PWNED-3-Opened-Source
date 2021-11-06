-- The variable below is the ID of the script you've created, you won't need
-- to enter any information other than this.

--https://script.google.com/macros/s/AKfycbzxJujK0frq3VfwymzkmvClcmO798ISSdMhFas8BMLMNX7nyOk/exec
local scriptId = "AKfycbzxJujK0frq3VfwymzkmvClcmO798ISSdMhFas8BMLMNX7nyOk"

-- Touch anything below and you'll upset the script, and that's not a good thing.

local url = "https://script.google.com/macros/s/" .. scriptId .. "/exec"
local httpService = game:GetService'HttpService'
local module = {}

game:WaitForChild'NetworkServer'

function decodeJson(json)
	local jsonTab = {} pcall(function ()
	jsonTab = httpService:JSONDecode(json)
	end) return jsonTab
end

function encodeJson(data)
	local jsonString = data pcall(function ()
	jsonString = httpService:JSONEncode(data)
	end) return jsonString
end

function doGet(sheet, key)
	local json = httpService:GetAsync(url .. "?sheet=" .. sheet .. "&key=" .. key)
	local data = decodeJson(json)
	if data.result == "success" then
		return data.value
	else
		warn("Database error:", data.error)
		return
	end
end

function doPost(sheet, key, data)
	local json = httpService:UrlEncode(encodeJson(data))
	local retJson = httpService:PostAsync(url, "sheet=" .. sheet .. "&key=" .. key .. "&value=" .. json, 2)
	local data = decodeJson(retJson)
	print(retJson)
	if data.result == "success" then
		return true
	else
		warn("Database error:", data.error)
		return false
	end
end

function module:GetDatabase(sheet)
	local database = {}
	function database:PostAsync(key, value)
		return doPost(sheet, key, value)
	end
	function database:GetAsync(key)
		return doGet(sheet, key)
	end
	return database
end

return module