local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local player = Players.LocalPlayer
local character: Model?
local humanoid: Humanoid?
local root: BasePart?

local sprinting = false
local crouching = false
local baseHipHeight = 0
local gameStarted = player:GetAttribute("CampaignStarted") == true

local firstPersonParts: {BasePart} = {}
local rebuildPartsQueued = false

local difficultyNames = {
	EASY = "FACIL",
	NORMAL = "NORMAL",
	HARD = "DIFICIL",
}

local mapNames = {
	COMPLEX_01 = "COMPLEXO INDUSTRIAL",
}

local visibleNameTokens = {
	"arm",
	"hand",
	"palm",
	"finger",
	"thumb",
	"sleeve",
	"wrist",
	"forearm",
	"elbowpad",
}

local function isFirstPersonBodyPart(part: BasePart): boolean
	local name = string.lower(part.Name)

	for _, token in visibleNameTokens do
		if string.find(name, token, 1, true) then
			return true
		end
	end

	local tool = part:FindFirstAncestorOfClass("Tool")
	return tool ~= nil
end

local function rebuildFirstPersonParts()
	table.clear(firstPersonParts)

	if not character then
		return
	end

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") and isFirstPersonBodyPart(descendant) then
			table.insert(firstPersonParts, descendant)
		end
	end
end

local function queueFirstPersonPartsRebuild()
	if rebuildPartsQueued then
		return
	end

	rebuildPartsQueued = true
	task.defer(function()
		rebuildPartsQueued = false
		rebuildFirstPersonParts()
	end)
end

local function forceHandsVisible()
	for index = #firstPersonParts, 1, -1 do
		local part = firstPersonParts[index]

		if not part.Parent then
			table.remove(firstPersonParts, index)
		else
			part.LocalTransparencyModifier = 0
		end
	end
end

local function makeHud()
	if player.PlayerGui:FindFirstChild("BodycamHUD") then
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "BodycamHUD"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 500
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local fx = Instance.new("Frame")
	fx.Name = "BodycamFX"
	fx.Size = UDim2.fromScale(1, 1)
	fx.BackgroundTransparency = 1
	fx.BorderSizePixel = 0
	fx.ZIndex = 1
	fx.Parent = gui

	for index = 1, 18 do
		local line = Instance.new("Frame")
		line.Name = "Scanline_" .. tostring(index)
		line.Size = UDim2.new(1, 0, 0, 1)
		line.Position = UDim2.new(0, 0, index / 19, 0)
		line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		line.BackgroundTransparency = 0.9
		line.BorderSizePixel = 0
		line.ZIndex = 1
		line.Parent = fx
	end

	local interference = Instance.new("Frame")
	interference.Name = "Interference"
	interference.Size = UDim2.new(1, 0, 0, 2)
	interference.Position = UDim2.fromScale(0, 0.42)
	interference.BackgroundColor3 = Color3.fromRGB(225, 233, 236)
	interference.BackgroundTransparency = 0.94
	interference.BorderSizePixel = 0
	interference.ZIndex = 2
	interference.Parent = fx

	local topShade = Instance.new("Frame")
	topShade.Size = UDim2.new(1, 0, 0, 52)
	topShade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	topShade.BackgroundTransparency = 0.72
	topShade.BorderSizePixel = 0
	topShade.ZIndex = 2
	topShade.Parent = fx

	local bottomShade = topShade:Clone()
	bottomShade.AnchorPoint = Vector2.new(0, 1)
	bottomShade.Position = UDim2.fromScale(0, 1)
	bottomShade.Parent = fx

	local rec = Instance.new("TextLabel")
	rec.Name = "Rec"
	rec.BackgroundTransparency = 1
	rec.Position = UDim2.fromOffset(28, 20)
	rec.Size = UDim2.fromOffset(230, 38)
	rec.Font = Enum.Font.RobotoMono
	rec.TextSize = 19
	rec.TextXAlignment = Enum.TextXAlignment.Left
	rec.TextColor3 = Color3.fromRGB(255, 44, 44)
	rec.TextStrokeColor3 = Color3.fromRGB(40, 0, 0)
	rec.TextStrokeTransparency = 0.28
	rec.Text = "● REC"
	rec.ZIndex = 5
	rec.Parent = gui

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.AnchorPoint = Vector2.new(1, 0)
	status.Position = UDim2.new(1, -28, 0, 20)
	status.Size = UDim2.fromOffset(520, 60)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.RobotoMono
	status.TextSize = 15
	status.TextXAlignment = Enum.TextXAlignment.Right
	status.TextYAlignment = Enum.TextYAlignment.Top
	status.TextColor3 = Color3.fromRGB(246, 248, 249)
	status.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	status.TextStrokeTransparency = 0.35
	status.ZIndex = 5
	status.Parent = gui

	task.spawn(function()
		local blink = false

		while gui.Parent do
			blink = not blink
			rec.TextTransparency = blink and 0.38 or 0
			rec.TextStrokeTransparency = blink and 0.65 or 0.28
			task.wait(0.52)
		end
	end)

	task.spawn(function()
		while gui.Parent do
			interference.Position = UDim2.fromScale(0, math.random(8, 92) / 100)
			interference.BackgroundTransparency = math.random(91, 97) / 100
			interference.Size = UDim2.new(1, 0, 0, math.random(1, 2))
			task.wait(0.18)
		end
	end)

	task.spawn(function()
		while gui.Parent do
			local now = DateTime.now()
			local difficulty = player:GetAttribute("CampaignDifficulty")
			local mapCode = player:GetAttribute("CampaignMap")
			local difficultyName = difficultyNames[difficulty] or "UNKNOWN"
			local mapName = mapNames[mapCode] or "UNKNOWN"

			status.Text = now:FormatLocalTime("DD/MM/YYYY  HH:mm:ss", "pt-br")
				.. "\nBODYCAM // "
				.. mapName
				.. " // "
				.. difficultyName

			task.wait(0.25)
		end
	end)
