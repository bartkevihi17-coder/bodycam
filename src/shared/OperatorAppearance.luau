local OperatorAppearance = {}

local COLORS = {
	Skin = Color3.fromRGB(205, 174, 143),
	Uniform = Color3.fromRGB(54, 61, 48),
	UniformDark = Color3.fromRGB(38, 43, 35),
	Vest = Color3.fromRGB(71, 72, 57),
	VestDark = Color3.fromRGB(47, 49, 40),
	Boot = Color3.fromRGB(23, 24, 23),
	Black = Color3.fromRGB(18, 19, 20),
	Lens = Color3.fromRGB(27, 34, 38),
	Metal = Color3.fromRGB(56, 58, 59),
	Red = Color3.fromRGB(176, 37, 37),
}

local COSMETICS_NAME = "OperatorCosmetics"

local function newPart(
	parent: Instance,
	name: string,
	size: Vector3,
	color: Color3,
	material: Enum.Material,
	target: BasePart,
	offset: CFrame,
	transparency: number?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.Transparency = transparency or 0
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CastShadow = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = target.CFrame * offset
	part.Parent = parent

	local weld = Instance.new("WeldConstraint")
	weld.Name = "CosmeticWeld"
	weld.Part0 = target
	weld.Part1 = part
	weld.Parent = part

	return part
end

local function addDefaultFace(head: BasePart)
	for _, child in head:GetChildren() do
		if child:IsA("Decal") or child:IsA("Texture") then
			child:Destroy()
		end
	end

	local face = Instance.new("Decal")
	face.Name = "OperatorFace"
	face.Face = Enum.NormalId.Front
	face.Texture = "rbxasset://textures/face.png"
	face.Parent = head
end

local function hideAvatarVisuals(character: Model)
	for _, child in character:GetChildren() do
		if child:IsA("Accessory")
			or child:IsA("Shirt")
			or child:IsA("Pants")
			or child:IsA("ShirtGraphic")
			or child:IsA("CharacterMesh") then
			child:Destroy()
		end
	end

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
			if not descendant:IsDescendantOf(character:FindFirstChild(COSMETICS_NAME) or Instance.new("Folder")) then
				descendant.Transparency = 1
			end
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			if not descendant:IsDescendantOf(character:FindFirstChild(COSMETICS_NAME) or Instance.new("Folder")) then
				descendant:Destroy()
			end
		end
	end
end

local function visualShell(
	cosmetics: Folder,
	target: BasePart?,
	name: string,
	size: Vector3,
	color: Color3,
	material: Enum.Material,
	offset: CFrame?
): Part?
	if not target then
		return nil
	end

	return newPart(
		cosmetics,
		name,
		size,
		color,
		material,
		target,
		offset or CFrame.identity
	)
end

local function addR6Body(character: Model, cosmetics: Folder)
	local torso = character:FindFirstChild("Torso") :: BasePart?
	local head = character:FindFirstChild("Head") :: BasePart?
	local leftArm = character:FindFirstChild("Left Arm") :: BasePart?
	local rightArm = character:FindFirstChild("Right Arm") :: BasePart?
	local leftLeg = character:FindFirstChild("Left Leg") :: BasePart?
	local rightLeg = character:FindFirstChild("Right Leg") :: BasePart?

	visualShell(cosmetics, torso, "UniformTorso", Vector3.new(2.04, 2.02, 1.04), COLORS.Uniform, Enum.Material.Fabric)

	local operatorHead = visualShell(cosmetics, head, "OperatorHead", Vector3.new(2, 1, 1), COLORS.Skin, Enum.Material.SmoothPlastic)
	if operatorHead then
		addDefaultFace(operatorHead)
	end

	visualShell(cosmetics, leftArm, "LeftArmBase", Vector3.new(1, 2, 1), COLORS.Skin, Enum.Material.SmoothPlastic)
	visualShell(cosmetics, rightArm, "RightArmBase", Vector3.new(1, 2, 1), COLORS.Skin, Enum.Material.SmoothPlastic)

	visualShell(cosmetics, leftArm, "LeftSleeve", Vector3.new(1.06, 1.55, 1.06), COLORS.Uniform, Enum.Material.Fabric, CFrame.new(0, 0.22, 0))
	visualShell(cosmetics, rightArm, "RightSleeve", Vector3.new(1.06, 1.55, 1.06), COLORS.Uniform, Enum.Material.Fabric, CFrame.new(0, 0.22, 0))

	visualShell(cosmetics, leftLeg, "LeftTrouser", Vector3.new(1.05, 2.02, 1.05), COLORS.UniformDark, Enum.Material.Fabric)
	visualShell(cosmetics, rightLeg, "RightTrouser", Vector3.new(1.05, 2.02, 1.05), COLORS.UniformDark, Enum.Material.Fabric)

	visualShell(cosmetics, leftLeg, "LeftBoot", Vector3.new(1.08, 0.55, 1.22), COLORS.Boot, Enum.Material.Leather, CFrame.new(0, -0.73, -0.08))
	visualShell(cosmetics, rightLeg, "RightBoot", Vector3.new(1.08, 0.55, 1.22), COLORS.Boot, Enum.Material.Leather, CFrame.new(0, -0.73, -0.08))

	visualShell(cosmetics, leftLeg, "LeftKneePad", Vector3.new(0.72, 0.55, 0.16), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, 0.05, -0.58))
	visualShell(cosmetics, rightLeg, "RightKneePad", Vector3.new(0.72, 0.55, 0.16), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, 0.05, -0.58))
