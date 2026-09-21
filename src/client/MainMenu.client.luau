local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Shared")
local OperatorAppearance = require(shared:WaitForChild("OperatorAppearance"))

local startCampaign = ReplicatedStorage
	:WaitForChild("BodycamRemotes")
	:WaitForChild("StartCampaign")

if player:GetAttribute("CampaignStarted") == true then
	return
end

local WHITE = Color3.fromRGB(255, 255, 255)
local SOFT_WHITE = Color3.fromRGB(224, 228, 231)
local MUTED = Color3.fromRGB(168, 175, 181)
local PANEL = Color3.fromRGB(19, 22, 24)
local BORDER = Color3.fromRGB(193, 200, 205)

local selectedMap = "COMPLEX_01"
local selectionLocked = false
local renderConnection: RBXScriptConnection?

local function setCoreGui(enabled: boolean)
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, enabled)
	end)
end

setCoreGui(false)
player.CameraMode = Enum.CameraMode.Classic
UserInputService.MouseIconEnabled = true

local function sinkMovement()
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindActionAtPriority(
	"BodycamMenuMovementLock",
	sinkMovement,
	false,
	Enum.ContextActionPriority.High.Value,
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Space,
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.LeftControl,
	Enum.KeyCode.C
)

local gui = Instance.new("ScreenGui")
gui.Name = "MainMenu"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local canvas = Instance.new("CanvasGroup")
canvas.Name = "Canvas"
canvas.Size = UDim2.fromScale(1, 1)
canvas.BackgroundColor3 = Color3.fromRGB(46, 51, 54)
canvas.BorderSizePixel = 0
canvas.Parent = gui

local operatorView = Instance.new("ViewportFrame")
operatorView.Name = "OperatorView"
operatorView.AnchorPoint = Vector2.new(1, 0)
operatorView.Position = UDim2.fromScale(1, 0)
operatorView.Size = UDim2.new(0.7, 0, 1, 0)
operatorView.BackgroundColor3 = Color3.fromRGB(74, 80, 83)
operatorView.BackgroundTransparency = 0
operatorView.BorderSizePixel = 0
operatorView.Ambient = Color3.fromRGB(205, 209, 210)
operatorView.LightColor = Color3.fromRGB(255, 248, 234)
operatorView.LightDirection = Vector3.new(-0.65, -0.8, -0.4)
operatorView.Parent = canvas

local worldModel = Instance.new("WorldModel")
worldModel.Name = "OperatorWorld"
worldModel.Parent = operatorView

local preview = OperatorAppearance.BuildPreview(worldModel)

local previewFloor = Instance.new("Part")
previewFloor.Name = "Floor"
previewFloor.Size = Vector3.new(24, 0.25, 24)
previewFloor.Position = Vector3.new(0, -0.12, 0)
previewFloor.Anchored = true
previewFloor.CanCollide = false
previewFloor.Color = Color3.fromRGB(47, 51, 53)
previewFloor.Material = Enum.Material.Concrete
previewFloor.Parent = worldModel

local previewCamera = Instance.new("Camera")
previewCamera.Name = "OperatorCamera"
previewCamera.FieldOfView = 38
previewCamera.Parent = operatorView
operatorView.CurrentCamera = previewCamera

local topLight = Instance.new("Part")
topLight.Name = "LightPanel"
topLight.Size = Vector3.new(8, 0.15, 3)
topLight.Position = Vector3.new(0, 7.5, -1.5)
topLight.Anchored = true
topLight.CanCollide = false
topLight.Color = Color3.fromRGB(238, 241, 241)
topLight.Material = Enum.Material.Neon
topLight.Parent = worldModel

local leftShade = Instance.new("Frame")
leftShade.Name = "LeftShade"
leftShade.Size = UDim2.fromScale(1, 1)
leftShade.BackgroundColor3 = Color3.fromRGB(10, 12, 13)
leftShade.BackgroundTransparency = 0.1
leftShade.BorderSizePixel = 0
leftShade.Parent = canvas

local shadeGradient = Instance.new("UIGradient")
shadeGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
shadeGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.02),
	NumberSequenceKeypoint.new(0.42, 0.12),
	NumberSequenceKeypoint.new(0.68, 0.62),
	NumberSequenceKeypoint.new(1, 1),
})
shadeGradient.Parent = leftShade

local content = Instance.new("Frame")
content.Name = "Content"
content.AnchorPoint = Vector2.new(0, 0.5)
content.Position = UDim2.new(0, 64, 0.5, 0)
content.Size = UDim2.new(0, 610, 0, 610)
content.BackgroundTransparency = 1
content.Parent = canvas

