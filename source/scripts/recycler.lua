import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Recycler").extends(gfx.sprite)

local recyclerImagePath = "images/recycler"

function Recycler:init(x, y)
    Recycler.super.init(self)
    self.type = "gun-element"

    self:setImage(gfx.image.new(recyclerImagePath))
    self:setCollideRect(0, 0, self:getSize())

    self:moveTo(x, y)
    self:add()
end

function Recycler:getHit()

end
