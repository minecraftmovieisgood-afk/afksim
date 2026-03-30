local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local equipEvent = ReplicatedStorage:WaitForChild("EquipTitleEvent")
local autoBestTimeEvent = ReplicatedStorage:WaitForChild("SetAutoBestTimeTitle")
local equippedTitleValue = player:WaitForChild("EquippedTitle")
local ACTIVE_UI_ATTR = "ActiveMenuUI"
local UI_ID = "Titles"

local FONT = Enum.Font.FredokaOne
local BUTTON_TEXTURE = "rbxassetid://18878365966"
local BUTTON_TEXTURE_TRANSPARENCY = 0.5

local TITLES = {
	{Id = "None", Name = "None", Required = 0, Description = "The Default Title", IsAFK = true, Color = Color3.fromRGB(230, 230, 230)},
	{Id = "IdleBeginner", Name = "Time Newbie", Required = 60, Description = "First tiny step into the clockwork.", IsAFK = true, Color = Color3.fromRGB(135, 206, 235)},
	{Id = "AFKExplorer", Name = "Clock Rookie", Required = 300, Description = "A few minutes in, still warming up.", IsAFK = true, Color = Color3.fromRGB(90, 190, 255)},
	{Id = "AFKRookie", Name = "Minute Stacker", Required = 1200, Description = "Piling up minutes like it's nothing.", IsAFK = true, Color = Color3.fromRGB(124, 252, 0)},
	{Id = "AFKVeteran", Name = "Hour Holder", Required = 3600, Description = "You can hold a full hour with ease.", IsAFK = true, Color = Color3.fromRGB(40, 220, 160)},
	{Id = "AFKGrinder", Name = "Drift Runner", Required = 7200, Description = "Two-hour sessions are your comfort zone.", IsAFK = true, Color = Color3.fromRGB(255, 170, 0)},
	{Id = "AFKElite", Name = "Chrono Charger", Required = 10800, Description = "Three-hour pace, high momentum.", IsAFK = true, Color = Color3.fromRGB(255, 120, 70)},
	{Id = "AFKMaster", Name = "Day Dreamer", Required = 21600, Description = "Half-day grind unlocked.", IsAFK = true, Color = Color3.fromRGB(170, 85, 255)},
	{Id = "AFKTitan", Name = "Half-Day Howler", Required = 43200, Description = "12-hour endurance machine.", IsAFK = true, Color = Color3.fromRGB(255, 70, 170)},
	{Id = "AFKLegend", Name = "24H Beast", Required = 86400, Description = "One full day conquered.", IsAFK = true, Color = Color3.fromRGB(255, 215, 0)},
	{Id = "ChronoSovereign", Name = "Storm of Seconds", Required = 172800, Description = "100K+ territory begins here.", IsAFK = true, Color = Color3.fromRGB(170, 225, 255)},
	{Id = "Daybreaker", Name = "Clockbreaker X", Required = 259200, Description = "Time bends when you log in.", IsAFK = true, Color = Color3.fromRGB(140, 245, 200)},
	{Id = "Weeksmith", Name = "Temporal Overlord", Required = 345600, Description = "You command the timeline.", IsAFK = true, Color = Color3.fromRGB(255, 195, 120)},
	{Id = "Everclock", Name = "Paradox Reaper", Required = 432000, Description = "Reality glitches around your sessions.", IsAFK = true, Color = Color3.fromRGB(225, 150, 255)},
	{Id = "InfinityWatch", Name = "Infinity Cataclysm", Required = 604800, Description = "A week deep. Pure chaos energy.", IsAFK = true, Color = Color3.fromRGB(255, 245, 160)},
		{Id = "QuantumSleeper", Name = "Quantum Sleeper", Required = 777600, Description = "Nine days in deep AFK stasis.", IsAFK = true, Color = Color3.fromRGB(190, 225, 255)},
	{Id = "EpochWarden", Name = "Epoch Warden", Required = 950400, Description = "You guard entire epochs of idle time.", IsAFK = true, Color = Color3.fromRGB(170, 240, 255)},
	{Id = "CalendarCrusher", Name = "Calendar Crusher", Required = 1209600, Description = "Two-week timer breaker.", IsAFK = true, Color = Color3.fromRGB(255, 220, 170)},
	{Id = "MonthMarauder", Name = "Month Marauder", Required = 1814400, Description = "Three-week relentless grinder.", IsAFK = true, Color = Color3.fromRGB(255, 190, 150)},
	{Id = "TimeGlacier", Name = "Time Glacier", Required = 2419200, Description = "A month of frozen focus.", IsAFK = true, Color = Color3.fromRGB(180, 255, 245)},
	{Id = "EraArchitect", Name = "Era Architect", Required = 3024000, Description = "Building eras one second at a time.", IsAFK = true, Color = Color3.fromRGB(210, 200, 255)},
	{Id = "MillenniumDrift", Name = "Millennium Drift", Required = 3628800, Description = "A legend adrift through endless hours.", IsAFK = true, Color = Color3.fromRGB(255, 170, 225)},
	{Id = "CosmicClocklord", Name = "Cosmic Clocklord", Required = 4233600, Description = "Master of cosmic countdowns.", IsAFK = true, Color = Color3.fromRGB(255, 240, 170)},
	{Id = "TimelineDevourer", Name = "Timeline Devourer", Required = 4838400, Description = "You consume timelines for breakfast.", IsAFK = true, Color = Color3.fromRGB(255, 145, 210)},
	{Id = "AbsoluteEternity", Name = "Absolute Eternity", Required = 5443200, Description = "The highest form of AFK existence.", IsAFK = true, Color = Color3.fromRGB(255, 120, 170)},
	{Id = "Donater", Name = "Donater", Required = 0, Description = "Awarded to players who have donated.", IsAFK = false, RequiresDonation = true, Color = Color3.fromRGB(255, 210, 90)},
	{Id = "Disco", Name = "Disco", Required = 0, Description = "1% chance every second during active disco event.", IsAFK = false, RequiresDiscoTitle = true, Color = Color3.fromRGB(255, 90, 90)},
		{Id = "PackComet", Name = "Comet Trail", Required = 0, Description = "From Title Packs (Common).", IsAFK = false, RequiresPackTitle = "PackComet", Color = Color3.fromRGB(150, 220, 255)},
	{Id = "PackAurora", Name = "Aurora Pulse", Required = 0, Description = "From Title Packs (Uncommon).", IsAFK = false, RequiresPackTitle = "PackAurora", Color = Color3.fromRGB(170, 255, 210)},
	{Id = "PackNebula", Name = "Nebula Core", Required = 0, Description = "From Title Packs (Rare).", IsAFK = false, RequiresPackTitle = "PackNebula", Color = Color3.fromRGB(200, 170, 255)},
	{Id = "PackCelestial", Name = "Celestial Crown", Required = 0, Description = "From Title Packs (Epic).", IsAFK = false, RequiresPackTitle = "PackCelestial", Color = Color3.fromRGB(255, 210, 120)},
	{Id = "PackSingularity", Name = "GOD", Required = 0, Description = "From Title Packs (0.1% GOD drop).", IsAFK = false, RequiresPackTitle = "PackSingularity", Color = Color3.fromRGB(255, 245, 120)},
	{Id = "Owner", Name = "Owner", Required = 0, Description = "Exclusive title for the game owner.", IsAFK = false, AllowedUserIds = {3653999284}, Color = Color3.fromRGB(210, 210, 210)},
}