local eyebrow = Instance.new("TextLabel")
eyebrow.BackgroundTransparency = 1
eyebrow.Size = UDim2.new(1, 0, 0, 28)
eyebrow.Font = Enum.Font.RobotoMono
eyebrow.Text = "TACTICAL RESPONSE // CAMPAIGN"
eyebrow.TextColor3 = SOFT_WHITE
eyebrow.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
eyebrow.TextStrokeTransparency = 0.5
eyebrow.TextSize = 14
eyebrow.TextXAlignment = Enum.TextXAlignment.Left
eyebrow.Parent = content

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 30)
title.Size = UDim2.new(1, 0, 0, 98)
title.Font = Enum.Font.GothamBlack
title.Text = "BODYCAM"
title.TextColor3 = WHITE
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.TextStrokeTransparency = 0.28
title.TextSize = 76
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = content

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(2, 140)
divider.Size = UDim2.fromOffset(92, 3)
divider.BackgroundColor3 = WHITE
divider.BorderSizePixel = 0
divider.Parent = content

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.fromOffset(0, 160)
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Font = Enum.Font.RobotoMono
sub.Text = "SELECIONE UM MODO"
sub.TextColor3 = WHITE
sub.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
sub.TextStrokeTransparency = 0.42
sub.TextSize = 15
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = content

local menuArea = Instance.new("Frame")
menuArea.Name = "MenuArea"
menuArea.Position = UDim2.fromOffset(0, 215)
menuArea.Size = UDim2.new(1, 0, 0, 340)
menuArea.BackgroundTransparency = 1
menuArea.Parent = content

local function styleButton(button: TextButton, strong: boolean?)
	button.AutoButtonColor = false
	button.BackgroundColor3 = strong and Color3.fromRGB(244, 246, 247) or PANEL
	button.BackgroundTransparency = strong and 0.08 or 0.18
	button.BorderSizePixel = 0
	button.TextColor3 = strong and Color3.fromRGB(16, 18, 19) or WHITE

	local stroke = Instance.new("UIStroke")
	stroke.Color = strong and WHITE or BORDER
	stroke.Transparency = strong and 0.18 or 0.38
	stroke.Thickness = 1
	stroke.Parent = button

	button.MouseEnter:Connect(function()
		if selectionLocked then
			return
		end

		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundTransparency = strong and 0 or 0.04,
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Transparency = 0.05,
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		if selectionLocked then
			return
		end

		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundTransparency = strong and 0.08 or 0.18,
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Transparency = strong and 0.18 or 0.38,
		}):Play()
	end)
end

local campaignButton = Instance.new("TextButton")
campaignButton.Name = "Campaign"
campaignButton.Size = UDim2.fromOffset(450, 72)
campaignButton.Font = Enum.Font.GothamBold
campaignButton.Text = "   CAMPANHA"
campaignButton.TextSize = 22
campaignButton.TextXAlignment = Enum.TextXAlignment.Left
campaignButton.Parent = menuArea
styleButton(campaignButton, true)

local campaignMarker = Instance.new("Frame")
campaignMarker.Size = UDim2.new(0, 4, 1, 0)
campaignMarker.BackgroundColor3 = Color3.fromRGB(17, 18, 19)
campaignMarker.BorderSizePixel = 0
campaignMarker.Parent = campaignButton

local mapPanel = Instance.new("Frame")
mapPanel.Name = "MapPanel"
mapPanel.Size = UDim2.fromScale(1, 1)
mapPanel.BackgroundTransparency = 1
mapPanel.Visible = false
mapPanel.Parent = menuArea

local mapTitle = Instance.new("TextLabel")
mapTitle.BackgroundTransparency = 1
mapTitle.Size = UDim2.new(1, 0, 0, 30)
mapTitle.Font = Enum.Font.RobotoMono
mapTitle.Text = "MAPAS DISPONÍVEIS"
mapTitle.TextColor3 = WHITE
mapTitle.TextSize = 14
mapTitle.TextXAlignment = Enum.TextXAlignment.Left
mapTitle.Parent = mapPanel

local mapButton = Instance.new("TextButton")
mapButton.Name = "COMPLEX_01"
mapButton.Position = UDim2.fromOffset(0, 48)
mapButton.Size = UDim2.fromOffset(525, 118)
mapButton.Font = Enum.Font.GothamBold
mapButton.Text = "   COMPLEXO INDUSTRIAL"
mapButton.TextSize = 21
mapButton.TextXAlignment = Enum.TextXAlignment.Left
mapButton.Parent = mapPanel
styleButton(mapButton, false)

