import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/gun"
import "scripts/recycler"

-- gun
local gunBaseSize = 64
gunBaseX, gunBaseY = 0, 0

-- recycler
local maxRecyclerCount = 5
local recyclerSize = 32

local activeRecyclers = {}

local function isOverlappingGunElements(pairs, x, gunStartX, gunEndX)
    -- logic to check if it doesn't overlap gun base
    if (x - recyclerSize / 2 <= gunEndX
    and x + recyclerSize / 2 >= gunStartX) then
        return true
    end

    for _, pair in ipairs(pairs) do
        local distanceBetweenX = math.abs(pair.x - x)
        if distanceBetweenX < recyclerSize then
            return true
        end
    end
    return false
end

local function generateRecyclerPositions(numPairs, minX, maxX, maxY)
    -- Why doesn't this work?
    -- math.randomseed(os.time())
    local gunStartX = gunBaseX - gunBaseSize / 2
    local gunEndX = gunBaseX + gunBaseSize / 2
    local pairs = {}

    while #pairs < numPairs do
        local x = math.random(minX, maxX)
        local y = maxY

        if not isOverlappingGunElements(pairs, x, gunStartX, gunEndX) then
            table.insert(pairs, { x = x, y = y })
        end
    end

    return pairs
end

local function spawnRecyclers()
    local recyclerCenterPos = recyclerSize / 2
    local pairs = generateRecyclerPositions(maxRecyclerCount, recyclerCenterPos,
        maxScreenWidth - recyclerCenterPos, maxScreenHeight - recyclerCenterPos)

    for _, pair in ipairs(pairs) do
        table.insert(activeRecyclers, Recycler(pair.x, pair.y))
    end
end

function setupGun()
    drawGunBase()
    setupVacuumArea()
    spawnRecyclers()
    setupCrankInputTimer()
    setupGunAnimation()
end

function updateGun()
    setFiringCooldown()
    readRotationInput()
end
