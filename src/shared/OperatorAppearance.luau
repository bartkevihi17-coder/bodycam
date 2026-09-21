local OperatorAppearance = {}

local COLORS = {
	Skin = Color3.fromRGB(205, 174, 143),
	Uniform = Color3.fromRGB(60, 67, 53),
	UniformDark = Color3.fromRGB(42, 47, 39),
	UniformLight = Color3.fromRGB(78, 84, 65),
	Vest = Color3.fromRGB(76, 77, 60),
	VestDark = Color3.fromRGB(47, 49, 40),
	Boot = Color3.fromRGB(25, 26, 25),
	Black = Color3.fromRGB(18, 19, 20),
	Lens = Color3.fromRGB(34, 45, 50),
	Metal = Color3.fromRGB(59, 62, 63),
	Red = Color3.fromRGB(196, 36, 36),
	Tan = Color3.fromRGB(118, 105, 80),
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
	transparency: number?,
	shape: Enum.PartType?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.Transparency = transparency or 0
	part.Shape = shape or Enum.PartType.Block
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CastShadow = false
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

local function addClassicHeadMesh(headPart: BasePart)
	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "ClassicRobloxHeadMesh"
	mesh.MeshType = Enum.MeshType.Head
	mesh.Scale = Vector3.new(1.22, 1.22, 1.22)
	mesh.Parent = headPart
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

local function hideAvatarVisuals(character: Model, cosmetics: Folder)
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
		if descendant:IsDescendantOf(cosmetics) then
			continue
		end

		if descendant:IsA("BasePart") then
			if descendant.Name ~= "HumanoidRootPart" then
				descendant.Transparency = 1
			end
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant:Destroy()
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
	offset: CFrame?,
	transparency: number?,
	shape: Enum.PartType?
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
		offset or CFrame.identity,
		transparency,
		shape
	)
end

local function addNeck(cosmetics: Folder, torso: BasePart?)
	if not torso then
		return
	end

	newPart(
		cosmetics,
		"Neck",
		Vector3.new(0.36, 0.52, 0.52),
		COLORS.Skin,
		Enum.Material.SmoothPlastic,
		torso,
		CFrame.new(0, 1.08, 0) * CFrame.Angles(0, 0, math.rad(90)),
		0,
		Enum.PartType.Cylinder
	)
end

local function addFinger(
	cosmetics: Folder,
	target: BasePart,
	name: string,
	x: number,
	y: number,
	z: number,
	length: number,
	side: number
)
	newPart(
		cosmetics,
		name,
		Vector3.new(length, 0.115, 0.115),
		COLORS.Skin,
		Enum.Material.SmoothPlastic,
		target,
		CFrame.new(x * side, y, z) * CFrame.Angles(0, 0, math.rad(90)),
		0,
		Enum.PartType.Cylinder
	)
end

local function addHandDetails(cosmetics: Folder, target: BasePart?, sideName: string, r15: boolean?)
	if not target then
		return
	end

	local side = sideName == "Left" and -1 or 1
	local palmOffsetY = r15 and -0.04 or -0.98

	newPart(
		cosmetics,
		sideName .. "Palm",
		Vector3.new(0.8, 0.34, 0.72),
		COLORS.Skin,
		Enum.Material.SmoothPlastic,
		target,
		CFrame.new(0, palmOffsetY, -0.02)
	)

	local fingerY = palmOffsetY - 0.31
	local xs = {-0.26, -0.09, 0.09, 0.26}

	for index, x in xs do
		addFinger(
			cosmetics,
			target,
			sideName .. "Finger" .. tostring(index),
			x,
			fingerY,
			-0.2,
			0.34 - (index == 1 and 0.03 or 0),
			1
		)
	end

	newPart(
		cosmetics,
		sideName .. "Thumb",
		Vector3.new(0.28, 0.13, 0.13),
		COLORS.Skin,
		Enum.Material.SmoothPlastic,
		target,
		CFrame.new(0.43 * side, palmOffsetY - 0.04, -0.14)
			* CFrame.Angles(0, 0, math.rad(35 * side)),
		0,
		Enum.PartType.Cylinder
	)