end

local function applyMovement()
	if not humanoid then
		return
	end

	if not gameStarted then
		humanoid.WalkSpeed = 0
		humanoid.AutoRotate = false
		humanoid.CameraOffset = Vector3.zero
		return
	end

	humanoid.AutoRotate = true
	humanoid.CameraOffset = Vector3.new(0, -0.62, -0.08)

	if crouching then
		humanoid.WalkSpeed = Config.Movement.CrouchSpeed
		humanoid.HipHeight = math.max(0, baseHipHeight + Config.Movement.CrouchHipOffset)
	elseif sprinting then
		humanoid.WalkSpeed = Config.Movement.SprintSpeed
		humanoid.HipHeight = baseHipHeight
	else
		humanoid.WalkSpeed = Config.Movement.WalkSpeed
		humanoid.HipHeight = baseHipHeight
	end
end

local function setGameStarted(started: boolean)
	gameStarted = started

	if started then
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseIconEnabled = false
		makeHud()
	else
		player.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseIconEnabled = true
	end

	applyMovement()
end

local function onCharacterAdded(newCharacter: Model)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid") :: Humanoid
	root = newCharacter:WaitForChild("HumanoidRootPart") :: BasePart
	baseHipHeight = humanoid.HipHeight

	sprinting = false
	crouching = false

	newCharacter.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") or descendant:IsA("Tool") then
			queueFirstPersonPartsRebuild()
		end
	end)

	newCharacter.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("BasePart") or descendant:IsA("Tool") then
			queueFirstPersonPartsRebuild()
		end
	end)

	task.delay(0.9, rebuildFirstPersonParts)
	setGameStarted(player:GetAttribute("CampaignStarted") == true)
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
	onCharacterAdded(player.Character)
end

player:GetAttributeChangedSignal("CampaignStarted"):Connect(function()
	setGameStarted(player:GetAttribute("CampaignStarted") == true)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not gameStarted then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprinting = true
		crouching = false
		applyMovement()
	elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
		crouching = not crouching
		if crouching then
			sprinting = false
		end
		applyMovement()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not gameStarted then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprinting = false
		applyMovement()
	end
end)

local elapsed = 0
local smoothSway = Vector2.zero

RunService:BindToRenderStep("BodycamCamera", Enum.RenderPriority.Camera.Value + 2, function(dt)
	if not gameStarted or not humanoid or not root or humanoid.Health <= 0 then
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	forceHandsVisible()

	elapsed += dt

	local planarVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
	local speed = planarVelocity.Magnitude
	local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
	local moving = speed > 1 and grounded

	local frequency = sprinting and Config.Camera.SprintBobFrequency or Config.Camera.WalkBobFrequency
	local amplitude = sprinting and Config.Camera.SprintBobAmplitude or Config.Camera.WalkBobAmplitude

	local bobX = 0
	local bobY = 0
	if moving then
		bobX = math.sin(elapsed * frequency * 0.5) * amplitude * 0.58
		bobY = math.abs(math.sin(elapsed * frequency)) * amplitude * 0.82
	end

	local mouseDelta = UserInputService:GetMouseDelta()
	local targetSway = Vector2.new(
		math.clamp(-mouseDelta.Y * Config.Camera.SwayStrength, -Config.Camera.MaxSwayDegrees, Config.Camera.MaxSwayDegrees),
		math.clamp(-mouseDelta.X * Config.Camera.SwayStrength, -Config.Camera.MaxSwayDegrees, Config.Camera.MaxSwayDegrees)
	)

	smoothSway = smoothSway:Lerp(targetSway, math.clamp(dt * 10, 0, 1))

	local localVelocity = root.CFrame:VectorToObjectSpace(planarVelocity)
	local roll = math.clamp(-localVelocity.X / math.max(Config.Movement.SprintSpeed, 1), -1, 1)
		* Config.Camera.CameraRollDegrees

	local targetFov = sprinting and Config.Camera.SprintFov or Config.Camera.BaseFov
	camera.FieldOfView += (targetFov - camera.FieldOfView)
		* math.clamp(dt * Config.Camera.FovLerpSpeed, 0, 1)

	camera.CFrame = camera.CFrame
		* CFrame.new(bobX, bobY, 0)
		* CFrame.Angles(
			math.rad(smoothSway.X),
			math.rad(smoothSway.Y),
			math.rad(roll)
		)
end)
