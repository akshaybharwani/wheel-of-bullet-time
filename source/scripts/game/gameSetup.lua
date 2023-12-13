import "scripts/background/cloud"
import "scripts/background/satellite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("GameSetup").extends(gfx.sprite)

local openingAnimationConstants = OPENING_ANIMATION_CONSTANTS

local waitDurationToSpawnRecyclers = openingAnimationConstants.waitDurationToSpawnRecyclers
local waitDurationToSpawnDebris = openingAnimationConstants.waitDurationToSpawnDebris
local debrisGroupAtStartCount = openingAnimationConstants.debrisGroupAtStartCount
local cloudsAtStartCount = openingAnimationConstants.cloudsAtStartCount

local titleImagePath = "images/background/Title"

local currentRecyclerIndex = 0
local currentDebrisCount = 0

local openingDebrisSpawned = false
local initialDebrisCollected = false


function GameSetup:init(delay, debrisManager)
    GameSetup.super.init(self)

    self.debrisManager = debrisManager

    self.titleSprite = gfx.sprite.new(gfx.image.new(titleImagePath))
    self.titleSprite:moveTo(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT)
    self.titleSprite:setZIndex(BANNER_Z_INDEX)
    self.titleSprite:add()

    local titleTimer = pd.timer.new(delay)
    titleTimer.timerEndedCallback = function(timer)
        self.titleSprite:remove()
        -- TODO: move background stuff to backgroundManager
        self:spawnClouds()
        self:spawnSatellite()
        self:spawnRecyclers()
        self:spawnDebris()
    end

    self:add()
end

function GameSetup:update()
    if openingDebrisSpawned and not initialDebrisCollected then
        if #ACTIVE_DEBRIS <= 0 then
            NOTIFICATION_CENTER:notify(NOTIFY_INITIAL_DEBRIS_COLLECTED)
            initialDebrisCollected = true
        end
    end
end

function GameSetup:spawnRecyclers()
    self.recyclerSpawningTimer = pd.timer.new(waitDurationToSpawnRecyclers)
    --self.recyclerSpawningTimer.delay = 500
    self.recyclerSpawningTimer.discardOnCompletion = false
    self.recyclerSpawningTimer.repeats = true
    self.recyclerSpawningTimer.timerEndedCallback = function(timer)
        if currentRecyclerIndex < #ACTIVE_RECYCLERS then
            currentRecyclerIndex += 1
            local recycler = ACTIVE_RECYCLERS[currentRecyclerIndex]
            recycler:addSprite()
        else
            self.recyclerSpawningTimer:remove()
            self.debrisSpawningTimer:start()
        end
    end
end

function GameSetup:spawnDebris()
    self.debrisSpawningTimer = pd.timer.new(waitDurationToSpawnDebris)
    self.debrisSpawningTimer:pause()
    self.debrisSpawningTimer.discardOnCompletion = false
    self.debrisSpawningTimer.repeats = true
    self.debrisSpawningTimer.timerEndedCallback = function(timer)
        if currentDebrisCount < debrisGroupAtStartCount then
            currentDebrisCount += 1
            local spawnX = math.random(16, SCREEN_WIDTH - 16)
            local spawnY = math.random(16, HALF_SCREEN_HEIGHT)
            self.debrisManager:spawnDebris(spawnX, spawnY)
        else
            self.debrisSpawningTimer:remove()
            openingDebrisSpawned = true
        end
    end
end

function GameSetup:spawnClouds()
    self.clouds = {}
    local cloudX = CLOUD_WIDTH / 2
    for i = 1, cloudsAtStartCount, 1 do
        table.insert(self.clouds, Cloud(cloudX))
        cloudX = i * CLOUD_WIDTH + i * CLOUD_SEPARATION_DISTANCE + CLOUD_WIDTH / 2
    end
end

function GameSetup:spawnSatellite()
    self.satellite = Satellite()
end
