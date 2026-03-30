local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ACTIVE_UI_ATTR = "ActiveMenuUI"
local UI_ID = "UpdateLog"

--[[
	========================
	UPDATE DATA (EDIT HERE)
	========================
	To add an update, insert a new table at index 1 (top = newest).
	Fields:
	- Version: short label
	- Date: display date
	- Title: one-line summary
	- Changes: list of bullet lines shown on the right panel
]]
local UPDATES = {
	{
		Version = "v1.3.0",
		Date = "2026-03-24",
		Title = "Titles + Tutorial Upgrade",
		Changes = {
			"Added AFK and Other Titles UI with equip states.",
			"Added Owner-only title support.",
			"Added overhead title display above players.",
			"Added onboarding tutorial flow.",
		},
	},
	{
		Version = "v1.2.0",
		Date = "2026-03-20",
		Title = "Progression Improvements",
		Changes = {
			"Improved second tracking performance.",
			"Balanced unlock timings for early progression.",
		},
	},
	{
		Version = "v1.1.0",
		Date = "2026-03-15",
		Title = "UI Polish Pass",
		Changes = {
			"Updated menu visuals with textured button backgrounds.",
			"Improved scaling for more device sizes.",
		},
	},
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
gui.Name = "UpdateLogGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local blur = Lighting:FindFirstChild("UpdateLogBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "UpdateLogBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

local openBtn = makeButton(
	gui,
	"OpenUpdateLogButton",
	"Updates",
	UDim2.fromScale(0.855, 0.9), -- far right bottom
	UDim2.fromScale(0.13, 0.08),
	Color3.fromRGB(25, 25, 25)
)
openBtn.Visible = true
local openBtnBasePosition = openBtn.Position
local openBtnHiddenPosition = openBtnBasePosition + UDim2.fromScale(0.2, 0)
local openBtnTween

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

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromScale(0.62, 0.68)
main.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
main.BackgroundTransparency = 1
main.Visible = false
addStroke(main, 4, Color3.new(0, 0, 0))

local defaultMainSize = main.Size
local closedMainSize = UDim2.new(defaultMainSize.X.Scale * 0.85, defaultMainSize.X.Offset, defaultMainSize.Y.Scale * 0.85, defaultMainSize.Y.Offset)
main.Size = closedMainSize

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = main
titleLabel.Position = UDim2.fromScale(0.02, 0.02)
titleLabel.Size = UDim2.fromScale(0.5, 0.08)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Update Log"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = FONT
titleLabel.TextScaled = true
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextStrokeTransparency = 0

local closeBtn = makeButton(main, "CloseButton", "X", UDim2.fromScale(0.92, 0.02), UDim2.fromScale(0.06, 0.08), Color3.fromRGB(255, 0, 0))

local updatesList = Instance.new("ScrollingFrame")
updatesList.Parent = main
updatesList.Name = "UpdatesList"
updatesList.Position = UDim2.fromScale(0.02, 0.12)
updatesList.Size = UDim2.fromScale(0.36, 0.84)
updatesList.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
updatesList.BackgroundTransparency = 0.1
updatesList.CanvasSize = UDim2.new(0, 0, 0, 0)
updatesList.ScrollBarThickness = 8
updatesList.AutomaticCanvasSize = Enum.AutomaticSize.Y
addStroke(updatesList, 3, Color3.new(0, 0, 0))

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = updatesList
listLayout.Padding = UDim.new(0.012, 0)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local detailsFrame = Instance.new("Frame")
detailsFrame.Parent = main
detailsFrame.Position = UDim2.fromScale(0.4, 0.12)
detailsFrame.Size = UDim2.fromScale(0.58, 0.84)
detailsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
detailsFrame.BackgroundTransparency = 0.1
addStroke(detailsFrame, 3, Color3.new(0, 0, 0))

local detailsTitle = Instance.new("TextLabel")
detailsTitle.Parent = detailsFrame
detailsTitle.Position = UDim2.fromScale(0.03, 0.03)
detailsTitle.Size = UDim2.fromScale(0.94, 0.12)
detailsTitle.BackgroundTransparency = 1
detailsTitle.TextXAlignment = Enum.TextXAlignment.Left
detailsTitle.Font = FONT
detailsTitle.TextScaled = true
detailsTitle.TextColor3 = Color3.new(1, 1, 1)
detailsTitle.TextStrokeTransparency = 0

detailsTitle.Text = "Select an update"

local detailsBody = Instance.new("TextLabel")
detailsBody.Parent = detailsFrame
detailsBody.Position = UDim2.fromScale(0.03, 0.17)
detailsBody.Size = UDim2.fromScale(0.94, 0.8)
detailsBody.BackgroundTransparency = 1
detailsBody.TextXAlignment = Enum.TextXAlignment.Left
detailsBody.TextYAlignment = Enum.TextYAlignment.Top
detailsBody.TextWrapped = true
detailsBody.Font = FONT
detailsBody.TextScaled = true
detailsBody.TextColor3 = Color3.fromRGB(240, 240, 240)
detailsBody.TextStrokeTransparency = 0
detailsBody.Text = "Click an update on the left to see details."

local selectedButton

local function setDetails(update)
	local lines = {}
	for _, item in ipairs(update.Changes) do
		table.insert(lines, "• " .. item)
	end
	detailsTitle.Text = string.format("%s - %s", update.Version, update.Title)
	detailsBody.Text = string.format("Date: %s\n\n%s", update.Date, table.concat(lines, "\n"))
end

local function createUpdateRow(index, update)
	local row = makeButton(
		updatesList,
		"Update_" .. tostring(index),
		string.format("%s\n%s", update.Version, update.Date),
		UDim2.fromScale(0.02, 0),
		UDim2.fromScale(0.95, 0.13),
		Color3.fromRGB(30, 30, 35)
	)
	row.LayoutOrder = index

	row.MouseButton1Click:Connect(function()
		if selectedButton and selectedButton ~= row then
			selectedButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		end
		selectedButton = row
		row.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		setDetails(update)
	end)

	return row
end

for i, update in ipairs(UPDATES) do
	createUpdateRow(i, update)
end

if #UPDATES > 0 then
	setDetails(UPDATES[1])
	local firstRow = updatesList:FindFirstChild("Update_1")
	if firstRow and firstRow:IsA("ImageButton") then
		selectedButton = firstRow
		firstRow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
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
	else
		tweenOpenButton(activeUi == nil or activeUi == UI_ID)
	end
end

player:GetAttributeChangedSignal(ACTIVE_UI_ATTR):Connect(refreshOpenButtonVisibility)
refreshOpenButtonVisibility()
