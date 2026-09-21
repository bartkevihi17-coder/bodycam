local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OperatorAppearance = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("OperatorAppearance")
)

local TARGET_HEIGHT = 5.8

local SCALE_VALUES = {
	BodyHeightScale = 1,
	BodyWidthScale = 1,
	BodyDepthScale = 1,
	HeadScale = 1,
	BodyTypeScale = 0,
	BodyProportionScale = 0,
}

local MATERIAL_STYLES = {
	fabric = {Color3.fromRGB(66, 75, 57), Enum.Material.Fabric},
	iron = {Color3.fromRGB(62, 65, 66), Enum.Material.Metal},
	metal = {Color3.fromRGB(86, 89, 90), Enum.Material.Metal},
	clothes = {Color3.fromRGB(51, 60, 48), Enum.Material.Fabric},
	skin = {Color3.fromRGB(191, 139, 111), Enum.Material.SmoothPlastic},
	armor = {Color3.fromRGB(79, 81, 62), Enum.Material.Fabric},
	elements = {Color3.fromRGB(31, 35, 33), Enum.Material.SmoothPlastic},
	flesh = {Color3.fromRGB(111, 71, 61), Enum.Material.SmoothPlastic},
	glass = {Color3.fromRGB(50, 65, 69), Enum.Material.Glass},
	shoes = {Color3.fromRGB(36, 37, 35), Enum.Material.SmoothPlastic},
	boots = {Color3.fromRGB(28, 30, 27), Enum.Material.SmoothPlastic},
}

local function normalizeScales(humanoid: Humanoid)
	for name, value in SCALE_VALUES do
		local scale = humanoid:FindFirstChild(name)
		if scale and scale:IsA("NumberValue") then
			scale.Value = value
		end
	end
end

local function getImportedTemplate(): Model?
	local importedAssets = ReplicatedStorage:FindFirstChild("ImportedAssets")
	if not importedAssets then
		return nil
	end

	local template = importedAssets:FindFirstChild("MilitarySoldier")
	if template and template:IsA("Model") then
		return template
	end

	return nil
end

local function styleMeshPart(part: BasePart)
	local name = string.lower(part.Name)

	for token, style in MATERIAL_STYLES do
		if string.find(name, token, 1, true) then
			part.Color = style[1]
			part.Material = style[2]

			if token == "glass" then
				part.Transparency = math.max(part.Transparency, 0.28)
			end

			return
		end
	end

	part.Color = Color3.fromRGB(78, 82, 79)
	part.Material = Enum.Material.SmoothPlastic
end

local function bonesMatching(model: Model, token: string): {Bone}
	local result = {}
	local tokenLower = string.lower(token)

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Bone")
			and string.find(string.lower(descendant.Name), tokenLower, 1, true) then
			table.insert(result, descendant)
		end
	end

	return result
end

local function captureBaseTransforms(model: Model): {[Bone]: CFrame}
	local transforms = {}

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Bone") then
			transforms[descendant] = descendant.Transform
		end
	end

	return transforms
end

local function applyOffset(
	bones: {Bone},
	baseTransforms: {[Bone]: CFrame},
	offset: CFrame
)
	for _, bone in bones do
		local base = baseTransforms[bone]
		if base and bone.Parent then
			bone.Transform = base * offset
		end
	end
end

local function applyRelaxedPose(model: Model)
	local baseTransforms = captureBaseTransforms(model)

	applyOffset(
		bonesMatching(model, "leftarm_"),
		baseTransforms,
		CFrame.Angles(math.rad(-3), math.rad(4), math.rad(67))
	)
	applyOffset(
		bonesMatching(model, "rightarm_"),
		baseTransforms,
		CFrame.Angles(math.rad(-3), math.rad(-4), math.rad(-67))
	)
	applyOffset(
		bonesMatching(model, "leftforearm_"),
		baseTransforms,
		CFrame.Angles(math.rad(-8), math.rad(-8), math.rad(8))
	)
	applyOffset(
		bonesMatching(model, "rightforearm_"),
		baseTransforms,
		CFrame.Angles(math.rad(-8), math.rad(8), math.rad(-8))
	)
