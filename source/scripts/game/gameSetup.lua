local pd <const> = playdate
local gfx <const> = pd.graphics

local utils <const> = UTILITIES

class("GameSetup").extends(gfx.sprite)

IS_GAME_ACTIVE = false
-- as the crankCheckWaitDuration is non-zero, the animation relying on IS_GAME_ACTIVE will
-- continously won't work properly, this can be used to help with that
WAS_GAME_ACTIVE_LAST_CHECK = false

IS_GAME_STARTED = false
IS_GAME_SETUP_DONE = false
IS_GUN_DISABLED = false
IS_GAME_OVER = false

local openingAnimationConstants = OPENING_ANIMATION_CONSTANTS

local waitDurationToSpawnRecyclers = openingAnimationConstants.waitDurationToSpawnRecyclers
local waitDurationToSpawnDebris = openingAnimationConstants.waitDurationToSpawnDebris
local debrisGroupAtStartCount = openingAnimationConstants.debrisGroupAtStartCount

local titleImagePath = "images/background/Title"

function GameSetup:init()
    GameSetup.super.init(self)
    self:setupGameVariables()

    self.gameStartSound = SfxPlayer(SFX_FILES.game_start)
    self.warningSirenSound = SfxPlayer(SFX_FILES.warning_sirens)

    self.titleSprite = gfx.sprite.new(gfx.image.new(titleImagePath))
    self.titleSprite:moveTo(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT)
    self.titleSprite:setZIndex(BANNER_Z_INDEX)
    self.titleSprite:add()

    self.titleTimer = pd.timer.new(TITLE_CONSTANTS.titleDuration)
    self.titleTimer.timerEndedCallback = function(timer)
        self.titleTimerEnded = true
    end

    self:add()
end

function GameSetup:update()
    if self.titleTimerEnded and not self.gameEntitiesSetupStarted then
        if utils.checkActionButtonInput() then
            self:setupGameEntities()
            self.gameEntitiesSetupStarted = true
        end
    end

    if self.openingDebrisSpawned and not self.initialDebrisCollected then
        if #ACTIVE_DEBRIS <= 0 then
            NOTIFICATION_CENTER:notify(NOTIFY_GAME_STARTED)
            self.initialDebrisCollected = true
        end
    end
end

function GameSetup:setupGameVariables()
    math.randomseed(pd.getSecondsSinceEpoch())
    pd.resetElapsedTime()

    -- TODO: add all relevant variables

    IS_GAME_ACTIVE = false
    WAS_GAME_ACTIVE_LAST_CHECK = false

    IS_GAME_STARTED = false
    IS_GAME_SETUP_DONE = false
    IS_GUN_DISABLED = false
    IS_GAME_OVER = false

    self.currentRecyclerIndex = 0
    self.currentDebrisCount = 0

    self.openingDebrisSpawned = false
    self.initialDebrisCollected = false
    self.titleTimerEnded = false
    self.gameEntitiesSetupStarted = false
end

function GameSetup:setupGameEntities()
    self.titleSprite:remove()
    self.gameStartSound:play()

    NotificationCenter()
    CrankInput()
    self.gunManager = GunManager()
    -- ? is assigning a manager to initialization of another manager a good idea?
    self.recyclerManager = RecyclerManager(self.gunManager)
    self.debrisManager = DebrisManager(self.recyclerManager)

    local warningSirenDelayTimer = pd.timer.new(self.gameStartSound:getLength() * 1000)
    warningSirenDelayTimer.timerEndedCallback = function(timer)
        self.warningSirenSound:play()
        self:setupRecyclerSpawn()
    end

    Background()
    TimeDisplay()
    GameOver(self.gunManager)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GAME_STARTED, self, function()
        EnemyManager(self.debrisManager)
        IS_GAME_STARTED = true
    end)
    
    -- TODO: move to DebrisManager
    self:spawnDebris()
end

function GameSetup:setupRecyclerSpawn()
    local recyclerSpawningDelayTimer = pd.timer.new(self.warningSirenSound:getLength() * 1000)
    recyclerSpawningDelayTimer.timerEndedCallback = function(timer)
        -- spawn first recycler as soon as the siren ends, start timer which waits for other spawning
        self:showRecycler()
        self:showRecyclers()
    end
end

function GameSetup:showRecyclers()
    self.recyclerSpawningTimer = pd.timer.new(waitDurationToSpawnRecyclers)
    self.recyclerSpawningTimer.discardOnCompletion = false
    self.recyclerSpawningTimer.repeats = true
    self.recyclerSpawningTimer.timerEndedCallback = function(timer)
        if self.currentRecyclerIndex < #ACTIVE_RECYCLERS then
            self:showRecycler()
        else
            self.recyclerSpawningTimer:remove()
            self.debrisSpawningTimer:start()
        end
    end
end

function GameSetup:showRecycler()
    self.currentRecyclerIndex += 1
    local recycler = ACTIVE_RECYCLERS[self.currentRecyclerIndex]
    recycler:addSprite()
end

function GameSetup:spawnDebris()
    self.debrisSpawningTimer = pd.timer.new(waitDurationToSpawnDebris)
    self.debrisSpawningTimer:pause()
    self.debrisSpawningTimer.discardOnCompletion = false
    self.debrisSpawningTimer.repeats = true
    self.debrisSpawningTimer.timerEndedCallback = function(timer)
        if self.currentDebrisCount < debrisGroupAtStartCount then
            self.currentDebrisCount += 1
            local spawnX = math.random(16, SCREEN_WIDTH - 16)
            local spawnY = math.random(16, HALF_SCREEN_HEIGHT)
            self.debrisManager:spawnDebris(spawnX, spawnY)
        else
            self.debrisSpawningTimer:remove()
            IS_GAME_SETUP_DONE = true
            self.openingDebrisSpawned = true
        end
    end
end

-- use this for debugging inside simulator
--[[ function pd.keyPressed(key)
    if (key == "q") then
        disableGun()
    end

    if (key == "u") then
        print("yeah debugging!")
    end
end ]]
