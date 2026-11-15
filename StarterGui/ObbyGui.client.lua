-- ObbyGui -- cute client UI: top bar, stage display, reset button, messages.
-- Install: put this LocalScript in StarterGui and name it "ObbyGui".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ObbyRemotes")
local stageUpdate = remotes:WaitForChild("StageUpdate")
local showMessage = remotes:WaitForChild("ShowMessage")
local resetRequest = remotes:WaitForChild("ResetRequest")

local STAGE_COUNT = 15

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ObbyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Top bar: pastel pill with stage, wins and a reset button.
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(0, 420, 0, 56)
topBar.Position = UDim2.new(0.5, -210, 0, 12)
topBar.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 28)
topCorner.Parent = topBar

local topGradient = Instance.new("UIGradient")
topGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 235)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 230, 255)),
})
topGradient.Rotation = 90
topGradient.Parent = topBar

local topStroke = Instance.new("UIStroke")
topStroke.Color = Color3.fromRGB(255, 255, 255)
topStroke.Thickness = 2
topStroke.Parent = topBar

local stageLabel = Instance.new("TextLabel")
stageLabel.Name = "StageLabel"
stageLabel.Size = UDim2.new(0, 200, 1, 0)
stageLabel.Position = UDim2.new(0, 16, 0, 0)
stageLabel.BackgroundTransparency = 1
stageLabel.Text = "Stage 1 / 15"
stageLabel.Font = Enum.Font.FredokaOne
stageLabel.TextSize = 26
stageLabel.TextColor3 = Color3.fromRGB(90, 60, 120)
stageLabel.TextXAlignment = Enum.TextXAlignment.Left
stageLabel.Parent = topBar

local winsLabel = Instance.new("TextLabel")
winsLabel.Name = "WinsLabel"
winsLabel.Size = UDim2.new(0, 90, 1, 0)
winsLabel.Position = UDim2.new(0, 220, 0, 0)
winsLabel.BackgroundTransparency = 1
winsLabel.Text = "Wins: 0"
winsLabel.Font = Enum.Font.GothamBold
winsLabel.TextSize = 20
winsLabel.TextColor3 = Color3.fromRGB(90, 60, 120)
winsLabel.TextXAlignment = Enum.TextXAlignment.Left
winsLabel.Parent = topBar

local resetButton = Instance.new("TextButton")
resetButton.Name = "ResetButton"
resetButton.Size = UDim2.new(0, 84, 0, 40)
resetButton.Position = UDim2.new(1, -96, 0.5, -20)
resetButton.BackgroundColor3 = Color3.fromRGB(255, 150, 180)
resetButton.Text = "Reset"
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 18
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Parent = topBar

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 20)
resetCorner.Parent = resetButton

-- Center message label (checkpoint and win announcements).
local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(0, 600, 0, 80)
messageLabel.Position = UDim2.new(0.5, -300, 0, 90)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = ""
messageLabel.Font = Enum.Font.FredokaOne
messageLabel.TextSize = 44
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.TextStrokeTransparency = 0
messageLabel.TextStrokeColor3 = Color3.fromRGB(90, 60, 120)
messageLabel.Parent = screenGui

-- Win panel with a Play Again button.
local winFrame = Instance.new("Frame")
winFrame.Name = "WinFrame"
winFrame.Size = UDim2.new(0, 380, 0, 220)
winFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
winFrame.BackgroundColor3 = Color3.fromRGB(255, 245, 200)
winFrame.BorderSizePixel = 0
winFrame.Visible = false
winFrame.Parent = screenGui

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0, 24)
winCorner.Parent = winFrame

local winTitle = Instance.new("TextLabel")
winTitle.Size = UDim2.new(1, 0, 0, 70)
winTitle.Position = UDim2.new(0, 0, 0, 20)
winTitle.BackgroundTransparency = 1
winTitle.Text = "You Win!"
winTitle.Font = Enum.Font.FredokaOne
winTitle.TextSize = 48
winTitle.TextColor3 = Color3.fromRGB(230, 140, 40)
winTitle.Parent = winFrame

local winSub = Instance.new("TextLabel")
winSub.Size = UDim2.new(1, 0, 0, 30)
winSub.Position = UDim2.new(0, 0, 0, 95)
winSub.BackgroundTransparency = 1
winSub.Text = "You reached the top of the Rainbow Obby!"
winSub.Font = Enum.Font.GothamBold
winSub.TextSize = 16
winSub.TextColor3 = Color3.fromRGB(120, 90, 60)
winSub.Parent = winFrame

local playAgainButton = Instance.new("TextButton")
playAgainButton.Size = UDim2.new(0, 180, 0, 48)
playAgainButton.Position = UDim2.new(0.5, -90, 0, 145)
playAgainButton.BackgroundColor3 = Color3.fromRGB(120, 220, 130)
playAgainButton.Text = "Play Again"
playAgainButton.Font = Enum.Font.GothamBold
playAgainButton.TextSize = 20
playAgainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playAgainButton.Parent = winFrame

local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 24)
playCorner.Parent = playAgainButton

local messageToken = 0

local function showCenterMessage(text, kind)
	messageToken = messageToken + 1
	local token = messageToken
	messageLabel.Text = text
	messageLabel.TextTransparency = 0
	if kind == "win" then
		winFrame.Visible = true
	end
	task.delay(2.5, function()
		if token == messageToken then
			local tween = TweenService:Create(messageLabel, TweenInfo.new(0.5), {TextTransparency = 1})
			tween:Play()
		end
	end)
end

stageUpdate.OnClientEvent:Connect(function(stage, wins)
	stageLabel.Text = "Stage " .. tostring(stage) .. " / " .. tostring(STAGE_COUNT)
	winsLabel.Text = "Wins: " .. tostring(wins)
end)

showMessage.OnClientEvent:Connect(function(text, kind)
	showCenterMessage(text, kind)
end)

resetButton.MouseButton1Click:Connect(function()
	resetRequest:FireServer()
end)

playAgainButton.MouseButton1Click:Connect(function()
	winFrame.Visible = false
	resetRequest:FireServer()
end)
