-- CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/frameTimer"
import "CoreLibs/crank"
import "CoreLibs/animator"

-- libraries
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/Signal"

-- game
import "scripts/globals"
import "scripts/game/utilities"
import "scripts/game/crankTimer"
import "scripts/game/crankInput"

import "scripts/audio/sfxPlayer"
import "scripts/background/background"
import "scripts/enemies/enemyManager"
import "scripts/gun/gunManager"
import "scripts/game/gameSetup"
import "scripts/game/timeDisplay"
import "scripts/game/gameOver"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- constants

NOTIFICATION_CENTER = Signal()

NOTIFY_INITIAL_DEBRIS_COLLECTED = "initialDebrisCollected"
NOTIFY_BULLET_COUNT_UPDATED = "bulletCountUpdate"
NOTIFY_GUN_WAS_HIT = "gunWasHit"
NOTIFY_GUN_STATE_CHANGED = "gunStateChanged"

-- TODO: assuming FPS is constant 30, majorly used by AnimatedSprite
CONSTANT_FPS = 30

DELTA_TIME = 0
-- if crank was moved this frame based on crankCheckWaitDuration, this is true
IS_GAME_ACTIVE = false
-- as the crankCheckWaitDuration is non-zero, the animation relying on IS_GAME_ACTIVE will
-- continously won't work properly, this can be used to help with that
WAS_GAME_ACTIVE_LAST_CHECK = false

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

GAME_ACTIVE_ELAPSED_SECONDS = 0

local titleConstants = TITLE_CONSTANTS
local titleDuration = titleConstants.titleDuration

IS_GAME_SETUP_DONE = false
IS_GAME_OVER = false

local function setupGame()
    math.randomseed(pd.getSecondsSinceEpoch())
    pd.resetElapsedTime()

    CrankInput()
    local gunManager = GunManager()
    -- ? is assigning a manager to initialization of another manager a good idea?
    local recyclerManager = RecyclerManager(gunManager)
    local debrisManager = DebrisManager(recyclerManager)
    TimeDisplay()
    GameSetup(titleDuration, debrisManager)
    Background(titleDuration)
    GameOver()
    NOTIFICATION_CENTER:subscribe(NOTIFY_INITIAL_DEBRIS_COLLECTED, self, function()
        EnemyManager(debrisManager)
        print("intial Debris collected")
        IS_GAME_SETUP_DONE = true
    end)
end

setupGame()

function pd.update()
    DELTA_TIME = pd.getElapsedTime()
    pd.resetElapsedTime()

    pd.timer.updateTimers()
    gfx.sprite.update()
    -- This needs to be called after the sprites are updated
    --[[ if pd.isCrankDocked() then
        pd.ui.crankIndicator:draw()
    end ]]
    pd.drawFPS(x, y)

    -- reset game state after updating everything
    if IS_GAME_ACTIVE then
        IS_GAME_ACTIVE = false
    end
end
