-- ObbyServer -- checkpoints, kills, wins, leaderboard and obstacle animation.
-- Install: put this Script in ServerScriptService and name it "ObbyServer".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ObbyConfig = require(ReplicatedStorage:WaitForChild("ObbyConfig"))
local BuildObby = require(script.Parent:WaitForChild("BuildObby"))

local world = BuildObby.Build()

-- Remote events (the server creates them, the client waits for them).
local remotes = Instance.new("Folder")
remotes.Name = "ObbyRemotes"
remotes.Parent = ReplicatedStorage

local stageUpdate = Instance.new("RemoteEvent")
stageUpdate.Name = "StageUpdate"
stageUpdate.Parent = remotes

local showMessage = Instance.new("RemoteEvent")
showMessage.Name = "ShowMessage"
showMessage.Parent = remotes

local resetRequest = Instance.new("RemoteEvent")
resetRequest.Name = "ResetRequest"
resetRequest.Parent = remotes

local playerStage = {}
local playerWins = {}
local lastCheckpointTime = {}
local lastKillTime = {}
local lastWinTime = {}

local function checkpointPosition(stageNum)
	local stage = world.Stages[stageNum]
	return stage.Center + Vector3.new(0, stage.TopY + ObbyConfig.RespawnHeight, 0)
end

local function teleportToCheckpoint(player)
	local stageNum = playerStage[player] or 1
	local character = player.Character
	if not character then
		return
	end
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if root then
		root.CFrame = CFrame.new(checkpointPosition(stageNum))
	end
end

local function setStage(player, stageNum, silent)
	if stageNum < 1 then
		stageNum = 1
	end
	if stageNum > ObbyConfig.StageCount then
		stageNum = ObbyConfig.StageCount
	end
	local oldStage = playerStage[player] or 1
	playerStage[player] = stageNum
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local stageValue = leaderstats:FindFirstChild("Stage")
		if stageValue then
			stageValue.Value = stageNum
		end
	end
	stageUpdate:FireClient(player, stageNum, playerWins[player] or 0)
	if not silent and stageNum > oldStage then
		showMessage:FireClient(player, "Checkpoint! Stage " .. stageNum, "checkpoint")
	end
end

local function killPlayer(player)
	local now = os.clock()
	if lastKillTime[player] and now - lastKillTime[player] < 1 then
		return
	end
	lastKillTime[player] = now
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

local function spawnConfetti()
	local pad = world.WinPad
	if not pad then
		return
	end
	local colors = {
		Color3.fromRGB(255, 120, 140),
		Color3.fromRGB(255, 220, 90),
		Color3.fromRGB(120, 220, 130),
		Color3.fromRGB(120, 160, 255),
		Color3.fromRGB(230, 170, 255),
	}
	for i = 1, 24 do
		local piece = Instance.new("Part")
		piece.Name = "Confetti"
		piece.Size = Vector3.new(0.6, 0.6, 0.6)
		piece.Color = colors[(i - 1) % #colors + 1]
		piece.Material = Enum.Material.Neon
		piece.Anchored = false
		piece.CanCollide = false
		piece.CFrame = pad.CFrame + Vector3.new(math.random(-4, 4), 6 + math.random(0, 4), math.random(-4, 4))
		piece.Parent = workspace
		Debris:AddItem(piece, 3)
	end
end

local function addWin(player)
	local now = os.clock()
	if lastWinTime[player] and now - lastWinTime[player] < 3 then
		return
	end
	lastWinTime[player] = now
	playerWins[player] = (playerWins[player] or 0) + 1
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local winsValue = leaderstats:FindFirstChild("Wins")
		if winsValue then
			winsValue.Value = playerWins[player]
		end
	end
	stageUpdate:FireClient(player, playerStage[player] or 1, playerWins[player])
	showMessage:FireClient(player, "You Win!", "win")
	spawnConfetti()
	task.wait(2)
	setStage(player, 1, true)
	teleportToCheckpoint(player)
end

local function onStageTouched(stageNum, otherPart)
	local character = otherPart.Parent
	if not character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local now = os.clock()
	if lastCheckpointTime[player] and now - lastCheckpointTime[player] < 0.5 then
		return
	end
	lastCheckpointTime[player] = now
	setStage(player, stageNum, false)
end

-- Touching any part of a stage sets that stage as the checkpoint.
for stageNum, stage in ipairs(world.Stages) do
	for _, part in ipairs(stage.Parts) do
		part.Touched:Connect(function(otherPart)
			onStageTouched(stageNum, otherPart)
		end)
	end
end

-- Touching a kill brick or the lava kills the player.
for _, part in ipairs(world.KillParts) do
	part.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			killPlayer(player)
		end
	end)
end

-- Touching the WIN pad counts a win and restarts the player at stage 1.
if world.WinPad then
	world.WinPad.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			addWin(player)
		end
	end)
end

local function onPlayerAdded(player)
	playerStage[player] = 1
	playerWins[player] = 0

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local stageValue = Instance.new("IntValue")
	stageValue.Name = "Stage"
	stageValue.Value = 1
	stageValue.Parent = leaderstats

	local winsValue = Instance.new("IntValue")
	winsValue.Name = "Wins"
	winsValue.Value = 0
	winsValue.Parent = leaderstats

	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		teleportToCheckpoint(player)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- The reset button sends the player back to their last checkpoint.
resetRequest.OnServerEvent:Connect(function(player)
	teleportToCheckpoint(player)
end)

-- Spinners rotate around their pivot.
task.spawn(function()
	while true do
		local dt = task.wait(0.03)
		for _, spinner in ipairs(world.Spinners) do
			spinner.Angle = spinner.Angle + spinner.Speed * dt
			spinner.Part.CFrame = spinner.Pivot * CFrame.Angles(0, spinner.Angle, 0)
		end
	end
end)

-- Movers slide side to side along X.
task.spawn(function()
	local clock = 0
	while true do
		local dt = task.wait(0.03)
		clock = clock + dt
		for _, mover in ipairs(world.Movers) do
			local offset = math.sin(clock * ObbyConfig.MoverSpeed + mover.Phase) * mover.Distance
			mover.Part.CFrame = CFrame.new(mover.Center + Vector3.new(offset, 0, 0))
		end
	end
end)

-- Disappearing platforms blink on and off, staggered by their offset.
task.spawn(function()
	while true do
		local now = os.clock()
		for _, blinker in ipairs(world.Blinkers) do
			local cycle = ObbyConfig.BlinkVisibleTime + ObbyConfig.BlinkHiddenTime
			local t = (now + blinker.Offset) % cycle
			local visible = t < ObbyConfig.BlinkVisibleTime
			blinker.Part.CanCollide = visible
			blinker.Part.Transparency = visible and 0 or 1
		end
		task.wait(0.1)
	end
end)
