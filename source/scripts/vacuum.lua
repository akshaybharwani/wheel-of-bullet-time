import "CoreLibs/crank"
import "CoreLibs/animation"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Vacuum").extends(gfx.sprite)

local vacuumAreaWidth = 32
local vacuumSprite = nil

local gunVacuumAnimationLoop = nil

function Vacuum:init()
    Vacuum.super.init(self)
    self:setupVacuumArea()
    self:moveTo(GUN_BASE_X, GUN_BASE_Y)
    self:setupAnimation()
    self:add()
end

function Vacuum:setupVacuumArea()
    local vacuumImage = gfx.image.new(vacuumAreaWidth, 180)
    gfx.pushContext(vacuumImage)
    gfx.drawRect(0, 0, vacuumAreaWidth, 180)
    gfx.popContext()
    vacuumSprite = gfx.sprite.new(vacuumImage)
    vacuumSprite:moveTo(MAX_SCREEN_WIDTH / 2, 120 - 32)
end

function Vacuum:setupAnimation()
    local animationImageTable = gfx.imagetable.new("images/gun_vacuum")
    gunVacuumAnimationLoop = gfx.animation.loop.new()
    gunVacuumAnimationLoop.paused = true
    gunVacuumAnimationLoop:setImageTable(animationImageTable)
end

function Vacuum:collectDebris()
    -- rotate vacuum with the gun
    -- refactor gun and everything gun related to be easy to work with
    vacuumSprite:setRotation(GUN_CURRENT_ROTATION_ANGLE)
    vacuumSprite:add()
    -- calculate current vacuum area based on gun's rotation
    -- show vacuum graphics
    -- show additional vacuum animations
    -- check for debris objects overlapping the area
    -- show animation of debris collection
end

function Vacuum:checkGunState()
    if (GUN_CURRENT_STATE == GUN_VACUUM_STATE) then
        print("vacuum")
        gunVacuumAnimationLoop.paused = false
        GUN_TOP_SPRITE:setImage(gunVacuumAnimationLoop:image())

        if (CURRENT_CRANK_SHOOTING_TICKS == -1) then
            -- self:collectDebris()
        end
    end
end

function Vacuum:update()
    if not IS_GAME_ACTIVE then
        gunVacuumAnimationLoop.paused = true
        return
    end
    self:checkGunState()
end
