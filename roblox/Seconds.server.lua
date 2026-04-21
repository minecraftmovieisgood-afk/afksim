local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local DATASTORE_NAME = "PlayerSecondsTotals_v1"
local SAVE_INTERVAL = 30
local OWNERSHIP_REFRESH_INTERVAL = 20
local TICK_INTERVAL = 1
local MAX_RETRIES = 3

local TWO_X_SECONDS_GAMEPASS_ID = 1769149472
local FOUR_X_SECONDS_GAMEPASS_ID = 1765744598

local store = DataStoreService:GetDataStore(DATASTORE_NAME)
local activeLoops = {}
local multiplierCache = {}

local function getOrCreateLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	return leaderstats
end

local function getOrCreateSecondsValue(player)
	local leaderstats = getOrCreateLeaderstats(player)
	local secondsValue = leaderstats:FindFirstChild("Seconds")
	if not secondsValue then
		secondsValue = Instance.new("IntValue")
		secondsValue.Name = "Seconds"
		secondsValue.Value = 0
		secondsValue.Parent = leaderstats
	end
	return secondsValue
end

local function loadSeconds(player)
	local secondsValue = getOrCreateSecondsValue(player)
	local key = tostring(player.UserId)

	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(function()
			return store:GetAsync(key)
		end)
		if ok then
			if typeof(result) == "number" then
				secondsValue.Value = math.max(0, math.floor(result))
			end
			return
		end
		if attempt < MAX_RETRIES then
			task.wait(0.5)
		else
			warn("[Seconds] Failed to load seconds for", player.UserId)
		end
	end
end

local function saveSeconds(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local secondsValue = leaderstats:FindFirstChild("Seconds")
	if not secondsValue then return end

	local key = tostring(player.UserId)
	local valueToSave = math.max(0, math.floor(secondsValue.Value))

	for attempt = 1, MAX_RETRIES do
		local ok, err = pcall(function()
			store:SetAsync(key, valueToSave)
		end)
		if ok then return end
		if attempt < MAX_RETRIES then
			task.wait(0.5)
		else
			warn("[Seconds] Failed to save seconds for", player.UserId, err)
		end
	end
end

local function ownsPass(userId, passId)
	local ok, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, passId)
	end)
	return ok and result == true
end

local function refreshMultiplier(player)
	local owns2x = ownsPass(player.UserId, TWO_X_SECONDS_GAMEPASS_ID)
	local owns4x = ownsPass(player.UserId, FOUR_X_SECONDS_GAMEPASS_ID)

	if owns2x and owns4x then
		multiplierCache[player] = 4
	elseif owns2x then
		multiplierCache[player] = 2
	else
		multiplierCache[player] = 1
	end
end

local function startSecondsLoop(player)
	if activeLoops[player] then
		activeLoops[player]:Disconnect()
		activeLoops[player] = nil
	end

	local elapsed = 0
	activeLoops[player] = RunService.Heartbeat:Connect(function(dt)
		if player.Parent ~= Players then return end
		local secondsValue = getOrCreateSecondsValue(player)
		elapsed += dt
		while elapsed >= TICK_INTERVAL do
			secondsValue.Value += (multiplierCache[player] or 1)
			elapsed -= TICK_INTERVAL
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	loadSeconds(player)
	refreshMultiplier(player)
	startSecondsLoop(player)

	task.spawn(function()
		while player.Parent == Players do
			task.wait(OWNERSHIP_REFRESH_INTERVAL)
			refreshMultiplier(player)
		end
	end)

	task.spawn(function()
		while player.Parent == Players do
			task.wait(SAVE_INTERVAL)
			saveSeconds(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if activeLoops[player] then
		activeLoops[player]:Disconnect()
		activeLoops[player] = nil
	end
	saveSeconds(player)
	multiplierCache[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		loadSeconds(player)
		refreshMultiplier(player)
		startSecondsLoop(player)
	end)
end
