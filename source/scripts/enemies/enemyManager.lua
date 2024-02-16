import "scripts/enemies/enemy"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('EnemyManager').extends(gfx.sprite)

local enemyConstants = ENEMY_CONSTANTS

local enemySpawnWaitDuration = enemyConstants.enemySpawnWaitDuration
local oneWaveDuration = enemyConstants.oneWaveDuration
local maxEnemySpawnRate = enemyConstants.maxEnemySpawnRate
local maxEnemiesOnScreen = enemyConstants.maxEnemiesOnScreen

local explosionImagePath = "images/enemies/enemy_explosion-table-64-64"

local enemyA = {
    hp = 2,
    attackColliderSize = 22,
    shieldColliderSize = 26,
    baseImagePath = "images/enemies/enemy_a",
    explosionImageTable = gfx.imagetable.new(explosionImagePath),
    deathSound = SfxPlayer(SFX_FILES.enemy_dead_type1)
}

local enemyB = {
    hp = 6,
    attackColliderSize = 26,
    shieldColliderSize = 30,
    baseImagePath = "images/enemies/enemy_b",
    explosionImageTable = gfx.imagetable.new(explosionImagePath),
    deathSound = SfxPlayer(SFX_FILES.enemy_dead_type3)
}

local enemyC = {
    hp = 10,
    attackColliderSize = 40,
    shieldColliderSize = 46,
    baseImagePath = "images/enemies/enemy_c",
    explosionImageTable = gfx.imagetable.new(explosionImagePath),
    deathSound = SfxPlayer(SFX_FILES.enemy_dead_type5)
}

local enemies = { enemyA, enemyB, enemyC }

function EnemyManager:init(debrisManager)
    EnemyManager.super.init(self)
    self.currentEnemySpawnRate = 1
    self.currentWaveDuration = 0
    self.isGunDisabled = false
    -- TODO: enemies are not removed when they are killed
    self.enemies = {}

    self.debrisManager = debrisManager
    self.gameActiveSpawnTimer = CrankTimer(enemySpawnWaitDuration / 1000, true, function()
        self:handleEnemySpawning()
    end)
    self:handleEnemySpawning()
    self:setupGunDisabledSpawnTimer()
    NOTIFICATION_CENTER:subscribe(NOTIFY_GUN_IS_DISABLED, self, function()
        self.gameActiveSpawnTimer:remove()
        self.isGunDisabled = true
        self.gunDisabledSpawnTimer:start()
    end)
    NOTIFICATION_CENTER:subscribe(NOTIFY_GAME_OVER, self, function()
        self.gunDisabledSpawnTimer:remove()
        --self:destroyAllEnemies()
    end)
    self:add()
end

function EnemyManager:update()
    if not IS_GAME_STARTED then
        return
    end

    if IS_GAME_OVER then
        return
    end

    if #ACTIVE_DEBRIS <= 0 and #self.enemies <= 0 then
        self:handleEnemySpawning()
        self.gameActiveSpawnTimer:reset()
    end
end

function EnemyManager:setupGunDisabledSpawnTimer()
    self.gunDisabledSpawnTimer = pd.timer.new(enemySpawnWaitDuration / GAME_OVER_CONSTANTS.timeMultiplier)
    self.gunDisabledSpawnTimer.repeats = true
    self.gunDisabledSpawnTimer:pause()
    self.gunDisabledSpawnTimer.timerEndedCallback = function(timer)
        self:handleEnemySpawning()
    end
end

function EnemyManager:handleEnemySpawning()
    self:handleEnemyWave()
    self:spawnEnemies()
end

function EnemyManager:spawnEnemies()
    if #self.enemies > maxEnemiesOnScreen then
        return
    end
    for i = 1, self.currentEnemySpawnRate do
        local enemyToSpawn = enemies[math.random(1, #enemies)]
        local enemy = Enemy(enemyToSpawn, self, self.debrisManager, self.isGunDisabled)
        table.insert(self.enemies, enemy)
    end

end

function EnemyManager:handleEnemyWave()
    if (maxEnemySpawnRate > self.currentEnemySpawnRate) then
        self.currentWaveDuration += enemySpawnWaitDuration
        if (self.currentWaveDuration >= oneWaveDuration) then
            self.currentEnemySpawnRate += 1
            self.currentWaveDuration = 0
        end
    end
end

function EnemyManager:removeEnemy(enemy)
    for i = 1, #self.enemies do
        if self.enemies[i] == enemy then
            table.remove(self.enemies, i)
            enemy:remove()
            break
        end
    end
end

function EnemyManager:destroyAllEnemies()
    for i = 1, #self.enemies do
        self.enemies[i]:remove()
    end
end