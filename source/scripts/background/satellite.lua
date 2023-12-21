local pd <const> = playdate
local gfx <const> = pd.graphics

class("Satellite").extends(AnimatedSprite)

local satelliteImagePath = "images/background/satellite-table-64-64"
local imageTable = gfx.imagetable.new(satelliteImagePath)

local backgroundConstants = BACKGROUND_CONSTANTS
local satelliteFPS = backgroundConstants.satelliteFPS

local minRespawnDuration, maxRespawnDuration = BACKGROUND_CONSTANTS.satelliteMinRespawnDuration, BACKGROUND_CONSTANTS.satelliteMinRespawnDuration

-- TODO: shouldn't be a magic number
SATELLITE_WIDTH = 64
local satelliteWidth = 64

function Satellite:init()
    Satellite.super.init(self, imageTable)

    self.speed = backgroundConstants.satelliteSpeed
    self.isGunDisabled = false

    self:setupPosition(nil)
    self:addState("fly", 1, 4, {tickStep = satelliteFPS})
    self.states.fly.yoyo = true
    self:setZIndex(BACKGROUND_Z_INDEX)
    self:playAnimation()

    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_IS_DISABLED, self, function()
        self.speed *= GAME_OVER_CONSTANTS.timeMultiplier
        self.isGunDisabled = true
    end)
end

function Satellite:update()
    if IS_GAME_OVER then
        return
    end

    if not IS_GAME_SETUP_DONE then
        return
    end

    if self.isGunDisabled or WAS_GAME_ACTIVE_LAST_CHECK then
        if (self.x < -satelliteWidth) then
            self:setupRespawnTimer()
        else
            local nextX = self.x - self.speed * DELTA_TIME
            self:moveTo(nextX, self.y)
            self:updateAnimation()
        end
    end
end

function Satellite:setupPosition(spawnX)
    if spawnX == nil then
        spawnX = math.random(16, SCREEN_WIDTH - 16)
    end
    local spawnY = math.random(16, SCREEN_HEIGHT / 2)
    self:moveTo(spawnX, spawnY)
end

function Satellite:setupRespawnTimer()
    self.respawnTimer = CrankTimer(math.random(minRespawnDuration, maxRespawnDuration), false, function()
        self:setupPosition(SCREEN_WIDTH + SATELLITE_WIDTH)
    end)
end