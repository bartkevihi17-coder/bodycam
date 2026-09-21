local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPack = game:GetService("StarterPack")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local remotes = ReplicatedStorage:FindFirstChild("BodycamRemotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "BodycamRemotes"
	remotes.Parent = ReplicatedStorage
end

if not remotes:FindFirstChild("FireWeapon") then
	local remote = Instance.new("RemoteEvent")
	remote.Name = "FireWeapon"
	remote.Parent = remotes
end

if not StarterPack:FindFirstChild(Config.Weapon.Name) then
	local tool = Instance.new("Tool")
	tool.Name = Config.Weapon.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool.ToolTip = "Prototype sidearm"

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.35, 0.8, 1.5)
	handle.Color = Color3.fromRGB(18, 18, 21)
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	tool.Parent = StarterPack
end

if not workspace:FindFirstChild("BodycamTestMap") then
	local map = Instance.new("Folder")
	map.Name = "BodycamTestMap"
	map.Parent = workspace

	local function makePart(
		name: string,
		size: Vector3,
		position: Vector3,
		color: Color3,
		material: Enum.Material?
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
		part.Parent = map
		return part
	end

	local wallColor = Color3.fromRGB(55, 57, 62)
	local floorColor = Color3.fromRGB(38, 40, 43)

	makePart("Floor", Vector3.new(90, 1, 90), Vector3.new(0, -0.5, 0), floorColor, Enum.Material.Concrete)
	makePart("NorthWall", Vector3.new(90, 12, 1), Vector3.new(0, 6, -45), wallColor)
	makePart("SouthWall", Vector3.new(90, 12, 1), Vector3.new(0, 6, 45), wallColor)
	makePart("WestWall", Vector3.new(1, 12, 90), Vector3.new(-45, 6, 0), wallColor)
	makePart("EastWall", Vector3.new(1, 12, 90), Vector3.new(45, 6, 0), wallColor)

	makePart("HallWallA", Vector3.new(1, 10, 52), Vector3.new(-12, 5, -10), wallColor)
	makePart("HallWallB", Vector3.new(1, 10, 30), Vector3.new(12, 5, 10), wallColor)
	makePart("RoomDivider", Vector3.new(28, 10, 1), Vector3.new(26, 5, -12), wallColor)

	for index = -2, 2 do
		local cover = makePart(
			"Cover_" .. tostring(index),
			Vector3.new(6, 4, 2),
			Vector3.new(index * 12, 2, 25),
			Color3.fromRGB(78, 67, 56),
			Enum.Material.WoodPlanks
		)
		cover.Orientation = Vector3.new(0, index * 7, 0)
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "DevSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(5, 0.5, 5)
	spawn.Position = Vector3.new(0, 0.25, 35)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Parent = map

	for index = -3, 3 do
		local fixture = makePart(
			"CeilingLight_" .. tostring(index),
			Vector3.new(5, 0.2, 1),
			Vector3.new(index * 12, 9.5, 0),
			Color3.fromRGB(230, 235, 255),
			Enum.Material.Neon
		)

		local light = Instance.new("PointLight")
		light.Brightness = 1.2
		light.Range = 22
		light.Color = Color3.fromRGB(205, 215, 255)
		light.Shadows = true
		light.Parent = fixture
	end
end

Lighting.ClockTime = 21
Lighting.Brightness = 1.35
Lighting.Ambient = Color3.fromRGB(19, 22, 29)
Lighting.OutdoorAmbient = Color3.fromRGB(8, 10, 15)

if not Lighting:FindFirstChild("BodycamColor") then
	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "BodycamColor"
	colorCorrection.Brightness = -0.03
	colorCorrection.Contrast = 0.12
	colorCorrection.Saturation = -0.18
	colorCorrection.TintColor = Color3.fromRGB(210, 220, 235)
	colorCorrection.Parent = Lighting
end

if not Lighting:FindFirstChild("BodycamBloom") then
	local bloom = Instance.new("BloomEffect")
	bloom.Name = "BodycamBloom"
	bloom.Intensity = 0.18
	bloom.Size = 20
	bloom.Threshold = 1.8
	bloom.Parent = Lighting
end
