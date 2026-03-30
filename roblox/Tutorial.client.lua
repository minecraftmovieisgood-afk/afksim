local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local getProgressFn = ReplicatedStorage:WaitForChild("GetPlayerProgress")
local tutorialDoneEvent = ReplicatedStorage:WaitForChild("SetTutorialCompleted")

local loadedProgress = {}
local ok, result = pcall(function()
	return getProgressFn:InvokeServer()
end)
if ok and typeof(result) == "table" then
	loadedProgress = result
end

-- Skip tutorial if already completed (server-persisted) or completed in this session.
if player:GetAttribute("TutorialCompleted") or loadedProgress.tutorialCompleted == true then
	return
end

local FONT = Enum.Font.FredokaOne

local STEPS = {
	{
		Title = "Welcome to AFK Simulator",
		Body = "Stay in game to earn Seconds automatically. The longer you play, the stronger your progression.",
	},
	{
		Title = "Earn Seconds",
		Body = "Your Seconds counter grows while you are playing. Use these seconds to unlock better titles.",
	},
	{
		Title = "Open Titles",
		Body = "Tap the red Titles button on the left to open your title menu, then equip any unlocked title.",
	},
	{
		Title = "Leaderboard Goal",
		Body = "Grind seconds to get on the leaderboard. Keep playing to climb the ranks.",
		FocusLeaderboard = true,
	},
	{
		Title = "You're Ready",
		Body = "That is everything. Keep grinding and become an AFK legend.",
	},
}

local function addStroke(guiObj, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 3
	stroke.Color = Color3.new(0, 0, 0)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcall(function()
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
	end)
	stroke.Parent = guiObj
	return stroke
end

local function makeButton(parent, text, position, size, color)
	local btn = Instance.new("ImageButton")
	btn.Parent = parent
	btn.Position = position
	btn.Size = size
	btn.BackgroundColor3 = color
	btn.Image = "rbxassetid://18878365966"
	btn.ImageTransparency = 0.5
	btn.ScaleType = Enum.ScaleType.Stretch
	btn.AutoButtonColor = false
	addStroke(btn, 3)

	local label = Instance.new("TextLabel")
	label.Parent = btn
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = FONT
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Text = text

	return btn
end

local gui = Instance.new("ScreenGui")
gui.Name = "TutorialGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = playerGui

local fade = Instance.new("Frame")
fade.Parent = gui
fade.Size = UDim2.fromScale(1, 1)
fade.BackgroundColor3 = Color3.new(0, 0, 0)
fade.BackgroundTransparency = 0.35
fade.BorderSizePixel = 0

local card = Instance.new("Frame")
card.Parent = gui
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.82)
card.Size = UDim2.fromScale(0.54, 0.24)
card.BackgroundColor3 = Color3.fromRGB(44, 44, 50)
addStroke(card, 4)

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = card
titleLabel.Position = UDim2.fromScale(0.03, 0.07)
titleLabel.Size = UDim2.fromScale(0.72, 0.25)
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = FONT
titleLabel.TextScaled = true
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextStrokeTransparency = 0

local bodyLabel = Instance.new("TextLabel")
bodyLabel.Parent = card
bodyLabel.Position = UDim2.fromScale(0.03, 0.35)
bodyLabel.Size = UDim2.fromScale(0.94, 0.45)
bodyLabel.BackgroundTransparency = 1
bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
bodyLabel.TextWrapped = true
bodyLabel.Font = FONT
bodyLabel.TextScaled = true
bodyLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
bodyLabel.TextStrokeTransparency = 0

local progressLabel = Instance.new("TextLabel")
progressLabel.Parent = card
progressLabel.Position = UDim2.fromScale(0.03, 0.83)
progressLabel.Size = UDim2.fromScale(0.22, 0.12)
progressLabel.BackgroundTransparency = 1
progressLabel.Font = FONT
progressLabel.TextScaled = true
progressLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
progressLabel.TextStrokeTransparency = 0

local nextButton = makeButton(card, "Next", UDim2.fromScale(0.74, 0.78), UDim2.fromScale(0.22, 0.16), Color3.fromRGB(0, 190, 0))

local leaderboardArrow = Instance.new("BillboardGui")
leaderboardArrow.Name = "LeaderboardArrow"
leaderboardArrow.AlwaysOnTop = true
leaderboardArrow.Size = UDim2.new(0, 120, 0, 120)
leaderboardArrow.StudsOffset = Vector3.new(0, 8, 0)
leaderboardArrow.Enabled = false

local arrowText = Instance.new("TextLabel")
arrowText.Parent = leaderboardArrow
arrowText.BackgroundTransparency = 1
arrowText.Size = UDim2.fromScale(1, 1)
arrowText.Font = FONT
arrowText.TextScaled = true
arrowText.TextColor3 = Color3.fromRGB(255, 240, 90)
arrowText.TextStrokeTransparency = 0
arrowText.Text = "↓ LEADERBOARD"

local tutorialActive = true
local stepIndex = 1
local nextReadyAt = 0
local nextEnableToken = 0

local function setButtonTween(btn)
	local base = btn.Size
	local hover = UDim2.new(base.X.Scale * 1.03, base.X.Offset, base.Y.Scale * 1.03, base.Y.Offset)
	local down = UDim2.new(base.X.Scale * 0.97, base.X.Offset, base.Y.Scale * 0.97, base.Y.Offset)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), {Size = hover}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), {Size = base}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.07), {Size = down}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.07), {Size = hover}):Play()
	end)
end
setButtonTween(nextButton)

local function lockNextBriefly()
	nextEnableToken += 1
	local token = nextEnableToken
	nextReadyAt = os.clock() + 0.5
	nextButton.Active = false
	nextButton.AutoButtonColor = false
	nextButton.Label.TextTransparency = 0.35

	task.delay(0.5, function()
		if not tutorialActive then return end
		if token ~= nextEnableToken then return end
		nextButton.Active = true
		nextButton.AutoButtonColor = false
		nextButton.Label.TextTransparency = 0
	end)
end

local function clearLeaderboardArrow()
	leaderboardArrow.Enabled = false
	leaderboardArrow.Parent = nil
end

local function focusLeaderboard()
	local lookAtPoint = workspace:FindFirstChild("LeaderboardLookAtPoint")

	if not lookAtPoint then
		return
	end

	leaderboardArrow.Parent = lookAtPoint
	leaderboardArrow.Enabled = true
end

local function clearLeaderboardFocus()
	clearLeaderboardArrow()
end

local function finishTutorial()
	tutorialActive = false
	clearLeaderboardFocus()
	player:SetAttribute("TutorialCompleted", true)
	tutorialDoneEvent:FireServer()
	gui:Destroy()
end

local function renderStep()
	local step = STEPS[stepIndex]
	if not step then
		finishTutorial()
		return
	end

	titleLabel.Text = step.Title
	bodyLabel.Text = step.Body
	progressLabel.Text = string.format("%d/%d", stepIndex, #STEPS)
	nextButton.Label.Text = (stepIndex >= #STEPS) and "Finish" or "Next"
	lockNextBriefly()

	clearLeaderboardArrow()
	if step.FocusLeaderboard then
		focusLeaderboard()
	else
		clearLeaderboardFocus()
	end
end

nextButton.MouseButton1Click:Connect(function()
	if not tutorialActive then return end
	if os.clock() < nextReadyAt then return end
	stepIndex += 1
	renderStep()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not tutorialActive then return end
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
		if os.clock() < nextReadyAt then return end
		stepIndex += 1
		renderStep()
	end
end)

renderStep()
