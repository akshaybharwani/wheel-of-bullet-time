import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/recyclerConnector"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Recycler").extends(gfx.sprite)

local recyclerImagePath = "images/recycler"

function Recycler:init(x, y, connectorY)
    Recycler.super.init(self)
    self.type = "gun-element"

    self:setImage(gfx.image.new(recyclerImagePath))
    self:setCollideRect(0, 0, self:getSize())

    self:moveTo(x, y)
    self.connector = RecyclerConnector(x, y, connectorY)
    self:add()
end

function Recycler:getHit()
    -- show damaged states
    self:remove()
end
