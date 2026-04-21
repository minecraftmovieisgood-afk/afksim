local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local PLAYER_TOTALS_STORE_NAME = "PlayerRobuxDonatedTotals_v1"
local donationTotalsStore = DataStoreService:GetDataStore(PLAYER_TOTALS_STORE_NAME)
local titlePrefsStore = DataStoreService:GetDataStore("TitleEquipPrefs_v1")

local equipEvent = ReplicatedStorage:FindFirstChild("EquipTitleEvent")
if not equipEvent then
	equipEvent = Instance.new("RemoteEvent")
	equipEvent.Name = "EquipTitleEvent"
	equipEvent.Parent = ReplicatedStorage
end

local autoBestTimeEvent = ReplicatedStorage:FindFirstChild("SetAutoBestTimeTitle")
if not autoBestTimeEvent then
	autoBestTimeEvent = Instance.new("RemoteEvent")
	autoBestTimeEvent.Name = "SetAutoBestTimeTitle"
	autoBestTimeEvent.Parent = ReplicatedStorage
end

-- Add/remove user IDs here for the "A Cool Person" title.
local COOL_PERSON_USER_IDS = {
	3653999284,
}

local TITLES = {
	{Id = "None", Name = "None", Required = 0, Description = "The Default Title"},
	{Id = "IdleBeginner", Name = "Time Newbie", Required = 60, Description = "First tiny step into the clockwork."},
	{Id = "AFKExplorer", Name = "Clock Rookie", Required = 300, Description = "A few minutes in, still warming up."},
	{Id = "AFKRookie", Name = "Minute Stacker", Required = 1200, Description = "Piling up minutes like it's nothing."},
	{Id = "AFKVeteran", Name = "Hour Holder", Required = 3600, Description = "You can hold a full hour with ease."},
	{Id = "AFKGrinder", Name = "Drift Runner", Required = 7200, Description = "Two-hour sessions are your comfort zone."},
	{Id = "AFKElite", Name = "Chrono Charger", Required = 10800, Description = "Three-hour pace, high momentum."},
	{Id = "AFKMaster", Name = "Day Dreamer", Required = 21600, Description = "Half-day grind unlocked."},
	{Id = "AFKTitan", Name = "Half-Day Howler", Required = 43200, Description = "12-hour endurance machine."},
	{Id = "AFKLegend", Name = "24H Beast", Required = 86400, Description = "One full day conquered."},
	{Id = "ChronoSovereign", Name = "Storm of Seconds", Required = 172800, Description = "100K+ territory begins here."},
	{Id = "Daybreaker", Name = "Clockbreaker X", Required = 259200, Description = "Time bends when you log in."},
	{Id = "Weeksmith", Name = "Temporal Overlord", Required = 345600, Description = "You command the timeline."},
	{Id = "Everclock", Name = "Paradox Reaper", Required = 432000, Description = "Reality glitches around your sessions."},
	{Id = "InfinityWatch", Name = "Infinity Cataclysm", Required = 604800, Description = "A week deep. Pure chaos energy."},
		{Id = "QuantumSleeper", Name = "Quantum Sleeper", Required = 777600, Description = "Nine days in deep AFK stasis."},
	{Id = "EpochWarden", Name = "Epoch Warden", Required = 950400, Description = "You guard entire epochs of idle time."},
	{Id = "CalendarCrusher", Name = "Calendar Crusher", Required = 1209600, Description = "Two-week timer breaker."},
	{Id = "MonthMarauder", Name = "Month Marauder", Required = 1814400, Description = "Three-week relentless grinder."},
	{Id = "TimeGlacier", Name = "Time Glacier", Required = 2419200, Description = "A month of frozen focus."},
	{Id = "EraArchitect", Name = "Era Architect", Required = 3024000, Description = "Building eras one second at a time."},
	{Id = "MillenniumDrift", Name = "Millennium Drift", Required = 3628800, Description = "A legend adrift through endless hours."},
	{Id = "CosmicClocklord", Name = "Cosmic Clocklord", Required = 4233600, Description = "Master of cosmic countdowns."},
	{Id = "TimelineDevourer", Name = "Timeline Devourer", Required = 4838400, Description = "You consume timelines for breakfast."},
	{Id = "AbsoluteEternity", Name = "Absolute Eternity", Required = 5443200, Description = "The highest form of AFK existence."},
	{Id = "Donater", Name = "Donater", Required = 0, Description = "Awarded to players who have donated.", RequiresDonation = true},
	{Id = "Disco", Name = "Disco", Required = 0, Description = "1% chance every second during active disco event.", RequiresDiscoTitle = true},
		{Id = "PackComet", Name = "Comet Trail", Required = 0, Description = "From Title Packs (Common).", RequiresPackTitle = "PackComet"},
	{Id = "PackAurora", Name = "Aurora Pulse", Required = 0, Description = "From Title Packs (Uncommon).", RequiresPackTitle = "PackAurora"},
	{Id = "PackNebula", Name = "Nebula Core", Required = 0, Description = "From Title Packs (Rare).", RequiresPackTitle = "PackNebula"},
	{Id = "PackCelestial", Name = "Celestial Crown", Required = 0, Description = "From Title Packs (Epic).", RequiresPackTitle = "PackCelestial"},
	{Id = "PackSingularity", Name = "GOD", Required = 0, Description = "From Title Packs (0.1% GOD drop).", RequiresPackTitle = "PackSingularity"},
	{Id = "CoolPerson", Name = "A Cool Person", Required = 0, Description = "Special title granted to selected user IDs.", AllowedUserIds = COOL_PERSON_USER_IDS},
	{Id = "Owner", Name = "Owner", Required = 0, Description = "Exclusive title for the game owner.", AllowedUserIds = {3653999284}},
}

