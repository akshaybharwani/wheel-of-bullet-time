import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "scripts/recycler"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('RecyclerManager').extends(gfx.sprite)

local maxRecyclerCount = 1
local activeRecyclers = {}

local debrisHoldTime = 300
local collectedDebris = 0

function RecyclerManager:init()
    RecyclerManager.super.init(self)

    self.holdDebrisTimer = pd.timer.new(debrisHoldTime)
    self.holdDebrisTimer:pause()
    self.holdDebrisTimer.discardOnCompletion = false
    self.holdDebrisTimer.repeats = true
    self.holdDebrisTimer.timerEndedCallback = function(timer)
        if collectedDebris > 0 then
            for i = 1, #activeRecyclers do
                if activeRecyclers[i].available == true then
                    activeRecyclers[i]:sendDebrisToRecycler()
                    collectedDebris -= 1
                    break
                end
            end
        else
            self.holdDebrisTimer:pause()
        end
    end

    self:spawnRecyclers()
    self:add()
end

function RecyclerManager:spawnRecyclers()
    local recyclerCenterPos = RECYCLER_SIZE / 2
    local pairs = self:generateRecyclerPositions(maxRecyclerCount, recyclerCenterPos,
        MAX_SCREEN_WIDTH - recyclerCenterPos, MAX_SCREEN_HEIGHT - recyclerCenterPos)

    local leftToGunRecyclers = {}
    local rightToGunRecyclers = {}
    for i = 1, #pairs do
        if (pairs[i].x < MAX_SCREEN_WIDTH / 2) then
            table.insert(leftToGunRecyclers, pairs[i])
        else
            table.insert(rightToGunRecyclers, pairs[i])
        end
    end

    table.sort(leftToGunRecyclers, function(a, b)
        return a.x > b.x
    end)

    table.sort(rightToGunRecyclers, function(a, b)
        return a.x < b.x
    end)

    local recyclerConnectorY = 10
    for i = 1, #leftToGunRecyclers do
        local recycler = Recycler(leftToGunRecyclers[i].x, leftToGunRecyclers[i].y, recyclerConnectorY, true)
        table.insert(activeRecyclers, recycler)
        table.insert(ACTIVE_TARGETS, recycler)
        recyclerConnectorY += 5
    end

    recyclerConnectorY = 10
    for i = 1, #rightToGunRecyclers do
        local recycler = Recycler(rightToGunRecyclers[i].x, rightToGunRecyclers[i].y, recyclerConnectorY, false)
        table.insert(activeRecyclers, recycler)
        table.insert(ACTIVE_TARGETS, recycler)
        recyclerConnectorY += 5
    end
end

function RecyclerManager:generateRecyclerPositions(maxCount, minX, maxX, maxY)
    local gunStartX = GUN_BASE_X - GUN_BASE_SIZE / 2
    local gunEndX = GUN_BASE_X + GUN_BASE_SIZE / 2
    local pairs = {}

    while #pairs < maxCount do
        local x = math.random(minX, maxX)
        local y = maxY

        if not isOverlappingGunElements(pairs, x, gunStartX, gunEndX) then
            table.insert(pairs, { x = x, y = y })
        end
    end

    return pairs
end

function RecyclerManager:assignDebris()
    collectedDebris += 1
    if self.holdDebrisTimer.paused == true then
        self.holdDebrisTimer:start()
    end
end
