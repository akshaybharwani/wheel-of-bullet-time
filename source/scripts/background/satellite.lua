import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/game/crankTimer"
import "scripts/libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Satellite").extends(AnimatedSprite)

local satelliteImagePath = "images/background/satellite-table-64-64"
local imageTable = gfx.imagetable.new(satelliteImagePath)

local speed = 15

-- TODO: shouldn't be a magic number
SATELLITE_WIDTH = 64

local satelliteFPS = 3

local minRespawnDuration, maxRespawnDuration = 3, 6

function Satellite:init()
    Satellite.super.init(self, imageTable)

    self:setupPosition(nil)
    self:addState("fly", 1, 4, {tickStep = satelliteFPS})
    self.states.fly.yoyo = true
    self:setZIndex(BACKGROUND_Z_INDEX)
    self:playAnimation()
end

function Satellite:update()
    if (WAS_GAME_ACTIVE_LAST_CHECK) then
        if (self.x < -SATELLITE_WIDTH) then
            self:setupRespawnTimer()
        else
            local nextX = self.x - speed * DELTA_TIME
            self:moveTo(nextX, self.y)
            self:updateAnimation()
        end
    end
end

function Satellite:setupPosition(spawnX)
    if spawnX == nil then
        spawnX = math.random(16, MAX_SCREEN_WIDTH - 16)
    end
    local spawnY = math.random(16, MAX_SCREEN_HEIGHT / 2)
    self:moveTo(spawnX, spawnY)
end

function Satellite:setupRespawnTimer()
    self.respawnTimer = CrankTimer(math.random(minRespawnDuration, maxRespawnDuration), false, function()
        self:setupPosition(MAX_SCREEN_WIDTH + SATELLITE_WIDTH)
    end)
end