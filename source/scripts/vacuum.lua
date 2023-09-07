import "CoreLibs/crank"
import "CoreLibs/animation"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Vacuum").extends(gfx.sprite)

local vacuumAreaWidth = 32

local gunVacuumAnimationLoop = nil

function Vacuum:init(x, y)
    Vacuum.super.init(self)
    local vacuumImage = gfx.image.new(vacuumAreaWidth, MAX_SCREEN_HEIGHT)
    gfx.pushContext(vacuumImage)
        gfx.drawRect(0, 0, vacuumAreaWidth, MAX_SCREEN_HEIGHT)
    gfx.popContext()
    self:setImage(vacuumImage)
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(DEBRIS_GROUP)
    self:setCollidesWithGroups({ DEBRIS_GROUP })
    self:moveTo(MAX_SCREEN_WIDTH / 2, GUN_BASE_Y)
    self:setCenter(0.5, 1)
    self:setupAnimation()
    self:add()
    self:setVisible(false)
end

function Vacuum:setupAnimation()
    local animationImageTable = gfx.imagetable.new("images/gun_vacuum")
    gunVacuumAnimationLoop = gfx.animation.loop.new()
    gunVacuumAnimationLoop.paused = true
    gunVacuumAnimationLoop:setImageTable(animationImageTable)
end

function Vacuum:collectDebris()
    self:setVisible(true)
    -- show additional vacuum animations
    local collisions = self:overlappingSprites()
    local angleRad = math.rad(GUN_CURRENT_ROTATION_ANGLE - 90)
    local dx = math.cos(angleRad)
    local dy = math.sin(angleRad)

    -- local sprites = gfx.sprite.querySpritesAlongLine(GUN_BASE_X, GUN_BASE_Y, 200 + dx, 120 + dy)

    for i = 1, #collisions do
        local collidedObject = collisions[i]
        if collidedObject.type == "debris" then

            collidedObject:collect()
            return
        end
    end

    -- show animation of debris collection
end

function Vacuum:checkGunState()
    if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        gunVacuumAnimationLoop.paused = false
        GUN_TOP_SPRITE:setImage(gunVacuumAnimationLoop:image())

        if (CURRENT_CRANK_SHOOTING_TICKS == -1) then
            self:collectDebris()
        end
    else
        self:setVisible(false)
    end
end

function Vacuum:update()
    gfx.setLineWidth(20)
    gfx.drawLine(0, 0, 400, 240)
    if not IS_GAME_ACTIVE then
        gunVacuumAnimationLoop.paused = true
        return
    end
    self:checkGunState()
end
