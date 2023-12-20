import "scripts/background/cloud"
import "scripts/background/satellite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Background').extends(gfx.sprite)

local backgroundConstants = BACKGROUND_CONSTANTS
local cloudSeparationDistance = backgroundConstants.cloudSeperationDistance
local cloudsAtStartCount = backgroundConstants.cloudsAtStartCount

local cloudWidth = CLOUD_WIDTH

function Background:init()
    Background.super.init(self)

    self:showBackground()
    self:spawnClouds()
    self:spawnSatellite()
    self:add()
end

function Background:showBackground()
    local backgroundImage = gfx.image.new("images/background/background_01")
    if assert(backgroundImage) then
        gfx.sprite.setBackgroundDrawingCallback(
            function(x, y, width, height)
                backgroundImage:draw(0, 0)
            end
        )
    end
end

function Background:spawnClouds()
    self.clouds = {}
    local cloudX = cloudWidth / 2
    for i = 1, cloudsAtStartCount, 1 do
        table.insert(self.clouds, Cloud(cloudX))
        cloudX = i * cloudWidth + i * cloudSeparationDistance + cloudWidth / 2
    end
end

function Background:spawnSatellite()
    self.satellite = Satellite()
end