end

local function addClassicHead(cosmetics: Folder, head: BasePart?)
	if not head then
		return
	end

	local operatorHead = newPart(
		cosmetics,
		"OperatorHead",
		Vector3.new(1.84, 0.96, 0.96),
		COLORS.Skin,
		Enum.Material.SmoothPlastic,
		head,
		CFrame.identity
	)

	addClassicHeadMesh(operatorHead)
	addDefaultFace(operatorHead)
end

local function addR6Body(character: Model, cosmetics: Folder)
	local torso = character:FindFirstChild("Torso") :: BasePart?
	local head = character:FindFirstChild("Head") :: BasePart?
	local leftArm = character:FindFirstChild("Left Arm") :: BasePart?
	local rightArm = character:FindFirstChild("Right Arm") :: BasePart?
	local leftLeg = character:FindFirstChild("Left Leg") :: BasePart?
	local rightLeg = character:FindFirstChild("Right Leg") :: BasePart?

	visualShell(cosmetics, torso, "UniformTorso", Vector3.new(2.02, 2, 1.02), COLORS.Uniform, Enum.Material.Fabric)
	addNeck(cosmetics, torso)
	addClassicHead(cosmetics, head)

	visualShell(cosmetics, leftArm, "LeftArmBase", Vector3.new(0.98, 2, 0.98), COLORS.Skin, Enum.Material.SmoothPlastic)
	visualShell(cosmetics, rightArm, "RightArmBase", Vector3.new(0.98, 2, 0.98), COLORS.Skin, Enum.Material.SmoothPlastic)

	visualShell(cosmetics, leftArm, "LeftSleeve", Vector3.new(1.04, 1.28, 1.04), COLORS.Uniform, Enum.Material.Fabric, CFrame.new(0, 0.35, 0))
	visualShell(cosmetics, rightArm, "RightSleeve", Vector3.new(1.04, 1.28, 1.04), COLORS.Uniform, Enum.Material.Fabric, CFrame.new(0, 0.35, 0))

	visualShell(cosmetics, leftArm, "LeftElbowPad", Vector3.new(0.66, 0.42, 0.16), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, -0.18, -0.56))
	visualShell(cosmetics, rightArm, "RightElbowPad", Vector3.new(0.66, 0.42, 0.16), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, -0.18, -0.56))

	visualShell(cosmetics, leftArm, "LeftWristCuff", Vector3.new(1.03, 0.18, 1.03), COLORS.UniformDark, Enum.Material.Fabric, CFrame.new(0, -0.72, 0))
	visualShell(cosmetics, rightArm, "RightWristCuff", Vector3.new(1.03, 0.18, 1.03), COLORS.UniformDark, Enum.Material.Fabric, CFrame.new(0, -0.72, 0))

	addHandDetails(cosmetics, leftArm, "Left", false)
	addHandDetails(cosmetics, rightArm, "Right", false)

	visualShell(cosmetics, leftLeg, "LeftTrouser", Vector3.new(1.04, 2, 1.04), COLORS.UniformDark, Enum.Material.Fabric)
	visualShell(cosmetics, rightLeg, "RightTrouser", Vector3.new(1.04, 2, 1.04), COLORS.UniformDark, Enum.Material.Fabric)

	visualShell(cosmetics, leftLeg, "LeftCargoPocket", Vector3.new(0.22, 0.62, 0.68), COLORS.UniformLight, Enum.Material.Fabric, CFrame.new(-0.61, 0.25, 0))
	visualShell(cosmetics, rightLeg, "RightCargoPocket", Vector3.new(0.22, 0.62, 0.68), COLORS.UniformLight, Enum.Material.Fabric, CFrame.new(0.61, 0.25, 0))

	visualShell(cosmetics, leftLeg, "LeftThighStrap", Vector3.new(1.08, 0.14, 1.09), COLORS.Black, Enum.Material.Fabric, CFrame.new(0, 0.48, 0))
	visualShell(cosmetics, rightLeg, "RightThighStrap", Vector3.new(1.08, 0.14, 1.09), COLORS.Black, Enum.Material.Fabric, CFrame.new(0, 0.48, 0))

	visualShell(cosmetics, leftLeg, "LeftKneePad", Vector3.new(0.72, 0.52, 0.17), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, -0.03, -0.58))
	visualShell(cosmetics, rightLeg, "RightKneePad", Vector3.new(0.72, 0.52, 0.17), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, -0.03, -0.58))

	visualShell(cosmetics, leftLeg, "LeftBoot", Vector3.new(1.08, 0.58, 1.26), COLORS.Boot, Enum.Material.SmoothPlastic, CFrame.new(0, -0.72, -0.1))
	visualShell(cosmetics, rightLeg, "RightBoot", Vector3.new(1.08, 0.58, 1.26), COLORS.Boot, Enum.Material.SmoothPlastic, CFrame.new(0, -0.72, -0.1))
