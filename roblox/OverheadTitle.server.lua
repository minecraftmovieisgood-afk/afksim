local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local FONT = Enum.Font.FredokaOne
local equippedConnections = {}
local secondsConnections = {}
local gradientTweens = {}
local TITLE_COLORS = {
	["None"] = Color3.fromRGB(230, 230, 230),
	["Time Newbie"] = Color3.fromRGB(135, 206, 235),
	["Clock Rookie"] = Color3.fromRGB(90, 190, 255),
	["Minute Stacker"] = Color3.fromRGB(124, 252, 0),
	["Hour Holder"] = Color3.fromRGB(40, 220, 160),
	["Drift Runner"] = Color3.fromRGB(255, 170, 0),
	["Chrono Charger"] = Color3.fromRGB(255, 120, 70),
	["Day Dreamer"] = Color3.fromRGB(170, 85, 255),
	["Half-Day Howler"] = Color3.fromRGB(255, 70, 170),
	["24H Beast"] = Color3.fromRGB(255, 215, 0),
	["Storm of Seconds"] = Color3.fromRGB(170, 225, 255),
	["Clockbreaker X"] = Color3.fromRGB(140, 245, 200),
	["Temporal Overlord"] = Color3.fromRGB(255, 195, 120),
	["Paradox Reaper"] = Color3.fromRGB(225, 150, 255),
	["Infinity Cataclysm"] = Color3.fromRGB(255, 245, 160),
	["Quantum Sleeper"] = Color3.fromRGB(190, 225, 255),
	["Epoch Warden"] = Color3.fromRGB(170, 240, 255),
	["Calendar Crusher"] = Color3.fromRGB(255, 220, 170),
	["Month Marauder"] = Color3.fromRGB(255, 190, 150),
	["Time Glacier"] = Color3.fromRGB(180, 255, 245),
	["Era Architect"] = Color3.fromRGB(210, 200, 255),
	["Millennium Drift"] = Color3.fromRGB(255, 170, 225),
	["Cosmic Clocklord"] = Color3.fromRGB(255, 240, 170),
	["Timeline Devourer"] = Color3.fromRGB(255, 145, 210),
	["Absolute Eternity"] = Color3.fromRGB(255, 120, 170),
	["Comet Trail"] = Color3.fromRGB(150, 220, 255),
	["Aurora Pulse"] = Color3.fromRGB(170, 255, 210),
	["Nebula Core"] = Color3.fromRGB(200, 170, 255),
	["Celestial Crown"] = Color3.fromRGB(255, 210, 120),
	["GOD"] = Color3.fromRGB(255, 245, 120),
	["Donater"] = Color3.fromRGB(255, 210, 90),
	["Disco"] = Color3.fromRGB(255, 90, 90),
	["Owner"] = Color3.fromRGB(210, 210, 210),
}
local DISCO_RICHTEXT = [[<font color="#FF0000">D</font><font color="#FF7F00">i</font><font color="#FFFF00">s</font><font color="#00FF00">c</font><font color="#0000FF">o</font>]]

local GRADIENT_TITLES = {
	["Storm of Seconds"] = true,
	["Clockbreaker X"] = true,
	["Temporal Overlord"] = true,
	["Paradox Reaper"] = true,
	["Infinity Cataclysm"] = true,
	["Donater"] = true,
}

local function addStroke(guiObj, thickness, color)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 2
	stroke.Color = color or Color3.new(0, 0, 0)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcall(function()
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
	end)
	stroke.Parent = guiObj
	return stroke
end

