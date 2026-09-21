local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OperatorAppearance = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("OperatorAppearance")
)

local OperatorPreview = {}

local TARGET_HEIGHT = 5.8

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

local function findHeadBone(model: Model): Bone?
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Bone") then
			local name = string.lower(descendant.Name)
			if string.find(name, "head", 1, true)
				and not string.find(name, "headtop", 1, true)
				and not string.find(name, "_end", 1, true) then
				return descendant
			end
		end
	end

	return nil
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

	local headBone = findHeadBone(model)
	local baseHeadTransform = headBone and headBone.Transform or CFrame.identity

	local result = {
		Model = model,
		IsImported = true,
		Height = size.Y,
	}

	function result:SetLook(pitch: number, yaw: number)
		if not headBone or not headBone.Parent then
			return
		end

		-- Mixamo head bones generally use local axes compatible with this small look offset.
		headBone.Transform = baseHeadTransform
			* CFrame.Angles(pitch, yaw, 0)
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
