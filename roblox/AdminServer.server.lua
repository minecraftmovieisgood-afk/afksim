local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local ADMIN_USER_IDS = {
	[3653999284] = true,
}

local DISCO_DURATION = 120
local DISCO_CHANCE_PERCENT = 1
local DISCO_TITLE_STORE = DataStoreService:GetDataStore("DiscoTitleOwners_v1")

local sendMessageRemote = ReplicatedStorage:FindFirstChild("AdminSendGlobalMessage") or Instance.new("RemoteEvent")
sendMessageRemote.Name = "AdminSendGlobalMessage"
sendMessageRemote.Parent = ReplicatedStorage

local globalMessageRemote = ReplicatedStorage:FindFirstChild("AdminGlobalMessageBroadcast") or Instance.new("RemoteEvent")
globalMessageRemote.Name = "AdminGlobalMessageBroadcast"
globalMessageRemote.Parent = ReplicatedStorage

local startDiscoRemote = ReplicatedStorage:FindFirstChild("AdminStartDiscoEvent") or Instance.new("RemoteEvent")
startDiscoRemote.Name = "AdminStartDiscoEvent"
startDiscoRemote.Parent = ReplicatedStorage

local discoStateRemote = ReplicatedStorage:FindFirstChild("DiscoEventState") or Instance.new("RemoteEvent")
discoStateRemote.Name = "DiscoEventState"
discoStateRemote.Parent = ReplicatedStorage

local discoActive = false
local discoEndsAt = 0

local function isAdmin(player)
	if ADMIN_USER_IDS[player.UserId] == true then
		return true
	end

	-- Allow private server owner to use admin tools in their private server.
	if game.PrivateServerId ~= "" and game.PrivateServerOwnerId == player.UserId then
		return true
	end

	return false
end

local function setDiscoOwned(player, owned)
	player:SetAttribute("HasDiscoTitle", owned == true)
end

local function loadDiscoOwned(player)
	local ok, data = pcall(function()
		return DISCO_TITLE_STORE:GetAsync(tostring(player.UserId))
	end)
	if ok and data == true then
		setDiscoOwned(player, true)
	else
		setDiscoOwned(player, false)
	end
end

local function saveDiscoOwned(player)
	local hasDisco = player:GetAttribute("HasDiscoTitle") == true
	pcall(function()
		DISCO_TITLE_STORE:SetAsync(tostring(player.UserId), hasDisco)
	end)
end

local function grantDiscoTitle(player)
	if player:GetAttribute("HasDiscoTitle") == true then
		return
	end
	setDiscoOwned(player, true)
	saveDiscoOwned(player)
	globalMessageRemote:FireAllClients("🎉 " .. player.Name .. " just unlocked the Disco title!", "System")
end

local function broadcastDiscoState()
	local remaining = math.max(0, discoEndsAt - os.time())
	discoStateRemote:FireAllClients(discoActive, remaining)
end

Players.PlayerAdded:Connect(function(player)
	loadDiscoOwned(player)
	if discoActive then
		task.defer(broadcastDiscoState)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	saveDiscoOwned(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	loadDiscoOwned(player)
end

sendMessageRemote.OnServerEvent:Connect(function(player, rawMessage)
	if not isAdmin(player) then
		return
	end
	if type(rawMessage) ~= "string" then
		return
	end
	local message = rawMessage:gsub("^%s+", ""):gsub("%s+$", "")
	if message == "" then
		return
	end
	if #message > 180 then
		message = message:sub(1, 180)
	end
	globalMessageRemote:FireAllClients(message, player.DisplayName)
end)

startDiscoRemote.OnServerEvent:Connect(function(player)
	if not isAdmin(player) then
		return
	end
	if discoActive then
		discoEndsAt = os.time() + DISCO_DURATION
		broadcastDiscoState()
		globalMessageRemote:FireAllClients("🪩 Disco Event started for 2 minutes!", "System")
		return
	end

	discoActive = true
	discoEndsAt = os.time() + DISCO_DURATION
	broadcastDiscoState()
	globalMessageRemote:FireAllClients("🪩 Disco Event started for 2 minutes!", "System")

	task.spawn(function()
		while discoActive do
			local remaining = discoEndsAt - os.time()
			if remaining <= 0 then
				break
			end

			for _, targetPlayer in ipairs(Players:GetPlayers()) do
				if targetPlayer:GetAttribute("HasDiscoTitle") ~= true and math.random(1, 100) <= DISCO_CHANCE_PERCENT then
					grantDiscoTitle(targetPlayer)
				end
			end

			broadcastDiscoState()
			task.wait(1)
		end

		discoActive = false
		discoEndsAt = 0
		broadcastDiscoState()
		globalMessageRemote:FireAllClients("🪩 Disco Event ended.", "System")
	end)
end)
