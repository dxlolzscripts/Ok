local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Поиск события стрельбы (замените на имя/путь к вашему RemoteEvent)
local FireEvent = ReplicatedStorage:FindFirstChild("FireEvent")

-- Состояния функций
local isAimbotActive = false
local isEspActive = false
local isAutoShootActive = false

-- Настройки стрельбы
local AUTO_SHOOT_DISTANCE = 100 -- Дистанция в студах
local SHOOT_COOLDOWN = 0.15      -- Задержка между выстрелами (в секундах)
local lastShootTime = 0

-- === 1. СОЗДАНИЕ ИНТЕРФЕЙСА (UI) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DroneControlSystemUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главная панель
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 240, 0, 230)
mainFrame.Position = UDim2.new(0.5, -120, 0.5, -115)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 0, 30)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.Text = "Drone Control Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

-- Кнопка сворачивания "_"
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -28, 0, 2.5)
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.Parent = mainFrame

-- Маленький квадратик (Свернутый UI)
local minimizedFrame = Instance.new("TextButton")
minimizedFrame.Name = "MinimizedFrame"
minimizedFrame.Size = UDim2.new(0, 40, 0, 40)
minimizedFrame.Position = mainFrame.Position
minimizedFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
minimizedFrame.Text = "🎯"
minimizedFrame.TextSize = 20
minimizedFrame.Visible = false
minimizedFrame.Parent = screenGui

-- Вспомогательная функция для создания кнопок UI
local function createMenuButton(text, positionY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, positionY)
	btn.Text = text .. ": ВЫКЛ"
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 15
	btn.Parent = mainFrame
	return btn
end

local aimbotBtn = createMenuButton("Автонаведение", 35)
local espBtn = createMenuButton("Красный ESP", 85)
local autoShootBtn = createMenuButton("Автострельба (<=100s)", 135)

-- === 2. ТАСКАНИЕ (DRAGGING) И СВОРАЧИВАНИЕ ===
local function enableDragging(frame, dragHandle)
	local dragging = false
	local dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
