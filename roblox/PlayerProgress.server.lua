local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DATASTORE_NAME = "AFKSimPlayerProgress_v2" -- bumped for fresh testing
local NOTIFIED_TITLES_VERSION = 2 -- bump this to reset title notifications without resetting tutorial
local store = DataStoreService:GetDataStore(DATASTORE_NAME)
local cache = {}
local dirty = {}
local MAX_RETRIES = 3

local getProgressFn = ReplicatedStorage:FindFirstChild("GetPlayerProgress")
if not getProgressFn then
	getProgressFn = Instance.new("RemoteFunction")
	getProgressFn.Name = "GetPlayerProgress"
	getProgressFn.Parent = ReplicatedStorage
end

local markTitleEvent = ReplicatedStorage:FindFirstChild("MarkTitleNotified")
if not markTitleEvent then
	markTitleEvent = Instance.new("RemoteEvent")
	markTitleEvent.Name = "MarkTitleNotified"
	markTitleEvent.Parent = ReplicatedStorage
end

local tutorialDoneEvent = ReplicatedStorage:FindFirstChild("SetTutorialCompleted")
if not tutorialDoneEvent then
	tutorialDoneEvent = Instance.new("RemoteEvent")
	tutorialDoneEvent.Name = "SetTutorialCompleted"
	tutorialDoneEvent.Parent = ReplicatedStorage
end

local function defaultProgress()
	return {
		notifiedTitles = {},
		notifiedTitlesVersion = NOTIFIED_TITLES_VERSION,
		tutorialCompleted = false,
	}
end

local function loadPlayer(player)
	local key = tostring(player.UserId)
	local data

	local loaded = false
	for attempt = 1, MAX_RETRIES do
		local ok, err = pcall(function()
			data = store:GetAsync(key)
		end)
		if ok then
			loaded = true
			break
		end
		if attempt == MAX_RETRIES then
			warn("[PlayerProgress] load failed", player.UserId, err)
		else
			task.wait(0.5)
		end
	end

	if not loaded then
		data = nil
	end

	if typeof(data) ~= "table" then
		data = defaultProgress()
	end
	if typeof(data.notifiedTitles) ~= "table" then
		data.notifiedTitles = {}
	end
	if data.notifiedTitlesVersion ~= NOTIFIED_TITLES_VERSION then
		data.notifiedTitles = {}
		data.notifiedTitlesVersion = NOTIFIED_TITLES_VERSION
	end
	if typeof(data.tutorialCompleted) ~= "boolean" then
		data.tutorialCompleted = false
	end

	cache[player.UserId] = data
	dirty[player.UserId] = false
end

local function savePlayerByUserId(userId)
	local data = cache[userId]
	if not data then return end
	if not dirty[userId] then return end

	local key = tostring(userId)
	local saved = false
	for attempt = 1, MAX_RETRIES do
		local ok, err = pcall(function()
			store:SetAsync(key, data)
		end)
		if ok then
			saved = true
			break
		end
		if attempt == MAX_RETRIES then
			warn("[PlayerProgress] save failed", userId, err)
		else
			task.wait(0.5)
		end
	end

	if not saved then return end
	dirty[userId] = false
end

Players.PlayerAdded:Connect(loadPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	loadPlayer(p)
end

Players.PlayerRemoving:Connect(function(player)
	savePlayerByUserId(player.UserId)
	cache[player.UserId] = nil
	dirty[player.UserId] = nil
end)

getProgressFn.OnServerInvoke = function(player)
	if not cache[player.UserId] then
		loadPlayer(player)
	end
	return cache[player.UserId] or defaultProgress()
end

markTitleEvent.OnServerEvent:Connect(function(player, titleId)
	if typeof(titleId) ~= "string" then return end
	local data = cache[player.UserId]
	if not data then return end
	if data.notifiedTitles[titleId] then return end
	data.notifiedTitles[titleId] = true
	dirty[player.UserId] = true
	savePlayerByUserId(player.UserId)
end)

tutorialDoneEvent.OnServerEvent:Connect(function(player)
	local data = cache[player.UserId]
	if not data then return end
	if data.tutorialCompleted then return end
	data.tutorialCompleted = true
	dirty[player.UserId] = true
	savePlayerByUserId(player.UserId)
end)

-- periodic save safety
while true do
	task.wait(60)
	for userId, _ in pairs(cache) do
		savePlayerByUserId(userId)
	end
end
