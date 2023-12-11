import "scripts/game/storedDataManager"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameOver').extends(gfx.sprite)

function GameOver:init()
    GameOver.super.init(self)

    -- TODO: would need to move this to a more central place when complexity increases
    self.storedDataManager = StoredDataManager()
    self:add()
end

function GameOver:update()
    if IS_GAME_SETUP_DONE then
        if DEBRIS_NOT_RECYCLED_COUNT <= 0 and CURRENT_BULLET_COUNT <= 0 then
            --gfx.drawText("GAME OVER", 200, 120)
            -- TODO: Add the Game Over screen after this ends
            --pd.wait(GAME_OVER_CONSTANTS.gameOverWaitDuration)
        end
    end
end