local pd <const> = playdate
local gfx <const> = pd.graphics

class('BulletDisplay').extends(gfx.sprite)

function BulletDisplay:init()
    self:setCenter(0, 0)
    -- TODO: very magic numbery. change.
    self.displayString = string.format("%03d", CURRENT_BULLET_COUNT)
    local displayTextWidth, displayTextHeight = gfx.getTextSize(self.displayString)
    self:moveTo(MAX_SCREEN_WIDTH / 2 - displayTextWidth / 2, 223)
    -- Important, so you don't have it moving in
    -- the world space
    --self:setIgnoresDrawOffset(true)
    self:setZIndex(UI_Z_INDEX)
    self:add()
end

function BulletDisplay:update()
    self.displayString = string.format("%03d", CURRENT_BULLET_COUNT)
    -- Getting the width and height of the text to make sure the image
    -- will always fit the text
    local displayTextWidth, displayTextHeight = gfx.getTextSize(self.displayString)
    local displayImage = gfx.image.new(displayTextWidth, displayTextHeight)
    gfx.pushContext(displayImage)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText(self.displayString, 0, 0)
    gfx.popContext()
    self:setImage(displayImage)
end
