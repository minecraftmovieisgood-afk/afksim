local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ACTIVE_UI_ATTR = "ActiveMenuUI"
local UI_ID = "Shop"

local getPackDataFn = ReplicatedStorage:WaitForChild("GetTitlePackData")
local rewardsRevealRemote = ReplicatedStorage:WaitForChild("TitlePackRewardsReveal")

local TITLE_PACK_PRODUCT_IDS = {
	[1] = 3566239112,
	[5] = 3566239569,
	[10] = 3566239990,
}

local FONT = Enum.Font.FredokaOne
local BUTTON_TEXTURE = "rbxassetid://18878365966"
local BUTTON_TEXTURE_TRANSPARENCY = 0.5

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
	btn.MouseEnter:Connect(function() hoverIn:Play() end)
	btn.MouseLeave:Connect(function() hoverOut:Play() end)
	btn.MouseButton1Down:Connect(function() pressIn:Play() end)
	btn.MouseButton1Up:Connect(function() pressOut:Play() end)
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
gui.Name = "ShopGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local blur = Lighting:FindFirstChild("ShopBlur") or Instance.new("BlurEffect")
blur.Name = "ShopBlur"
blur.Size = 0
blur.Parent = Lighting

local openBtn = makeButton(gui, "OpenShopButton", "Shop", UDim2.fromScale(0.015, 0.50), UDim2.fromScale(0.13, 0.085), Color3.fromRGB(0, 120, 255))
local openBtnStroke = openBtn:FindFirstChildOfClass("UIStroke")
if openBtnStroke then openBtnStroke.Thickness = 5 end
local openBtnBasePosition = openBtn.Position
local openBtnHiddenPosition = openBtnBasePosition + UDim2.fromScale(-0.2, 0)
local openBtnTween

local function tweenOpenButton(shouldShow)
	local target = shouldShow and openBtnBasePosition or openBtnHiddenPosition
	openBtn.Active = shouldShow
	if openBtnTween then openBtnTween:Cancel() end
	openBtnTween = TweenService:Create(openBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target})
	openBtnTween:Play()
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromScale(0.7, 0.62)
main.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
main.BackgroundTransparency = 1
main.Visible = false
addStroke(main, 4, Color3.new(0, 0, 0))

local defaultMainSize = main.Size
local closedMainSize = UDim2.new(defaultMainSize.X.Scale * 0.85, defaultMainSize.X.Offset, defaultMainSize.Y.Scale * 0.85, defaultMainSize.Y.Offset)
main.Size = closedMainSize

local header = Instance.new("TextLabel")
header.Parent = main
header.Position = UDim2.fromScale(0.03, 0.03)
header.Size = UDim2.fromScale(0.46, 0.12)
header.BackgroundTransparency = 1
header.Text = "Title Pack #1"
header.TextXAlignment = Enum.TextXAlignment.Left
header.Font = FONT
header.TextScaled = true
header.TextColor3 = Color3.new(1, 1, 1)
header.TextStrokeTransparency = 0

local odds = Instance.new("TextLabel")
odds.Parent = main
odds.Position = UDim2.fromScale(0.03, 0.16)
odds.Size = UDim2.fromScale(0.4, 0.62)
odds.BackgroundTransparency = 1
odds.TextXAlignment = Enum.TextXAlignment.Left
odds.TextYAlignment = Enum.TextYAlignment.Top
odds.Text = "Title 1 - 55%\nTitle 2 - 33%\nTitle 3 - 10%\nTitle 4 - 1.9%\nTitle 5 - 0.1%"
odds.Font = FONT
odds.TextScaled = true
odds.TextColor3 = Color3.new(1, 1, 1)
odds.TextStrokeTransparency = 0

local previewNames = {"Comet Trail", "Aurora Pulse", "Nebula Core", "Celestial Crown", "GOD"}
local previewPositions = {
	UDim2.fromScale(0.45, 0.22),
	UDim2.fromScale(0.67, 0.22),
	UDim2.fromScale(0.45, 0.40),
	UDim2.fromScale(0.67, 0.40),
	UDim2.fromScale(0.56, 0.58),
}
for i, name in ipairs(previewNames) do
	local box = Instance.new("Frame")
	box.Parent = main
	box.Position = previewPositions[i]
	box.Size = UDim2.fromScale(0.2, 0.14)
	box.BackgroundColor3 = Color3.new(0, 0, 0)
	addStroke(box, 3, Color3.new(0, 0, 0))
	local label = Instance.new("TextLabel")
	label.Parent = box
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = name
	label.Font = FONT
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
end

local buy1 = makeButton(main, "Buy1", "Buy 1", UDim2.fromScale(0.49, 0.78), UDim2.fromScale(0.15, 0.11), Color3.fromRGB(35, 35, 35))
local buy5 = makeButton(main, "Buy5", "Buy 5", UDim2.fromScale(0.65, 0.78), UDim2.fromScale(0.15, 0.11), Color3.fromRGB(35, 35, 35))
local buy10 = makeButton(main, "Buy10", "Buy 10", UDim2.fromScale(0.81, 0.78), UDim2.fromScale(0.15, 0.11), Color3.fromRGB(35, 35, 35))

