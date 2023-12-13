local pd <const> = playdate
local gfx <const> = pd.graphics

class("Cloud").extends(gfx.sprite)

local cloudImagePath = "images/background/clouds-table-64-16"

local yBaselineMin, yBaselineMax = 224, 230

local speed = 40

local rotationChance = 0.5
CLOUD_SEPARATION_DISTANCE = 3

-- TODO: shouldn't be a magic number
CLOUD_WIDTH = 64

function Cloud:init(x)
    Cloud.super.init(self)

    self.imageTable = gfx.imagetable.new(cloudImagePath)
    self:setSpriteImage(x)
    self:setZIndex(BACKGROUND_Z_INDEX)
    self:add()
end

function Cloud:update()
    if (WAS_GAME_ACTIVE_LAST_CHECK) then
        if (self.x < -CLOUD_WIDTH) then
            self:setSpriteImage(SCREEN_WIDTH + CLOUD_SEPARATION_DISTANCE)
        end
        local nextX = self.x - speed * DELTA_TIME
        self:moveTo(nextX, self.y)
    end
end

function Cloud:setSpriteImage(x)
    local imageIndex = math.random(1, #self.imageTable)
    local image = self.imageTable:getImage(imageIndex)
    self:setImage(image)
    local shouldFlip = math.random() < rotationChance
    if shouldFlip then
        self:setImageFlip(gfx.kImageFlippedX)
    end
    self.baseline = math.random(yBaselineMin, yBaselineMax)
    self:moveTo(x, self.baseline)
end