local mapCode = Instance.new("TextLabel")
mapCode.AnchorPoint = Vector2.new(1, 0)
mapCode.Position = UDim2.new(1, -18, 0, 17)
mapCode.Size = UDim2.fromOffset(210, 24)
mapCode.BackgroundTransparency = 1
mapCode.Font = Enum.Font.RobotoMono
mapCode.Text = "SETOR 01 // DISPONÍVEL"
mapCode.TextColor3 = SOFT_WHITE
mapCode.TextSize = 11
mapCode.TextXAlignment = Enum.TextXAlignment.Right
mapCode.Parent = mapButton

local mapDesc = Instance.new("TextLabel")
mapDesc.Position = UDim2.fromOffset(18, 69)
mapDesc.Size = UDim2.new(1, -36, 0, 30)
mapDesc.BackgroundTransparency = 1
mapDesc.Font = Enum.Font.RobotoMono
mapDesc.Text = "ÁREA DE PREPARAÇÃO + COMPLEXO DE TESTE"
mapDesc.TextColor3 = MUTED
mapDesc.TextSize = 11
mapDesc.TextXAlignment = Enum.TextXAlignment.Left
mapDesc.Parent = mapButton

local mapBack = Instance.new("TextButton")
mapBack.Position = UDim2.fromOffset(0, 205)
mapBack.Size = UDim2.fromOffset(130, 32)
mapBack.BackgroundTransparency = 1
mapBack.Font = Enum.Font.RobotoMono
mapBack.Text = "< VOLTAR"
mapBack.TextColor3 = WHITE
mapBack.TextSize = 13
mapBack.TextXAlignment = Enum.TextXAlignment.Left
mapBack.Parent = mapPanel

local difficultyPanel = Instance.new("Frame")
difficultyPanel.Name = "DifficultyPanel"
difficultyPanel.Size = UDim2.fromScale(1, 1)
difficultyPanel.BackgroundTransparency = 1
difficultyPanel.Visible = false
difficultyPanel.Parent = menuArea

local difficultyTitle = Instance.new("TextLabel")
difficultyTitle.BackgroundTransparency = 1
difficultyTitle.Size = UDim2.new(1, 0, 0, 30)
difficultyTitle.Font = Enum.Font.RobotoMono
difficultyTitle.Text = "DIFICULDADE // COMPLEXO INDUSTRIAL"
difficultyTitle.TextColor3 = WHITE
difficultyTitle.TextSize = 14
difficultyTitle.TextXAlignment = Enum.TextXAlignment.Left
difficultyTitle.Parent = difficultyPanel

local choices = Instance.new("Frame")
choices.Position = UDim2.fromOffset(0, 48)
choices.Size = UDim2.new(1, 0, 0, 205)
choices.BackgroundTransparency = 1
choices.Parent = difficultyPanel

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10)
list.FillDirection = Enum.FillDirection.Vertical
list.Parent = choices

local difficultyButtons: {TextButton} = {}

local function makeDifficulty(label: string, code: string, description: string)
	local button = Instance.new("TextButton")
	button.Name = code
	button.Size = UDim2.fromOffset(525, 58)
	button.Font = Enum.Font.GothamBold
	button.Text = "   " .. label
	button.TextSize = 18
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = choices
	styleButton(button, false)

	local desc = Instance.new("TextLabel")
	desc.AnchorPoint = Vector2.new(1, 0.5)
	desc.Position = UDim2.new(1, -17, 0.5, 0)
	desc.Size = UDim2.fromOffset(310, 30)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.RobotoMono
	desc.Text = description
	desc.TextColor3 = SOFT_WHITE
	desc.TextSize = 11
	desc.TextXAlignment = Enum.TextXAlignment.Right
	desc.Parent = button

	table.insert(difficultyButtons, button)
	return button
end

local easy = makeDifficulty("FÁCIL", "EASY", "FOCO NA HISTÓRIA")
local normal = makeDifficulty("NORMAL", "NORMAL", "EXPERIÊNCIA PADRÃO")
local hard = makeDifficulty("DIFÍCIL", "HARD", "MENOS MARGEM PARA ERRO")

local difficultyBack = Instance.new("TextButton")
difficultyBack.Position = UDim2.fromOffset(0, 264)
difficultyBack.Size = UDim2.fromOffset(130, 32)
difficultyBack.BackgroundTransparency = 1
difficultyBack.Font = Enum.Font.RobotoMono
difficultyBack.Text = "< VOLTAR"
difficultyBack.TextColor3 = WHITE
difficultyBack.TextSize = 13
difficultyBack.TextXAlignment = Enum.TextXAlignment.Left
difficultyBack.Parent = difficultyPanel

