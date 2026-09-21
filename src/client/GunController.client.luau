local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local fireRemote = ReplicatedStorage:WaitForChild("BodycamRemotes"):WaitForChild("FireWeapon")

local ammo = Config.Weapon.MagazineSize
local reserve = Config.Weapon.ReserveAmmo
local equippedTool: Tool? = nil
local ready = true
local reloading = false
local connectedTools: {[Tool]: boolean} = {}

local function updateToolName()
	if equippedTool then
		equippedTool.Name = string.format(
			"%s [%d/%d]",
			Config.Weapon.Name,
			ammo,
			reserve
		)
	end
end

local function recoil()
	local camera = workspace.CurrentCamera
	if camera then
		camera.CFrame *= CFrame.Angles(
			math.rad(-1.8),
			math.rad((math.random() - 0.5) * 0.8),
			0
		)
	end
end

local function reload()
	if not equippedTool or reloading or ammo >= Config.Weapon.MagazineSize or reserve <= 0 then
		return
	end

	reloading = true
	ready = false
	task.wait(Config.Weapon.ReloadTime)

	if not equippedTool then
		reloading = false
		ready = true
		return
	end

	local needed = Config.Weapon.MagazineSize - ammo
	local loaded = math.min(needed, reserve)

	ammo += loaded
	reserve -= loaded
	reloading = false
	ready = true
	updateToolName()
end

local function connectTool(tool: Tool)
	if connectedTools[tool] then
		return
	end

	if tool.Name ~= Config.Weapon.Name and not string.match(tool.Name, "^" .. Config.Weapon.Name) then
		return
	end

	connectedTools[tool] = true

	tool.Equipped:Connect(function()
		equippedTool = tool
		updateToolName()
	end)

	tool.Unequipped:Connect(function()
		if equippedTool == tool then
			equippedTool = nil
		end
	end)

	tool.Activated:Connect(function()
		if equippedTool ~= tool or not ready or reloading then
			return
		end

		if ammo <= 0 then
			task.spawn(reload)
			return
		end

		local camera = workspace.CurrentCamera
		if not camera then
			return
		end

		ready = false
		ammo -= 1
		updateToolName()

		fireRemote:FireServer(camera.CFrame.Position, camera.CFrame.LookVector)
		recoil()

		task.delay(Config.Weapon.FireDelay, function()
			if not reloading then
				ready = true
			end
		end)
	end)
end

local function watch(container: Instance)
	for _, child in container:GetChildren() do
		if child:IsA("Tool") then
			connectTool(child)
		end
	end

	container.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			connectTool(child)
		end
	end)
end

watch(player:WaitForChild("Backpack"))

player.CharacterAdded:Connect(function(character)
	watch(character)
end)

if player.Character then
	watch(player.Character)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not equippedTool then
		return
	end

	if input.KeyCode == Enum.KeyCode.R then
		task.spawn(reload)
	end
end)
