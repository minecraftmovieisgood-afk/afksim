local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ACTIVE_UI_ATTR = "ActiveMenuUI"
local UI_ID = "ItemShop"

local FONT = Enum.Font.FredokaOne
local BUTTON_TEXTURE = "rbxassetid://18878365966"
local BUTTON_TEXTURE_TRANSPARENCY = 0.5

local getStateRemote = ReplicatedStorage:FindFirstChild("GetStarterPackState")
local purchaseRemote = ReplicatedStorage:FindFirstChild("PurchaseStarterPack")

local STARTER_PACKS = {
	{ Name = "Bloxy Cola", RequiredSeconds = 500, IconText = "COLA", IconColor = Color3.fromRGB(90, 150, 255) },
	{ Name = "Cheezburger", RequiredSeconds = 2500, IconText = "BURGER", IconColor = Color3.fromRGB(255, 210, 110) },
	{ Name = "Roblox University PIZZA!", RequiredSeconds = 5000, IconText = "PIZZA", IconColor = Color3.fromRGB(255, 115, 60) },
	{ Name = "TeddyBloxpin", RequiredSeconds = 15000, IconText = "TEDDY", IconColor = Color3.fromRGB(165, 110, 80) },
	{ Name = "Taco", RequiredSeconds = 30000, IconText = "TACO", IconColor = Color3.fromRGB(120, 205, 90) },
}

local packByName = {}
for _, pack in ipairs(STARTER_PACKS) do
	packByName[pack.Name] = pack
end

local unlockedItems = {}

local function resolveRemotes()
	if not getStateRemote then
		getStateRemote = ReplicatedStorage:FindFirstChild("GetStarterPackState")
	end
	if not purchaseRemote then
		purchaseRemote = ReplicatedStorage:FindFirstChild("PurchaseStarterPack")
	end
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

	local hoverIn = TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = hoverSize })
	local hoverOut = TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = baseSize })
	local pressIn = TweenService:Create(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = pressSize })
	local pressOut = TweenService:Create(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = hoverSize })

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
gui.Name = "ItemShopGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local blur = Lighting:FindFirstChild("ItemShopBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "ItemShopBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

local openBtn = makeButton(gui, "OpenItemShopButton", "Item Shop", UDim2.fromScale(0.015, 0.62), UDim2.fromScale(0.13, 0.085), Color3.fromRGB(45, 165, 255))
openBtn.Visible = false
openBtn.Active = false
local openBtnStroke = openBtn:FindFirstChildOfClass("UIStroke")
if openBtnStroke then
	openBtnStroke.Thickness = 5
end
local openBtnBasePosition = openBtn.Position
local openBtnHiddenPosition = openBtnBasePosition + UDim2.fromScale(-0.2, 0)
local openBtnTween

local function tweenOpenButton(shouldShow)
	local target = shouldShow and openBtnBasePosition or openBtnHiddenPosition
	openBtn.Active = shouldShow
	if openBtnTween then
		openBtnTween:Cancel()
	end
	openBtnTween = TweenService:Create(openBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = target })
	openBtnTween:Play()
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromScale(0.6, 0.66)
main.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
main.BackgroundTransparency = 1
main.Visible = false
addStroke(main, 4, Color3.new(0, 0, 0))

local defaultMainSize = main.Size
local closedMainSize = UDim2.new(defaultMainSize.X.Scale * 0.85, defaultMainSize.X.Offset, defaultMainSize.Y.Scale * 0.85, defaultMainSize.Y.Offset)
main.Size = closedMainSize

local header = Instance.new("TextLabel")
header.Parent = main
header.Position = UDim2.fromScale(0.03, 0.02)
header.Size = UDim2.fromScale(0.7, 0.09)
header.BackgroundTransparency = 1
header.Text = "Item Shop"
header.TextXAlignment = Enum.TextXAlignment.Left
header.Font = FONT
header.TextScaled = true
header.TextColor3 = Color3.new(1, 1, 1)
header.TextStrokeTransparency = 0

local secondsLabel = Instance.new("TextLabel")
secondsLabel.Parent = main
secondsLabel.Position = UDim2.fromScale(0.03, 0.1)
secondsLabel.Size = UDim2.fromScale(0.84, 0.08)
secondsLabel.BackgroundTransparency = 1
secondsLabel.Text = "Your Seconds: 0"
secondsLabel.TextXAlignment = Enum.TextXAlignment.Left
secondsLabel.Font = FONT
secondsLabel.TextScaled = true
secondsLabel.TextColor3 = Color3.fromRGB(255, 240, 140)
secondsLabel.TextStrokeTransparency = 0

