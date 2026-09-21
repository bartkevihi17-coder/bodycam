local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OperatorAppearance = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("OperatorAppearance")
)

local OperatorPreview = {}

local TARGET_HEIGHT = 5.8

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

local function findImportedTemplate(): Model?
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

local function bonesMatching(model: Model, token: string, reject: string?): {Bone}
	local result = {}
	local tokenLower = string.lower(token)
	local rejectLower = reject and string.lower(reject) or nil

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Bone") then
			local name = string.lower(descendant.Name)

			if string.find(name, tokenLower, 1, true)
				and (not rejectLower or not string.find(name, rejectLower, 1, true)) then
				table.insert(result, descendant)
			end
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

local function applyToBones(
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

local function prepareImportedModel(template: Model, parent: Instance)
	local model = template:Clone()
	model.Name = "MenuMilitarySoldier"
	model.Parent = parent

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.CastShadow = false
			styleMeshPart(descendant)
		elseif descendant:IsA("Script")
			or descendant:IsA("LocalScript")
			or descendant:IsA("ModuleScript")
			or descendant:IsA("Sound") then
			descendant:Destroy()
		end
	end

	local _, initialSize = model:GetBoundingBox()
	if initialSize.Y > 0.001 then
		local scale = model:GetScale()
		model:ScaleTo(scale * (TARGET_HEIGHT / initialSize.Y))
	end

	local boxCFrame, size = model:GetBoundingBox()
	local offset = Vector3.new(
		-boxCFrame.Position.X,
		(size.Y * 0.5) - boxCFrame.Position.Y,
		-boxCFrame.Position.Z
	)

	model:PivotTo(model:GetPivot() + offset)

	local baseTransforms = captureBaseTransforms(model)

	local headBones = bonesMatching(model, "head_", "headtop")
	local neckBones = bonesMatching(model, "neck_")
	local leftArmBones = bonesMatching(model, "leftarm_")
	local rightArmBones = bonesMatching(model, "rightarm_")
	local leftForeArmBones = bonesMatching(model, "leftforearm_")
	local rightForeArmBones = bonesMatching(model, "rightforearm_")
	local leftHandBones = bonesMatching(model, "lefthand_")
	local rightHandBones = bonesMatching(model, "righthand_")
	local leftUpLegBones = bonesMatching(model, "leftupleg_")
	local rightUpLegBones = bonesMatching(model, "rightupleg_")

	-- Convert the bind/T pose into a relaxed operator stance.
	applyToBones(
		leftArmBones,
		baseTransforms,
		CFrame.Angles(math.rad(-3), math.rad(4), math.rad(67))
	)
	applyToBones(
		rightArmBones,
		baseTransforms,
		CFrame.Angles(math.rad(-3), math.rad(-4), math.rad(-67))
	)
	applyToBones(
		leftForeArmBones,
		baseTransforms,
		CFrame.Angles(math.rad(-8), math.rad(-8), math.rad(8))
	)
	applyToBones(
		rightForeArmBones,
		baseTransforms,
		CFrame.Angles(math.rad(-8), math.rad(8), math.rad(-8))
	)
	applyToBones(
		leftHandBones,
		baseTransforms,
		CFrame.Angles(0, math.rad(-4), math.rad(3))
	)
	applyToBones(
		rightHandBones,
		baseTransforms,
		CFrame.Angles(0, math.rad(4), math.rad(-3))
	)
	applyToBones(
		leftUpLegBones,
		baseTransforms,
		CFrame.Angles(0, 0, math.rad(-2))
	)
	applyToBones(
		rightUpLegBones,
		baseTransforms,
		CFrame.Angles(0, 0, math.rad(2))
	)

	local result = {
		Model = model,
		IsImported = true,
		Height = size.Y,
	}

	function result:SetLook(pitch: number, yaw: number)
		applyToBones(
			neckBones,
			baseTransforms,
			CFrame.Angles(pitch * 0.38, yaw * 0.38, 0)
		)

		applyToBones(
			headBones,
			baseTransforms,
			CFrame.Angles(pitch * 0.72, yaw * 0.72, 0)
		)
	end

	return result
end

local function prepareProcedural(parent: Instance)
	local preview = OperatorAppearance.BuildPreview(parent)
	local baseHeadOffset = preview.Torso.CFrame:ToObjectSpace(preview.Head.CFrame)

	local result = {
		Model = preview.Model,
		IsImported = false,
		Height = 5.8,
	}

	function result:SetLook(pitch: number, yaw: number)
		if not preview.Head.Parent or not preview.Torso.Parent then
			return
		end

		preview.Head.CFrame = preview.Torso.CFrame
			* CFrame.new(baseHeadOffset.Position)
			* CFrame.Angles(pitch, yaw, 0)
	end

	return result
end

function OperatorPreview.Build(parent: Instance)
	local imported = findImportedTemplate()
	if imported then
		local ok, preview = pcall(prepareImportedModel, imported, parent)
		if ok and preview then
			return preview
		end

		warn("BODYCAM: imported MilitarySoldier preview failed, using procedural fallback")
	end

	return prepareProcedural(parent)
end

function OperatorPreview.HasImportedOperator(): boolean
	return findImportedTemplate() ~= nil
end

return OperatorPreview
