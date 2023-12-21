local pd <const> = playdate
local gfx <const> = pd.graphics

class("Cloud").extends(gfx.sprite)

local cloudImagePath = "images/background/clouds-table-64-16"

local yBaselineMin, yBaselineMax = 224, 230
local rotationChance = 0.5

local backgroundConstants = BACKGROUND_CONSTANTS

local speed = backgroundConstants.cloudSpeed
local cloudSeparationDistance = backgroundConstants.cloudSeperationDistance

-- TODO: shouldn't be a magic number
CLOUD_WIDTH = 64
local cloudWidth = CLOUD_WIDTH

function Cloud:init(x)
    Cloud.super.init(self)

    self.imageTable = gfx.imagetable.new(cloudImagePath)
    self:setSpriteImage(x)
    self:setZIndex(BACKGROUND_Z_INDEX)
    self:add()
end

function Cloud:update()
    if IS_GAME_OVER then
        return
    end

    if not IS_GAME_SETUP_DONE then
        return
    end

    if WAS_GAME_ACTIVE_LAST_CHECK or IS_GUN_DISABLED then
        if (self.x < -cloudWidth) then
            self:setSpriteImage(SCREEN_WIDTH + cloudSeparationDistance)
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
    -- TODO: check if this working properly
    if shouldFlip then
        self:setImageFlip(gfx.kImageFlippedX)
    end
    self.baseline = math.random(yBaselineMin, yBaselineMax)
    self:moveTo(x, self.baseline)
end