local rowRefreshers = {}
local function isCountableTitle(data)
	return data.Id ~= "None"
end

local function isTitleUnlockedForPlayer(data, secondsValue)
	local unlocked = secondsValue.Value >= data.Required
	if data.RequiresDonation then
		unlocked = player:GetAttribute("HasDonated") == true
	end
	if data.RequiresDiscoTitle then
		unlocked = player:GetAttribute("HasDiscoTitle") == true
	end
	if data.RequiresPackTitle then
		unlocked = player:GetAttribute("HasPackTitle_" .. data.RequiresPackTitle) == true
	end
	if data.AllowedUserIds then
		unlocked = false
		for _, userId in ipairs(data.AllowedUserIds) do
			if player.UserId == userId then
				unlocked = true
				break
			end
		end
	end
	return unlocked
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

local function addButtonTweens(btn)
	local baseSize = btn.Size
	local hoverSize = UDim2.new(baseSize.X.Scale * 1.03, baseSize.X.Offset, baseSize.Y.Scale * 1.03, baseSize.Y.Offset)
	local pressSize = UDim2.new(baseSize.X.Scale * 0.97, baseSize.X.Offset, baseSize.Y.Scale * 0.97, baseSize.Y.Offset)

	local hoverIn = TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = hoverSize})
	local hoverOut = TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = baseSize})
	local pressIn = TweenService:Create(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = pressSize})
	local pressOut = TweenService:Create(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = hoverSize})

	btn.MouseEnter:Connect(function()
		hoverIn:Play()
	end)
	btn.MouseLeave:Connect(function()
		hoverOut:Play()
	end)
	btn.MouseButton1Down:Connect(function()
		pressIn:Play()
	end)
	btn.MouseButton1Up:Connect(function()
		pressOut:Play()
	end)
