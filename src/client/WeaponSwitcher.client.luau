local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local playerGui = player:WaitForChild("PlayerGui")

local tools: {Tool} = {}
local toolConnections: {[Tool]: {RBXScriptConnection}} = {}
local currentTool: Tool? = nil
local showGeneration = 0
local currentTween: Tween?

local keyToSlot = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
}

local function disableStockBackpack()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
end

disableStockBackpack()
task.spawn(function()
	for _ = 1, 8 do
		task.wait(0.5)
		disableStockBackpack()
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "WeaponSwitcher"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 460
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local panel = Instance.new("CanvasGroup")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, 300, 0.56, 0)
panel.Size = UDim2.fromOffset(270, 360)
panel.BackgroundTransparency = 1
panel.GroupTransparency = 1
panel.Parent = gui

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 25)
title.Font = Enum.Font.RobotoMono
title.Text = "LOADOUT"
title.TextColor3 = Color3.fromRGB(226, 230, 232)
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.TextStrokeTransparency = 0.42
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Right
title.Parent = panel

local line = Instance.new("Frame")
line.AnchorPoint = Vector2.new(1, 0)
line.Position = UDim2.new(1, 0, 0, 29)
line.Size = UDim2.fromOffset(54, 2)
line.BackgroundColor3 = Color3.fromRGB(242, 244, 245)
line.BorderSizePixel = 0
line.Parent = panel

local listFrame = Instance.new("Frame")
listFrame.Position = UDim2.fromOffset(0, 43)
listFrame.Size = UDim2.new(1, 0, 1, -43)
listFrame.BackgroundTransparency = 1
listFrame.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = listFrame

local function cleanToolName(tool: Tool): (string, string?)
	local weapon, ammo = string.match(tool.Name, "^(.-)%s*%[(.-)%]$")
	if weapon then
		return weapon, ammo
	end

	return tool.Name, nil
end

local function refreshRows()
	for _, child in listFrame:GetChildren() do
		if child ~= listLayout then
			child:Destroy()
		end
	end

	for index, tool in tools do
		local selected = tool == currentTool
		local weaponName, ammoText = cleanToolName(tool)

		local row = Instance.new("Frame")
		row.Name = "Slot_" .. tostring(index)
		row.Size = UDim2.fromOffset(selected and 254 or 232, 54)
		row.BackgroundColor3 = selected
			and Color3.fromRGB(235, 238, 239)
			or Color3.fromRGB(12, 14, 15)
		row.BackgroundTransparency = selected and 0.08 or 0.24
		row.BorderSizePixel = 0
		row.LayoutOrder = index
		row.Parent = listFrame

		local stroke = Instance.new("UIStroke")
		stroke.Color = selected
			and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(139, 146, 151)
		stroke.Transparency = selected and 0.1 or 0.55
		stroke.Thickness = 1
		stroke.Parent = row

		local slot = Instance.new("TextLabel")
		slot.Position = UDim2.fromOffset(13, 0)
		slot.Size = UDim2.fromOffset(36, 54)
		slot.BackgroundTransparency = 1
		slot.Font = Enum.Font.RobotoMono
		slot.Text = string.format("%02d", index)
		slot.TextColor3 = selected
			and Color3.fromRGB(17, 19, 20)
			or Color3.fromRGB(166, 171, 175)
		slot.TextSize = 12
		slot.TextXAlignment = Enum.TextXAlignment.Left
		slot.Parent = row

		local name = Instance.new("TextLabel")
		name.Position = UDim2.fromOffset(52, 0)
		name.Size = UDim2.new(1, -110, 1, 0)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBold
		name.Text = string.upper(weaponName)
		name.TextColor3 = selected
			and Color3.fromRGB(17, 19, 20)
			or Color3.fromRGB(244, 246, 247)
		name.TextSize = 15
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextTruncate = Enum.TextTruncate.AtEnd
		name.Parent = row

		if ammoText then
			local ammo = Instance.new("TextLabel")
			ammo.AnchorPoint = Vector2.new(1, 0)
			ammo.Position = UDim2.new(1, -13, 0, 0)
			ammo.Size = UDim2.fromOffset(62, 54)
			ammo.BackgroundTransparency = 1
			ammo.Font = Enum.Font.RobotoMono
			ammo.Text = ammoText
			ammo.TextColor3 = selected
				and Color3.fromRGB(45, 48, 49)
				or Color3.fromRGB(186, 191, 194)
			ammo.TextSize = 11
			ammo.TextXAlignment = Enum.TextXAlignment.Right
			ammo.Parent = row
		end

		if selected then
			local marker = Instance.new("Frame")
			marker.AnchorPoint = Vector2.new(1, 0)
			marker.Position = UDim2.fromScale(1, 0)
			marker.Size = UDim2.new(0, 4, 1, 0)
			marker.BackgroundColor3 = Color3.fromRGB(26, 28, 29)
			marker.BorderSizePixel = 0
			marker.Parent = row
		end
	end
