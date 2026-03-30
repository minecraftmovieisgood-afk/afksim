local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local UserService = game:GetService("UserService")

-- CONFIG
local BOARD_PART_NAME = "Seconds leaderbord" -- requested part name
local TITLE_TEXT = "Most Seconds AFKED"
local REFRESH_INTERVAL = 30
local MAX_ROWS = 10
local ORDERED_STORE_NAME = "GlobalSecondsAFKLeaderboard_v1"

local leaderboardStore = DataStoreService:GetOrderedDataStore(ORDERED_STORE_NAME)
local nameCache = {}
local thumbCache = {}

local function addStroke(guiObject, thickness, color)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 2
	stroke.Color = color or Color3.new(0, 0, 0)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcall(function()
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
	end)
	stroke.Parent = guiObject
	return stroke
end

local function createBoardGui(boardPart)
	local existing = boardPart:FindFirstChild("SecondsLeaderboardGui")
	if existing then
		existing:Destroy()
	end

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "SecondsLeaderboardGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 45
	surfaceGui.ResetOnSpawn = false
	surfaceGui.Adornee = boardPart
	surfaceGui.AlwaysOnTop = false
	surfaceGui.Parent = boardPart

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	root.Parent = surfaceGui
	addStroke(root, 4, Color3.new(0, 0, 0))

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Parent = root
	title.Size = UDim2.fromScale(1, 0.1)
	title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	title.Text = TITLE_TEXT
	title.Font = Enum.Font.FredokaOne
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextStrokeTransparency = 0
	addStroke(title, 3, Color3.new(0, 0, 0))

	local countdown = Instance.new("TextLabel")
	countdown.Name = "Countdown"
	countdown.Parent = root
	countdown.AnchorPoint = Vector2.new(0.5, 1)
	countdown.Position = UDim2.fromScale(0.5, 0.985)
	countdown.Size = UDim2.fromScale(0.9, 0.055)
	countdown.BackgroundTransparency = 1
	countdown.TextXAlignment = Enum.TextXAlignment.Center
	countdown.Font = Enum.Font.FredokaOne
	countdown.TextScaled = true
	countdown.TextColor3 = Color3.fromRGB(230, 230, 230)
	countdown.TextStrokeTransparency = 0
	countdown.Text = "Next Reset: 30s"

	local rows = Instance.new("Frame")
	rows.Name = "Rows"
	rows.Parent = root
	rows.Position = UDim2.fromScale(0.02, 0.14)
	rows.Size = UDim2.fromScale(0.96, 0.74)
	rows.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout")
	layout.Parent = rows
	layout.Padding = UDim.new(0.01, 0)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	return surfaceGui, rows, countdown
end

local function getSeconds(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 0 end
	local seconds = leaderstats:FindFirstChild("Seconds")
	if not seconds then return 0 end
	return tonumber(seconds.Value) or 0
end

local function pushPlayerToGlobal(player)
	local secondsValue = getSeconds(player)
	local ok, err = pcall(function()
		leaderboardStore:SetAsync(tostring(player.UserId), secondsValue)
	end)
	if not ok then
		warn("[SecondsLeaderboard] Failed SetAsync for", player.UserId, err)
	end
end

local function pushAllPlayersToGlobal()
	for _, player in ipairs(Players:GetPlayers()) do
		pushPlayerToGlobal(player)
	end
end

local function getUserName(userId)
	if nameCache[userId] then
		return nameCache[userId]
	end

	local onlinePlayer = Players:GetPlayerByUserId(userId)
	if onlinePlayer then
		local combined = string.format("%s (@%s)", onlinePlayer.DisplayName, onlinePlayer.Name)
		nameCache[userId] = combined
		return combined
	end

	local infoOk, infoResult = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({userId})
	end)

	if infoOk and infoResult and infoResult[1] then
		local displayName = infoResult[1].DisplayName or infoResult[1].Username or tostring(userId)
		local username = infoResult[1].Username or tostring(userId)
		local combined = string.format("%s (@%s)", displayName, username)
		nameCache[userId] = combined
		return combined
	end

	local ok, result = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)

	if ok and result then
		local combined = string.format("%s (@%s)", result, result)
		nameCache[userId] = combined
		return combined
	end

	return "User " .. tostring(userId)
