local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ACTIVE_UI_ATTR = "ActiveMenuUI"

local function addStroke(guiObject, thickness, color)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 3
	stroke.Color = color or Color3.new(0, 0, 0)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcall(function()
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
	end)
	stroke.Parent = guiObject
	return stroke
end

local gui = Instance.new("ScreenGui")
gui.Name = "SecondsCounterGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.Parent = gui
container.AnchorPoint = Vector2.new(0.5, 0)
container.Position = UDim2.fromScale(0.5, 0.02)
container.Size = UDim2.fromScale(0.23, 0.08)
container.BackgroundColor3 = Color3.fromRGB(65, 65, 72)
addStroke(container, 3, Color3.new(0, 0, 0))
local containerShownPosition = container.Position
local containerHiddenPosition = containerShownPosition + UDim2.fromScale(0, -0.12)
local containerTween

local icon = Instance.new("TextLabel")
icon.Name = "Icon"
icon.Parent = container
icon.Position = UDim2.fromScale(0.02, 0.08)
icon.Size = UDim2.fromScale(0.16, 0.84)
icon.BackgroundTransparency = 1
icon.Text = "⏱"
icon.Font = Enum.Font.FredokaOne
icon.TextScaled = true
icon.TextColor3 = Color3.fromRGB(255, 215, 80)
icon.TextStrokeTransparency = 0

local label = Instance.new("TextLabel")
label.Name = "Label"
label.Parent = container
label.Position = UDim2.fromScale(0.2, 0.08)
label.Size = UDim2.fromScale(0.78, 0.84)
label.BackgroundTransparency = 1
label.TextXAlignment = Enum.TextXAlignment.Left
label.Text = "SECONDS\n0s"
label.Font = Enum.Font.FredokaOne
label.TextScaled = true
label.TextColor3 = Color3.new(1, 1, 1)
label.TextStrokeTransparency = 0

local leaderstats = player:WaitForChild("leaderstats")
local secondsValue = leaderstats:WaitForChild("Seconds")

local function refreshSeconds()
	label.Text = "SECONDS\n" .. tostring(math.floor(tonumber(secondsValue.Value) or 0)) .. "s"
end

secondsValue:GetPropertyChangedSignal("Value"):Connect(refreshSeconds)
refreshSeconds()

local function tweenCounter(shouldShow)
	local target = shouldShow and containerShownPosition or containerHiddenPosition
	if containerTween then
		containerTween:Cancel()
	end
	containerTween = TweenService:Create(container, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = target,
	})
	containerTween:Play()
end

local function refreshCounterVisibility()
	local activeUi = player:GetAttribute(ACTIVE_UI_ATTR)
	tweenCounter(activeUi == nil)
end

player:GetAttributeChangedSignal(ACTIVE_UI_ATTR):Connect(refreshCounterVisibility)
refreshCounterVisibility()