end

local function makeButton(parent, name, text, pos, size, bgColor)
	local btn = Instance.new("ImageButton")
	btn.Name = name
	btn.Parent = parent
	btn.Position = pos
	btn.Size = size
	btn.BackgroundColor3 = bgColor or Color3.fromRGB(255, 0, 0)
	btn.AutoButtonColor = false
	btn.Image = BUTTON_TEXTURE
	btn.ImageTransparency = BUTTON_TEXTURE_TRANSPARENCY
	btn.ScaleType = Enum.ScaleType.Stretch
	addStroke(btn, 3, Color3.new(0, 0, 0))

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Label"
	lbl.Parent = btn
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = FONT
	lbl.TextScaled = true
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency = 0
	lbl.TextStrokeColor3 = Color3.new(0, 0, 0)

	addButtonTweens(btn)
	return btn
end

local gui = Instance.new("ScreenGui")
gui.Name = "TitlesGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = gui

local blur = Lighting:FindFirstChild("TitlesBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "TitlesBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

local openBtn = makeButton(
	gui,
	"OpenTitlesButton",
	"Titles",
	UDim2.fromScale(0.015, 0.40),
	UDim2.fromScale(0.13, 0.085),
	Color3.fromRGB(255, 0, 0)
)
local openBtnStroke = openBtn:FindFirstChildOfClass("UIStroke")
if openBtnStroke then
	openBtnStroke.Thickness = 5
end
openBtn.Visible = true

local autoBestSideBtn = makeButton(
	gui,
	"AutoBestTimeSideButton",
	"Auto Time: OFF",
	UDim2.fromScale(0.015, 0.70),
	UDim2.fromScale(0.13, 0.07),
	Color3.fromRGB(120, 40, 40)
)
local autoBestStroke = autoBestSideBtn:FindFirstChildOfClass("UIStroke")
if autoBestStroke then
	autoBestStroke.Thickness = 5
end

local openBtnBasePosition = openBtn.Position
local openBtnHiddenPosition = openBtnBasePosition + UDim2.fromScale(-0.2, 0)
local openBtnTween
local autoBtnBasePosition = autoBestSideBtn.Position
local autoBtnHiddenPosition = autoBtnBasePosition + UDim2.fromScale(-0.2, 0)
local autoBtnTween

local function tweenOpenButton(shouldShow)
	local target = shouldShow and openBtnBasePosition or openBtnHiddenPosition
	openBtn.Active = shouldShow
	if openBtnTween then
		openBtnTween:Cancel()
	end
	openBtnTween = TweenService:Create(openBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = target,
	})
	openBtnTween:Play()