local inventoryLabel = Instance.new("TextLabel")
inventoryLabel.Parent = main
inventoryLabel.Position = UDim2.fromScale(0.03, 0.16)
inventoryLabel.Size = UDim2.fromScale(0.94, 0.06)
inventoryLabel.BackgroundTransparency = 1
inventoryLabel.Text = "Inventory: None"
inventoryLabel.TextXAlignment = Enum.TextXAlignment.Left
inventoryLabel.Font = FONT
inventoryLabel.TextScaled = true
inventoryLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
inventoryLabel.TextStrokeTransparency = 0

local closeBtn = makeButton(main, "CloseButton", "X", UDim2.fromScale(0.9, 0.03), UDim2.fromScale(0.08, 0.09), Color3.fromRGB(255, 0, 0))

local list = Instance.new("ScrollingFrame")
list.Name = "ItemList"
list.Parent = main
list.Position = UDim2.fromScale(0.03, 0.24)
list.Size = UDim2.fromScale(0.94, 0.73)
list.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
list.BackgroundTransparency = 0.1
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 8
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
addStroke(list, 3, Color3.new(0, 0, 0))

local layout = Instance.new("UIListLayout")
layout.Parent = list
layout.Padding = UDim.new(0.012, 0)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

local rowRefreshers = {}
local secondsValue

local function getOwnedNamesSorted()
	local owned = {}
	for _, pack in ipairs(STARTER_PACKS) do
		if unlockedItems[pack.Name] then
			table.insert(owned, pack.Name)
		end
	end
	return owned
end

local function refreshInventoryLabel()
	local owned = getOwnedNamesSorted()
	if #owned == 0 then
		inventoryLabel.Text = "Inventory: None"
	else
		inventoryLabel.Text = "Inventory: " .. table.concat(owned, ", ")
	end
end

local function applyState(state)
	unlockedItems = {}
	if type(state) == "table" and type(state.unlocked) == "table" then
		for itemName, unlocked in pairs(state.unlocked) do
			if unlocked == true and packByName[itemName] then
				unlockedItems[itemName] = true
			end
		end
	end

	refreshInventoryLabel()
	for _, refresh in ipairs(rowRefreshers) do
		refresh()
	end
end

local function requestState()
	resolveRemotes()
	if not getStateRemote then
		return
	end
	local ok, state = pcall(function()
		return getStateRemote:InvokeServer()
	end)
	if ok and type(state) == "table" then
		applyState(state)
	end
end

local function refreshAllRows()
	for _, refresh in ipairs(rowRefreshers) do
		refresh()
	end
end

local function makeStarterPackRow(index, data)
	local row = Instance.new("Frame")
	row.Name = "StarterPack_" .. tostring(index)
	row.Parent = list
	row.Size = UDim2.fromScale(0.985, 0.2)
	row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	row.LayoutOrder = index
	addStroke(row, 3, Color3.new(0, 0, 0))

	local icon = Instance.new("Frame")
	icon.Parent = row
	icon.Position = UDim2.fromScale(0.02, 0.12)
	icon.Size = UDim2.fromScale(0.17, 0.76)
	icon.BackgroundColor3 = data.IconColor
	addStroke(icon, 2, Color3.new(0, 0, 0))

	local iconText = Instance.new("TextLabel")
	iconText.Parent = icon
	iconText.Size = UDim2.fromScale(1, 1)
	iconText.BackgroundTransparency = 1
	iconText.Text = data.IconText
	iconText.Font = FONT
	iconText.TextScaled = true
	iconText.TextColor3 = Color3.new(1, 1, 1)
	iconText.TextStrokeTransparency = 0

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Parent = row
	nameLabel.Position = UDim2.fromScale(0.21, 0.1)
	nameLabel.Size = UDim2.fromScale(0.5, 0.38)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = data.Name
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Font = FONT
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0

	local reqLabel = Instance.new("TextLabel")
	reqLabel.Parent = row
	reqLabel.Position = UDim2.fromScale(0.21, 0.52)
	reqLabel.Size = UDim2.fromScale(0.5, 0.35)
	reqLabel.BackgroundTransparency = 1
	reqLabel.TextXAlignment = Enum.TextXAlignment.Left
	reqLabel.Font = FONT
	reqLabel.TextScaled = true
	reqLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	reqLabel.TextStrokeTransparency = 0
	reqLabel.Text = string.format("Requires %d Seconds", data.RequiredSeconds)

	local action = makeButton(row, "Action", "Locked", UDim2.fromScale(0.73, 0.18), UDim2.fromScale(0.25, 0.64), Color3.fromRGB(80, 80, 80))

	local function refresh()
		local owned = unlockedItems[data.Name] == true
		local unlockedBySeconds = secondsValue and secondsValue.Value >= data.RequiredSeconds
		if owned then
			action.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
			action.Label.Text = "Unlocked"
		elseif unlockedBySeconds then
			action.BackgroundColor3 = Color3.fromRGB(255, 205, 60)
			action.Label.Text = "Unlock"
		else
			action.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			action.Label.Text = "Locked"
		end
	end

	action.MouseButton1Click:Connect(function()
		if not secondsValue then
			return
		end

		if unlockedItems[data.Name] then
			return
		end

		if secondsValue.Value >= data.RequiredSeconds then
			resolveRemotes()
			if not purchaseRemote then
				return
			end
			local ok, success, _, state = pcall(function()
				return purchaseRemote:InvokeServer(data.Name)
			end)
			if ok and success and type(state) == "table" then
				applyState(state)
			end
		end
	end)

	table.insert(rowRefreshers, refresh)
