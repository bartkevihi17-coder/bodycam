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

local difficultyNames = {
	EASY = "FACIL",
	NORMAL = "NORMAL",
	HARD = "DIFICIL",
}

local function makeHud()
	if player.PlayerGui:FindFirstChild("BodycamHUD") then
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "BodycamHUD"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local rec = Instance.new("TextLabel")
	rec.Name = "Rec"
	rec.BackgroundTransparency = 1
	rec.Position = UDim2.fromOffset(28, 22)
	rec.Size = UDim2.fromOffset(300, 36)
	rec.Font = Enum.Font.RobotoMono
	rec.TextSize = 19
	rec.TextXAlignment = Enum.TextXAlignment.Left
	rec.TextColor3 = Color3.fromRGB(235, 235, 235)
	rec.TextStrokeTransparency = 0.55
	rec.Text = "REC ●"
	rec.Parent = gui

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.AnchorPoint = Vector2.new(1, 0)
	status.Position = UDim2.new(1, -28, 0, 22)
	status.Size = UDim2.fromOffset(440, 56)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.RobotoMono
	status.TextSize = 16
	status.TextXAlignment = Enum.TextXAlignment.Right
	status.TextYAlignment = Enum.TextYAlignment.Top
	status.TextColor3 = Color3.fromRGB(235, 235, 235)
	status.TextStrokeTransparency = 0.55
	status.Parent = gui

	task.spawn(function()
		while gui.Parent do
			local now = DateTime.now()
			local difficulty = player:GetAttribute("CampaignDifficulty")
			local difficultyName = difficultyNames[difficulty] or "UNKNOWN"

			status.Text = now:FormatLocalTime("DD/MM/YYYY  HH:mm:ss", "pt-br")
				.. "\nBODYCAM // CAMPANHA // "
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
		return
	end

	humanoid.AutoRotate = true

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

RunService:BindToRenderStep("BodycamCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if not gameStarted or not humanoid or not root or humanoid.Health <= 0 then
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

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
		bobX = math.sin(elapsed * frequency * 0.5) * amplitude * 0.65
		bobY = math.abs(math.sin(elapsed * frequency)) * amplitude
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