local price1 = Instance.new("TextLabel")
price1.Parent = main
price1.Position = UDim2.fromScale(0.49, 0.89)
price1.Size = UDim2.fromScale(0.15, 0.07)
price1.BackgroundTransparency = 1
price1.Text = "19 Robux"
price1.Font = FONT
price1.TextScaled = true
price1.TextColor3 = Color3.new(1, 1, 1)
price1.TextStrokeTransparency = 0

local price5 = price1:Clone()
price5.Parent = main
price5.Position = UDim2.fromScale(0.65, 0.89)
price5.Text = "100 Robux"

local price10 = price1:Clone()
price10.Parent = main
price10.Position = UDim2.fromScale(0.81, 0.89)
price10.Text = "300 Robux"

local closeBtn = makeButton(main, "CloseButton", "X", UDim2.fromScale(0.92, 0.03), UDim2.fromScale(0.06, 0.1), Color3.fromRGB(255, 0, 0))

local revealOverlay = Instance.new("Frame")
revealOverlay.Parent = gui
revealOverlay.Size = UDim2.fromScale(1, 1)
revealOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
revealOverlay.BackgroundTransparency = 1
revealOverlay.Visible = false

local revealContainer = Instance.new("Frame")
revealContainer.Parent = revealOverlay
revealContainer.AnchorPoint = Vector2.new(0.5, 0.5)
revealContainer.Position = UDim2.fromScale(0.5, 0.5)
revealContainer.Size = UDim2.fromScale(0.7, 0.55)
revealContainer.BackgroundTransparency = 1

local revealLayout = Instance.new("UIGridLayout")
revealLayout.Parent = revealContainer
revealLayout.CellPadding = UDim2.fromScale(0.02, 0.03)
revealLayout.CellSize = UDim2.fromScale(0.31, 0.22)

local function showPackReveal(rewards)
	if type(rewards) ~= "table" or #rewards == 0 then return end
	for _, child in ipairs(revealContainer:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	revealOverlay.Visible = true
	TweenService:Create(revealOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()
	for i, rewardName in ipairs(rewards) do
		local card = Instance.new("Frame")
		card.Parent = revealContainer
		card.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		card.BackgroundTransparency = 0.1
		card.LayoutOrder = i
		addStroke(card, 3, Color3.new(0, 0, 0))
		local label = Instance.new("TextLabel")
		label.Parent = card
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = FONT
		label.TextScaled = true
		label.TextWrapped = true
		label.TextStrokeTransparency = 0
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Text = rewardName
		card.Size = UDim2.fromScale(0.01, 0.01)
		task.delay(0.05 * (i - 1), function()
			if card.Parent then
				TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0.31, 0.22)}):Play()
			end
		end)
	end
	task.delay(3.5, function()
		local out = TweenService:Create(revealOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
		out:Play()
		out.Completed:Wait()
		revealOverlay.Visible = false
	end)
end

local function buyAmount(amount)
	local productId = TITLE_PACK_PRODUCT_IDS[amount]
	if not productId then
		return
	end
	MarketplaceService:PromptProductPurchase(player, productId)
end

buy1.MouseButton1Click:Connect(function() buyAmount(1) end)
buy5.MouseButton1Click:Connect(function() buyAmount(5) end)
buy10.MouseButton1Click:Connect(function() buyAmount(10) end)

rewardsRevealRemote.OnClientEvent:Connect(function(rewards)
	showPackReveal(rewards)
end)

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
	local mainTween = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = defaultMainSize, BackgroundTransparency = 0})
	local blurTween = TweenService:Create(blur, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 16})
	mainTween:Play(); blurTween:Play(); mainTween.Completed:Wait(); isAnimating = false
end

local function closeUI()
	if isAnimating or not main.Visible then return end
	isAnimating = true
	local mainTween = TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = closedMainSize, BackgroundTransparency = 1})
	local blurTween = TweenService:Create(blur, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0})
	mainTween:Play(); blurTween:Play(); mainTween.Completed:Wait()
	main.Visible = false
	if player:GetAttribute(ACTIVE_UI_ATTR) == UI_ID then player:SetAttribute(ACTIVE_UI_ATTR, nil) end
	isAnimating = false
end

openBtn.MouseButton1Click:Connect(openUI)
closeBtn.MouseButton1Click:Connect(closeUI)

local function refreshOpenButtonVisibility()
	local activeUi = player:GetAttribute(ACTIVE_UI_ATTR)
	if main.Visible then tweenOpenButton(false) else tweenOpenButton(activeUi == nil or activeUi == UI_ID) end
end

player:GetAttributeChangedSignal(ACTIVE_UI_ATTR):Connect(refreshOpenButtonVisibility)
refreshOpenButtonVisibility()
