local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local getDonatedTotalFn = ReplicatedStorage:WaitForChild("GetDonatedRobuxTotal")
local getSpentTotalFn = ReplicatedStorage:WaitForChild("GetRobuxSpentTotal")
local ACTIVE_UI_ATTR = "ActiveMenuUI"
local UI_ID = "Donate"

--[[
	========================
	DONATION TIERS (EDIT HERE)
	========================
	Add tiers from least to most Robux.
	Each entry:
	- Name: button/title text
	- Robux: displayed amount
	- ProductId: Developer Product Id to prompt purchase
	- Description: optional flavor text
]]
local DONATION_TIERS = {
	{ Name = "Small Tip", Robux = 5, ProductId = 3559541392, Description = "Thank you for supporting the game!" },
	{ Name = "Supporter", Robux = 25, ProductId = 0, Description = "Helps us keep updates coming." },
	{ Name = "Big Support", Robux = 100, ProductId = 0, Description = "Huge support for development." },
	{ Name = "Legend Donator", Robux = 500, ProductId = 0, Description = "Massive support. Thank you!" },
}

table.sort(DONATION_TIERS, function(a, b)
	return a.Robux < b.Robux
end)

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
gui.Name = "DonateGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local blur = Lighting:FindFirstChild("DonateBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "DonateBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

local openBtn = makeButton(
	gui,
	"OpenDonateButton",
	"Donate",
	UDim2.fromScale(0.015, 0.60),
	UDim2.fromScale(0.15, 0.095),
	Color3.fromRGB(140, 25, 180)
)
local openBtnStroke = openBtn:FindFirstChildOfClass("UIStroke")
if openBtnStroke then
	openBtnStroke.Thickness = 5
end
openBtn.Visible = true
local openBtnBasePosition = openBtn.Position
local openBtnHiddenPosition = openBtnBasePosition + UDim2.fromScale(-0.2, 0)
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
main.Size = UDim2.fromScale(0.58, 0.66)
main.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
main.BackgroundTransparency = 1
main.Visible = false
addStroke(main, 4, Color3.new(0, 0, 0))

local defaultMainSize = main.Size
local closedMainSize = UDim2.new(defaultMainSize.X.Scale * 0.85, defaultMainSize.X.Offset, defaultMainSize.Y.Scale * 0.85, defaultMainSize.Y.Offset)
main.Size = closedMainSize

local header = Instance.new("TextLabel")
header.Parent = main
header.Position = UDim2.fromScale(0.02, 0.02)
header.Size = UDim2.fromScale(0.7, 0.08)
header.BackgroundTransparency = 1
header.Text = "Donate"
header.TextXAlignment = Enum.TextXAlignment.Left
header.Font = FONT
header.TextScaled = true
header.TextColor3 = Color3.new(1, 1, 1)
header.TextStrokeTransparency = 0

local closeBtn = makeButton(main, "CloseButton", "X", UDim2.fromScale(0.92, 0.02), UDim2.fromScale(0.06, 0.08), Color3.fromRGB(255, 0, 0))

local tipLabel = Instance.new("TextLabel")
tipLabel.Parent = main
tipLabel.Position = UDim2.fromScale(0.02, 0.11)
tipLabel.Size = UDim2.fromScale(0.96, 0.07)
tipLabel.BackgroundTransparency = 1
tipLabel.Text = "Choose any amount below. Tiers are listed from least to most Robux."
tipLabel.TextXAlignment = Enum.TextXAlignment.Left
tipLabel.Font = FONT
tipLabel.TextScaled = true
tipLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
tipLabel.TextStrokeTransparency = 0

local list = Instance.new("ScrollingFrame")
list.Name = "DonationList"
list.Parent = main
list.Position = UDim2.fromScale(0.02, 0.2)
list.Size = UDim2.fromScale(0.96, 0.68)
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

local donatedTotalLabel = Instance.new("TextLabel")
donatedTotalLabel.Name = "DonatedTotalLabel"
donatedTotalLabel.Parent = main
donatedTotalLabel.Position = UDim2.fromScale(0.02, 0.9)
donatedTotalLabel.Size = UDim2.fromScale(0.96, 0.055)
donatedTotalLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
donatedTotalLabel.BackgroundTransparency = 0.1
donatedTotalLabel.Text = "Total Donated: 0 Robux"
donatedTotalLabel.Font = FONT
donatedTotalLabel.TextScaled = true
donatedTotalLabel.TextColor3 = Color3.fromRGB(255, 230, 120)
donatedTotalLabel.TextStrokeTransparency = 0
addStroke(donatedTotalLabel, 2, Color3.new(0, 0, 0))

