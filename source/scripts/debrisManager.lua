import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/debris"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('DebrisManager').extends(gfx.sprite)

local gridSize = 64
local debrisSize = 16
local debrisCenter = (gridSize / 4) - (debrisSize / 2)

local minDebris, maxDebris = 3, 8
local debrisActiveDuration = 1000

ACTIVE_DEBRIS = {}

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

function DebrisManager:init()
    DebrisManager.super.init(self)
    self:add()
end

function DebrisManager:spawnDebris(enemyX, enemyY)
    local noOfDebrisToSpawn = math.random(minDebris, maxDebris)

    local debrisSpawnPositions = self:getDebrisSpawnPositions(enemyX, enemyY, noOfDebrisToSpawn)
    for i = 1, noOfDebrisToSpawn do
        table.insert(ACTIVE_DEBRIS, Debris(debrisSpawnPositions[i][1], debrisSpawnPositions[i][2], self))
    end
    -- remove debtis after some time
    --[[ local activeAnimator = pd.timer.new(debrisActiveDuration)
    activeAnimator.timerEndedCallback = function(timer)
        for i = 1, #debris do
            debris[i]:remove()
        end
    end ]]
end

function DebrisManager:getDebrisSpawnPositions(enemyX, enemyY, noOfDebrisToSpawn)
    local possibleDebrisPositions = {}
    for i = 1, #quadrants do
        possibleDebrisPositions[i] = {}
        for j = 1, #quadrants[i] do
            local xOffset = quadrants[i][j][1] * debrisCenter
            local yOffset = quadrants[i][j][2] * debrisCenter
            table.insert(possibleDebrisPositions[i], { enemyX + xOffset, enemyY + yOffset })
        end
    end

    --[[ for _, pos in ipairs(possibleDebrisPositions) do
        for _, posi in ipairs(pos) do
            print(posi[1] .. " , " .. posi[2])
        end
    end ]]

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
            -- TODO: removing an element while iterating over it, instead set the element to nil
            table.remove(possibleDebrisPositions[i], spawnPositionIndex)
        end
    end

    --[[ print("-- spawn positions --")
    for _, pos in ipairs(spawnPositions) do
        print(pos[1] .. " , " .. pos[2])
    end ]]

    return spawnPositions
end

function DebrisManager:removeDebris(debris)
    for i = 1, #ACTIVE_DEBRIS do
        if ACTIVE_DEBRIS[i] == debris then
            ACTIVE_DEBRIS[i] = nil
        end
    end
end
