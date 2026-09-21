local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local startCampaign = ReplicatedStorage
	:WaitForChild("BodycamRemotes")
	:WaitForChild("StartCampaign")

local validDifficulties = {
	EASY = true,
	NORMAL = true,
	HARD = true,
}

local function setupPlayer(player: Player)
	if player:GetAttribute("CampaignStarted") == nil then
		player:SetAttribute("CampaignStarted", false)
	end

	if player:GetAttribute("CampaignDifficulty") == nil then
		player:SetAttribute("CampaignDifficulty", "NONE")
	end
end

for _, player in Players:GetPlayers() do
	setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

startCampaign.OnServerEvent:Connect(function(player: Player, difficulty: string)
	if player:GetAttribute("CampaignStarted") == true then
		return
	end

	if typeof(difficulty) ~= "string" or not validDifficulties[difficulty] then
		return
	end

	player:SetAttribute("CampaignDifficulty", difficulty)
	player:SetAttribute("CampaignStarted", true)
end)
