local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPack = game:GetService("StarterPack")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local MAP_VERSION = 3

local remotes = ReplicatedStorage:FindFirstChild("BodycamRemotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "BodycamRemotes"
	remotes.Parent = ReplicatedStorage
end

local function ensureRemote(name: string)
	if remotes:FindFirstChild(name) then
		return
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
end

ensureRemote("FireWeapon")
ensureRemote("StartCampaign")

local function createWeaponPart(
	tool: Tool,
	handle: BasePart,
	name: string,
	size: Vector3,
	offset: CFrame,
	color: Color3,
	material: Enum.Material
)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CastShadow = false
	part.CFrame = handle.CFrame * offset
	part.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = part
	weld.Parent = part

	return part
end

if not StarterPack:FindFirstChild(Config.Weapon.Name) then
	local tool = Instance.new("Tool")
	tool.Name = Config.Weapon.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool.ToolTip = "G17 prototype"
	tool.Grip = CFrame.new(0, -0.1, -0.18) * CFrame.Angles(math.rad(-4), 0, 0)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.38, 0.92, 0.48)
	handle.Color = Color3.fromRGB(24, 25, 25)
	handle.Material = Enum.Material.SmoothPlastic
	handle.CanCollide = false
	handle.CanQuery = false
	handle.CanTouch = false
	handle.Massless = true
	handle.Parent = tool

	local slide = createWeaponPart(
		tool,
		handle,
		"Slide",
		Vector3.new(0.48, 0.36, 1.42),
		CFrame.new(0, 0.56, -0.34),
		Color3.fromRGB(45, 47, 47),
		Enum.Material.Metal
	)

	createWeaponPart(
		tool,
		handle,
		"Barrel",
		Vector3.new(0.2, 0.2, 0.72),
		CFrame.new(0, 0.51, -1.05),
		Color3.fromRGB(23, 24, 24),
		Enum.Material.Metal
	)

	createWeaponPart(
		tool,
		handle,
		"Trigger",
		Vector3.new(0.08, 0.34, 0.1),
		CFrame.new(0, 0.14, -0.33) * CFrame.Angles(math.rad(-18), 0, 0),
		Color3.fromRGB(14, 15, 15),
		Enum.Material.Metal
	)

	createWeaponPart(
		tool,
		handle,
		"TriggerGuardBottom",
		Vector3.new(0.34, 0.08, 0.5),
		CFrame.new(0, -0.05, -0.36),
		Color3.fromRGB(24, 25, 25),
		Enum.Material.SmoothPlastic
	)

	createWeaponPart(
		tool,
		handle,
		"FrontSight",
		Vector3.new(0.12, 0.12, 0.12),
		CFrame.new(0, 0.79, -0.93),
		Color3.fromRGB(20, 21, 21),
		Enum.Material.Metal
	)

	createWeaponPart(
		tool,
		handle,
		"RearSight",
		Vector3.new(0.3, 0.12, 0.12),
		CFrame.new(0, 0.79, 0.22),
		Color3.fromRGB(20, 21, 21),
		Enum.Material.Metal
	)

	local muzzle = createWeaponPart(
		tool,
		handle,
		"Muzzle",
		Vector3.new(0.22, 0.22, 0.05),
		CFrame.new(0, 0.52, -1.42) * CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(8, 9, 9),
		Enum.Material.Metal
	)
	muzzle.Shape = Enum.PartType.Cylinder

	slide.CastShadow = false
	tool.Parent = StarterPack
end

local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then
	baseplate:Destroy()
end

local oldMap = workspace:FindFirstChild("BodycamTestMap")
if oldMap and oldMap:GetAttribute("MapVersion") ~= MAP_VERSION then
	oldMap:Destroy()
	oldMap = nil
end

