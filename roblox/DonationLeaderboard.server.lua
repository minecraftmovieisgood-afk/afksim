local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local UserService = game:GetService("UserService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG
local BOARD_PART_NAME = "Donate leaderboard" -- CASE + SPACE sensitive
local TITLE_TEXT = "Most Robux Spent"
local REFRESH_INTERVAL = 30
local MAX_ROWS = 10
local ORDERED_STORE_NAME = "GlobalRobuxSpentLeaderboard_v1"
local DONATED_TOTALS_STORE_NAME = "PlayerRobuxDonatedTotals_v1"
local SPENT_TOTALS_STORE_NAME = "PlayerRobuxSpentTotals_v1"
local GET_DONATED_TOTAL_FN_NAME = "GetDonatedRobuxTotal"
local GET_SPENT_TOTAL_FN_NAME = "GetRobuxSpentTotal"
local PROCESSED_RECEIPTS_STORE_NAME = "ProcessedDonationReceipts_v1"

-- IMPORTANT: Replace with your real Developer Product IDs and Robux values.
local DONATION_PRODUCTS = {
	[3559541392] = 5,
	[3566239112] = 19, -- Title Pack x1
	[3566239569] = 100, -- Title Pack x5
	[3566239990] = 300, -- Title Pack x10
}

local TITLE_PACK_PRODUCT_AMOUNTS = {
	[3566239112] = 1,
	[3566239569] = 5,
	[3566239990] = 10,
}

local GAMEPASS_SPEND = {
	[1769149472] = 19,
	[1765744598] = 36,
}

local leaderboardStore = DataStoreService:GetOrderedDataStore(ORDERED_STORE_NAME)
local donatedTotalsStore = DataStoreService:GetDataStore(DONATED_TOTALS_STORE_NAME)
local spentTotalsStore = DataStoreService:GetDataStore(SPENT_TOTALS_STORE_NAME)
local receiptsStore = DataStoreService:GetDataStore(PROCESSED_RECEIPTS_STORE_NAME)
local nameCache = {}
local thumbCache = {}
local donatedTotalsCache = {}
local spentTotalsCache = {}

local getDonatedTotalFn = ReplicatedStorage:FindFirstChild(GET_DONATED_TOTAL_FN_NAME)
if not getDonatedTotalFn then
	getDonatedTotalFn = Instance.new("RemoteFunction")
	getDonatedTotalFn.Name = GET_DONATED_TOTAL_FN_NAME
	getDonatedTotalFn.Parent = ReplicatedStorage
end

local getSpentTotalFn = ReplicatedStorage:FindFirstChild(GET_SPENT_TOTAL_FN_NAME)
if not getSpentTotalFn then
	getSpentTotalFn = Instance.new("RemoteFunction")
	getSpentTotalFn.Name = GET_SPENT_TOTAL_FN_NAME
	getSpentTotalFn.Parent = ReplicatedStorage
end

local titlePackPurchaseGrantedEvent = ReplicatedStorage:FindFirstChild("TitlePackPurchaseGranted") or Instance.new("BindableEvent")
titlePackPurchaseGrantedEvent.Name = "TitlePackPurchaseGranted"
titlePackPurchaseGrantedEvent.Parent = ReplicatedStorage

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
	local existing = boardPart:FindFirstChild("DonationLeaderboardGui")
	if existing then
		existing:Destroy()
	end

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "DonationLeaderboardGui"
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

local function createRow(parent, rank, userId, playerName, robuxValue)
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

	local robuxLabel = Instance.new("TextLabel")
	robuxLabel.Parent = row
	robuxLabel.Position = UDim2.fromScale(0.7, 0.08)
	robuxLabel.Size = UDim2.fromScale(0.29, 0.84)
	robuxLabel.BackgroundTransparency = 1
	robuxLabel.TextXAlignment = Enum.TextXAlignment.Right
	robuxLabel.Text = tostring(robuxValue) .. " Robux"
	robuxLabel.Font = Enum.Font.FredokaOne
	robuxLabel.TextScaled = true
	robuxLabel.TextColor3 = Color3.fromRGB(255, 235, 130)
	robuxLabel.TextStrokeTransparency = 0
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
		warn("[DonationLeaderboard] Failed GetSortedAsync")
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

local function getStoredTotal(store, cache, userId)
	if cache[userId] ~= nil then
		return cache[userId]
	end
	local ok, value = pcall(function()
		return store:GetAsync(tostring(userId))
	end)
	local total = 0
	if ok and tonumber(value) then
		total = tonumber(value)
	end
	cache[userId] = total
	return total
end

local function addToStore(store, cache, userId, robux)
	local key = tostring(userId)
	local ok, newTotal = pcall(function()
		return store:UpdateAsync(key, function(old)
			old = tonumber(old) or 0
			return old + robux
		end)
	end)
	if not ok then
		return nil
	end
	cache[userId] = tonumber(newTotal) or 0
	return cache[userId]
end

local function addSpentToPlayer(userId, robux)
	local newSpent = addToStore(spentTotalsStore, spentTotalsCache, userId, robux)
	if not newSpent then
		warn("[DonationLeaderboard] Failed spent UpdateAsync for", userId)
		return false
	end
	local key = tostring(userId)
	local ok2, err2 = pcall(function()
		leaderboardStore:SetAsync(key, newSpent)
	end)
	if not ok2 then
		warn("[DonationLeaderboard] Failed ordered SetAsync for", userId, err2)
	end

	local onlinePlayer = Players:GetPlayerByUserId(userId)
	if onlinePlayer then
		onlinePlayer:SetAttribute("SpentRobuxTotal", newSpent)
	end
	return true
end

local function addDonatedToPlayer(userId, robux)
	local newDonated = addToStore(donatedTotalsStore, donatedTotalsCache, userId, robux)
	if not newDonated then
		warn("[DonationLeaderboard] Failed donated UpdateAsync for", userId)
		return false
	end
	local onlinePlayer = Players:GetPlayerByUserId(userId)
	if onlinePlayer then
		onlinePlayer:SetAttribute("DonatedRobuxTotal", newDonated)
		onlinePlayer:SetAttribute("HasDonated", newDonated > 0)
	end
	return true
end

local function addDonationToPlayer(userId, robux)
	local donatedAdded = addDonatedToPlayer(userId, robux)
	local spentAdded = addSpentToPlayer(userId, robux)
	if not donatedAdded or not spentAdded then
		return false
	end
	return true
end

Players.PlayerAdded:Connect(function(player)
	local donated = getStoredTotal(donatedTotalsStore, donatedTotalsCache, player.UserId)
	local spent = getStoredTotal(spentTotalsStore, spentTotalsCache, player.UserId)
	player:SetAttribute("DonatedRobuxTotal", donated)
	player:SetAttribute("SpentRobuxTotal", spent)
	player:SetAttribute("HasDonated", donated > 0)
end)

getDonatedTotalFn.OnServerInvoke = function(player)
	local donated = getStoredTotal(donatedTotalsStore, donatedTotalsCache, player.UserId)
	player:SetAttribute("DonatedRobuxTotal", donated)
	player:SetAttribute("HasDonated", donated > 0)
	return donated
end

getSpentTotalFn.OnServerInvoke = function(player)
	local spent = getStoredTotal(spentTotalsStore, spentTotalsCache, player.UserId)
	player:SetAttribute("SpentRobuxTotal", spent)
	return spent
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local receiptKey = tostring(receiptInfo.PurchaseId)
	local seenOk, seenResult = pcall(function()
		return receiptsStore:GetAsync(receiptKey)
	end)
	if seenOk and seenResult == true then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local robux = tonumber(receiptInfo.CurrencySpent)
	if not robux or robux <= 0 then
		robux = DONATION_PRODUCTS[receiptInfo.ProductId]
	end
	if not robux or robux <= 0 then
		warn("[DonationLeaderboard] Could not resolve robux for ProductId:", receiptInfo.ProductId, "PurchaseId:", receiptInfo.PurchaseId)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local added = addDonationToPlayer(receiptInfo.PlayerId, robux)
	if not added then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local packAmount = TITLE_PACK_PRODUCT_AMOUNTS[receiptInfo.ProductId]
	if packAmount then
		local packOk, packErr = pcall(function()
			titlePackPurchaseGrantedEvent:Fire(receiptInfo.PlayerId, packAmount)
		end)
		if not packOk then
			warn("[DonationLeaderboard] Failed to grant title packs for ProductId:", receiptInfo.ProductId, packErr)
		end
	end

	local markOk, markErr = pcall(function()
		receiptsStore:SetAsync(receiptKey, true)
	end)
	if not markOk then
		warn("[DonationLeaderboard] Failed to mark receipt processed:", receiptInfo.PurchaseId, markErr)
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end


MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(purchasePlayer, gamePassId, wasPurchased)
	if not wasPurchased then
		return
	end
	local spent = GAMEPASS_SPEND[gamePassId]
	if not spent or spent <= 0 then
		return
	end
	addSpentToPlayer(purchasePlayer.UserId, spent)
end)

local boardPart = workspace:FindFirstChild(BOARD_PART_NAME)
if not boardPart or not boardPart:IsA("BasePart") then
	warn("[DonationLeaderboard] Missing BasePart named '" .. BOARD_PART_NAME .. "'")
	return
end

local _, rowsFrame, countdownLabel = createBoardGui(boardPart)

while true do
	renderGlobalRows(rowsFrame)

	for remaining = REFRESH_INTERVAL, 1, -1 do
		countdownLabel.Text = "Next Reset: " .. tostring(remaining) .. "s"
		task.wait(1)
	end
end
