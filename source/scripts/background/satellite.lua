local pd <const> = playdate
local gfx <const> = pd.graphics

class("Satellite").extends(AnimatedSprite)

local satelliteImagePath = "images/background/satellite-table-64-64"
local imageTable = gfx.imagetable.new(satelliteImagePath)

local backgroundConstants = BACKGROUND_CONSTANTS
local satelliteFPS = backgroundConstants.satelliteFPS

local minRespawnDuration, maxRespawnDuration = BACKGROUND_CONSTANTS.satelliteMinRespawnDuration, BACKGROUND_CONSTANTS.satelliteMinRespawnDuration

function Satellite:init()
    Satellite.super.init(self, imageTable)

    self.speed = backgroundConstants.satelliteSpeed
    self.isGunDisabled = false
    self.isRespawing = false

    self.satelliteSize = imageTable:getImage(1):getSize()
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

    if self.isRespawing then
        return
    end

    if self.isGunDisabled or WAS_GAME_ACTIVE_LAST_CHECK then
        if self.x < -self.satelliteSize then
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
        self:setupPosition(SCREEN_WIDTH + self.satelliteSize)
        self.isRespawing = false
    end)
    self.isRespawing = true
end