local spentTotalLabel = Instance.new("TextLabel")
spentTotalLabel.Name = "SpentTotalLabel"
spentTotalLabel.Parent = main
spentTotalLabel.Position = UDim2.fromScale(0.02, 0.955)
spentTotalLabel.Size = UDim2.fromScale(0.96, 0.04)
spentTotalLabel.BackgroundTransparency = 1
spentTotalLabel.Text = "Robux Spent: 0"
spentTotalLabel.Font = FONT
spentTotalLabel.TextScaled = true
spentTotalLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
spentTotalLabel.TextStrokeTransparency = 0

local function createTierRow(index, tier)
	local row = Instance.new("Frame")
	row.Name = "Tier_" .. index
	row.Parent = list
	row.Size = UDim2.fromScale(0.985, 0.18)
	row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	row.LayoutOrder = index
	addStroke(row, 3, Color3.new(0, 0, 0))

	local title = Instance.new("TextLabel")
	title.Parent = row
	title.Position = UDim2.fromScale(0.02, 0.08)
	title.Size = UDim2.fromScale(0.62, 0.34)
	title.BackgroundTransparency = 1
	title.Text = string.format("%s  |  %d R$", tier.Name, tier.Robux)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = FONT
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextStrokeTransparency = 0

	local desc = Instance.new("TextLabel")
	desc.Parent = row
	desc.Position = UDim2.fromScale(0.02, 0.48)
	desc.Size = UDim2.fromScale(0.62, 0.4)
	desc.BackgroundTransparency = 1
	desc.Text = tier.Description or "Support the game."
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Font = FONT
	desc.TextScaled = true
	desc.TextColor3 = Color3.fromRGB(230, 230, 230)
	desc.TextStrokeTransparency = 0

	local donateBtn = makeButton(row, "DonateButton", "Donate", UDim2.fromScale(0.68, 0.19), UDim2.fromScale(0.3, 0.62), Color3.fromRGB(0, 180, 0))
	donateBtn.MouseButton1Click:Connect(function()
		if tier.ProductId and tier.ProductId > 0 then
			MarketplaceService:PromptProductPurchase(player, tier.ProductId)
		else
			warn(string.format("[DonateUI] Missing ProductId for tier '%s' (%d R$)", tier.Name, tier.Robux))
		end
	end)
end

for i, tier in ipairs(DONATION_TIERS) do
	createTierRow(i, tier)
end

local function refreshDonatedTotalLabel()
	local attrValue = player:GetAttribute("DonatedRobuxTotal")
	if typeof(attrValue) == "number" then
		donatedTotalLabel.Text = ("Total Donated: %d Robux"):format(math.floor(attrValue))
		return
	end

	local ok, total = pcall(function()
		return getDonatedTotalFn:InvokeServer()
	end)
	if ok and typeof(total) == "number" then
		donatedTotalLabel.Text = ("Total Donated: %d Robux"):format(math.floor(total))
	else
		donatedTotalLabel.Text = "Total Donated: 0 Robux"
	end
end

local function refreshSpentTotalLabel()
	local attrValue = player:GetAttribute("SpentRobuxTotal")
	if typeof(attrValue) == "number" then
		spentTotalLabel.Text = ("Robux Spent: %d"):format(math.floor(attrValue))
		return
	end

	local ok, total = pcall(function()
		return getSpentTotalFn:InvokeServer()
	end)
	if ok and typeof(total) == "number" then
		spentTotalLabel.Text = ("Robux Spent: %d"):format(math.floor(total))
	else
		spentTotalLabel.Text = "Robux Spent: 0"
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
	refreshDonatedTotalLabel()
	refreshSpentTotalLabel()
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

local function refreshOpenButtonVisibility()
	local activeUi = player:GetAttribute(ACTIVE_UI_ATTR)
	if main.Visible then
		tweenOpenButton(false)
	else
		tweenOpenButton(activeUi == nil or activeUi == UI_ID)
	end
end

player:GetAttributeChangedSignal(ACTIVE_UI_ATTR):Connect(refreshOpenButtonVisibility)
player:GetAttributeChangedSignal("DonatedRobuxTotal"):Connect(refreshDonatedTotalLabel)
player:GetAttributeChangedSignal("SpentRobuxTotal"):Connect(refreshSpentTotalLabel)
refreshOpenButtonVisibility()
refreshDonatedTotalLabel()
refreshSpentTotalLabel()
