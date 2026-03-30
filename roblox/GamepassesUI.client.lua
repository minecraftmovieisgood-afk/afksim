local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ACTIVE_UI_ATTR = "ActiveMenuUI"
local UI_ID = "Gamepasses"

local TWO_X_SECONDS_GAMEPASS_ID = 1769149472
local FOUR_X_SECONDS_GAMEPASS_ID = 1765744598

local FONT = Enum.Font.FredokaOne
local BUTTON_TEXTURE = "rbxassetid://18878365966"
local BUTTON_TEXTURE_TRANSPARENCY = 0.5

local function addStroke(guiObj, thickness, color)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 5
	stroke.Color = color or Color3.new(0, 0, 0)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcall(function()
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
	end)
	stroke.Parent = guiObj
	return stroke
end

local function computeMirroredPosition(basePosition, baseSize, targetSize)
	local deltaXScale = targetSize.X.Scale - baseSize.X.Scale
	local deltaXOffset = targetSize.X.Offset - baseSize.X.Offset
	return UDim2.new(basePosition.X.Scale - deltaXScale, basePosition.X.Offset - deltaXOffset, basePosition.Y.Scale, basePosition.Y.Offset)
end

local gui = Instance.new("ScreenGui")
gui.Name = "GamepassesGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local btn = Instance.new("ImageButton")
btn.Name = "Open2XSecondsButton"
btn.Parent = gui
btn.Position = UDim2.fromScale(0.855, 0.42)
btn.Size = UDim2.fromScale(0.13, 0.085)
btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btn.AutoButtonColor = false
btn.Image = BUTTON_TEXTURE
btn.ImageTransparency = BUTTON_TEXTURE_TRANSPARENCY
btn.ScaleType = Enum.ScaleType.Stretch
addStroke(btn, 5, Color3.new(0, 0, 0))
local btnSizeLimit = Instance.new("UISizeConstraint")
btnSizeLimit.MaxSize = Vector2.new(360, 120)
btnSizeLimit.Parent = btn

local rainbow = Instance.new("UIGradient")
rainbow.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 165, 70)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 235, 80)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(80, 255, 120)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(70, 170, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 70, 70)),
})
rainbow.Rotation = 18
rainbow.Offset = Vector2.new(-1, 0)
rainbow.Parent = btn
TweenService:Create(rainbow, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Offset = Vector2.new(1, 0)}):Play()

local buttonLabel = Instance.new("TextLabel")
buttonLabel.Name = "Label"
buttonLabel.Parent = btn
buttonLabel.Size = UDim2.fromScale(1, 1)
buttonLabel.BackgroundTransparency = 1
buttonLabel.Text = "2X Seconds"
buttonLabel.Font = FONT
buttonLabel.TextScaled = true
buttonLabel.TextColor3 = Color3.new(1, 1, 1)
buttonLabel.TextStrokeTransparency = 0
buttonLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

local only9 = Instance.new("TextLabel")
only9.Name = "Only9Tag"
only9.Parent = gui
only9.AnchorPoint = Vector2.new(0.5, 1)
only9.Position = UDim2.fromScale(0.92, 0.41)
only9.Size = UDim2.fromScale(0.14, 0.04)
only9.BackgroundTransparency = 1
only9.Text = "ONLY 9 ROBUX!!!"
only9.Font = FONT
only9.TextScaled = true
only9.TextColor3 = Color3.fromRGB(85, 255, 85)
only9.TextStrokeTransparency = 0
only9.TextStrokeColor3 = Color3.new(0, 0, 0)
local only9Scale = Instance.new("UIScale")
only9Scale.Parent = only9
TweenService:Create(only9Scale, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Scale = 1.1}):Play()