local titleById = {}
local titleByName = {}
for _, t in ipairs(TITLES) do
	titleById[t.Id] = t
	titleByName[t.Name] = t
end

local secondsConnections = {}
local loadedPrefsByUserId = {}

local function isTimeRelatedTitle(data)
	return data
		and data.Id ~= "None"
		and not data.RequiresDonation
		and not data.RequiresDiscoTitle
		and not data.RequiresPackTitle
		and not data.AllowedUserIds
		and data.Required > 0
end

local function isTitleUnlockedForPlayer(player, data)
	if not data then return false end
	local leaderstats = player:FindFirstChild("leaderstats")
	local seconds = leaderstats and leaderstats:FindFirstChild("Seconds")
	if not seconds then return false end

	local isAllowedUser = true
	if data.AllowedUserIds then
		isAllowedUser = false
		for _, userId in ipairs(data.AllowedUserIds) do
			if player.UserId == userId then
				isAllowedUser = true
				break
			end
		end
	end

	local meetsDonationRequirement = true
	if data.RequiresDonation then
		meetsDonationRequirement = player:GetAttribute("HasDonated") == true
	end

	local meetsDiscoRequirement = true
	if data.RequiresDiscoTitle then
		meetsDiscoRequirement = player:GetAttribute("HasDiscoTitle") == true
	end

	local meetsPackRequirement = true
	if data.RequiresPackTitle then
		meetsPackRequirement = player:GetAttribute("HasPackTitle_" .. data.RequiresPackTitle) == true
	end

	return seconds.Value >= data.Required and isAllowedUser and meetsDonationRequirement and meetsDiscoRequirement and meetsPackRequirement
end

local function getBestTimeTitleId(player)
	local bestId = "None"
	local bestRequired = -1
	for _, data in ipairs(TITLES) do
		if isTimeRelatedTitle(data) and isTitleUnlockedForPlayer(player, data) and data.Required > bestRequired then
			bestId = data.Id
			bestRequired = data.Required
		end
	end
	return bestId
end