if not oldMap then
	local map = Instance.new("Folder")
	map.Name = "BodycamTestMap"
	map:SetAttribute("MapVersion", MAP_VERSION)
	map:SetAttribute("MapCode", "COMPLEX_01")
	map:SetAttribute("DisplayName", "COMPLEXO INDUSTRIAL")
	map.Parent = workspace

	local function makePart(
		name: string,
		size: Vector3,
		position: Vector3,
		color: Color3,
		material: Enum.Material?,
		parent: Instance?
	)
		local part = Instance.new("Part")
		part.Name = name
		part.Anchored = true
		part.Size = size
		part.Position = position
		part.Color = color
		part.Material = material or Enum.Material.Concrete
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = parent or map
		return part
	end

	local wallColor = Color3.fromRGB(70, 73, 75)
	local floorColor = Color3.fromRGB(47, 49, 50)
	local metalColor = Color3.fromRGB(53, 57, 59)

	makePart("Floor", Vector3.new(110, 1, 100), Vector3.new(0, -0.5, 0), floorColor, Enum.Material.Concrete)

	makePart("NorthWall", Vector3.new(110, 12, 1), Vector3.new(0, 6, -50), wallColor)
	makePart("SouthWall", Vector3.new(110, 12, 1), Vector3.new(0, 6, 50), wallColor)
	makePart("WestWall", Vector3.new(1, 12, 100), Vector3.new(-55, 6, 0), wallColor)
	makePart("EastWall", Vector3.new(1, 12, 100), Vector3.new(55, 6, 0), wallColor)

	makePart("HallWallA", Vector3.new(1, 10, 56), Vector3.new(-13, 5, -12), wallColor)
	makePart("HallWallB", Vector3.new(1, 10, 34), Vector3.new(13, 5, 7), wallColor)
	makePart("RoomDivider", Vector3.new(34, 10, 1), Vector3.new(30, 5, -14), wallColor)

	for index = -2, 2 do
		local cover = makePart(
			"Cover_" .. tostring(index),
			Vector3.new(6, 4, 2),
			Vector3.new(index * 12, 2, 18),
			Color3.fromRGB(82, 72, 60),
			Enum.Material.WoodPlanks
		)
		cover.Orientation = Vector3.new(0, index * 7, 0)
	end

	local readyArea = Instance.new("Folder")
	readyArea.Name = "EquipmentArea"
	readyArea.Parent = map

	makePart("ReadyFloor", Vector3.new(30, 0.12, 23), Vector3.new(39.5, 0.05, 37.5), Color3.fromRGB(39, 42, 43), Enum.Material.SmoothPlastic, readyArea)
	makePart("ReadyDivider", Vector3.new(30, 9, 0.6), Vector3.new(39.5, 4.5, 25.5), wallColor, Enum.Material.Concrete, readyArea)

	local doorLeft = makePart("DoorFrameLeft", Vector3.new(0.7, 8, 0.9), Vector3.new(30.5, 4, 25), metalColor, Enum.Material.Metal, readyArea)
	local doorRight = makePart("DoorFrameRight", Vector3.new(0.7, 8, 0.9), Vector3.new(36.5, 4, 25), metalColor, Enum.Material.Metal, readyArea)
	local doorTop = makePart("DoorFrameTop", Vector3.new(6.7, 0.7, 0.9), Vector3.new(33.5, 8, 25), metalColor, Enum.Material.Metal, readyArea)
	doorLeft.Material = Enum.Material.Metal
	doorRight.Material = Enum.Material.Metal
	doorTop.Material = Enum.Material.Metal

	for index = 0, 3 do
		local locker = makePart(
			"Locker_" .. tostring(index + 1),
			Vector3.new(2.4, 7, 2.2),
			Vector3.new(53.1, 3.5, 26.8 + index * 2.8),
			Color3.fromRGB(63, 69, 69),
			Enum.Material.Metal,
			readyArea
		)

		local vent = makePart(
			"LockerVent_" .. tostring(index + 1),
			Vector3.new(0.08, 1.3, 1.25),
			locker.Position + Vector3.new(-1.24, 1.7, 0),
			Color3.fromRGB(27, 29, 29),
			Enum.Material.Metal,
			readyArea
		)
		vent.CanCollide = false
	end

	local mirror = makePart(
		"MirrorGlass",
		Vector3.new(0.16, 5.8, 8.4),
		Vector3.new(54.35, 5.15, 41.2),
		Color3.fromRGB(118, 129, 133),
		Enum.Material.Glass,
		readyArea
	)
	mirror.Transparency = 0.14
	mirror.Reflectance = 0.08

	makePart("MirrorFrameTop", Vector3.new(0.32, 0.28, 8.8), Vector3.new(54.22, 8.18, 41.2), metalColor, Enum.Material.Metal, readyArea)
	makePart("MirrorFrameBottom", Vector3.new(0.32, 0.28, 8.8), Vector3.new(54.22, 2.12, 41.2), metalColor, Enum.Material.Metal, readyArea)
	makePart("MirrorFrameLeft", Vector3.new(0.32, 6.3, 0.28), Vector3.new(54.22, 5.15, 36.85), metalColor, Enum.Material.Metal, readyArea)
	makePart("MirrorFrameRight", Vector3.new(0.32, 6.3, 0.28), Vector3.new(54.22, 5.15, 45.55), metalColor, Enum.Material.Metal, readyArea)

	makePart("BenchSeat", Vector3.new(3.2, 0.35, 8), Vector3.new(49.5, 1.45, 41.2), Color3.fromRGB(74, 64, 53), Enum.Material.WoodPlanks, readyArea)
	makePart("BenchLegA", Vector3.new(0.4, 1.4, 0.4), Vector3.new(49.5, 0.7, 38), metalColor, Enum.Material.Metal, readyArea)
	makePart("BenchLegB", Vector3.new(0.4, 1.4, 0.4), Vector3.new(49.5, 0.7, 44.4), metalColor, Enum.Material.Metal, readyArea)

	local mirrorLight = makePart(
		"MirrorLight",
		Vector3.new(0.45, 0.35, 8),
		Vector3.new(53.6, 8.75, 41.2),
		Color3.fromRGB(238, 241, 236),
		Enum.Material.Neon,
		readyArea
	)
	local mirrorPointLight = Instance.new("PointLight")
	mirrorPointLight.Brightness = 1.7
	mirrorPointLight.Range = 16
	mirrorPointLight.Color = Color3.fromRGB(235, 239, 231)
	mirrorPointLight.Shadows = false
	mirrorPointLight.Parent = mirrorLight

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "DevSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(5, 0.5, 5)
	spawn.CFrame = CFrame.lookAt(
		Vector3.new(43.5, 0.25, 41.2),
		Vector3.new(54.3, 0.25, 41.2)
	)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Parent = readyArea

	for index = -2, 2 do
		local fixture = makePart(
			"CeilingLight_" .. tostring(index),
			Vector3.new(7, 0.2, 1),
			Vector3.new(index * 22, 9.6, 0),
			Color3.fromRGB(235, 239, 247),
			Enum.Material.Neon
		)

		local light = Instance.new("PointLight")
		light.Brightness = 1.7
		light.Range = 31
		light.Color = Color3.fromRGB(214, 222, 236)
		light.Shadows = false
		light.Parent = fixture
	end
end

Lighting.ClockTime = 18.2
Lighting.Brightness = 2.15
Lighting.EnvironmentDiffuseScale = 0.45
Lighting.EnvironmentSpecularScale = 0.55
Lighting.Ambient = Color3.fromRGB(62, 69, 77)
Lighting.OutdoorAmbient = Color3.fromRGB(40, 46, 54)

local colorCorrection = Lighting:FindFirstChild("BodycamColor")
if not colorCorrection then
	colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "BodycamColor"
	colorCorrection.Parent = Lighting
end

colorCorrection.Brightness = 0.025
colorCorrection.Contrast = 0.08
colorCorrection.Saturation = -0.08
colorCorrection.TintColor = Color3.fromRGB(225, 232, 240)

local bloom = Lighting:FindFirstChild("BodycamBloom")
if not bloom then
	bloom = Instance.new("BloomEffect")
	bloom.Name = "BodycamBloom"
	bloom.Parent = Lighting
end

bloom.Enabled = false
bloom.Intensity = 0
bloom.Size = 18
bloom.Threshold = 1.9