end

local function addR15Body(character: Model, cosmetics: Folder)
	local head = character:FindFirstChild("Head") :: BasePart?
	local upperTorso = character:FindFirstChild("UpperTorso") :: BasePart?
	local lowerTorso = character:FindFirstChild("LowerTorso") :: BasePart?

	visualShell(cosmetics, upperTorso, "UniformUpperTorso", Vector3.new(2.05, 1.25, 1.03), COLORS.Uniform, Enum.Material.Fabric)
	visualShell(cosmetics, lowerTorso, "UniformLowerTorso", Vector3.new(1.9, 0.9, 1.02), COLORS.UniformDark, Enum.Material.Fabric)

	local operatorHead = visualShell(cosmetics, head, "OperatorHead", Vector3.new(2, 1, 1), COLORS.Skin, Enum.Material.SmoothPlastic)
	if operatorHead then
		addDefaultFace(operatorHead)
	end

	local uniformParts = {
		{"LeftUpperArm", Vector3.new(1, 1.15, 1)},
		{"LeftLowerArm", Vector3.new(1, 1.05, 1)},
		{"RightUpperArm", Vector3.new(1, 1.15, 1)},
		{"RightLowerArm", Vector3.new(1, 1.05, 1)},
		{"LeftUpperLeg", Vector3.new(1, 1.2, 1)},
		{"LeftLowerLeg", Vector3.new(1, 1.1, 1)},
		{"RightUpperLeg", Vector3.new(1, 1.2, 1)},
		{"RightLowerLeg", Vector3.new(1, 1.1, 1)},
	}

	for _, info in uniformParts do
		local target = character:FindFirstChild(info[1]) :: BasePart?
		local isLeg = string.find(info[1], "Leg") ~= nil
		visualShell(
			cosmetics,
			target,
			"Uniform_" .. info[1],
			info[2],
			isLeg and COLORS.UniformDark or COLORS.Uniform,
			Enum.Material.Fabric
		)
	end

	visualShell(cosmetics, character:FindFirstChild("LeftHand") :: BasePart?, "LeftHandSkin", Vector3.new(1, 0.45, 1), COLORS.Skin, Enum.Material.SmoothPlastic)
	visualShell(cosmetics, character:FindFirstChild("RightHand") :: BasePart?, "RightHandSkin", Vector3.new(1, 0.45, 1), COLORS.Skin, Enum.Material.SmoothPlastic)

	visualShell(cosmetics, character:FindFirstChild("LeftFoot") :: BasePart?, "LeftBoot", Vector3.new(1.05, 0.55, 1.25), COLORS.Boot, Enum.Material.Leather)
	visualShell(cosmetics, character:FindFirstChild("RightFoot") :: BasePart?, "RightBoot", Vector3.new(1.05, 0.55, 1.25), COLORS.Boot, Enum.Material.Leather)

	visualShell(cosmetics, character:FindFirstChild("LeftLowerLeg") :: BasePart?, "LeftKneePad", Vector3.new(0.72, 0.55, 0.16), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, 0.35, -0.56))
	visualShell(cosmetics, character:FindFirstChild("RightLowerLeg") :: BasePart?, "RightKneePad", Vector3.new(0.72, 0.55, 0.16), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, 0.35, -0.56))