end

local function tweenAutoBestButton(shouldShow)
	local target = shouldShow and autoBtnBasePosition or autoBtnHiddenPosition
	autoBestSideBtn.Active = shouldShow
	if autoBtnTween then
		autoBtnTween:Cancel()
	end
	autoBtnTween = TweenService:Create(autoBestSideBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = target,
	})
	autoBtnTween:Play()
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromScale(0.56, 0.62)
main.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
main.BackgroundTransparency = 1
main.Visible = false
addStroke(main, 4, Color3.new(0, 0, 0))

local defaultMainSize = main.Size
local closedMainSize = UDim2.new(defaultMainSize.X.Scale * 0.85, defaultMainSize.X.Offset, defaultMainSize.Y.Scale * 0.85, defaultMainSize.Y.Offset)
main.Size = closedMainSize

local afkTab = makeButton(main, "AFKTab", "AFK Titles", UDim2.fromScale(0.02, 0.02), UDim2.fromScale(0.23, 0.1), Color3.fromRGB(30, 30, 30))
local otherTab = makeButton(main, "OtherTab", "Other Titles", UDim2.fromScale(0.27, 0.02), UDim2.fromScale(0.23, 0.1), Color3.fromRGB(30, 30, 30))

local secondsLabel = Instance.new("TextLabel")
secondsLabel.Name = "SecondsLabel"
secondsLabel.Parent = main
secondsLabel.Position = UDim2.fromScale(0.52, 0.005)
secondsLabel.Size = UDim2.fromScale(0.35, 0.1)
secondsLabel.BackgroundTransparency = 1
secondsLabel.Text = "Your Seconds: 0"
secondsLabel.Font = FONT
secondsLabel.TextScaled = true
secondsLabel.TextColor3 = Color3.new(1,1,1)
secondsLabel.TextStrokeTransparency = 0
secondsLabel.TextStrokeColor3 = Color3.new(0,0,0)

local titlesCollectedLabel = Instance.new("TextLabel")
titlesCollectedLabel.Name = "TitlesCollectedLabel"
titlesCollectedLabel.Parent = main
titlesCollectedLabel.Position = UDim2.fromScale(0.52, 0.07)
titlesCollectedLabel.Size = UDim2.fromScale(0.35, 0.08)
titlesCollectedLabel.BackgroundTransparency = 1
titlesCollectedLabel.Text = "Titles Collected: 0/0"
titlesCollectedLabel.Font = FONT
titlesCollectedLabel.TextScaled = true
titlesCollectedLabel.TextColor3 = Color3.fromRGB(255, 235, 130)
titlesCollectedLabel.TextStrokeTransparency = 0
titlesCollectedLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

local closeBtn = makeButton(main, "CloseButton", "X", UDim2.fromScale(0.9, 0.03), UDim2.fromScale(0.08, 0.1), Color3.fromRGB(255, 0, 0))

