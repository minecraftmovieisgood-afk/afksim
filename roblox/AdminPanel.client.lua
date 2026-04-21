local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local FONT = Enum.Font.FredokaOne
local ADMIN_USER_IDS = {
	[3653999284] = true,
}

local sendMessageRemote = ReplicatedStorage:WaitForChild("AdminSendGlobalMessage")
local globalMessageRemote = ReplicatedStorage:WaitForChild("AdminGlobalMessageBroadcast")
local startDiscoRemote = ReplicatedStorage:WaitForChild("AdminStartDiscoEvent")
local discoStateRemote = ReplicatedStorage:WaitForChild("DiscoEventState")

local isPrivateServerOwner = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == player.UserId
local isAdmin = ADMIN_USER_IDS[player.UserId] == true or isPrivateServerOwner

local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanelGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

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

local messageStack = Instance.new("Frame")
messageStack.Name = "MessageStack"
messageStack.Parent = gui
messageStack.AnchorPoint = Vector2.new(0.5, 0)
messageStack.Position = UDim2.fromScale(0.5, 0.11)
messageStack.Size = UDim2.fromScale(0.64, 0.3)
messageStack.BackgroundTransparency = 1

local stackLayout = Instance.new("UIListLayout")
stackLayout.Parent = messageStack
stackLayout.Padding = UDim.new(0.01, 0)
stackLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
stackLayout.VerticalAlignment = Enum.VerticalAlignment.Top
stackLayout.SortOrder = Enum.SortOrder.LayoutOrder

local activeMessageCount = 0
local function showGlobalMessage(text)
	activeMessageCount += 1

	local banner = Instance.new("TextLabel")
	banner.Name = "GlobalMessageBanner"
	banner.Parent = messageStack
	banner.Size = UDim2.fromScale(0.95, 0.23)
	banner.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	banner.BackgroundTransparency = 1
	banner.Text = text
	banner.Font = FONT
	banner.TextScaled = true
	banner.TextColor3 = Color3.new(1, 1, 1)
	banner.TextStrokeTransparency = 0
	banner.TextWrapped = true
	banner.LayoutOrder = activeMessageCount
	banner.TextTransparency = 1

	TweenService:Create(banner, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	}):Play()

	task.delay(8, function()
		if banner and banner.Parent then
			local tween = TweenService:Create(banner, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1,
				BackgroundTransparency = 1,
			})
			tween:Play()
			tween.Completed:Wait()
			if banner and banner.Parent then
				banner:Destroy()
			end
		end
	end)
end

local discoOverlay = Instance.new("Frame")
discoOverlay.Name = "DiscoOverlay"
discoOverlay.Parent = gui
discoOverlay.Size = UDim2.fromScale(1, 1)
discoOverlay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
discoOverlay.BackgroundTransparency = 1
discoOverlay.ZIndex = 1
discoOverlay.Visible = false

local discoLabel = Instance.new("TextLabel")
discoLabel.Parent = discoOverlay
discoLabel.AnchorPoint = Vector2.new(0.5, 0)
discoLabel.Position = UDim2.fromScale(0.5, 0.02)
discoLabel.Size = UDim2.fromScale(0.45, 0.08)
discoLabel.BackgroundTransparency = 1
discoLabel.Font = FONT
discoLabel.TextScaled = true
discoLabel.TextColor3 = Color3.new(1, 1, 1)
discoLabel.TextStrokeTransparency = 0
discoLabel.ZIndex = 2
discoLabel.Visible = false

local eventsPanel = Instance.new("Frame")
eventsPanel.Name = "ActiveEventsPanel"
eventsPanel.Parent = gui
eventsPanel.Position = UDim2.fromScale(0.855, 0.82)
eventsPanel.Size = UDim2.fromScale(0.13, 0.07)
eventsPanel.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
eventsPanel.BackgroundTransparency = 0.15
eventsPanel.Visible = false
addStroke(eventsPanel, 3, Color3.new(0, 0, 0))

local eventsLabel = Instance.new("TextLabel")
eventsLabel.Parent = eventsPanel
eventsLabel.Size = UDim2.fromScale(1, 1)
eventsLabel.BackgroundTransparency = 1
eventsLabel.Text = ""
eventsLabel.Font = FONT
eventsLabel.TextScaled = true
eventsLabel.TextColor3 = Color3.new(1, 1, 1)
eventsLabel.TextStrokeTransparency = 0
eventsLabel.TextWrapped = true

local activeDisco = false
local discoRemaining = 0
local hue = 0

globalMessageRemote.OnClientEvent:Connect(function(message, sender)
	local author = sender and tostring(sender) or "System"
	showGlobalMessage("[" .. author .. "] " .. tostring(message))
end)

