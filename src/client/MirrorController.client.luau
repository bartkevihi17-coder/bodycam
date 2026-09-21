local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function waitForMirror(): BasePart?
	local map = workspace:WaitForChild("BodycamTestMap", 10)
	if not map then
		return nil
	end

	return map:WaitForChild("MirrorGlass", 10) :: BasePart?
end

local mirror = waitForMirror()
if not mirror then
	warn("BODYCAM mirror: MirrorGlass was not found")
	return
end

local surface = Instance.new("SurfaceGui")
surface.Name = "BodycamMirrorSurface"
surface.Adornee = mirror
surface.Face = Enum.NormalId.Left
surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
surface.PixelsPerStud = 95
surface.LightInfluence = 0
surface.AlwaysOnTop = false
surface.Parent = player:WaitForChild("PlayerGui")

local viewport = Instance.new("ViewportFrame")
viewport.Name = "MirrorViewport"
viewport.Size = UDim2.fromScale(1, 1)
viewport.BackgroundColor3 = Color3.fromRGB(91, 98, 101)
viewport.BackgroundTransparency = 0.08
viewport.BorderSizePixel = 0
viewport.Ambient = Color3.fromRGB(170, 175, 177)
viewport.LightColor = Color3.fromRGB(245, 242, 232)
viewport.LightDirection = Vector3.new(-0.45, -0.8, -0.35)
viewport.Parent = surface

local mirrorCamera = Instance.new("Camera")
mirrorCamera.Name = "MirrorCamera"
mirrorCamera.Parent = viewport
viewport.CurrentCamera = mirrorCamera

local worldModel = Instance.new("WorldModel")
worldModel.Name = "ReflectionWorld"
worldModel.Parent = viewport

local originalToClone: {[BasePart]: BasePart} = {}
local currentClone: Model?
local rebuildQueued = false
local connections: {RBXScriptConnection} = {}

local function clearConnections()
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
end

local function destroyClone()
	if currentClone then
		currentClone:Destroy()
		currentClone = nil
	end
	table.clear(originalToClone)
end

local function rebuildClone()
	rebuildQueued = false
	destroyClone()

	local character = player.Character
	if not character or not character.Parent then
		return
	end

	local oldArchivable = character.Archivable
	character.Archivable = true

	local originals: {[string]: BasePart} = {}
	local index = 0

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			index += 1
			local key = "mirror_" .. tostring(index)
			descendant:SetAttribute("BodycamMirrorKey", key)
			originals[key] = descendant
		end
	end

	local clone = character:Clone()
	character.Archivable = oldArchivable

	clone.Name = "ReflectedOperator"

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("Script")
			or descendant:IsA("LocalScript")
			or descendant:IsA("ModuleScript")
			or descendant:IsA("Sound") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false

			local key = descendant:GetAttribute("BodycamMirrorKey")
			if typeof(key) == "string" and originals[key] then
				originalToClone[originals[key]] = descendant
			end
		end
	end

	clone.Parent = worldModel
	currentClone = clone
end

local function queueRebuild()
	if rebuildQueued then
		return
	end

	rebuildQueued = true
	task.delay(0.2, function()
		if surface.Parent then
			rebuildClone()
		end
	end)
end

local function bindCharacter(character: Model)
	clearConnections()

	table.insert(connections, character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart")
			or descendant:IsA("Accessory")
			or descendant:IsA("Tool") then
			queueRebuild()
		end
	end))

	table.insert(connections, character.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("BasePart")
			or descendant:IsA("Accessory")
			or descendant:IsA("Tool") then
			queueRebuild()
		end
	end))

	task.delay(1, rebuildClone)
end

player.CharacterAdded:Connect(bindCharacter)

if player.Character then
	bindCharacter(player.Character)
end

local function reflectVector(vector: Vector3, normal: Vector3): Vector3
	return vector - (2 * vector:Dot(normal) * normal)
end

local function reflectPoint(point: Vector3, planePoint: Vector3, normal: Vector3): Vector3
	local distance = (point - planePoint):Dot(normal)
	return point - (2 * distance * normal)
end

RunService.RenderStepped:Connect(function()
	if not player:GetAttribute("CampaignStarted") then
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	for original, clonePart in originalToClone do
		if original.Parent and clonePart.Parent then
			clonePart.CFrame = original.CFrame
			clonePart.Transparency = original.Transparency
			clonePart.Color = original.Color
			clonePart.Material = original.Material
		end
	end

	local normal = -mirror.CFrame.RightVector
	local planePoint = mirror.Position

	local reflectedPosition = reflectPoint(camera.CFrame.Position, planePoint, normal)
	local reflectedLook = reflectVector(camera.CFrame.LookVector, normal)
	local reflectedUp = reflectVector(camera.CFrame.UpVector, normal)

	mirrorCamera.FieldOfView = camera.FieldOfView
	mirrorCamera.CFrame = CFrame.lookAt(
		reflectedPosition,
		reflectedPosition + reflectedLook,
		reflectedUp
	)
end)