local list = Instance.new("ScrollingFrame")
list.Name = "TitleList"
list.Parent = main
list.Position = UDim2.fromScale(0.02, 0.14)
list.Size = UDim2.fromScale(0.64, 0.82)
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 8
list.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout")
layout.Parent = list
layout.Padding = UDim.new(0.015, 0)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function createTitleRow(data, secondsValue, equippedValue)
	local row = Instance.new("Frame")
	row.Name = data.Id
	row.Size = UDim2.fromScale(0.98, 0.16)
	row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	addStroke(row, 3, Color3.new(0,0,0))

	local titleText = Instance.new("TextLabel")
	titleText.Parent = row
	titleText.Position = UDim2.fromScale(0.02, 0.08)
	titleText.Size = UDim2.fromScale(0.58, 0.38)
	titleText.BackgroundTransparency = 1
	titleText.Font = FONT
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.TextScaled = true
	titleText.TextColor3 = Color3.new(1,1,1)
	titleText.TextStrokeTransparency = 0
	titleText.TextStrokeColor3 = Color3.new(0,0,0)
	titleText.Text = (data.Name .. " | " .. data.Required .. " seconds required")
	titleText.TextColor3 = data.Color or Color3.new(1, 1, 1)

	local titleGradient = Instance.new("UIGradient")
	titleGradient.Rotation = 15
	local baseColor = data.Color or Color3.fromRGB(255, 255, 255)
	titleGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, baseColor:Lerp(Color3.new(1, 1, 1), 0.35)),
		ColorSequenceKeypoint.new(1, baseColor:Lerp(Color3.new(0, 0, 0), 0.25)),
	})
	titleGradient.Parent = titleText

	local desc = Instance.new("TextLabel")
	desc.Parent = row
	desc.Position = UDim2.fromScale(0.02, 0.48)
	desc.Size = UDim2.fromScale(0.58, 0.38)
	desc.BackgroundTransparency = 1
	desc.Font = FONT
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextScaled = true
	desc.TextColor3 = Color3.fromRGB(240,240,240)
	desc.TextStrokeTransparency = 0
	desc.TextStrokeColor3 = Color3.new(0,0,0)
	desc.Text = data.Description

	local action = makeButton(row, "Action", "Locked", UDim2.fromScale(0.64, 0.17), UDim2.fromScale(0.32, 0.66), Color3.fromRGB(80, 80, 80))

	local function refresh()
		local unlocked = isTitleUnlockedForPlayer(data, secondsValue)

		if unlocked then
			if equippedValue.Value == data.Name then
				action.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
				action.Label.Text = "Equipped"
			else
				action.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
				action.Label.Text = "Equip"
			end
		else
			action.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			action.Label.Text = "Locked"
		end
	end

	action.MouseButton1Click:Connect(function()
		local unlocked = isTitleUnlockedForPlayer(data, secondsValue)

		if unlocked then
			equipEvent:FireServer(data.Id)
		end
	end)
	refresh()

	return row, refresh
end

local activeAFKTab = true
local function populate(secondsValue)
	table.clear(rowRefreshers)
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, t in ipairs(TITLES) do
		if t.IsAFK == activeAFKTab then
			local row, refresh = createTitleRow(t, secondsValue, equippedTitleValue)
			row.Parent = list
			table.insert(rowRefreshers, refresh)
		end
	end
end

local isAnimating = false
local function openUI()
	local activeUi = player:GetAttribute(ACTIVE_UI_ATTR)
	if activeUi and activeUi ~= UI_ID then return end
	if isAnimating or main.Visible then return end
	isAnimating = true
	player:SetAttribute(ACTIVE_UI_ATTR, UI_ID)
	main.Visible = true
	main.Size = closedMainSize
	main.BackgroundTransparency = 1

	local mainTween = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = defaultMainSize,
		BackgroundTransparency = 0,
	})
	local blurTween = TweenService:Create(blur, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = 16,
	})

	mainTween:Play()
	blurTween:Play()
	mainTween.Completed:Wait()
	isAnimating = false
end

local function closeUI()
	if isAnimating or not main.Visible then return end
	isAnimating = true

	local mainTween = TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = closedMainSize,
		BackgroundTransparency = 1,
	})
	local blurTween = TweenService:Create(blur, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = 0,
	})

	mainTween:Play()
	blurTween:Play()
	mainTween.Completed:Wait()
	main.Visible = false
	if player:GetAttribute(ACTIVE_UI_ATTR) == UI_ID then
		player:SetAttribute(ACTIVE_UI_ATTR, nil)
	end
	isAnimating = false
end

openBtn.MouseButton1Click:Connect(openUI)
closeBtn.MouseButton1Click:Connect(closeUI)

local leaderstats = player:WaitForChild("leaderstats")
local secondsValue = leaderstats:WaitForChild("Seconds")

local function refreshSecondsText()
	secondsLabel.Text = "Your Seconds: " .. tostring(secondsValue.Value)
end

