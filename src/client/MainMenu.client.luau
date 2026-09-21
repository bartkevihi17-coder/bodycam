local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local startCampaign = ReplicatedStorage
	:WaitForChild("BodycamRemotes")
	:WaitForChild("StartCampaign")

if player:GetAttribute("CampaignStarted") == true then
	return
end

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

local blur = Lighting:FindFirstChild("BodycamMenuBlur") :: BlurEffect?
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "BodycamMenuBlur"
	blur.Size = 22
	blur.Parent = Lighting
else
	blur.Size = 22
end

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
canvas.BackgroundColor3 = Color3.fromRGB(5, 6, 7)
canvas.BackgroundTransparency = 0.08
canvas.BorderSizePixel = 0
canvas.Parent = gui

local gradient = Instance.new("UIGradient")
gradient.Rotation = 18
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 10, 12)),
	ColorSequenceKeypoint.new(0.55, Color3.fromRGB(12, 13, 14)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 3, 4)),
})
gradient.Parent = canvas

local scanline = Instance.new("Frame")
scanline.Name = "Scanline"
scanline.Size = UDim2.new(1, 0, 0, 1)
scanline.Position = UDim2.fromScale(0, 0.17)
scanline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scanline.BackgroundTransparency = 0.93
scanline.BorderSizePixel = 0
scanline.Parent = canvas

local content = Instance.new("Frame")
content.Name = "Content"
content.AnchorPoint = Vector2.new(0, 0.5)
content.Position = UDim2.new(0, 72, 0.5, 0)
content.Size = UDim2.new(0, 620, 0, 580)
content.BackgroundTransparency = 1
content.Parent = canvas

local eyebrow = Instance.new("TextLabel")
eyebrow.BackgroundTransparency = 1
eyebrow.Size = UDim2.new(1, 0, 0, 28)
eyebrow.Font = Enum.Font.RobotoMono
eyebrow.Text = "TACTICAL RESPONSE SYSTEM // DEV BUILD"
eyebrow.TextColor3 = Color3.fromRGB(145, 150, 154)
eyebrow.TextSize = 13
eyebrow.TextXAlignment = Enum.TextXAlignment.Left
eyebrow.Parent = content

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 34)
title.Size = UDim2.new(1, 0, 0, 95)
title.Font = Enum.Font.GothamBlack
title.Text = "BODYCAM"
title.TextColor3 = Color3.fromRGB(242, 243, 244)
title.TextSize = 72
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = content

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(3, 140)
divider.Size = UDim2.fromOffset(72, 2)
divider.BackgroundColor3 = Color3.fromRGB(222, 224, 226)
divider.BorderSizePixel = 0
divider.Parent = content

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.fromOffset(0, 154)
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Font = Enum.Font.RobotoMono
sub.Text = "SELECIONE UM MODO"
sub.TextColor3 = Color3.fromRGB(170, 174, 178)
sub.TextSize = 14
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = content

local menuArea = Instance.new("Frame")
menuArea.Name = "MenuArea"
menuArea.Position = UDim2.fromOffset(0, 215)
menuArea.Size = UDim2.new(1, 0, 0, 310)
menuArea.BackgroundTransparency = 1
menuArea.Parent = content

local function makeMainButton(text: string): TextButton
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.Size = UDim2.fromOffset(430, 68)
	button.BackgroundColor3 = Color3.fromRGB(225, 227, 229)
	button.BackgroundTransparency = 0.92
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.Text = "   " .. text
	button.TextColor3 = Color3.fromRGB(238, 239, 240)
	button.TextSize = 20
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = menuArea

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(200, 203, 206)
	stroke.Transparency = 0.72
	stroke.Thickness = 1
	stroke.Parent = button

	local marker = Instance.new("Frame")
	marker.Size = UDim2.new(0, 3, 1, 0)
	marker.BackgroundColor3 = Color3.fromRGB(240, 242, 244)
	marker.BorderSizePixel = 0
	marker.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundTransparency = 0.82,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Transparency = 0.35,
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundTransparency = 0.92,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Transparency = 0.72,
		}):Play()
	end)

	return button
end

local campaignButton = makeMainButton("CAMPANHA")

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
difficultyTitle.Text = "DIFICULDADE DA CAMPANHA"
difficultyTitle.TextColor3 = Color3.fromRGB(201, 204, 207)
difficultyTitle.TextSize = 14
difficultyTitle.TextXAlignment = Enum.TextXAlignment.Left
difficultyTitle.Parent = difficultyPanel

local choices = Instance.new("Frame")
choices.Position = UDim2.fromOffset(0, 48)
choices.Size = UDim2.new(1, 0, 0, 190)
choices.BackgroundTransparency = 1
choices.Parent = difficultyPanel

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10)
list.FillDirection = Enum.FillDirection.Vertical
list.Parent = choices

