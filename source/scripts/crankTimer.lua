import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('CrankTimer').extends(gfx.sprite)

function CrankTimer:init(duration, callback)
    self.timer = 0
    self.duration = duration
    self.callback = callback
    self:add()
end

function CrankTimer:update()
    if pd.getCrankChange() == 0 then
        return
    end
    self.timer += DELTA_TIME
    if self.timer >= self.duration then
        self.callback()
        self.timer = 0
    end
end
