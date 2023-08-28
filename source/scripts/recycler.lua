import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Recycler").extends(gfx.sprite)

local recyclerImagePath = "images/recycler"

function Recycler:init()
    Recycler.super.init(self)

    self:setImage(gfx.image.new(recyclerImagePath))
    self:setCollideRect(0, 0, self:getSize())

    local startX = math.random(self.width / 2, maxScreenWidth - self.width / 2)
    local startY = maxScreenHeight - self.height / 2
    self:moveTo(startX, startY)
    self:add()
end

function getStartingPosition()

end
