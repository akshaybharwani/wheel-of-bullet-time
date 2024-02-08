-- CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/frameTimer"
import "CoreLibs/crank"
import "CoreLibs/animator"
-- for debugging, should be removed for production
import "CoreLibs/utilities/where"

-- libraries
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/Signal"

-- game
import "scripts/globals"
import "scripts/game/notificationCenter"
import "scripts/game/utilities"
import "scripts/game/crankTimer"
import "scripts/game/crankInput"

import "scripts/audio/sfxPlayer"
import "scripts/audio/musicPlayer"
import "scripts/background/background"
import "scripts/enemies/enemyManager"
import "scripts/gun/gunManager"
import "scripts/game/timeDisplay"
import "scripts/game/gameOver"
import "scripts/game/gameSetup"
import "scripts/game/tutorial"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- constants

-- TODO: assuming FPS is constant 30, majorly used by AnimatedSprite
CONSTANT_FPS = 30

SCREEN_WIDTH = pd.display.getWidth()
HALF_SCREEN_WIDTH = SCREEN_WIDTH / 2
SCREEN_HEIGHT = pd.display.getHeight()
HALF_SCREEN_HEIGHT = SCREEN_HEIGHT / 2

PLAYER_GROUP = 1
ENEMY_GROUP = 2
DEBRIS_GROUP = 3
BULLET_GROUP = 4
GUN_GROUP = 5
VACUUM_GROUP = 6

-- ? do we need types _and_ groups? Revisit

GUN_TYPE_NAME = "gun-element"
ENEMY_TYPE_NAME = "enemy"
DEBRIS_TYPE_NAME = "debris"

BACKGROUND_Z_INDEX = -100
GUN_Z_INDEX = 100
UI_Z_INDEX = 200
BANNER_Z_INDEX = 300

GameSetup()

function pd.update()
    DELTA_TIME = pd.getElapsedTime()
    pd.resetElapsedTime()

    pd.timer.updateTimers()
    pd.frameTimer.updateTimers()
    gfx.sprite.update()
    -- This needs to be called after the sprites are updated
    --[[ if pd.isCrankDocked() then
        pd.ui.crankIndicator:draw()
    end ]]
    pd.drawFPS(x, y)

    --gfx.drawLine(HALF_SCREEN_WIDTH, 0, HALF_SCREEN_WIDTH, SCREEN_HEIGHT)

    -- reset game state after updating everything
    if IS_GAME_ACTIVE then
        IS_GAME_ACTIVE = false
    end
end