end

local function addR15Body(character: Model, cosmetics: Folder)
	local head = character:FindFirstChild("Head") :: BasePart?
	local upperTorso = character:FindFirstChild("UpperTorso") :: BasePart?
	local lowerTorso = character:FindFirstChild("LowerTorso") :: BasePart?

	visualShell(cosmetics, upperTorso, "UniformUpperTorso", Vector3.new(2.03, 1.28, 1.03), COLORS.Uniform, Enum.Material.Fabric)
	visualShell(cosmetics, lowerTorso, "UniformLowerTorso", Vector3.new(1.86, 0.92, 1.02), COLORS.UniformDark, Enum.Material.Fabric)
	addNeck(cosmetics, upperTorso)
	addClassicHead(cosmetics, head)

	local upperArms = {
		{"LeftUpperArm", "Left"},
		{"RightUpperArm", "Right"},
	}

	for _, info in upperArms do
		local target = character:FindFirstChild(info[1]) :: BasePart?
		visualShell(cosmetics, target, info[2] .. "Sleeve", Vector3.new(1, 1.15, 1), COLORS.Uniform, Enum.Material.Fabric)
		visualShell(cosmetics, target, info[2] .. "ShoulderPatch", Vector3.new(0.14, 0.48, 0.5), COLORS.VestDark, Enum.Material.Fabric, CFrame.new((info[2] == "Left" and -0.54 or 0.54), 0.18, 0))
	end

	local lowerArms = {
		{"LeftLowerArm", "Left"},
		{"RightLowerArm", "Right"},
	}

	for _, info in lowerArms do
		local target = character:FindFirstChild(info[1]) :: BasePart?
		visualShell(cosmetics, target, info[2] .. "Forearm", Vector3.new(0.96, 1.04, 0.96), COLORS.Skin, Enum.Material.SmoothPlastic)
		visualShell(cosmetics, target, info[2] .. "ElbowPad", Vector3.new(0.66, 0.42, 0.16), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, 0.42, -0.52))
	end

	local hands = {
		{"LeftHand", "Left"},
		{"RightHand", "Right"},
	}

	for _, info in hands do
		local hand = character:FindFirstChild(info[1]) :: BasePart?
		visualShell(cosmetics, hand, info[2] .. "HandBase", Vector3.new(0.88, 0.42, 0.82), COLORS.Skin, Enum.Material.SmoothPlastic)
		addHandDetails(cosmetics, hand, info[2], true)
	end

	local legData = {
		{"LeftUpperLeg", "Left"},
		{"RightUpperLeg", "Right"},
	}

	for _, info in legData do
		local target = character:FindFirstChild(info[1]) :: BasePart?
		visualShell(cosmetics, target, info[2] .. "UpperTrouser", Vector3.new(1.02, 1.18, 1.02), COLORS.UniformDark, Enum.Material.Fabric)
		visualShell(cosmetics, target, info[2] .. "CargoPocket", Vector3.new(0.18, 0.55, 0.62), COLORS.UniformLight, Enum.Material.Fabric, CFrame.new((info[2] == "Left" and -0.55 or 0.55), 0.02, 0))
		visualShell(cosmetics, target, info[2] .. "ThighStrap", Vector3.new(1.06, 0.13, 1.06), COLORS.Black, Enum.Material.Fabric, CFrame.new(0, -0.25, 0))
	end

	local lowerLegData = {
		{"LeftLowerLeg", "Left"},
		{"RightLowerLeg", "Right"},
	}

	for _, info in lowerLegData do
		local target = character:FindFirstChild(info[1]) :: BasePart?
		visualShell(cosmetics, target, info[2] .. "LowerTrouser", Vector3.new(1.01, 1.08, 1.01), COLORS.UniformDark, Enum.Material.Fabric)
		visualShell(cosmetics, target, info[2] .. "KneePad", Vector3.new(0.7, 0.5, 0.16), COLORS.VestDark, Enum.Material.SmoothPlastic, CFrame.new(0, 0.36, -0.52))
	end

	visualShell(cosmetics, character:FindFirstChild("LeftFoot") :: BasePart?, "LeftBoot", Vector3.new(1.05, 0.56, 1.28), COLORS.Boot, Enum.Material.SmoothPlastic)
	visualShell(cosmetics, character:FindFirstChild("RightFoot") :: BasePart?, "RightBoot", Vector3.new(1.05, 0.56, 1.28), COLORS.Boot, Enum.Material.SmoothPlastic)