local difficultyButtons: {TextButton} = {}
local selectionLocked = false

local function makeDifficulty(label: string, code: string, description: string)
	local button = Instance.new("TextButton")
	button.Name = code
	button.AutoButtonColor = false
	button.Size = UDim2.fromOffset(520, 55)
	button.BackgroundColor3 = Color3.fromRGB(232, 234, 236)
	button.BackgroundTransparency = 0.94
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.Text = "   " .. label
	button.TextColor3 = Color3.fromRGB(238, 239, 240)
	button.TextSize = 17
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = choices

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(180, 184, 188)
	stroke.Transparency = 0.78
	stroke.Parent = button

	local desc = Instance.new("TextLabel")
	desc.AnchorPoint = Vector2.new(1, 0.5)
	desc.Position = UDim2.new(1, -16, 0.5, 0)
	desc.Size = UDim2.fromOffset(310, 30)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.RobotoMono
	desc.Text = description
	desc.TextColor3 = Color3.fromRGB(135, 140, 145)
	desc.TextSize = 11
	desc.TextXAlignment = Enum.TextXAlignment.Right
	desc.Parent = button

	button.MouseEnter:Connect(function()
		if selectionLocked then
			return
		end
		TweenService:Create(button, TweenInfo.new(0.1), {
			BackgroundTransparency = 0.84,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.1), {
			Transparency = 0.35,
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		if selectionLocked then
			return
		end
		TweenService:Create(button, TweenInfo.new(0.1), {
			BackgroundTransparency = 0.94,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.1), {
			Transparency = 0.78,
		}):Play()
	end)

	table.insert(difficultyButtons, button)
	return button
end

local easy = makeDifficulty("FÁCIL", "EASY", "PARA CONHECER A CAMPANHA")
local normal = makeDifficulty("NORMAL", "NORMAL", "EXPERIÊNCIA PADRÃO")
local hard = makeDifficulty("DIFÍCIL", "HARD", "MENOS MARGEM PARA ERRO")

local back = Instance.new("TextButton")
back.AutoButtonColor = false
back.Position = UDim2.fromOffset(0, 260)
back.Size = UDim2.fromOffset(120, 32)
back.BackgroundTransparency = 1
back.Font = Enum.Font.RobotoMono
back.Text = "< VOLTAR"
back.TextColor3 = Color3.fromRGB(145, 150, 154)
back.TextSize = 13
back.TextXAlignment = Enum.TextXAlignment.Left
back.Parent = difficultyPanel

local footer = Instance.new("TextLabel")
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, 72, 1, -34)
footer.Size = UDim2.new(0, 700, 0, 24)
footer.BackgroundTransparency = 1
footer.Font = Enum.Font.RobotoMono
footer.Text = "BODYCAM // CAMPAIGN PROTOTYPE"
footer.TextColor3 = Color3.fromRGB(94, 98, 102)
footer.TextSize = 11
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = canvas

local status = Instance.new("TextLabel")
status.AnchorPoint = Vector2.new(1, 1)
status.Position = UDim2.new(1, -42, 1, -34)
status.Size = UDim2.fromOffset(420, 24)
status.BackgroundTransparency = 1
status.Font = Enum.Font.RobotoMono
status.Text = "SYSTEM READY"
status.TextColor3 = Color3.fromRGB(105, 110, 114)
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Right
status.Parent = canvas

local function showDifficulty()
	campaignButton.Visible = false
	sub.Text = "CAMPANHA"
	difficultyPanel.Visible = true
end

local function showModes()
	difficultyPanel.Visible = false
	campaignButton.Visible = true
	sub.Text = "SELECIONE UM MODO"
end

local function closeMenu()
	ContextActionService:UnbindAction("BodycamMenuMovementLock")
	setCoreGui(true)

	local fade = TweenService:Create(canvas, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		GroupTransparency = 1,
	})
	local blurTween = TweenService:Create(blur, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		Size = 0,
	})

	fade:Play()
	blurTween:Play()
	fade.Completed:Wait()

	if blur and blur.Parent then
		blur:Destroy()
	end
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
	back.Active = false

	status.Text = "INICIANDO CAMPANHA // " .. code
	startCampaign:FireServer(code)

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
		back.Active = true
		return
	end

	status.Text = "CAMPANHA INICIADA"
	closeMenu()
end

campaignButton.Activated:Connect(showDifficulty)
back.Activated:Connect(showModes)

easy.Activated:Connect(function()
	chooseDifficulty("EASY")
end)

normal.Activated:Connect(function()
	chooseDifficulty("NORMAL")
end)

hard.Activated:Connect(function()
	chooseDifficulty("HARD")
end)
