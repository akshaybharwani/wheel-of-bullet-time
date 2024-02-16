import "scripts/enemies/debris"

local pd <const> = playdate
local gfx <const> = pd.graphics

local utils <const> = UTILITIES

class('DebrisManager').extends(gfx.sprite)

local debrisConstants = DEBRIS_CONSTANTS
local minDebris, maxDebris = debrisConstants.minDebris, debrisConstants.maxDebris
local expirationDuration = debrisConstants.expirationDuration / 1000

local gridSize = 64
-- TODO: do this by getting the size of the image
local debrisSize = 16
local debrisCenter = (gridSize / 4) - (debrisSize / 2)

ACTIVE_DEBRIS = {}
-- table for maintaining debris count until they become a bullet
DEBRIS_NOT_RECYCLED_COUNT = 0

local quadrants = {
    {
        { 1, 1 },
        { 3, 1 },
        { 1, 3 },
        { 3, 3 }
    },
    {
        { -3, 1 },
        { -1, 1 },
        { -3, -1 },
        { -1, -1 }
    },
    {
        { -3, -3 },
        { -1, -3 },
        { -3, -1 },
        { -1, -1 }
    },
    {
        { 1, -3 },
        { 3, -3 },
        { 1, -1 },
        { -3, -1 }
    }
}

function DebrisManager:init(recyclerManager)
    DebrisManager.super.init(self)
    ACTIVE_DEBRIS = {}
    DEBRIS_NOT_RECYCLED_COUNT = 0

    self.recyclerManager = recyclerManager
    self:add()
end

function DebrisManager:update()
    if not IS_GAME_STARTED then
        return
    end

    if not WAS_GAME_ACTIVE_LAST_CHECK then
        return
    end

    local debrisToExpire = utils.arrayRemove(ACTIVE_DEBRIS,
    function(debris)
        return debris.gameActiveElapsedSecondsAtCreation + expirationDuration < GAME_ACTIVE_ELAPSED_SECONDS 
    end)
    
    for i = 1, #debrisToExpire do
        debrisToExpire[i]:expire()
    end
end

function DebrisManager:spawnDebris(spawnX, spawnY)
    local debrisSpawnCount = math.random(minDebris, maxDebris)
    local gameActiveElapsedSeconds = GAME_ACTIVE_ELAPSED_SECONDS

    local debrisSpawnPositions = self:getDebrisSpawnPositions(spawnX, spawnY, debrisSpawnCount)
    for i = 1, debrisSpawnCount do
        local debris = Debris(debrisSpawnPositions[i][1], debrisSpawnPositions[i][2], self, gameActiveElapsedSeconds)
        table.insert(ACTIVE_DEBRIS, debris)
        DEBRIS_NOT_RECYCLED_COUNT += 1
    end
end

function DebrisManager:getDebrisSpawnPositions(spawnX, spawnY, noOfDebrisToSpawn)
    local possibleDebrisPositions = {}
    for i = 1, #quadrants do
        possibleDebrisPositions[i] = {}
        for j = 1, #quadrants[i] do
            local xOffset = quadrants[i][j][1] * debrisCenter
            local yOffset = quadrants[i][j][2] * debrisCenter
            table.insert(possibleDebrisPositions[i], { spawnX + xOffset, spawnY + yOffset })
        end
    end

    local spawnPositions = {}
    while #spawnPositions < noOfDebrisToSpawn do
        for i = 1, #possibleDebrisPositions do
            -- repeat populating the grid after first 4 debris
            if i == 4 then
                i = 1
            end
            local spawnPositionIndex = math.random(1, #possibleDebrisPositions[i])
            local spawnPosition = possibleDebrisPositions[i][spawnPositionIndex]
            table.insert(spawnPositions, { spawnPosition[1], spawnPosition[2] })
            table.remove(possibleDebrisPositions[i], spawnPositionIndex)
        end
    end

    return spawnPositions
end

function DebrisManager:removeDebris(debris)
    for i = 1, #ACTIVE_DEBRIS do
        if ACTIVE_DEBRIS[i] == debris then
            self.recyclerManager:assignDebris()
            table.remove(ACTIVE_DEBRIS, i)
            break
        end
    end
end
