import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/background/cloud"
import "scripts/background/satellite"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Opening").extends(gfx.sprite)

local currentRecyclerIndex = 0
local currentDebrisCount = 0

local oa = OPENING_ANIMATION

function Opening:init(debrisManager)
    Opening.super.init(self)

    self.debrisManager = debrisManager

    self:spawnClouds()
    self:spawnSatellite()
    self:spawnRecyclers()
    self:spawnDebris()
    self:add()
end

function Opening:spawnRecyclers()
    self.recyclerSpawningTimer = pd.timer.new(oa.recyclerSpawnDuration)
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

function Opening:spawnDebris()
    self.debrisSpawningTimer = pd.timer.new(oa.debrisSpawnDuration)
    self.debrisSpawningTimer:pause()
    self.debrisSpawningTimer.discardOnCompletion = false
    self.debrisSpawningTimer.repeats = true
    self.debrisSpawningTimer.timerEndedCallback = function(timer)
        if currentDebrisCount < oa.debrisGroupAtStartCount then
            currentDebrisCount += 1
            local spawnX = math.random(16, MAX_SCREEN_WIDTH - 16)
            local spawnY = math.random(16, MAX_SCREEN_HEIGHT / 2)
            self.debrisManager:spawnDebris(spawnX, spawnY)
        else
            self.debrisSpawningTimer:remove()
            --self:spawnClouds()
        end
    end
end

function Opening:spawnClouds()
    self.clouds = {}
    local cloudX = CLOUD_WIDTH / 2
    for i = 1, oa.cloudAtStartCount, 1 do
        table.insert(self.clouds, Cloud(cloudX))
        cloudX = i * CLOUD_WIDTH + i * CLOUD_SEPARATION_DISTANCE + CLOUD_WIDTH / 2
    end
end

function Opening:spawnSatellite()
    self.satellite = Satellite()
end
