local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Поиск RemoteEvent для стрельбы (замените путь на ваш)
local FireEvent = ReplicatedStorage:FindFirstChild("FireEvent") 

-- Настройки механик
local AUTO_SHOOT_DISTANCE = 100 -- Дистанция в студах для срабатывания
local isAutoShootActive = false
local lastShootTime = 0
local SHOOT_COOLDOWN = 0.15 -- Задержка между выстрелами (в секундах)

-- === 1. ФУНКЦИЯ СТРЕЛЬБЫ ПО ЦЕНТРУ ЭКРАНА ===
local function shootAtScreenCenter()
	if not FireEvent then return end

	-- Центр экрана
	local viewportSize = Camera.ViewportSize
	local centerPoint = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

	-- Преобразуем точку 2D-экрана в 3D-луч
	local centerRay = Camera:ViewportPointToRay(centerPoint.X, centerPoint.Y)

	-- Точка назначения (например, на расстоянии 500 студов от камеры)
	local targetPosition = centerRay.Origin + (centerRay.Direction * 500)

	-- Вызываем событие стрельбы, передавая точку в центре экрана
	FireEvent:FireServer(targetPosition)
end

-- === 2. ПРОВЕРКА ДИСТАНЦИИ И АВТО-СТРЕЛЬБА ===
local function checkAutoShootAndTargeting()
	local folder = workspace:FindFirstChild("SpawnedDrones")
	if not folder then return end

	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local playerPos = character.HumanoidRootPart.Position
	local closestDrone = nil
	local shortestDistance = math.huge

	-- Находим ближайший дрон
	for _, drone in ipairs(folder:GetChildren()) do
		local part = drone:IsA("BasePart") and drone or drone:FindFirstChildWhichIsA("BasePart")
		if part then
			local distance = (part.Position - playerPos).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				closestDrone = part
			end
		end
	end

	-- Если цель найдена и авто-стрельба включена
	if closestDrone and isAutoShootActive then
		-- Проверяем условие по дистанции (<= 100 studs)
		if shortestDistance <= AUTO_SHOOT_DISTANCE then
			
			-- 1. Автоматическая наводка (плавно доворачиваем камеру)
			local currentCFrame = Camera.CFrame
			local targetCFrame = CFrame.lookAt(currentCFrame.Position, closestDrone.Position)
			Camera.CFrame = currentCFrame:Lerp(targetCFrame, 0.25)

			-- 2. Автоматическая стрельба по кулдауну
			local currentTime = tick()
			if currentTime - lastShootTime >= SHOOT_COOLDOWN then
				lastShootTime = currentTime
				shootAtScreenCenter()
			end
		end
	end
end

-- === 3. ПОДКЛЮЧЕНИЕ К ЦИКЛУ ОБНОВЛЕНИЯ ===
RunService.RenderStepped:Connect(function()
	checkAutoShootAndTargeting()
end)
