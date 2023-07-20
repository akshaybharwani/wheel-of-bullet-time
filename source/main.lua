import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

local playerX, playerY = 200, 120
local playerRadius = 10
local playerSpeed = 3

function playdate.update()
	gfx.clear()
    local crankAngle = math.rad(pd.getCrankPosition())
    playerX += math.sin(crankAngle) * playerSpeed
	playerY -= math.cos(crankAngle) * playerSpeed
	gfx.fillCircleAtPoint(playerX, playerY, playerRadius)
end
