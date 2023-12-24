local pd <const> = playdate
local gfx <const> = pd.graphics

class("NotificationCenter").extends(gfx.sprite)

NOTIFICATION_CENTER = Signal()

NOTIFY_BULLET_COUNT_UPDATED = "bulletCountUpdate"
NOTIFY_GUN_WAS_HIT = "gunWasHit"
NOTIFY_GUN_STATE_CHANGED = "gunStateChanged"
NOTIFY_GAME_OVER = "gameOver"
NOTIFY_GUN_IS_DISABLED = "gunIsDisabled"
NOTIFY_GAME_STARTED = "gameStarted"

function NotificationCenter:init()
    NOTIFICATION_CENTER = Signal()
end