end

local function addPlateCarrier(character: Model, cosmetics: Folder)
	local torso = (
		character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
	) :: BasePart?

	if not torso then
		return
	end

	newPart(cosmetics, "FrontPlate", Vector3.new(2.08, 1.52, 0.24), COLORS.Vest, Enum.Material.Fabric, torso, CFrame.new(0, -0.02, -0.62))
	newPart(cosmetics, "BackPlate", Vector3.new(2.08, 1.52, 0.22), COLORS.VestDark, Enum.Material.Fabric, torso, CFrame.new(0, -0.02, 0.62))

	newPart(cosmetics, "LeftStrap", Vector3.new(0.25, 0.7, 0.28), COLORS.Vest, Enum.Material.Fabric, torso, CFrame.new(-0.72, 0.73, -0.12))
	newPart(cosmetics, "RightStrap", Vector3.new(0.25, 0.7, 0.28), COLORS.Vest, Enum.Material.Fabric, torso, CFrame.new(0.72, 0.73, -0.12))

	newPart(cosmetics, "VestCenterZip", Vector3.new(0.07, 1.15, 0.045), COLORS.Black, Enum.Material.SmoothPlastic, torso, CFrame.new(0, 0.02, -0.76))

	for index = -1, 1 do
		newPart(
			cosmetics,
			"MagazinePouch_" .. tostring(index + 2),
			Vector3.new(0.48, 0.61, 0.27),
			COLORS.VestDark,
			Enum.Material.Fabric,
			torso,
			CFrame.new(index * 0.57, -0.34, -0.81)
		)

		newPart(
			cosmetics,
			"MagazineFlap_" .. tostring(index + 2),
			Vector3.new(0.44, 0.1, 0.29),
			COLORS.UniformLight,
			Enum.Material.Fabric,
			torso,
			CFrame.new(index * 0.57, -0.04, -0.83)
		)
	end

	local bodycam = newPart(cosmetics, "BodyCamera", Vector3.new(0.34, 0.5, 0.2), COLORS.Black, Enum.Material.SmoothPlastic, torso, CFrame.new(0.42, 0.22, -0.8))
	newPart(cosmetics, "BodyCameraLens", Vector3.new(0.16, 0.16, 0.045), COLORS.Lens, Enum.Material.Glass, bodycam, CFrame.new(0, 0.07, -0.12), 0.08)
	newPart(cosmetics, "BodyCameraLED", Vector3.new(0.05, 0.05, 0.025), COLORS.Red, Enum.Material.Neon, bodycam, CFrame.new(0.095, -0.11, -0.12))

	newPart(cosmetics, "Radio", Vector3.new(0.38, 0.72, 0.3), COLORS.Black, Enum.Material.SmoothPlastic, torso, CFrame.new(-1.1, 0.01, -0.08))
	newPart(
		cosmetics,
		"RadioAntenna",
		Vector3.new(0.7, 0.075, 0.075),
		COLORS.Black,
		Enum.Material.SmoothPlastic,
		torso,
		CFrame.new(-1.13, 0.68, -0.08) * CFrame.Angles(0, 0, math.rad(90)),
		0,
		Enum.PartType.Cylinder
	)

	newPart(cosmetics, "UtilityBeltFront", Vector3.new(2.08, 0.23, 0.15), COLORS.Black, Enum.Material.Fabric, torso, CFrame.new(0, -0.98, -0.53))
	newPart(cosmetics, "UtilityBeltBack", Vector3.new(2.08, 0.23, 0.15), COLORS.Black, Enum.Material.Fabric, torso, CFrame.new(0, -0.98, 0.53))

	newPart(cosmetics, "LeftBeltPouch", Vector3.new(0.48, 0.5, 0.28), COLORS.Tan, Enum.Material.Fabric, torso, CFrame.new(-0.78, -1.05, -0.28))
	newPart(cosmetics, "RightBeltPouch", Vector3.new(0.48, 0.5, 0.28), COLORS.Tan, Enum.Material.Fabric, torso, CFrame.new(0.78, -1.05, -0.28))

	local backpack = newPart(cosmetics, "Backpack", Vector3.new(1.78, 1.82, 0.72), COLORS.VestDark, Enum.Material.Fabric, torso, CFrame.new(0, -0.03, 0.97))
	newPart(cosmetics, "BackpackTop", Vector3.new(1.45, 0.42, 0.76), COLORS.Vest, Enum.Material.Fabric, backpack, CFrame.new(0, 0.83, 0.02))
	newPart(cosmetics, "BackpackFrontPouch", Vector3.new(1.25, 0.72, 0.28), COLORS.Tan, Enum.Material.Fabric, backpack, CFrame.new(0, -0.22, 0.48))
	newPart(cosmetics, "BackpackLeftStrap", Vector3.new(0.18, 1.62, 0.16), COLORS.Black, Enum.Material.Fabric, torso, CFrame.new(-0.68, 0.02, 0.63))
	newPart(cosmetics, "BackpackRightStrap", Vector3.new(0.18, 1.62, 0.16), COLORS.Black, Enum.Material.Fabric, torso, CFrame.new(0.68, 0.02, 0.63))