local function savePlayerPrefs(player)
	local equipped = player:FindFirstChild("EquippedTitle")
	local equippedId = "None"
	if equipped then
		local mapped = titleByName[equipped.Value]
		if mapped then
			equippedId = mapped.Id
		end
	end
	local payload = {
		equippedTitleId = equippedId,
		autoBestTime = player:GetAttribute("AutoEquipBestTimeTitle") == true,
	}
	pcall(function()
		titlePrefsStore:SetAsync(tostring(player.UserId), payload)
	end)
end

local function equipById(player, titleId, isAutomatic)
	local data = titleById[titleId]
	if not data then return false end
	if not isTitleUnlockedForPlayer(player, data) then return false end

	local equipped = player:FindFirstChild("EquippedTitle")
	if not equipped then
		equipped = Instance.new("StringValue")
		equipped.Name = "EquippedTitle"
		equipped.Value = "None"
		equipped.Parent = player
	end
	equipped.Value = data.Name

	if isAutomatic ~= true and player:GetAttribute("AutoEquipBestTimeTitle") == true then
		player:SetAttribute("AutoEquipBestTimeTitle", false)
	end
	savePlayerPrefs(player)
	return true
end

local function setupPlayer(player)
	local equipped = player:FindFirstChild("EquippedTitle")
	if not equipped then
		equipped = Instance.new("StringValue")
		equipped.Name = "EquippedTitle"
		equipped.Value = "None"
		equipped.Parent = player
	end

	local donated = false
	local ok, total = pcall(function()
		return donationTotalsStore:GetAsync(tostring(player.UserId))
	end)
	if ok and tonumber(total) and tonumber(total) > 0 then
		donated = true
	end
	player:SetAttribute("HasDonated", donated)

	local autoBest = false
	local lastId = "None"
	local prefsOk, prefs = pcall(function()
		return titlePrefsStore:GetAsync(tostring(player.UserId))
	end)
	if prefsOk and type(prefs) == "table" then
		if type(prefs.equippedTitleId) == "string" then
			lastId = prefs.equippedTitleId
		end
		autoBest = prefs.autoBestTime == true
	end

	player:SetAttribute("AutoEquipBestTimeTitle", autoBest)
	loadedPrefsByUserId[player.UserId] = {
		equippedTitleId = lastId,
	}

	if secondsConnections[player] then
		secondsConnections[player]:Disconnect()
		secondsConnections[player] = nil
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	local seconds = leaderstats and leaderstats:FindFirstChild("Seconds")
	if seconds then
		secondsConnections[player] = seconds:GetPropertyChangedSignal("Value"):Connect(function()
			if player:GetAttribute("AutoEquipBestTimeTitle") == true then
				equipById(player, getBestTimeTitleId(player), true)
			end
		end)
	end

	task.defer(function()
		if not player.Parent then return end
		local leaderstats = player:FindFirstChild("leaderstats") or player:WaitForChild("leaderstats", 10)
		if not leaderstats then return end
		if not leaderstats:FindFirstChild("Seconds") then
			leaderstats:WaitForChild("Seconds", 10)
		end
		if player:GetAttribute("AutoEquipBestTimeTitle") == true then
			equipById(player, getBestTimeTitleId(player), true)
			return
		end
		local loaded = loadedPrefsByUserId[player.UserId]
		local preferred = loaded and loaded.equippedTitleId or "None"
		if not equipById(player, preferred, true) then
			equipById(player, "None", true)
		end
	end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	setupPlayer(p)
end

equipEvent.OnServerEvent:Connect(function(player, titleId)
	if typeof(titleId) ~= "string" then return end
	equipById(player, titleId, false)
end)

autoBestTimeEvent.OnServerEvent:Connect(function(player, enabled)
	local shouldEnable = enabled == true
	player:SetAttribute("AutoEquipBestTimeTitle", shouldEnable)
	if shouldEnable then
		equipById(player, getBestTimeTitleId(player), true)
	else
		savePlayerPrefs(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if secondsConnections[player] then
		secondsConnections[player]:Disconnect()
		secondsConnections[player] = nil
	end
	savePlayerPrefs(player)
	loadedPrefsByUserId[player.UserId] = nil
end)