local function ensureBillboard(player, character)
	local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 10)
	if not head then return end

	local equippedTitle = player:FindFirstChild("EquippedTitle")
	if not equippedTitle then return end

	local billboard = head:FindFirstChild("EquippedTitleBillboard")
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "EquippedTitleBillboard"
		billboard.Size = UDim2.new(5.2, 0, 2.5, 0)
		billboard.StudsOffset = Vector3.new(0, 3.45, 0)
		billboard.AlwaysOnTop = true
		billboard.MaxDistance = 90
		billboard.Parent = head

		local minutesLabel = Instance.new("TextLabel")
		minutesLabel.Name = "MinutesLabel"
		minutesLabel.Size = UDim2.fromScale(1, 0.28)
		minutesLabel.Position = UDim2.fromScale(0, 0.02)
		minutesLabel.BackgroundTransparency = 1
		minutesLabel.Font = FONT
		minutesLabel.TextScaled = true
		minutesLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		minutesLabel.TextStrokeTransparency = 0
		minutesLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		minutesLabel.Text = "0 seconds"
		minutesLabel.Parent = billboard

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.fromScale(1, 0.38)
		nameLabel.Position = UDim2.fromScale(0, 0.25)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = FONT
		nameLabel.TextScaled = true
		nameLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		nameLabel.Parent = billboard

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "TitleLabel"
		titleLabel.Size = UDim2.fromScale(1, 0.34)
		titleLabel.Position = UDim2.fromScale(0, 0.63)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Font = FONT
		titleLabel.TextScaled = true
		titleLabel.TextColor3 = Color3.new(1, 1, 1)
		titleLabel.TextStrokeTransparency = 0
		titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		titleLabel.Parent = billboard

		local minutesConstraint = Instance.new("UITextSizeConstraint")
		minutesConstraint.MaxTextSize = 34
		minutesConstraint.MinTextSize = 10
		minutesConstraint.Parent = minutesLabel

		local nameConstraint = Instance.new("UITextSizeConstraint")
		nameConstraint.MaxTextSize = 64
		nameConstraint.MinTextSize = 12
		nameConstraint.Parent = nameLabel

		local titleConstraint = Instance.new("UITextSizeConstraint")
		titleConstraint.MaxTextSize = 48
		titleConstraint.MinTextSize = 10
		titleConstraint.Parent = titleLabel
	end

	local minutesLabel = billboard:FindFirstChild("MinutesLabel")
	local nameLabel = billboard:FindFirstChild("NameLabel")
	local label = billboard:FindFirstChild("TitleLabel")
	if not label or not minutesLabel or not nameLabel then return end

	nameLabel.Text = player.DisplayName

	local function refreshMinutes()
		local leaderstats = player:FindFirstChild("leaderstats")
		local secondsValue = leaderstats and leaderstats:FindFirstChild("Seconds")
		local seconds = (secondsValue and tonumber(secondsValue.Value)) or 0
		minutesLabel.Text = tostring(seconds) .. " seconds"
	end

	local function refreshText()
		local title = equippedTitle.Value
		if title == "None" or title == "" then
			label.Text = ""
			label.Visible = false
			local existingGradient = label:FindFirstChild("AnimatedGradient")
			if existingGradient then
				existingGradient:Destroy()
			end
			if gradientTweens[player] then
				gradientTweens[player]:Cancel()
				gradientTweens[player] = nil
			end
		else
			billboard.Enabled = true
			label.Visible = true
			if title == "Disco" then
				billboard.Size = UDim2.new(5.7, 0, 2.6, 0)
			else
				billboard.Size = UDim2.new(5.2, 0, 2.5, 0)
			end
			label.RichText = (title == "Disco")
			label.Text = (title == "Disco") and DISCO_RICHTEXT or title
			label.TextColor3 = TITLE_COLORS[title] or Color3.fromRGB(255, 90, 90)
			if title == "Owner" or title == "Disco" or title == "GOD" or GRADIENT_TITLES[title] then
				local gradient = label:FindFirstChild("AnimatedGradient")
				if not gradient then
					gradient = Instance.new("UIGradient")
					gradient.Name = "AnimatedGradient"
					gradient.Offset = Vector2.new(-1, 0)
					gradient.Rotation = 0
					gradient.Parent = label
				end
				if title == "Owner" then
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(225, 225, 225)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25)),
					})
				elseif title == "Donater" then
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 145, 40)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 235, 95)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 35)),
					})
				elseif title == "Disco" then
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 127, 0)),
						ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
						ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),
						ColorSequenceKeypoint.new(1.0, Color3.fromRGB(148, 0, 211)),
					})
				elseif title == "GOD" then
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 235, 90)),
						ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255)),
					})
				else
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 220)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 220, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 225, 90)),
					})
				end
				if not gradientTweens[player] then
					local tween = TweenService:Create(gradient, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
						Offset = Vector2.new(1, 0),
					})
					gradientTweens[player] = tween
					tween:Play()
				end
			else
				local existingGradient = label:FindFirstChild("AnimatedGradient")
				if existingGradient then
					existingGradient:Destroy()
				end
				if gradientTweens[player] then
					gradientTweens[player]:Cancel()
					gradientTweens[player] = nil
				end
			end
		end
	end

	refreshMinutes()
	refreshText()
	if equippedConnections[player] then
		equippedConnections[player]:Disconnect()
	end
	equippedConnections[player] = equippedTitle:GetPropertyChangedSignal("Value"):Connect(refreshText)

	if secondsConnections[player] then
		secondsConnections[player]:Disconnect()
		secondsConnections[player] = nil
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	local secondsValue = leaderstats and leaderstats:FindFirstChild("Seconds")
	if secondsValue then
		secondsConnections[player] = secondsValue:GetPropertyChangedSignal("Value"):Connect(refreshMinutes)
	end
end

local function onPlayerAdded(player)
	local function onCharacterAdded(character)
		ensureBillboard(player, character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
	onPlayerAdded(p)
end

Players.PlayerRemoving:Connect(function(player)
	if equippedConnections[player] then
		equippedConnections[player]:Disconnect()
		equippedConnections[player] = nil
	end
	if gradientTweens[player] then
		gradientTweens[player]:Cancel()
		gradientTweens[player] = nil
	end
	if secondsConnections[player] then
		secondsConnections[player]:Disconnect()
		secondsConnections[player] = nil
	end
end)
