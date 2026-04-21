local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DATASTORE_NAME = "PlayerStarterPacks_v1"
local STATE_REMOTE_NAME = "GetStarterPackState"
local PURCHASE_REMOTE_NAME = "PurchaseStarterPack"

local STARTER_PACKS = {
	["Bloxy Cola"] = { RequiredSeconds = 500 },
	["Cheezburger"] = { RequiredSeconds = 2500 },
	["Roblox University PIZZA!"] = { RequiredSeconds = 5000 },
	["TeddyBloxpin"] = { RequiredSeconds = 15000 },
	["Taco"] = { RequiredSeconds = 30000 },
}

local datastore = DataStoreService:GetDataStore(DATASTORE_NAME)

local stateByUserId = {}

local stateRemote = ReplicatedStorage:FindFirstChild(STATE_REMOTE_NAME)
if not stateRemote then
	stateRemote = Instance.new("RemoteFunction")
	stateRemote.Name = STATE_REMOTE_NAME
	stateRemote.Parent = ReplicatedStorage
end

local purchaseRemote = ReplicatedStorage:FindFirstChild(PURCHASE_REMOTE_NAME)
if not purchaseRemote then
	purchaseRemote = Instance.new("RemoteFunction")
	purchaseRemote.Name = PURCHASE_REMOTE_NAME
	purchaseRemote.Parent = ReplicatedStorage
end


local function deepCopyState(state)
	local unlockedCopy = {}
	for name, value in pairs(state.unlocked or {}) do
		unlockedCopy[name] = value
	end
	return {
		unlocked = unlockedCopy,
	}
end

local function getToolTemplate(itemName)
	local toolsFolder = ServerStorage:FindFirstChild("StarterPackTools")
	if not toolsFolder then
		return nil
	end
	return toolsFolder:FindFirstChild(itemName)
end

local function clearStarterPackTools(player)
	local backpack = player:FindFirstChild("Backpack")
	local starterGear = player:FindFirstChild("StarterGear")
	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if STARTER_PACKS[tool.Name] then
				tool:Destroy()
			end
		end
	end
	if starterGear then
		for _, tool in ipairs(starterGear:GetChildren()) do
			if STARTER_PACKS[tool.Name] then
				tool:Destroy()
			end
		end
	end
end

local function applyUnlockedTools(player)
	local state = stateByUserId[player.UserId]
	if not state then
		return
	end

	clearStarterPackTools(player)

	local backpack = player:FindFirstChild("Backpack")
	local starterGear = player:FindFirstChild("StarterGear")

	for itemName, isUnlocked in pairs(state.unlocked or {}) do
		if isUnlocked then
			local toolTemplate = getToolTemplate(itemName)
			if toolTemplate then
				if backpack then
					toolTemplate:Clone().Parent = backpack
				end
				if starterGear then
					toolTemplate:Clone().Parent = starterGear
				end
			end
		end
	end
end

local function saveState(userId)
	local state = stateByUserId[userId]
	if not state then
		return
	end
	local payload = {
		unlocked = state.unlocked,
	}
	pcall(function()
		datastore:SetAsync(tostring(userId), payload)
	end)
end

local function loadState(userId)
	local ok, data = pcall(function()
		return datastore:GetAsync(tostring(userId))
	end)

	if ok and type(data) == "table" then
		local unlocked = {}
		if type(data.unlocked) == "table" then
			for itemName, unlockedValue in pairs(data.unlocked) do
				if STARTER_PACKS[itemName] and unlockedValue == true then
					unlocked[itemName] = true
				end
			end
		end
		return {
			unlocked = unlocked,
		}
	end

	return {
		unlocked = {},
	}
end

local function getSecondsValue(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end
	return leaderstats:FindFirstChild("Seconds")
end

Players.PlayerAdded:Connect(function(player)
	stateByUserId[player.UserId] = loadState(player.UserId)

	player.CharacterAdded:Connect(function()
		applyUnlockedTools(player)
	end)

	task.defer(function()
		applyUnlockedTools(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	saveState(player.UserId)
	stateByUserId[player.UserId] = nil
end)

stateRemote.OnServerInvoke = function(player)
	local state = stateByUserId[player.UserId] or { unlocked = {} }
	return deepCopyState(state)
end

purchaseRemote.OnServerInvoke = function(player, itemName)
	if type(itemName) ~= "string" then
		return false, "Invalid item"
	end

	local config = STARTER_PACKS[itemName]
	if not config then
		return false, "Unknown item"
	end

	local state = stateByUserId[player.UserId]
	if not state then
		return false, "State unavailable"
	end

	if state.unlocked[itemName] then
		return true, "Already unlocked", deepCopyState(state)
	end

	local secondsValue = getSecondsValue(player)
	if not secondsValue or secondsValue.Value < config.RequiredSeconds then
		return false, "Not enough seconds"
	end

	state.unlocked[itemName] = true
	saveState(player.UserId)
	applyUnlockedTools(player)

	return true, "Unlocked", deepCopyState(state)
end


for _, player in ipairs(Players:GetPlayers()) do
	stateByUserId[player.UserId] = loadState(player.UserId)
	player.CharacterAdded:Connect(function()
		applyUnlockedTools(player)
	end)
	task.defer(function()
		applyUnlockedTools(player)
	end)
end