end

local function addPlateCarrier(character: Model, cosmetics: Folder)
	local torso = (
		character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
	) :: BasePart?

	if not torso then
		return
	end

	newPart(cosmetics, "FrontPlate", Vector3.new(2.12, 1.55, 0.26), COLORS.Vest, Enum.Material.Fabric, torso, CFrame.new(0, -0.04, -0.63))
	newPart(cosmetics, "BackPlate", Vector3.new(2.12, 1.55, 0.24), COLORS.VestDark, Enum.Material.Fabric, torso, CFrame.new(0, -0.04, 0.63))

	newPart(cosmetics, "LeftStrap", Vector3.new(0.28, 0.72, 0.3), COLORS.Vest, Enum.Material.Fabric, torso, CFrame.new(-0.72, 0.76, -0.15))
	newPart(cosmetics, "RightStrap", Vector3.new(0.28, 0.72, 0.3), COLORS.Vest, Enum.Material.Fabric, torso, CFrame.new(0.72, 0.76, -0.15))

	for index = -1, 1 do
		newPart(
			cosmetics,
			"MagazinePouch_" .. tostring(index + 2),
			Vector3.new(0.52, 0.64, 0.28),
			COLORS.VestDark,
			Enum.Material.Fabric,
			torso,
			CFrame.new(index * 0.61, -0.32, -0.82)
		)
	end

	local bodycam = newPart(cosmetics, "BodyCamera", Vector3.new(0.38, 0.54, 0.22), COLORS.Black, Enum.Material.SmoothPlastic, torso, CFrame.new(0.57, 0.42, -0.83))
	newPart(cosmetics, "BodyCameraLens", Vector3.new(0.18, 0.18, 0.05), COLORS.Lens, Enum.Material.Glass, bodycam, CFrame.new(0, 0.08, -0.13))
	newPart(cosmetics, "BodyCameraLED", Vector3.new(0.055, 0.055, 0.03), COLORS.Red, Enum.Material.Neon, bodycam, CFrame.new(0.11, -0.12, -0.13))

	newPart(cosmetics, "Radio", Vector3.new(0.42, 0.78, 0.32), COLORS.Black, Enum.Material.SmoothPlastic, torso, CFrame.new(-1.13, 0.02, -0.1))
	newPart(cosmetics, "RadioAntenna", Vector3.new(0.08, 0.72, 0.08), COLORS.Black, Enum.Material.SmoothPlastic, torso, CFrame.new(-1.14, 0.71, -0.08))

	newPart(cosmetics, "UtilityBeltFront", Vector3.new(2.1, 0.25, 0.16), COLORS.Black, Enum.Material.Fabric, torso, CFrame.new(0, -0.98, -0.54))
	newPart(cosmetics, "UtilityBeltBack", Vector3.new(2.1, 0.25, 0.16), COLORS.Black, Enum.Material.Fabric, torso, CFrame.new(0, -0.98, 0.54))
end

