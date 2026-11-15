-- Make the best Roblox game
-- ObbyConfig -- shared settings for the Rainbow Obby entry (roblox-game-01).
-- Install: put this ModuleScript in ReplicatedStorage and name it "ObbyConfig".

local ObbyConfig = {}

-- How many stages the course has. Stage 15 is the WIN stage.
ObbyConfig.StageCount = 15
ObbyConfig.WinStage = 15

-- Size of one full stage platform and the gap the player jumps between stages.
ObbyConfig.StageSize = Vector3.new(20, 1, 20)
ObbyConfig.StageGap = 6
ObbyConfig.StageStep = ObbyConfig.StageSize.Z + ObbyConfig.StageGap

-- Height of the lava floor below the course.
ObbyConfig.LavaY = -12

-- How high above a checkpoint the player respawns.
ObbyConfig.RespawnHeight = 4

-- Bright rainbow pastel color for each stage, in order.
ObbyConfig.StageColors = {
	Color3.fromRGB(255, 120, 140),
	Color3.fromRGB(255, 165, 90),
	Color3.fromRGB(255, 225, 100),
	Color3.fromRGB(140, 220, 120),
	Color3.fromRGB(90, 200, 210),
	Color3.fromRGB(120, 160, 255),
	Color3.fromRGB(180, 140, 255),
	Color3.fromRGB(255, 140, 210),
	Color3.fromRGB(120, 230, 200),
	Color3.fromRGB(255, 200, 120),
	Color3.fromRGB(160, 220, 90),
	Color3.fromRGB(255, 150, 150),
	Color3.fromRGB(140, 190, 255),
	Color3.fromRGB(230, 170, 255),
	Color3.fromRGB(255, 215, 90),
}

-- Cute theme for each stage. BuildObby uses the theme for material + decor.
ObbyConfig.StageThemes = {
	"Candy Stripes",
	"Polka Dots",
	"Checkerboard",
	"Stars",
	"Clouds",
	"Grass",
	"Rainbow",
	"Hearts",
	"Bubbles",
	"Chocolate",
	"Ice Cream",
	"Lollipop",
	"Confetti",
	"Sunshine",
	"Cotton Candy",
}

-- Obstacle plan for each stage, in order. Must have StageCount entries.
ObbyConfig.StageObstacles = {
	"start",
	"gaps",
	"beam",
	"spinner",
	"mover",
	"disappearing",
	"stairs",
	"spinner-beam",
	"movers",
	"disappearing-gaps",
	"beam-spinner",
	"mover-stairs",
	"disappearing-spinner",
	"gauntlet",
	"win",
}

-- Spinner, mover and disappearing-platform tuning.
ObbyConfig.SpinnerSpeed = 1.6
ObbyConfig.MoverDistance = 7
ObbyConfig.MoverSpeed = 2.5
ObbyConfig.BlinkVisibleTime = 3
ObbyConfig.BlinkHiddenTime = 2

return ObbyConfig