local footer = Instance.new("TextLabel")
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, 64, 1, -28)
footer.Size = UDim2.new(0, 620, 0, 22)
footer.BackgroundTransparency = 1
footer.Font = Enum.Font.RobotoMono
footer.Text = "BODYCAM // PROTOTYPE BUILD"
footer.TextColor3 = SOFT_WHITE
footer.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
footer.TextStrokeTransparency = 0.55
footer.TextSize = 11
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = canvas

local status = Instance.new("TextLabel")
status.AnchorPoint = Vector2.new(1, 1)
status.Position = UDim2.new(1, -34, 1, -28)
status.Size = UDim2.fromOffset(480, 22)
status.BackgroundTransparency = 1
status.Font = Enum.Font.RobotoMono
status.Text = "OPERATOR READY // SYSTEM ONLINE"
status.TextColor3 = WHITE
status.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
status.TextStrokeTransparency = 0.5
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Right
status.Parent = canvas

local orbitAngle = math.pi + 0.28
local previewAccumulator = 0
local baseHeadOffset = preview.Torso.CFrame:ToObjectSpace(preview.Head.CFrame)

renderConnection = RunService.RenderStepped:Connect(function(dt)
	previewAccumulator += dt
	if previewAccumulator < (1 / 30) then
		return
	end

	local step = previewAccumulator
	previewAccumulator = 0
	orbitAngle += step * math.rad(2.4)

	local focus = Vector3.new(0, 2.85, 0)
	local radius = 8.4
	local cameraPosition = Vector3.new(
		math.sin(orbitAngle) * radius,
		3.55,
		math.cos(orbitAngle) * radius
	)

	previewCamera.CFrame = CFrame.lookAt(cameraPosition, focus + Vector3.new(0, 0.25, 0))

	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local mouse = UserInputService:GetMouseLocation()

	local nx = math.clamp(((mouse.X / math.max(viewportSize.X, 1)) - 0.5) * 2, -1, 1)
	local ny = math.clamp(((mouse.Y / math.max(viewportSize.Y, 1)) - 0.5) * 2, -1, 1)

	local yaw = math.rad(-22 * nx)
	local pitch = math.rad(-10 * ny)

	preview.Head.CFrame = preview.Torso.CFrame
		* CFrame.new(baseHeadOffset.Position)
		* CFrame.Angles(pitch, yaw, 0)
end)

local function showModes()
	mapPanel.Visible = false
	difficultyPanel.Visible = false
	campaignButton.Visible = true
	sub.Text = "SELECIONE UM MODO"
end

local function showMaps()
	campaignButton.Visible = false
	difficultyPanel.Visible = false
	mapPanel.Visible = true
	sub.Text = "CAMPANHA // SELEÇÃO DE MAPA"
end

local function showDifficulty()
	campaignButton.Visible = false
	mapPanel.Visible = false
	difficultyPanel.Visible = true
	sub.Text = "CAMPANHA // " .. selectedMap
end

local function closeMenu()
	ContextActionService:UnbindAction("BodycamMenuMovementLock")
	setCoreGui(true)

	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	local fade = TweenService:Create(
		canvas,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad),
		{GroupTransparency = 1}
	)
	fade:Play()
	fade.Completed:Wait()

	gui:Destroy()
end

local function chooseDifficulty(code: string)
	if selectionLocked then
		return
	end

	selectionLocked = true
	for _, button in difficultyButtons do
		button.Active = false
	end
	difficultyBack.Active = false

	status.Text = "CARREGANDO // " .. selectedMap .. " // " .. code
	startCampaign:FireServer(selectedMap, code)

	local startedAt = os.clock()
	while player:GetAttribute("CampaignStarted") ~= true and os.clock() - startedAt < 4 do
		task.wait()
	end

	if player:GetAttribute("CampaignStarted") ~= true then
		status.Text = "FALHA AO INICIAR // TENTE NOVAMENTE"
		selectionLocked = false
		for _, button in difficultyButtons do
			button.Active = true
		end
		difficultyBack.Active = true
		return
	end

	status.Text = "OPERAÇÃO INICIADA"
	closeMenu()
end

campaignButton.Activated:Connect(showMaps)

mapButton.Activated:Connect(function()
	selectedMap = "COMPLEX_01"
	showDifficulty()
end)

mapBack.Activated:Connect(showModes)
difficultyBack.Activated:Connect(showMaps)

easy.Activated:Connect(function()
	chooseDifficulty("EASY")
end)

normal.Activated:Connect(function()
	chooseDifficulty("NORMAL")
end)

hard.Activated:Connect(function()
	chooseDifficulty("HARD")
end)
