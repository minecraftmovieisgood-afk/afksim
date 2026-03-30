local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local getProgressFn = ReplicatedStorage:WaitForChild("GetPlayerProgress")
local markTitleEvent = ReplicatedStorage:WaitForChild("MarkTitleNotified")

local TITLES = {
	{Id = "None", Name = "None", Required = 0, IsAFK = true, Color = Color3.fromRGB(230, 230, 230)},
	{Id = "IdleBeginner", Name = "Time Newbie", Required = 60, IsAFK = true, Color = Color3.fromRGB(135, 206, 235)},
	{Id = "AFKExplorer", Name = "Clock Rookie", Required = 300, IsAFK = true, Color = Color3.fromRGB(90, 190, 255)},
	{Id = "AFKRookie", Name = "Minute Stacker", Required = 1200, IsAFK = true, Color = Color3.fromRGB(124, 252, 0)},
	{Id = "AFKVeteran", Name = "Hour Holder", Required = 3600, IsAFK = true, Color = Color3.fromRGB(40, 220, 160)},
	{Id = "AFKGrinder", Name = "Drift Runner", Required = 7200, IsAFK = true, Color = Color3.fromRGB(255, 170, 0)},
	{Id = "AFKElite", Name = "Chrono Charger", Required = 10800, IsAFK = true, Color = Color3.fromRGB(255, 120, 70)},
	{Id = "AFKMaster", Name = "Day Dreamer", Required = 21600, IsAFK = true, Color = Color3.fromRGB(170, 85, 255)},
	{Id = "AFKTitan", Name = "Half-Day Howler", Required = 43200, IsAFK = true, Color = Color3.fromRGB(255, 70, 170)},
	{Id = "AFKLegend", Name = "24H Beast", Required = 86400, IsAFK = true, Color = Color3.fromRGB(255, 215, 0)},
	{Id = "ChronoSovereign", Name = "Storm of Seconds", Required = 172800, IsAFK = true, Color = Color3.fromRGB(170, 225, 255)},
	{Id = "Daybreaker", Name = "Clockbreaker X", Required = 259200, IsAFK = true, Color = Color3.fromRGB(140, 245, 200)},
	{Id = "Weeksmith", Name = "Temporal Overlord", Required = 345600, IsAFK = true, Color = Color3.fromRGB(255, 195, 120)},
	{Id = "Everclock", Name = "Paradox Reaper", Required = 432000, IsAFK = true, Color = Color3.fromRGB(225, 150, 255)},
	{Id = "InfinityWatch", Name = "Infinity Cataclysm", Required = 604800, IsAFK = true, Color = Color3.fromRGB(255, 245, 160)},
	{Id = "QuantumSleeper", Name = "Quantum Sleeper", Required = 777600, IsAFK = true, Color = Color3.fromRGB(190, 225, 255)},
	{Id = "EpochWarden", Name = "Epoch Warden", Required = 950400, IsAFK = true, Color = Color3.fromRGB(170, 240, 255)},
	{Id = "CalendarCrusher", Name = "Calendar Crusher", Required = 1209600, IsAFK = true, Color = Color3.fromRGB(255, 220, 170)},
	{Id = "MonthMarauder", Name = "Month Marauder", Required = 1814400, IsAFK = true, Color = Color3.fromRGB(255, 190, 150)},
	{Id = "TimeGlacier", Name = "Time Glacier", Required = 2419200, IsAFK = true, Color = Color3.fromRGB(180, 255, 245)},
	{Id = "EraArchitect", Name = "Era Architect", Required = 3024000, IsAFK = true, Color = Color3.fromRGB(210, 200, 255)},
	{Id = "MillenniumDrift", Name = "Millennium Drift", Required = 3628800, IsAFK = true, Color = Color3.fromRGB(255, 170, 225)},
	{Id = "CosmicClocklord", Name = "Cosmic Clocklord", Required = 4233600, IsAFK = true, Color = Color3.fromRGB(255, 240, 170)},
	{Id = "TimelineDevourer", Name = "Timeline Devourer", Required = 4838400, IsAFK = true, Color = Color3.fromRGB(255, 145, 210)},
	{Id = "AbsoluteEternity", Name = "Absolute Eternity", Required = 5443200, IsAFK = true, Color = Color3.fromRGB(255, 120, 170)},
	{Id = "Owner", Name = "Owner", Required = 0, IsAFK = false, AllowedUserIds = {3653999284}, Color = Color3.fromRGB(210, 210, 210)},
}

local unlocked = {}
local progress = {}