end

for i, pack in ipairs(STARTER_PACKS) do
	makeStarterPackRow(i, pack)
end

local cleanupStaleActiveUI
local isAnimating = false
local function openUI()
	local activeUi = player:GetAttribute(ACTIVE_UI_ATTR)
	if cleanupStaleActiveUI then
		activeUi = cleanupStaleActiveUI(activeUi)
	end
	if activeUi and activeUi ~= UI_ID then
		return
	end
	if isAnimating or main.Visible then
		return
	end
	isAnimating = true
	player:SetAttribute(ACTIVE_UI_ATTR, UI_ID)
	main.Visible = true
	main.Size = closedMainSize
	main.BackgroundTransparency = 1

	local mainTween = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = defaultMainSize, BackgroundTransparency = 0 })
	local blurTween = TweenService:Create(blur, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 16 })
	mainTween:Play()
	blurTween:Play()
	mainTween.Completed:Wait()
	isAnimating = false
end

local function closeUI()
	if isAnimating or not main.Visible then
		return
	end
	isAnimating = true

	local mainTween = TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = closedMainSize, BackgroundTransparency = 1 })
	local blurTween = TweenService:Create(blur, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = 0 })
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
secondsValue = leaderstats:WaitForChild("Seconds")

local function refreshSecondsAndRows()
	secondsLabel.Text = "Your Seconds: " .. tostring(secondsValue.Value)
	refreshAllRows()
end

secondsValue:GetPropertyChangedSignal("Value"):Connect(refreshSecondsAndRows)
refreshSecondsAndRows()


local MENU_GUI_BY_UI_ID = {
	Titles = "TitlesGui",
	Donate = "DonateGui",
	UpdateLog = "UpdateLogGui",
	Shop = "ShopGui",
	ItemShop = "ItemShopGui",
	Gamepasses = "GamepassesGui",
}

cleanupStaleActiveUI = function(activeUi)
	if not activeUi then
		return nil
	end
	if activeUi == UI_ID and main.Visible then
		return activeUi
	end
	local menuGuiName = MENU_GUI_BY_UI_ID[activeUi]
	if not menuGuiName then
		player:SetAttribute(ACTIVE_UI_ATTR, nil)
		return nil
	end
	local menuGui = playerGui:FindFirstChild(menuGuiName)
	local menuMain = menuGui and menuGui:FindFirstChild("Main")
	if not (menuMain and menuMain:IsA("GuiObject") and menuMain.Visible) then
		player:SetAttribute(ACTIVE_UI_ATTR, nil)
		return nil
	end
	return activeUi
end

local function refreshOpenButtonVisibility()
	tweenOpenButton(false)
	openBtn.Visible = false
	openBtn.Active = false
end

player:GetAttributeChangedSignal(ACTIVE_UI_ATTR):Connect(refreshOpenButtonVisibility)
refreshOpenButtonVisibility()

resolveRemotes()
requestState()
