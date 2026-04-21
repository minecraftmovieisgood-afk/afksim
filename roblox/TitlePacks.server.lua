local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local PACK_STORE = DataStoreService:GetDataStore("PlayerTitlePackData_v1")

local PACK_TITLES = {
	{Id = "PackComet", Name = "Comet Trail", Weight = 550, ChanceText = "55%"},
	{Id = "PackAurora", Name = "Aurora Pulse", Weight = 330, ChanceText = "33%"},
	{Id = "PackNebula", Name = "Nebula Core", Weight = 100, ChanceText = "10%"},
	{Id = "PackCelestial", Name = "Celestial Crown", Weight = 19, ChanceText = "1.9%"},
	{Id = "PackSingularity", Name = "GOD", Weight = 1, ChanceText = "0.1%"},
}

local getDataFn = ReplicatedStorage:FindFirstChild("GetTitlePackData") or Instance.new("RemoteFunction")
getDataFn.Name = "GetTitlePackData"
getDataFn.Parent = ReplicatedStorage

local buyPacksFn = ReplicatedStorage:FindFirstChild("BuyTitlePacks") or Instance.new("RemoteFunction")
buyPacksFn.Name = "BuyTitlePacks"
buyPacksFn.Parent = ReplicatedStorage

local purchaseGrantedEvent = ReplicatedStorage:FindFirstChild("TitlePackPurchaseGranted") or Instance.new("BindableEvent")
purchaseGrantedEvent.Name = "TitlePackPurchaseGranted"
purchaseGrantedEvent.Parent = ReplicatedStorage

local rewardsRevealRemote = ReplicatedStorage:FindFirstChild("TitlePackRewardsReveal") or Instance.new("RemoteEvent")
rewardsRevealRemote.Name = "TitlePackRewardsReveal"
rewardsRevealRemote.Parent = ReplicatedStorage

local dataByUserId = {}

local function weightedRoll()
	local roll = math.random(1, 1000)
	local cumulative = 0
	for _, item in ipairs(PACK_TITLES) do
		cumulative += item.Weight
		if roll <= cumulative then
			return item
		end
	end
	return PACK_TITLES[1]
end

local function applyAttributes(player, data)
	for _, item in ipairs(PACK_TITLES) do
		player:SetAttribute("HasPackTitle_" .. item.Id, data.unlocked[item.Id] == true)
	end
end

local function loadData(userId)
	local ok, data = pcall(function()
		return PACK_STORE:GetAsync(tostring(userId))
	end)
	if ok and type(data) == "table" then
		local unlocked = {}
		if type(data.unlocked) == "table" then
			for _, item in ipairs(PACK_TITLES) do
				if data.unlocked[item.Id] == true then
					unlocked[item.Id] = true
				end
			end
		end
		return { unlocked = unlocked }
	end
	return { unlocked = {} }
end

local function saveData(userId)
	local data = dataByUserId[userId]
	if not data then return end
	pcall(function()
		PACK_STORE:SetAsync(tostring(userId), data)
	end)
end

local function rollRewardsIntoData(data, amount)
	local wins = {}
	local rewards = {}
	for i = 1, amount do
		local reward = weightedRoll()
		data.unlocked[reward.Id] = true
		wins[reward.Name] = (wins[reward.Name] or 0) + 1
		table.insert(rewards, reward.Name)
	end
	return wins, rewards
end

local function grantPurchasedPacks(userId, amount)
	amount = tonumber(amount)
	if amount ~= 1 and amount ~= 5 and amount ~= 10 then
		return false
	end

	local data = dataByUserId[userId]
	if not data then
		data = loadData(userId)
		dataByUserId[userId] = data
	end

	local _, rewards = rollRewardsIntoData(data, amount)
	saveData(userId)

	local player = Players:GetPlayerByUserId(userId)
	if player then
		applyAttributes(player, data)
		rewardsRevealRemote:FireClient(player, rewards)
	end

	return true
end

Players.PlayerAdded:Connect(function(player)
	local data = loadData(player.UserId)
	dataByUserId[player.UserId] = data
	applyAttributes(player, data)
end)

Players.PlayerRemoving:Connect(function(player)
	saveData(player.UserId)
	dataByUserId[player.UserId] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	local data = loadData(player.UserId)
	dataByUserId[player.UserId] = data
	applyAttributes(player, data)
end

getDataFn.OnServerInvoke = function(player)
	local data = dataByUserId[player.UserId] or { unlocked = {} }
	local owned = {}
	for _, item in ipairs(PACK_TITLES) do
		if data.unlocked[item.Id] then
			table.insert(owned, item.Name)
		end
	end
	return {
		owned = owned,
		titles = PACK_TITLES,
	}
end

buyPacksFn.OnServerInvoke = function()
	return false, "Purchasing now uses Roblox developer products."
end

purchaseGrantedEvent.Event:Connect(function(userId, amount)
	local ok, err = pcall(function()
		grantPurchasedPacks(userId, amount)
	end)
	if not ok then
		warn("[TitlePacks] Failed to grant purchased packs:", err)
	end
end)