local placeholderBtn = Instance.new("ImageButton")
placeholderBtn.Name = "OpenPlaceholderGamepassButton"
placeholderBtn.Parent = gui
placeholderBtn.Position = UDim2.fromScale(0.855, 0.52)
placeholderBtn.Size = UDim2.fromScale(0.13, 0.085)
placeholderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
placeholderBtn.AutoButtonColor = false
placeholderBtn.Image = BUTTON_TEXTURE
placeholderBtn.ImageTransparency = BUTTON_TEXTURE_TRANSPARENCY
placeholderBtn.ScaleType = Enum.ScaleType.Stretch
addStroke(placeholderBtn, 5, Color3.new(0, 0, 0))
local placeholderSizeLimit = Instance.new("UISizeConstraint")
placeholderSizeLimit.MaxSize = Vector2.new(360, 120)
placeholderSizeLimit.Parent = placeholderBtn

local placeholderRainbow = rainbow:Clone()
placeholderRainbow.Parent = placeholderBtn
TweenService:Create(placeholderRainbow, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Offset = Vector2.new(1, 0)}):Play()

local placeholderLabel = Instance.new("TextLabel")
placeholderLabel.Name = "Label"
placeholderLabel.Parent = placeholderBtn
placeholderLabel.Size = UDim2.fromScale(1, 1)
placeholderLabel.BackgroundTransparency = 1
placeholderLabel.Text = "Placeholder GP"
placeholderLabel.Font = FONT
placeholderLabel.TextScaled = true
placeholderLabel.TextColor3 = Color3.new(1, 1, 1)
placeholderLabel.TextStrokeTransparency = 0
placeholderLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

local toast = Instance.new("TextLabel")
toast.Parent = gui
toast.AnchorPoint = Vector2.new(0.5, 1)
toast.Position = UDim2.fromScale(0.5, 1.12)
toast.Size = UDim2.fromScale(0.5, 0.07)
toast.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toast.BackgroundTransparency = 0.2
toast.Text = ""
toast.Font = FONT
toast.TextScaled = true
toast.TextColor3 = Color3.new(1, 1, 1)
toast.TextStrokeTransparency = 0
toast.Visible = false
addStroke(toast, 3, Color3.new(0, 0, 0))

local function showToast(text)
	toast.Text = text
	toast.Visible = true
	TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.93)}):Play()
	task.delay(2.4, function()
		if not toast.Parent then return end
		local tween = TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, 1.12)})
		tween:Play()
		tween.Completed:Wait()
		toast.Visible = false
	end)
end

local function hookButtonHover(button)
	local visualState = {baseSize = button.Size, restPosition = button.Position}
	button.MouseEnter:Connect(function()
		if not button.Active then return end
		local hoverSize = UDim2.new(visualState.baseSize.X.Scale * 1.03, visualState.baseSize.X.Offset, visualState.baseSize.Y.Scale * 1.03, visualState.baseSize.Y.Offset)
		local hoverPos = computeMirroredPosition(visualState.restPosition, visualState.baseSize, hoverSize)
		TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = hoverSize, Position = hoverPos}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = visualState.baseSize, Position = visualState.restPosition}):Play()
	end)
	button.MouseButton1Down:Connect(function()
		if not button.Active then return end
		local pressSize = UDim2.new(visualState.baseSize.X.Scale * 0.97, visualState.baseSize.X.Offset, visualState.baseSize.Y.Scale * 0.97, visualState.baseSize.Y.Offset)
		local pressPos = computeMirroredPosition(visualState.restPosition, visualState.baseSize, pressSize)
		TweenService:Create(button, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = pressSize, Position = pressPos}):Play()
	end)
	button.MouseButton1Up:Connect(function()
		if not button.Active then return end
		local hoverSize = UDim2.new(visualState.baseSize.X.Scale * 1.03, visualState.baseSize.X.Offset, visualState.baseSize.Y.Scale * 1.03, visualState.baseSize.Y.Offset)
		local hoverPos = computeMirroredPosition(visualState.restPosition, visualState.baseSize, hoverSize)
		TweenService:Create(button, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = hoverSize, Position = hoverPos}):Play()
	end)
	return visualState
end

local visualState = hookButtonHover(btn)
local placeholderVisualState = hookButtonHover(placeholderBtn)