local function isTitleUnlocked(title, seconds)
	if seconds < title.Required then
		return false
	end

	if title.AllowedUserIds then
		for _, userId in ipairs(title.AllowedUserIds) do
			if player.UserId == userId then
				return true
			end
		end
		return false
	end

	return true
end

local function addStroke(guiObj, thickness, color)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 3
	stroke.Color = color or Color3.new(0, 0, 0)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcall(function()
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
	end)
	stroke.Parent = guiObj
	return stroke
end

local function colorToHex(color)
	local r = math.clamp(math.floor(color.R * 255), 0, 255)
	local g = math.clamp(math.floor(color.G * 255), 0, 255)
	local b = math.clamp(math.floor(color.B * 255), 0, 255)
	return string.format("#%02X%02X%02X", r, g, b)
end

local gui = Instance.new("ScreenGui")
gui.Name = "TitleUnlockNotificationsGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local stack = Instance.new("Frame")
stack.Name = "NotificationStack"
stack.Parent = gui
stack.AnchorPoint = Vector2.new(0.5, 0)
stack.Position = UDim2.fromScale(0.5, 0.12)
stack.Size = UDim2.fromScale(0.45, 0.35)
stack.BackgroundTransparency = 1

local stackLayout = Instance.new("UIListLayout")
stackLayout.Parent = stack
stackLayout.Padding = UDim.new(0.01, 0)
stackLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
stackLayout.VerticalAlignment = Enum.VerticalAlignment.Top
stackLayout.SortOrder = Enum.SortOrder.LayoutOrder

local notifOrder = 0
local function pushMessage(message)
	notifOrder += 1
	local frame = Instance.new("Frame")
	frame.Name = "Notification"
	frame.Parent = stack
	frame.Size = UDim2.fromScale(0.95, 0.2)
	frame.BackgroundColor3 = Color3.fromRGB(72, 72, 78)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = notifOrder
	addStroke(frame, 3, Color3.new(0, 0, 0))

	local textLabel = Instance.new("TextLabel")
	textLabel.Parent = frame
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 230, 120)
	textLabel.TextStrokeTransparency = 1
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.RichText = true
	textLabel.Text = message
	textLabel.TextTransparency = 1
	textLabel.TextWrapped = true

	local tweenIn = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.05,
	})
	local textIn = TweenService:Create(textLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		TextStrokeTransparency = 0,
	})
	tweenIn:Play()
	textIn:Play()

	task.delay(5, function()
		if frame and frame.Parent then
			local tweenOut = TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
			})
			local textOut = TweenService:Create(textLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1,
				TextStrokeTransparency = 1,
			})
			tweenOut:Play()
			textOut:Play()
			tweenOut.Completed:Wait()
			if frame and frame.Parent then
				frame:Destroy()
			end
		end
	end)
end

local leaderstats = player:WaitForChild("leaderstats")
local secondsValue = leaderstats:WaitForChild("Seconds")
local ok, result = pcall(function()
	return getProgressFn:InvokeServer()
end)
if ok and typeof(result) == "table" then
	progress = result
end
local notifiedTitles = (typeof(progress.notifiedTitles) == "table" and progress.notifiedTitles) or {}

for _, title in ipairs(TITLES) do
	if title.Id ~= "None" then
		local currentlyUnlocked = isTitleUnlocked(title, secondsValue.Value)
		local alreadyNotified = notifiedTitles[title.Id] == true
		unlocked[title.Id] = currentlyUnlocked
		if currentlyUnlocked and not alreadyNotified then
			notifiedTitles[title.Id] = true
			markTitleEvent:FireServer(title.Id)
			local titleColor = colorToHex(title.Color or Color3.new(1, 1, 1))
			pushMessage('NEW TITLE UNLOCKED: <font color="' .. titleColor .. '">' .. title.Name .. '</font>')
		end
	end
end

secondsValue:GetPropertyChangedSignal("Value"):Connect(function()
	for _, title in ipairs(TITLES) do
		if title.Id ~= "None" then
			local nowUnlocked = isTitleUnlocked(title, secondsValue.Value)
			local alreadyNotified = notifiedTitles[title.Id] == true
			if nowUnlocked and not unlocked[title.Id] and not alreadyNotified then
				unlocked[title.Id] = true
				notifiedTitles[title.Id] = true
				markTitleEvent:FireServer(title.Id)
				local titleColor = colorToHex(title.Color or Color3.new(1, 1, 1))
				pushMessage('NEW TITLE UNLOCKED: <font color="' .. titleColor .. '">' .. title.Name .. '</font>')
			end
		end
	end
end)