end

local function getHeadshot(userId)
	if thumbCache[userId] then
		return thumbCache[userId]
	end

	local ok, thumb = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)

	if ok and thumb then
		thumbCache[userId] = thumb
		return thumb
	end

	return ""
end

local function createRow(parent, rank, userId, playerName, secondsValue)
	local row = Instance.new("Frame")
	row.Name = "Row_" .. rank
	row.Parent = parent
	row.Size = UDim2.fromScale(1, 0.09)
	row.LayoutOrder = rank
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	addStroke(row, 2, Color3.new(0, 0, 0))

	local rankLabel = Instance.new("TextLabel")
	rankLabel.Parent = row
	rankLabel.Position = UDim2.fromScale(0.01, 0.08)
	rankLabel.Size = UDim2.fromScale(0.08, 0.84)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = "#" .. rank
	rankLabel.Font = Enum.Font.FredokaOne
	rankLabel.TextScaled = true
	rankLabel.TextColor3 = Color3.new(1, 1, 1)
	rankLabel.TextStrokeTransparency = 0

	local avatar = Instance.new("ImageLabel")
	avatar.Parent = row
	avatar.Position = UDim2.fromScale(0.11, 0.08)
	avatar.Size = UDim2.fromScale(0.11, 0.84)
	avatar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	avatar.ScaleType = Enum.ScaleType.Fit
	avatar.Image = getHeadshot(userId)
	addStroke(avatar, 2, Color3.new(0, 0, 0))

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Parent = row
	nameLabel.Position = UDim2.fromScale(0.24, 0.08)
	nameLabel.Size = UDim2.fromScale(0.45, 0.84)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = playerName
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0

	local secondsLabel = Instance.new("TextLabel")
	secondsLabel.Parent = row
	secondsLabel.Position = UDim2.fromScale(0.7, 0.08)
	secondsLabel.Size = UDim2.fromScale(0.29, 0.84)
	secondsLabel.BackgroundTransparency = 1
	secondsLabel.TextXAlignment = Enum.TextXAlignment.Right
	secondsLabel.Text = tostring(secondsValue) .. "s"
	secondsLabel.Font = Enum.Font.FredokaOne
	secondsLabel.TextScaled = true
	secondsLabel.TextColor3 = Color3.fromRGB(255, 235, 130)
	secondsLabel.TextStrokeTransparency = 0
end

local function renderGlobalRows(rowsFrame)
	for _, child in ipairs(rowsFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local ok, pages = pcall(function()
		return leaderboardStore:GetSortedAsync(false, MAX_ROWS)
	end)

	if not ok then
		warn("[SecondsLeaderboard] Failed GetSortedAsync")
		return
	end

	local topPage = pages:GetCurrentPage()
	for rank, entry in ipairs(topPage) do
		local userId = tonumber(entry.key)
		if userId then
			local name = getUserName(userId)
			createRow(rowsFrame, rank, userId, name, math.floor(entry.value))
		end
	end
end

local boardPart = workspace:FindFirstChild(BOARD_PART_NAME)
if not boardPart or not boardPart:IsA("BasePart") then
	warn("[SecondsLeaderboard] Missing BasePart named '" .. BOARD_PART_NAME .. "'")
	return
end

local _, rowsFrame, countdownLabel = createBoardGui(boardPart)

-- Save when players leave so global board remains fresh.
Players.PlayerRemoving:Connect(function(player)
	pushPlayerToGlobal(player)
end)

while true do
	-- Global write + refresh snapshot every 30 seconds.
	pushAllPlayersToGlobal()
	renderGlobalRows(rowsFrame)

	for remaining = REFRESH_INTERVAL, 1, -1 do
		countdownLabel.Text = "Next Reset: " .. tostring(remaining) .. "s"
		task.wait(1)
	end
end
