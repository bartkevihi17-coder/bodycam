local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local OperatorAppearance = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("OperatorAppearance")
)

local function waitForMirror(): BasePart?
	local map = workspace:WaitForChild("BodycamTestMap", 10)
	if not map then
		return nil
	end

	local equipmentArea = map:WaitForChild("EquipmentArea", 10)
	if not equipmentArea then
		return nil
	end

	return equipmentArea:WaitForChild("MirrorGlass", 10) :: BasePart?
end

local mirrorPart = waitForMirror()
if not mirrorPart then
	warn("BODYCAM mirror: MirrorGlass was not found")
	return
end

local surface = Instance.new("SurfaceGui")
surface.Name = "BodycamMirrorSurface"
surface.Adornee = mirrorPart
surface.Face = Enum.NormalId.Left
surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
surface.PixelsPerStud = 72
surface.LightInfluence = 0
surface.AlwaysOnTop = false
surface.Parent = player:WaitForChild("PlayerGui")

local viewport = Instance.new("ViewportFrame")
viewport.Name = "MirrorViewport"
viewport.Size = UDim2.fromScale(1, 1)
viewport.BackgroundColor3 = Color3.fromRGB(96, 102, 104)
viewport.BackgroundTransparency = 0.08
viewport.BorderSizePixel = 0
viewport.Ambient = Color3.fromRGB(190, 194, 195)
viewport.LightColor = Color3.fromRGB(248, 245, 236)
viewport.LightDirection = Vector3.new(-0.45, -0.8, -0.35)
viewport.Parent = surface

local worldModel = Instance.new("WorldModel")
worldModel.Name = "ReflectionWorld"
worldModel.Parent = viewport

local preview = OperatorAppearance.BuildPreview(worldModel)

local mirrorCamera = Instance.new("Camera")
mirrorCamera.Name = "MirrorCamera"
mirrorCamera.FieldOfView = 36
mirrorCamera.CFrame = CFrame.lookAt(
	Vector3.new(0, 3.15, -8.4),
	Vector3.new(0, 2.8, 0)
)
mirrorCamera.Parent = viewport
viewport.CurrentCamera = mirrorCamera

local baseHeadOffset = preview.Torso.CFrame:ToObjectSpace(preview.Head.CFrame)
local updateAccumulator = 0
local wasNear = false
local entryYaw = 0

local function horizontalYaw(look: Vector3): number
	return math.atan2(look.X, -look.Z)
end

local function wrapAngle(angle: number): number
	return math.atan2(math.sin(angle), math.cos(angle))
end

RunService.RenderStepped:Connect(function(dt)
	if player:GetAttribute("CampaignStarted") ~= true then
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local camera = workspace.CurrentCamera

	if not root or not camera then
		return
	end

	local distance = (root.Position - mirrorPart.Position).Magnitude
	local nearMirror = distance <= 28

	if not nearMirror then
		wasNear = false
		return
	end

	if not wasNear then
		entryYaw = horizontalYaw(camera.CFrame.LookVector)
		wasNear = true
	end

	updateAccumulator += dt
	if updateAccumulator < (1 / 30) then
		return
	end
	updateAccumulator = 0

	local look = camera.CFrame.LookVector
	local currentYaw = horizontalYaw(look)
	local yawDelta = math.clamp(
		wrapAngle(currentYaw - entryYaw),
		math.rad(-38),
		math.rad(38)
	)

	local pitch = math.clamp(
		math.asin(math.clamp(look.Y, -1, 1)),
		math.rad(-24),
		math.rad(24)
	)

	preview.Head.CFrame = preview.Torso.CFrame
		* CFrame.new(baseHeadOffset.Position)
		* CFrame.Angles(-pitch, -yawDelta, 0)
end)