local buttonBasePosition = btn.Position
local buttonHiddenPosition = btn.Position + UDim2.fromScale(0.2, 0)
local only9BasePosition = UDim2.fromScale(0.92, 0.41)
local only9HiddenPosition = only9BasePosition + UDim2.fromScale(0.2, 0)
local placeholderBasePosition = placeholderBtn.Position
local placeholderHiddenPosition = placeholderBtn.Position + UDim2.fromScale(0.2, 0)
local buttonTween
local only9Tween
local placeholderTween
local function tweenButtonVisibility(shouldShow)
	local target = shouldShow and buttonBasePosition or buttonHiddenPosition
	local placeholderTarget = shouldShow and placeholderBasePosition or placeholderHiddenPosition
	btn.Active = shouldShow
	placeholderBtn.Active = shouldShow
	visualState.restPosition = target
	placeholderVisualState.restPosition = placeholderTarget
	if not shouldShow then
		btn.Size = visualState.baseSize
		placeholderBtn.Size = placeholderVisualState.baseSize
	end
	if buttonTween then buttonTween:Cancel() end
	if only9Tween then only9Tween:Cancel() end
	if placeholderTween then placeholderTween:Cancel() end
	buttonTween = TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target})
	only9Tween = TweenService:Create(only9, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = shouldShow and only9BasePosition or only9HiddenPosition})
	placeholderTween = TweenService:Create(placeholderBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = placeholderTarget})
	buttonTween:Play()
	only9Tween:Play()
	placeholderTween:Play()
end

local owns2x = false
local owns4x = false
local sessionOwned2x = false
local sessionOwned4x = false

local function ownsPass(passId)
	local ok, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	return ok and result == true
end

local function applyOwnershipToButton()
	if owns2x and owns4x then
		buttonLabel.Text = "MAX"
		only9.Visible = false
	elseif owns2x then
		buttonLabel.Text = "4X Seconds"
		only9.Text = "ONLY 36 ROBUX!!!"
		only9.Visible = true
	else
		buttonLabel.Text = "2X Seconds"
		only9.Text = "ONLY 9 ROBUX!!!"
		only9.Visible = true
	end
end

local function refreshOwnershipAndButton()
	owns2x = sessionOwned2x or ownsPass(TWO_X_SECONDS_GAMEPASS_ID)
	owns4x = sessionOwned4x or ownsPass(FOUR_X_SECONDS_GAMEPASS_ID)
	applyOwnershipToButton()
end

btn.MouseButton1Click:Connect(function()
	if owns2x and owns4x then
		showToast("Max seconds multiplier already owned")
		return
	end

	if not owns2x then
		MarketplaceService:PromptGamePassPurchase(player, TWO_X_SECONDS_GAMEPASS_ID)
		return
	end

	if owns2x and not owns4x then
		MarketplaceService:PromptGamePassPurchase(player, FOUR_X_SECONDS_GAMEPASS_ID)
	end
end)

placeholderBtn.MouseButton1Click:Connect(function()
	showToast("Placeholder GP coming soon")
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(finishedPlayer, gamePassId, wasPurchased)
	if finishedPlayer ~= player then return end

	if wasPurchased and gamePassId == TWO_X_SECONDS_GAMEPASS_ID then
		sessionOwned2x = true
		owns2x = true
		showToast("Thank you for purchasing 2x seconds")
	elseif wasPurchased and gamePassId == FOUR_X_SECONDS_GAMEPASS_ID then
		sessionOwned4x = true
		owns4x = true
		showToast("Thank you for purchasing 4x seconds")
	end

	applyOwnershipToButton()
end)

local function refreshButtonVisibility()
	local activeUi = player:GetAttribute(ACTIVE_UI_ATTR)
	tweenButtonVisibility(activeUi == nil or activeUi == UI_ID)
end

player:GetAttributeChangedSignal(ACTIVE_UI_ATTR):Connect(refreshButtonVisibility)
refreshOwnershipAndButton()
refreshButtonVisibility()

task.spawn(function()
	while btn.Parent do
		task.wait(15)
		refreshOwnershipAndButton()
	end
end)
