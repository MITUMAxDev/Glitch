local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local placeId = 108896138014377
local function joinAnyServer()
	local servers = {}
	local cursor = ""
	
	local success, result = pcall(function()
		return HttpService:GetAsync("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
	end)
	
	if success and result then
		local data = HttpService:JSONDecode(result)
		servers = data.data or {}
	end
	
	if #servers > 0 then
		local randomServer = servers[math.random(1, #servers)]
		TeleportService:TeleportToPlaceInstance(placeId, randomServer.id)
	else
		TeleportService:Teleport(placeId)
	end
end

joinAnyServer()