local function addHelmet(character: Model, cosmetics: Folder)
	local head = character:FindFirstChild("Head") :: BasePart?
	if not head then
		return
	end

	newPart(cosmetics, "HelmetTop", Vector3.new(2.16, 0.62, 1.38), COLORS.VestDark, Enum.Material.SmoothPlastic, head, CFrame.new(0, 0.52, 0.06))
	newPart(cosmetics, "HelmetLeftRail", Vector3.new(0.16, 0.44, 0.86), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(-1.03, 0.28, 0.04))
	newPart(cosmetics, "HelmetRightRail", Vector3.new(0.16, 0.44, 0.86), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(1.03, 0.28, 0.04))
	newPart(cosmetics, "HelmetFrontLip", Vector3.new(1.72, 0.16, 0.28), COLORS.VestDark, Enum.Material.SmoothPlastic, head, CFrame.new(0, 0.25, -0.68))
	newPart(cosmetics, "HelmetMount", Vector3.new(0.42, 0.27, 0.15), COLORS.Black, Enum.Material.Metal, head, CFrame.new(0, 0.43, -0.78))

	newPart(cosmetics, "LeftEarcup", Vector3.new(0.22, 0.62, 0.58), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(-1.1, -0.02, 0.03))
	newPart(cosmetics, "RightEarcup", Vector3.new(0.22, 0.62, 0.58), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(1.1, -0.02, 0.03))

	newPart(cosmetics, "LeftGoggleLens", Vector3.new(0.76, 0.34, 0.08), COLORS.Lens, Enum.Material.Glass, head, CFrame.new(-0.42, 0.08, -0.56), 0.25)
	newPart(cosmetics, "RightGoggleLens", Vector3.new(0.76, 0.34, 0.08), COLORS.Lens, Enum.Material.Glass, head, CFrame.new(0.42, 0.08, -0.56), 0.25)
	newPart(cosmetics, "GoggleBridge", Vector3.new(0.16, 0.12, 0.09), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(0, 0.08, -0.57))

	newPart(cosmetics, "MicBoom", Vector3.new(0.08, 0.08, 0.88), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(-0.84, -0.18, -0.47) * CFrame.Angles(0, math.rad(-28), 0))
	newPart(cosmetics, "Mic", Vector3.new(0.2, 0.18, 0.22), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(-0.53, -0.25, -0.84))
end

function OperatorAppearance.ApplyToCharacter(character: Model)
	local existing = character:FindFirstChild(COSMETICS_NAME)
	if existing then
		existing:Destroy()
	end

	local cosmetics = Instance.new("Folder")
	cosmetics.Name = COSMETICS_NAME
	cosmetics.Parent = character

	hideAvatarVisuals(character)

	if character:FindFirstChild("Torso") then
		addR6Body(character, cosmetics)
	else
		addR15Body(character, cosmetics)
	end

	addPlateCarrier(character, cosmetics)
	addHelmet(character, cosmetics)

	return cosmetics
end

local function previewPart(model: Model, name: string, size: Vector3, cframe: CFrame)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 0
	part.Parent = model
	return part
end

function OperatorAppearance.BuildPreview(parent: Instance)
	local model = Instance.new("Model")
	model.Name = "MenuOperator"
	model.Parent = parent

	local torso = previewPart(model, "Torso", Vector3.new(2, 2, 1), CFrame.new(0, 3, 0))
	local head = previewPart(model, "Head", Vector3.new(2, 1, 1), CFrame.new(0, 4.5, 0))
	previewPart(model, "Left Arm", Vector3.new(1, 2, 1), CFrame.new(-1.5, 3, 0))
	previewPart(model, "Right Arm", Vector3.new(1, 2, 1), CFrame.new(1.5, 3, 0))
	previewPart(model, "Left Leg", Vector3.new(1, 2, 1), CFrame.new(-0.5, 1, 0))
	previewPart(model, "Right Leg", Vector3.new(1, 2, 1), CFrame.new(0.5, 1, 0))

	local root = previewPart(model, "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(0, 3, 0))
	root.Transparency = 1
	model.PrimaryPart = root

	OperatorAppearance.ApplyToCharacter(model)

	return {
		Model = model,
		Head = head,
		Torso = torso,
	}
end

return OperatorAppearance