end

local function showPanel()
	if player:GetAttribute("CampaignStarted") ~= true then
		return
	end

	showGeneration += 1
	local generation = showGeneration

	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end

	refreshRows()

	panel.GroupTransparency = 1
	panel.Position = UDim2.new(1, 300, 0.56, 0)

	currentTween = TweenService:Create(
		panel,
		TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			GroupTransparency = 0,
			Position = UDim2.new(1, -26, 0.56, 0),
		}
	)
	currentTween:Play()

	task.delay(1.65, function()
		if generation ~= showGeneration or not panel.Parent then
			return
		end

		currentTween = TweenService:Create(
			panel,
			TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				GroupTransparency = 1,
				Position = UDim2.new(1, 36, 0.56, 0),
			}
		)
		currentTween:Play()
	end)
end

local function disconnectTool(tool: Tool)
	local connections = toolConnections[tool]
	if not connections then
		return
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	toolConnections[tool] = nil
end

local function isOwnedTool(tool: Instance): boolean
	if not tool:IsA("Tool") then
		return false
	end

	local character = player.Character
	return tool.Parent == backpack or (character ~= nil and tool.Parent == character)
end

local function rebuildTools()
	local previous = {}
	for _, tool in tools do
		previous[tool] = true
	end

	local found: {Tool} = {}
	local seen: {[Tool]: boolean} = {}

	local function collect(container: Instance?)
		if not container then
			return
		end

		for _, child in container:GetChildren() do
			if child:IsA("Tool") and not seen[child] then
				seen[child] = true
				table.insert(found, child)
			end
		end
	end

	collect(backpack)
	collect(player.Character)

	for tool in previous do
		if not seen[tool] then
			disconnectTool(tool)
		end
	end

	table.sort(found, function(a, b)
		local aSlot = a:GetAttribute("Slot")
		local bSlot = b:GetAttribute("Slot")

		if typeof(aSlot) == "number" and typeof(bSlot) == "number" and aSlot ~= bSlot then
			return aSlot < bSlot
		end

		return cleanToolName(a) < cleanToolName(b)
	end)

	tools = found

	if currentTool and not seen[currentTool] then
		currentTool = nil
	end

	for _, tool in tools do
		if toolConnections[tool] then
			continue
		end

		toolConnections[tool] = {
			tool.Equipped:Connect(function()
				currentTool = tool
				showPanel()
			end),

			tool.Unequipped:Connect(function()
				if currentTool == tool then
					currentTool = nil
				end
				refreshRows()
			end),

			tool:GetPropertyChangedSignal("Name"):Connect(function()
				refreshRows()
			end),
		}
	end

	refreshRows()
end

local function equipSlot(index: number)
	if player:GetAttribute("CampaignStarted") ~= true then
		return
	end

	local tool = tools[index]
	if not tool then
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if tool.Parent == character then
		humanoid:UnequipTools()
		currentTool = nil
		showPanel()
		return
	end

	humanoid:EquipTool(tool)
	currentTool = tool
	showPanel()
end

local function cycleTool(direction: number)
	if #tools == 0 then
		return
	end

	local currentIndex = 0

	if currentTool then
		for index, tool in tools do
			if tool == currentTool then
				currentIndex = index
				break
			end
		end
	end

	local nextIndex
	if currentIndex == 0 then
		nextIndex = direction > 0 and 1 or #tools
	else
		nextIndex = ((currentIndex - 1 + direction) % #tools) + 1
	end

	equipSlot(nextIndex)
end

backpack.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		task.defer(rebuildTools)
	end
end)

backpack.ChildRemoved:Connect(function(child)
	if child:IsA("Tool") then
		task.defer(rebuildTools)
	end
end)

local function bindCharacter(character: Model)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.defer(rebuildTools)
		end
	end)

	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			task.defer(rebuildTools)
		end
	end)

	task.defer(rebuildTools)
end

player.CharacterAdded:Connect(bindCharacter)

if player.Character then
	bindCharacter(player.Character)
end

player:GetAttributeChangedSignal("CampaignStarted"):Connect(function()
	disableStockBackpack()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or player:GetAttribute("CampaignStarted") ~= true then
		return
	end

	local slot = keyToSlot[input.KeyCode]
	if slot then
		equipSlot(slot)
	end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed or player:GetAttribute("CampaignStarted") ~= true then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local direction = input.Position.Z > 0 and -1 or 1
		cycleTool(direction)
	end
end)

rebuildTools()