end

local function addHelmet(character: Model, cosmetics: Folder)
	local head = character:FindFirstChild("Head") :: BasePart?
	if not head then
		return
	end

	newPart(
		cosmetics,
		"HelmetShell",
		Vector3.new(2.08, 1.12, 1.48),
		COLORS.VestDark,
		Enum.Material.SmoothPlastic,
		head,
		CFrame.new(0, 0.48, 0.06),
		0,
		Enum.PartType.Ball
	)

	newPart(cosmetics, "HelmetBrow", Vector3.new(1.62, 0.14, 0.26), COLORS.VestDark, Enum.Material.SmoothPlastic, head, CFrame.new(0, 0.25, -0.67))
	newPart(cosmetics, "HelmetLeftRail", Vector3.new(0.12, 0.36, 0.74), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(-0.98, 0.27, 0.05))
	newPart(cosmetics, "HelmetRightRail", Vector3.new(0.12, 0.36, 0.74), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(0.98, 0.27, 0.05))

	newPart(cosmetics, "HelmetMountBase", Vector3.new(0.4, 0.24, 0.11), COLORS.Black, Enum.Material.Metal, head, CFrame.new(0, 0.43, -0.77))
	newPart(cosmetics, "HelmetMountClip", Vector3.new(0.16, 0.16, 0.1), COLORS.Metal, Enum.Material.Metal, head, CFrame.new(0, 0.31, -0.81))

	newPart(
		cosmetics,
		"LeftEarcup",
		Vector3.new(0.18, 0.52, 0.52),
		COLORS.Black,
		Enum.Material.SmoothPlastic,
		head,
		CFrame.new(-1.02, -0.02, 0.04),
		0,
		Enum.PartType.Cylinder
	)

	newPart(
		cosmetics,
		"RightEarcup",
		Vector3.new(0.18, 0.52, 0.52),
		COLORS.Black,
		Enum.Material.SmoothPlastic,
		head,
		CFrame.new(1.02, -0.02, 0.04),
		0,
		Enum.PartType.Cylinder
	)

	local leftLens = newPart(cosmetics, "LeftGoggleLens", Vector3.new(0.64, 0.27, 0.055), COLORS.Lens, Enum.Material.Glass, head, CFrame.new(-0.36, 0.04, -0.55), 0.38)
	local rightLens = newPart(cosmetics, "RightGoggleLens", Vector3.new(0.64, 0.27, 0.055), COLORS.Lens, Enum.Material.Glass, head, CFrame.new(0.36, 0.04, -0.55), 0.38)

	newPart(cosmetics, "LeftGoggleTop", Vector3.new(0.7, 0.06, 0.08), COLORS.Black, Enum.Material.SmoothPlastic, leftLens, CFrame.new(0, 0.16, 0))
	newPart(cosmetics, "RightGoggleTop", Vector3.new(0.7, 0.06, 0.08), COLORS.Black, Enum.Material.SmoothPlastic, rightLens, CFrame.new(0, 0.16, 0))
	newPart(cosmetics, "GoggleBridge", Vector3.new(0.12, 0.08, 0.07), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(0, 0.04, -0.57))

	newPart(cosmetics, "LeftChinStrap", Vector3.new(0.07, 0.72, 0.07), COLORS.Black, Enum.Material.Fabric, head, CFrame.new(-0.62, -0.35, 0.04) * CFrame.Angles(0, 0, math.rad(-18)))
	newPart(cosmetics, "RightChinStrap", Vector3.new(0.07, 0.72, 0.07), COLORS.Black, Enum.Material.Fabric, head, CFrame.new(0.62, -0.35, 0.04) * CFrame.Angles(0, 0, math.rad(18)))

	newPart(cosmetics, "MicBoom", Vector3.new(0.72, 0.07, 0.07), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(-0.72, -0.16, -0.48) * CFrame.Angles(0, math.rad(35), 0), 0, Enum.PartType.Cylinder)
	newPart(cosmetics, "Mic", Vector3.new(0.18, 0.16, 0.2), COLORS.Black, Enum.Material.SmoothPlastic, head, CFrame.new(-0.47, -0.22, -0.82))
end

function OperatorAppearance.ApplyToCharacter(character: Model)
	local existing = character:FindFirstChild(COSMETICS_NAME)
	if existing then
		existing:Destroy()
	end

	local cosmetics = Instance.new("Folder")
	cosmetics.Name = COSMETICS_NAME
	cosmetics.Parent = character

	hideAvatarVisuals(character, cosmetics)

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
		Root = root,
	}
end

return OperatorAppearance
