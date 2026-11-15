-- BuildObby -- builds the whole Rainbow Obby world from ObbyConfig.
-- Install: put this ModuleScript in ServerScriptService and name it "BuildObby".
-- It only builds parts. ObbyServer wires up checkpoints, kills, wins and animation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObbyConfig = require(ReplicatedStorage:WaitForChild("ObbyConfig"))

local BuildObby = {}

local function newPart(parent, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function stageCenter(stageNum)
	return Vector3.new(0, 0, -(stageNum - 1) * ObbyConfig.StageStep)
end

local function materialForTheme(theme)
	if theme == "Grass" then
		return Enum.Material.Grass
	elseif theme == "Chocolate" then
		return Enum.Material.Wood
	elseif theme == "Bubbles" or theme == "Clouds" then
		return Enum.Material.Glass
	elseif theme == "Checkerboard" then
		return Enum.Material.Slate
	else
		return Enum.Material.SmoothPlastic
	end
end

-- Darker border frame around a platform so each stage stands out.
local function addBorder(folder, center, size, color)
	local borderColor = Color3.new(
		math.max(0, color.R - 0.25),
		math.max(0, color.G - 0.25),
		math.max(0, color.B - 0.25)
	)
	local y = center.Y + 0.55
	local t = 1
	newPart(folder, "Border", Vector3.new(size.X, t, t), CFrame.new(center.X, y, center.Z - size.Z / 2), borderColor, Enum.Material.SmoothPlastic)
	newPart(folder, "Border", Vector3.new(size.X, t, t), CFrame.new(center.X, y, center.Z + size.Z / 2), borderColor, Enum.Material.SmoothPlastic)
	newPart(folder, "Border", Vector3.new(t, t, size.Z), CFrame.new(center.X - size.X / 2, y, center.Z), borderColor, Enum.Material.SmoothPlastic)
	newPart(folder, "Border", Vector3.new(t, t, size.Z), CFrame.new(center.X + size.X / 2, y, center.Z), borderColor, Enum.Material.SmoothPlastic)
end

-- Small cute decorations on top of a platform, picked by theme.
local function addThemeDecor(folder, center, size, color, theme)
	local topY = center.Y + 0.15
	if theme == "Polka Dots" or theme == "Hearts" or theme == "Confetti" or theme == "Ice Cream" or theme == "Cotton Candy" then
		local dotColor = Color3.fromRGB(255, 255, 255)
		if theme == "Hearts" then
			dotColor = Color3.fromRGB(255, 120, 180)
		elseif theme == "Confetti" then
			dotColor = Color3.fromRGB(255, 220, 90)
		end
		local offsets = {Vector3.new(-6, 0, -6), Vector3.new(6, 0, -6), Vector3.new(-6, 0, 6), Vector3.new(6, 0, 6), Vector3.new(0, 0, 0)}
		for _, offset in ipairs(offsets) do
			newPart(folder, "Dot", Vector3.new(2, 0.3, 2), CFrame.new(center + offset + Vector3.new(0, topY, 0)), dotColor, Enum.Material.SmoothPlastic)
		end
	elseif theme == "Bubbles" then
		local offsets = {Vector3.new(-6, 0, -6), Vector3.new(6, 0, 6), Vector3.new(0, 0, 0)}
		for _, offset in ipairs(offsets) do
			local bubble = newPart(folder, "Bubble", Vector3.new(2, 2, 2), CFrame.new(center + offset + Vector3.new(0, topY + 1, 0)), Color3.fromRGB(200, 230, 255), Enum.Material.Glass)
			bubble.Shape = Enum.PartType.Ball
			bubble.CanCollide = false
		end
	elseif theme == "Candy Stripes" or theme == "Rainbow" or theme == "Lollipop" then
		for i = 1, 3 do
			local stripeColor = Color3.fromRGB(255, 255, 255)
			if theme == "Rainbow" then
				stripeColor = Color3.fromRGB(255, 200, 60)
			elseif theme == "Lollipop" then
				stripeColor = Color3.fromRGB(255, 90, 120)
			end
			local z = center.Z - 6 + (i - 1) * 6
			newPart(folder, "Stripe", Vector3.new(size.X - 2, 0.3, 2), CFrame.new(center.X, topY, z), stripeColor, Enum.Material.SmoothPlastic)
		end
	elseif theme == "Stars" or theme == "Sunshine" then
		local offsets = {Vector3.new(-6, 0, -6), Vector3.new(6, 0, 6), Vector3.new(0, 0, 0)}
		for _, offset in ipairs(offsets) do
			newPart(folder, "Star", Vector3.new(2, 0.3, 2), CFrame.new(center + offset + Vector3.new(0, topY, 0)), Color3.fromRGB(255, 220, 90), Enum.Material.Neon)
		end
	elseif theme == "Checkerboard" then
		for ix = 1, 2 do
			for iz = 1, 2 do
				if (ix + iz) % 2 == 0 then
					local x = center.X - 5 + (ix - 1) * 10
					local z = center.Z - 5 + (iz - 1) * 10
					newPart(folder, "Square", Vector3.new(8, 0.3, 8), CFrame.new(x, topY, z), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
				end
			end
		end
	end
end

-- Big stage number floating above the platform.
local function addStageNumber(folder, center, stageNum, color)
	local anchor = newPart(folder, "StageLabel", Vector3.new(1, 1, 1), CFrame.new(center + Vector3.new(0, 7, 0)), color, Enum.Material.SmoothPlastic)
	anchor.Transparency = 1
	anchor.CanCollide = false
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 120, 0, 120)
	gui.StudsOffset = Vector3.new(0, 0, 0)
	gui.AlwaysOnTop = true
	gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = tostring(stageNum)
	label.Font = Enum.Font.FredokaOne
	label.TextSize = 90
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(60, 60, 90)
	label.Parent = gui
end

-- Full 20x20 stage platform with border, theme decor and stage number.
local function buildFullPlatform(world, stageNum, center, color, theme)
	local folder = world.Course
	local platform = newPart(folder, "Stage" .. stageNum, ObbyConfig.StageSize, CFrame.new(center.X, -0.5, center.Z), color, materialForTheme(theme))
	addBorder(folder, center, ObbyConfig.StageSize, color)
	addThemeDecor(folder, center, ObbyConfig.StageSize, color, theme)
	addStageNumber(folder, center, stageNum, color)
	table.insert(world.Stages[stageNum].Parts, platform)
	return platform
end

-- Three small pads with jump gaps between them.
local function buildGaps(world, stageNum, center, color, theme, gap)
	gap = gap or 7
	for i = 1, 3 do
		local z = center.Z - gap + (i - 1) * gap
		local pad = newPart(world.Course, "GapPad", Vector3.new(12, 1, 5), CFrame.new(center.X, -0.5, z), color, materialForTheme(theme))
		table.insert(world.Stages[stageNum].Parts, pad)
	end
	addStageNumber(world.Course, center, stageNum, color)
end

-- Entry pad, thin beam, exit pad.
local function buildBeam(world, stageNum, center, color, theme)
	local entry = newPart(world.Course, "BeamPad", Vector3.new(12, 1, 6), CFrame.new(center.X, -0.5, center.Z - 7), color, materialForTheme(theme))
	local beam = newPart(world.Course, "Beam", Vector3.new(2, 1, 8), CFrame.new(center.X, -0.5, center.Z), Color3.fromRGB(255, 255, 255), Enum.Material.Wood)
	local exitPad = newPart(world.Course, "BeamPad", Vector3.new(12, 1, 6), CFrame.new(center.X, -0.5, center.Z + 7), color, materialForTheme(theme))
	table.insert(world.Stages[stageNum].Parts, entry)
	table.insert(world.Stages[stageNum].Parts, beam)
	table.insert(world.Stages[stageNum].Parts, exitPad)
	addStageNumber(world.Course, center, stageNum, color)
end

-- Spinning red kill bar. The server rotates it around the pivot.
local function addSpinner(world, pivot, length, speed)
	local bar = newPart(world.Course, "Spinner", Vector3.new(length, 1, 1.5), pivot, Color3.fromRGB(255, 40, 60), Enum.Material.Neon)
	table.insert(world.KillParts, bar)
	table.insert(world.Spinners, {Part = bar, Pivot = pivot, Angle = 0, Speed = speed or ObbyConfig.SpinnerSpeed})
end

-- Moving platform. The server slides it side to side along X.
local function addMover(world, stageNum, centerPos, distance, phase)
	local mover = newPart(world.Course, "Mover", Vector3.new(6, 1, 6), CFrame.new(centerPos), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
	table.insert(world.Stages[stageNum].Parts, mover)
	table.insert(world.Movers, {Part = mover, Center = centerPos, Distance = distance, Phase = phase})
	return mover
end

-- Steps up to a high pad, then down. Top surface is 4 studs up.
local function buildStairs(world, stageNum, center, color, theme)
	for i = 1, 4 do
		local step = newPart(world.Course, "Step", Vector3.new(12, 1, 3), CFrame.new(center.X, -0.5 + i, center.Z - 8 + (i - 1) * 3), color, materialForTheme(theme))
		table.insert(world.Stages[stageNum].Parts, step)
	end
	local top = newPart(world.Course, "StepTop", Vector3.new(12, 1, 6), CFrame.new(center.X, 3.5, center.Z + 4), color, materialForTheme(theme))
	table.insert(world.Stages[stageNum].Parts, top)
	world.Stages[stageNum].TopY = 4
	addStageNumber(world.Course, center, stageNum, color)
end

-- Three pads that blink on and off, staggered.
local function buildDisappearing(world, stageNum, center, color, theme, gap)
	gap = gap or 7
	for i = 1, 3 do
		local z = center.Z - gap + (i - 1) * gap
		local pad = newPart(world.Course, "BlinkPad", Vector3.new(12, 1, 5), CFrame.new(center.X, -0.5, z), color, materialForTheme(theme))
		table.insert(world.Stages[stageNum].Parts, pad)
		table.insert(world.Blinkers, {Part = pad, Offset = (i - 1) * 1.5})
	end
	addStageNumber(world.Course, center, stageNum, color)
end

-- Bright orange glowing lava floor under the whole course. Touching it kills.
local function buildLava(world)
	local span = (ObbyConfig.StageCount - 1) * ObbyConfig.StageStep
	local lavaLength = span + 40
	local lava = newPart(world.Course, "Lava", Vector3.new(120, 2, lavaLength), CFrame.new(0, ObbyConfig.LavaY - 1, -span / 2), Color3.fromRGB(255, 90, 0), Enum.Material.Neon)
	table.insert(world.KillParts, lava)
end

-- Clouds, balloons, a rainbow arch, stars and floating hearts.
local function buildDecorations(world)
	for i = 1, 8 do
		local x = -60 + (i - 1) * 17
		local z = -20 - (i - 1) * 40
		local cloud = newPart(world.Decor, "Cloud", Vector3.new(10, 4, 6), CFrame.new(x, 30, z), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
		cloud.Shape = Enum.PartType.Ball
		cloud.CanCollide = false
	end
	local balloonColors = {Color3.fromRGB(255, 120, 140), Color3.fromRGB(120, 200, 255), Color3.fromRGB(255, 220, 90)}
	for i, bcolor in ipairs(balloonColors) do
		local x = -25 + (i - 1) * 25
		local balloon = newPart(world.Decor, "Balloon", Vector3.new(4, 5, 4), CFrame.new(x, 18, 10), bcolor, Enum.Material.SmoothPlastic)
		balloon.Shape = Enum.PartType.Ball
		balloon.CanCollide = false
	end
	local rainbowColors = {
		Color3.fromRGB(255, 80, 80),
		Color3.fromRGB(255, 170, 60),
		Color3.fromRGB(255, 230, 80),
		Color3.fromRGB(90, 220, 120),
		Color3.fromRGB(90, 160, 255),
		Color3.fromRGB(180, 120, 255),
		Color3.fromRGB(255, 120, 200),
	}
	for i = 1, 7 do
		local t = (i - 1) / 6
		local x = -14 + t * 28
		local y = 8 + math.sin(t * math.pi) * 8
		local arch = newPart(world.Decor, "Rainbow", Vector3.new(3, 3, 3), CFrame.new(x, y, -8), rainbowColors[i], Enum.Material.Neon)
		arch.CanCollide = false
	end
	for i = 1, 10 do
		local z = -15 - (i - 1) * 36
		local star = newPart(world.Decor, "Star", Vector3.new(2, 2, 2), CFrame.new(25, 8, z), Color3.fromRGB(255, 220, 90), Enum.Material.Neon)
		star.CanCollide = false
		local heart = newPart(world.Decor, "Heart", Vector3.new(2, 2, 2), CFrame.new(-25, 8, z - 18), Color3.fromRGB(255, 120, 180), Enum.Material.Neon)
		heart.Shape = Enum.PartType.Ball
		heart.CanCollide = false
	end
end

local function buildSpawn(world)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "ObbySpawn"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(0, 0.5, 0)
	spawn.Color = Color3.fromRGB(140, 220, 120)
	spawn.Material = Enum.Material.Grass
	spawn.Anchored = true
	spawn.CanCollide = true
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.Neutral = true
	spawn.Parent = world.Course
	world.Spawn = spawn
end

function BuildObby.Build()
	local course = Instance.new("Folder")
	course.Name = "ObbyCourse"
	course.Parent = workspace
	local decor = Instance.new("Folder")
	decor.Name = "ObbyDecor"
	decor.Parent = workspace

	local world = {
		Course = course,
		Decor = decor,
		Stages = {},
		KillParts = {},
		Spinners = {},
		Movers = {},
		Blinkers = {},
		WinPad = nil,
		Spawn = nil,
	}

	for stageNum = 1, ObbyConfig.StageCount do
		local center = stageCenter(stageNum)
		world.Stages[stageNum] = {Parts = {}, Center = center, TopY = 0}
		local color = ObbyConfig.StageColors[stageNum]
		local theme = ObbyConfig.StageThemes[stageNum]
		local kind = ObbyConfig.StageObstacles[stageNum]

		if kind == "start" then
			buildFullPlatform(world, stageNum, center, color, theme)
		elseif kind == "gaps" then
			buildGaps(world, stageNum, center, color, theme, 7)
		elseif kind == "beam" then
			buildBeam(world, stageNum, center, color, theme)
		elseif kind == "spinner" then
			buildFullPlatform(world, stageNum, center, color, theme)
			addSpinner(world, CFrame.new(center.X, 1.5, center.Z), 16, ObbyConfig.SpinnerSpeed)
		elseif kind == "mover" then
			local padA = newPart(world.Course, "MoverPad", Vector3.new(8, 1, 8), CFrame.new(center.X, -0.5, center.Z - 6), color, materialForTheme(theme))
			local padB = newPart(world.Course, "MoverPad", Vector3.new(8, 1, 8), CFrame.new(center.X, -0.5, center.Z + 6), color, materialForTheme(theme))
			table.insert(world.Stages[stageNum].Parts, padA)
			table.insert(world.Stages[stageNum].Parts, padB)
			addMover(world, stageNum, Vector3.new(center.X, -0.5, center.Z), ObbyConfig.MoverDistance, stageNum)
			addStageNumber(world.Course, center, stageNum, color)
		elseif kind == "disappearing" then
			buildDisappearing(world, stageNum, center, color, theme, 7)
		elseif kind == "stairs" then
			buildStairs(world, stageNum, center, color, theme)
		elseif kind == "spinner-beam" then
			buildBeam(world, stageNum, center, color, theme)
			addSpinner(world, CFrame.new(center.X, 2.5, center.Z), 8, ObbyConfig.SpinnerSpeed)
		elseif kind == "movers" then
			local padA = newPart(world.Course, "MoverPad", Vector3.new(6, 1, 6), CFrame.new(center.X, -0.5, center.Z - 8), color, materialForTheme(theme))
			local padB = newPart(world.Course, "MoverPad", Vector3.new(6, 1, 6), CFrame.new(center.X, -0.5, center.Z + 8), color, materialForTheme(theme))
			table.insert(world.Stages[stageNum].Parts, padA)
			table.insert(world.Stages[stageNum].Parts, padB)
			addMover(world, stageNum, Vector3.new(center.X, -0.5, center.Z - 2), ObbyConfig.MoverDistance, stageNum)
			addMover(world, stageNum, Vector3.new(center.X, -0.5, center.Z + 2), ObbyConfig.MoverDistance, stageNum + 3)
			addStageNumber(world.Course, center, stageNum, color)
		elseif kind == "disappearing-gaps" then
			buildDisappearing(world, stageNum, center, color, theme, 8)
		elseif kind == "beam-spinner" then
			buildBeam(world, stageNum, center, color, theme)
			addSpinner(world, CFrame.new(center.X, 2.5, center.Z + 7), 10, ObbyConfig.SpinnerSpeed)
		elseif kind == "mover-stairs" then
			buildStairs(world, stageNum, center, color, theme)
			addMover(world, stageNum, Vector3.new(center.X, 3.5, center.Z + 11), ObbyConfig.MoverDistance, stageNum)
		elseif kind == "disappearing-spinner" then
			buildDisappearing(world, stageNum, center, color, theme, 7)
			addSpinner(world, CFrame.new(center.X, 2.5, center.Z), 10, ObbyConfig.SpinnerSpeed)
		elseif kind == "gauntlet" then
			buildBeam(world, stageNum, center, color, theme)
			addSpinner(world, CFrame.new(center.X, 2.5, center.Z), 8, ObbyConfig.SpinnerSpeed)
			addMover(world, stageNum, Vector3.new(center.X, -0.5, center.Z + 12), ObbyConfig.MoverDistance, stageNum)
		elseif kind == "win" then
			buildFullPlatform(world, stageNum, center, color, theme)
			local pad = newPart(world.Course, "WinPad", Vector3.new(10, 1, 10), CFrame.new(center.X, 0.5, center.Z), Color3.fromRGB(255, 210, 60), Enum.Material.Neon)
			world.WinPad = pad
			local star = newPart(world.Course, "WinStar", Vector3.new(3, 3, 3), CFrame.new(center.X, 5, center.Z), Color3.fromRGB(255, 210, 60), Enum.Material.Neon)
			star.Shape = Enum.PartType.Ball
			star.CanCollide = false
		end
	end

	buildLava(world)
	buildDecorations(world)
	buildSpawn(world)
	return world
end

return BuildObby
