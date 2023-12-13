import "scripts/game/storedDataManager"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameOver').extends(gfx.sprite)

IS_GAME_OVER = false

local gameOverConstants = GAME_OVER_CONSTANTS

local gameOverImagePath = "images/gameover"

function GameOver:init()
    GameOver.super.init(self)
    self:setImage(gfx.image.new(gameOverImagePath))

    -- TODO: would need to move this to a more central place when complexity increases
    self.storedDataManager = StoredDataManager()
    self:moveTo(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT)
    self:setZIndex(BANNER_Z_INDEX)
    self:add()
    self:setVisible(false)
end

function GameOver:update()
    if IS_GAME_SETUP_DONE then
        
        if DEBRIS_NOT_RECYCLED_COUNT <= 0 and CURRENT_BULLET_COUNT <= 0 then
            IS_GAME_OVER = true
            --gfx.drawText("GAME OVER", 200, 120)
        end
    end
end

function GameOver:setupGameOverTimer()
    self.gameOverTimer = pd.timer.new(gameOverConstants.gameOverWaitDuration)
    self.gameOverTimer:pause()
    self.gameOverTimer.timerEndedCallback = function(timer)
        self:setVisible(true)
    end
end