end

local function hideNativeCharacter(character: Model, importedVisual: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsDescendantOf(importedVisual) then
			continue
		end

		if descendant:IsA("BasePart") then
			if descendant.Name ~= "HumanoidRootPart"
				and not descendant:FindFirstAncestorOfClass("Tool") then
				descendant.Transparency = 1
				descendant.CastShadow = false
			end
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = 1
		end
	end

	for _, child in character:GetChildren() do
		if child:IsA("Accessory") then
			child:Destroy()
		end
	end

	local cosmetics = character:FindFirstChild("OperatorCosmetics")
	if cosmetics then
		cosmetics:Destroy()
	end
end

local function attachImportedOperator(character: Model, template: Model): boolean
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		root = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
	end

	if not root then
		return false
	end

	local existing = character:FindFirstChild("ImportedOperatorVisual")
	if existing then
		existing:Destroy()
	end

	local visual = template:Clone()
	visual.Name = "ImportedOperatorVisual"
	visual.Parent = character

	for _, descendant in visual:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.CastShadow = false
			descendant.Massless = true
			styleMeshPart(descendant)
		elseif descendant:IsA("Script")
			or descendant:IsA("LocalScript")
			or descendant:IsA("ModuleScript")
			or descendant:IsA("Sound")
			or descendant:IsA("Humanoid")
			or descendant:IsA("AnimationController") then
			descendant:Destroy()
		end
	end

	local _, initialSize = visual:GetBoundingBox()
	if initialSize.Y > 0.001 then
		visual:ScaleTo(visual:GetScale() * (TARGET_HEIGHT / initialSize.Y))
	end

	local pivot = visual:GetPivot()
	local boxCFrame = visual:GetBoundingBox()
	local boxRelativeToPivot = pivot:ToObjectSpace(boxCFrame)
	local desiredBoxCFrame = root.CFrame * CFrame.new(0, -0.05, 0)
	local desiredPivot = desiredBoxCFrame * boxRelativeToPivot:Inverse()
	visual:PivotTo(desiredPivot)

	applyRelaxedPose(visual)

	for _, descendant in visual:GetDescendants() do
		if descendant:IsA("BasePart") then
			local weld = Instance.new("WeldConstraint")
			weld.Name = "ImportedOperatorWeld"
			weld.Part0 = root
			weld.Part1 = descendant
			weld.Parent = descendant
			descendant.Anchored = false
		end
	end

	hideNativeCharacter(character, visual)
	character:SetAttribute("UsingImportedOperator", true)

	return true
end

local function applyOperator(character: Model)
	if not character.Parent then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		humanoid = character:WaitForChild("Humanoid", 5) :: Humanoid?
	end

	if not humanoid then
		return
	end

	normalizeScales(humanoid)
	task.wait(0.08)

	local importedTemplate = getImportedTemplate()
	if importedTemplate and character.Parent then
		local ok, attached = pcall(attachImportedOperator, character, importedTemplate)
		if ok and attached then
			return
		end

		warn("BODYCAM: failed to attach MilitarySoldier, using procedural operator")
	end

	character:SetAttribute("UsingImportedOperator", false)

	if character.Parent then
		OperatorAppearance.ApplyToCharacter(character)
	end
end

local function bindPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		task.delay(0.8, function()
			if character.Parent then
				applyOperator(character)
			end
		end)
	end)

	player.CharacterAppearanceLoaded:Connect(function(character)
		task.delay(0.1, function()
			if character.Parent then
				applyOperator(character)
			end
		end)
	end)

	if player.Character then
		task.defer(applyOperator, player.Character)
	end
end

for _, player in Players:GetPlayers() do
	bindPlayer(player)
end

Players.PlayerAdded:Connect(bindPlayer)