discoStateRemote.OnClientEvent:Connect(function(isActive, remaining)
	activeDisco = isActive == true
	discoRemaining = tonumber(remaining) or 0
	discoOverlay.Visible = activeDisco
	eventsPanel.Visible = activeDisco
	if not activeDisco then
		discoOverlay.BackgroundTransparency = 1
				eventsLabel.Text = ""
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if not activeDisco then
		return
	end
	hue = (hue + dt * 0.35) % 1
	discoOverlay.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 1)
	discoOverlay.BackgroundTransparency = 0.84
	local remainingInt = math.max(0, math.floor(discoRemaining))
		eventsLabel.Text = string.format("Disco: %ds", remainingInt)
	if discoRemaining > 0 then
		discoRemaining -= dt
	end
end)

if isAdmin then
	local openBtn = Instance.new("TextButton")
	openBtn.Name = "OpenAdminPanelButton"
	openBtn.Parent = gui
	openBtn.Position = UDim2.fromScale(0.84, 0.02)
	openBtn.Size = UDim2.fromScale(0.14, 0.06)
	openBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	openBtn.Text = "Admin"
	openBtn.Font = FONT
	openBtn.TextScaled = true
	openBtn.TextColor3 = Color3.new(1, 1, 1)
	openBtn.TextStrokeTransparency = 0
	addStroke(openBtn, 4, Color3.new(0, 0, 0))

	local panel = Instance.new("Frame")
	panel.Name = "AdminPanel"
	panel.Parent = gui
	panel.Position = UDim2.fromScale(0.67, 0.1)
	panel.Size = UDim2.fromScale(0.31, 0.24)
	panel.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
	panel.Visible = false
	addStroke(panel, 4, Color3.new(0, 0, 0))

	local title = Instance.new("TextLabel")
	title.Parent = panel
	title.Position = UDim2.fromScale(0.03, 0.03)
	title.Size = UDim2.fromScale(0.94, 0.18)
	title.BackgroundTransparency = 1
	title.Text = "Admin Panel"
	title.Font = FONT
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextStrokeTransparency = 0

	local messageBox = Instance.new("TextBox")
	messageBox.Parent = panel
	messageBox.Position = UDim2.fromScale(0.03, 0.24)
	messageBox.Size = UDim2.fromScale(0.94, 0.26)
	messageBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	messageBox.PlaceholderText = "Type global message..."
	messageBox.Text = ""
	messageBox.ClearTextOnFocus = false
	messageBox.Font = FONT
	messageBox.TextScaled = true
	messageBox.TextColor3 = Color3.new(1, 1, 1)
	messageBox.TextStrokeTransparency = 0
	addStroke(messageBox, 3, Color3.new(0, 0, 0))

	local sendBtn = Instance.new("TextButton")
	sendBtn.Parent = panel
	sendBtn.Position = UDim2.fromScale(0.03, 0.56)
	sendBtn.Size = UDim2.fromScale(0.45, 0.18)
	sendBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	sendBtn.Text = "Send Global"
	sendBtn.Font = FONT
	sendBtn.TextScaled = true
	sendBtn.TextColor3 = Color3.new(1, 1, 1)
	sendBtn.TextStrokeTransparency = 0
	addStroke(sendBtn, 3, Color3.new(0, 0, 0))

	local discoBtn = Instance.new("TextButton")
	discoBtn.Parent = panel
	discoBtn.Position = UDim2.fromScale(0.52, 0.56)
	discoBtn.Size = UDim2.fromScale(0.45, 0.18)
	discoBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 230)
	discoBtn.Text = "Start 2m Disco"
	discoBtn.Font = FONT
	discoBtn.TextScaled = true
	discoBtn.TextColor3 = Color3.new(1, 1, 1)
	discoBtn.TextStrokeTransparency = 0
	addStroke(discoBtn, 3, Color3.new(0, 0, 0))

	local hint = Instance.new("TextLabel")
	hint.Parent = panel
	hint.Position = UDim2.fromScale(0.03, 0.78)
	hint.Size = UDim2.fromScale(0.94, 0.17)
	hint.BackgroundTransparency = 1
	hint.Text = "Disco gives 1%/sec chance for Disco title."
	hint.Font = FONT
	hint.TextScaled = true
	hint.TextColor3 = Color3.fromRGB(230, 230, 230)
	hint.TextStrokeTransparency = 0

	openBtn.MouseButton1Click:Connect(function()
		panel.Visible = not panel.Visible
	end)

	sendBtn.MouseButton1Click:Connect(function()
		sendMessageRemote:FireServer(messageBox.Text)
	end)

	discoBtn.MouseButton1Click:Connect(function()
		startDiscoRemote:FireServer()
	end)
end
