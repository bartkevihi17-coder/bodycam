local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local fireRemote = ReplicatedStorage:WaitForChild("BodycamRemotes"):WaitForChild("FireWeapon")

local lastShot: {[Player]: number} = {}

local function hasEquippedWeapon(player: Player): boolean
	local character = player.Character
	if not character then
		return false
	end

	local tool = character:FindFirstChild(Config.Weapon.Name)
	return tool ~= nil and tool:IsA("Tool")
end

local function isValidShot(player: Player, origin: Vector3, direction: Vector3): boolean
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		return false
	end

	if not hasEquippedWeapon(player) then
		return false
	end

	local character = player.Character
	if not character then
		return false
	end

	local head = character:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then
		return false
	end

	if (origin - head.Position).Magnitude > 12 then
		return false
	end

	local magnitude = direction.Magnitude
	if magnitude < 0.95 or magnitude > 1.05 then
		return false
	end

	local now = os.clock()
	local previous = lastShot[player] or 0
	if now - previous < Config.Weapon.FireDelay * 0.8 then
		return false
	end

	lastShot[player] = now
	return true
end

fireRemote.OnServerEvent:Connect(function(player: Player, origin: Vector3, direction: Vector3)
	if not isValidShot(player, origin, direction) then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction.Unit * Config.Weapon.Range, raycastParams)
	if not result then
		return
	end

	local model = result.Instance:FindFirstAncestorOfClass("Model")
	if not model then
		return
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local damage = Config.Weapon.Damage
	if result.Instance.Name == "Head" then
		damage *= Config.Weapon.HeadshotMultiplier
	end

	humanoid:TakeDamage(damage)
end)

Players.PlayerRemoving:Connect(function(player)
	lastShot[player] = nil
end)
