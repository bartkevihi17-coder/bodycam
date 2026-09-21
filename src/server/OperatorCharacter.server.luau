local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OperatorAppearance = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("OperatorAppearance")
)

local SCALE_VALUES = {
	BodyHeightScale = 1,
	BodyWidthScale = 1,
	BodyDepthScale = 1,
	HeadScale = 1,
	BodyTypeScale = 0,
	BodyProportionScale = 0,
}

local function normalizeScales(humanoid: Humanoid)
	for name, value in SCALE_VALUES do
		local scale = humanoid:FindFirstChild(name)
		if scale and scale:IsA("NumberValue") then
			scale.Value = value
		end
	end
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

	task.wait(0.05)

	if character.Parent then
		OperatorAppearance.ApplyToCharacter(character)
	end
end

local function bindPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		task.delay(0.8, function()
			if character.Parent and not character:FindFirstChild("OperatorCosmetics") then
				applyOperator(character)
			end
		end)
	end)

	player.CharacterAppearanceLoaded:Connect(function(character)
		applyOperator(character)
	end)

	if player.Character then
		task.defer(applyOperator, player.Character)
	end
end

for _, player in Players:GetPlayers() do
	bindPlayer(player)
end

Players.PlayerAdded:Connect(bindPlayer)
