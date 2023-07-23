import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- local playerX, playerY = 200, 120
-- local playerRadius = 10
-- local playerSpeed = 3

-- WeaponSize
local weaponBaseSize = 20

local maxScreenWidth = 400
local maxScreenHeight = 240

function pd.update()
    gfx.clear()
	-- Update stuff every frame
    gfx.sprite.update()
    pd.timer.updateTimers()

    -- local crankAngle = math.rad(pd.getCrankPosition())
    -- playerX += math.sin(crankAngle) * playerSpeed
    -- playerY -= math.cos(crankAngle) * playerSpeed

	-- Draw Weapon
    gfx.fillRect((maxScreenWidth - weaponBaseSize) / 2,
        maxScreenHeight - weaponBaseSize,
        weaponBaseSize, weaponBaseSize)
    gfx.drawLine((maxScreenWidth / 2),
		maxScreenHeight - weaponBaseSize, 200, 120)
end