local function refreshTitlesCollectedText()
	local collected = 0
	local totalTitles = 0
	for _, data in ipairs(TITLES) do
		if isCountableTitle(data) then
			totalTitles += 1
			if isTitleUnlockedForPlayer(data, secondsValue) then
				collected += 1
			end
		end
	end
	titlesCollectedLabel.Text = "Titles Collected: " .. tostring(collected) .. "/" .. tostring(totalTitles)
end

local function refreshAutoBestToggle()
	local enabled = player:GetAttribute("AutoEquipBestTimeTitle") == true
	autoBestSideBtn.Label.Text = enabled and "Auto Time: ON" or "Auto Time: OFF"
	autoBestSideBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(120, 40, 40)
end

secondsValue:GetPropertyChangedSignal("Value"):Connect(function()
	refreshSecondsText()
	refreshTitlesCollectedText()
	for _, refresh in ipairs(rowRefreshers) do
		refresh()
	end
end)
equippedTitleValue:GetPropertyChangedSignal("Value"):Connect(function()
	for _, refresh in ipairs(rowRefreshers) do
		refresh()
	end
end)
player:GetAttributeChangedSignal("AutoEquipBestTimeTitle"):Connect(function()
	refreshAutoBestToggle()
end)
player:GetAttributeChangedSignal("HasDonated"):Connect(function()
	refreshTitlesCollectedText()
	for _, refresh in ipairs(rowRefreshers) do
		refresh()
	end
end)
player:GetAttributeChangedSignal("HasDiscoTitle"):Connect(function()
	refreshTitlesCollectedText()
	for _, refresh in ipairs(rowRefreshers) do
		refresh()
	end
end)
for _, packId in ipairs({"PackComet", "PackAurora", "PackNebula", "PackCelestial", "PackSingularity"}) do
	player:GetAttributeChangedSignal("HasPackTitle_" .. packId):Connect(function()
		refreshTitlesCollectedText()
		for _, refresh in ipairs(rowRefreshers) do
			refresh()
		end
	end)
end

refreshSecondsText()
refreshTitlesCollectedText()
refreshAutoBestToggle()

autoBestSideBtn.MouseButton1Click:Connect(function()
	local nextValue = not (player:GetAttribute("AutoEquipBestTimeTitle") == true)
	autoBestTimeEvent:FireServer(nextValue)
end)

afkTab.MouseButton1Click:Connect(function()
	activeAFKTab = true
	populate(secondsValue)
end)

otherTab.MouseButton1Click:Connect(function()
	activeAFKTab = false
	populate(secondsValue)
end)

local MENU_GUI_BY_UI_ID = {
	Titles = "TitlesGui",
	Donate = "DonateGui",
	UpdateLog = "UpdateLogGui",
	Shop = "ShopGui",
	ItemShop = "ItemShopGui",
}

local function isMenuReallyOpen(activeUi)
	local guiName = MENU_GUI_BY_UI_ID[activeUi]
	if not guiName then
		return false
	end
	local menuGui = playerGui:FindFirstChild(guiName)
	local menuMain = menuGui and menuGui:FindFirstChild("Main")
	return menuMain and menuMain:IsA("GuiObject") and menuMain.Visible == true
end

local function refreshOpenButtonVisibility()
	local activeUi = player:GetAttribute(ACTIVE_UI_ATTR)
	if activeUi and activeUi ~= UI_ID and not isMenuReallyOpen(activeUi) then
		player:SetAttribute(ACTIVE_UI_ATTR, nil)
		activeUi = nil
	end
	if main.Visible then
		tweenOpenButton(false)
		tweenAutoBestButton(false)
	else
		local shouldShowButtons = activeUi == nil or activeUi == UI_ID
		tweenOpenButton(shouldShowButtons)
		tweenAutoBestButton(shouldShowButtons)
	end
end

player:GetAttributeChangedSignal(ACTIVE_UI_ATTR):Connect(refreshOpenButtonVisibility)
refreshOpenButtonVisibility()

populate(secondsValue)
