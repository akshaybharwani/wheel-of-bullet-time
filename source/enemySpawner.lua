import "enemy"

local pd <const> = playdate

enemyA = {
    hp = 1,
    attackColliderSize = 22,
    shieldColliderSize = 26,
    baseImagePath = "images/enemy_a",
    explostionImagePath = "images/enemy_explosionattack_a"
}

enemyB = {
    hp = 3,
    attackColliderSize = 26,
    shieldColliderSize = 30,
    baseImagePath = "images/enemy_b",
    explostionImagePath = "images/enemy_explosionattack_bc"
}

enemyC = {
    hp = 5,
    attackColliderSize = 40,
    shieldColliderSize = 46,
    baseImagePath = "images/enemy_c",
    explostionImagePath = "images/enemy_explosionattack_bc"
}

enemies = { enemyA, enemyB, enemyC }

function setupEnemySpawn()
    setupEnemySpawnerTimer()
end

function setupEnemySpawnerTimer()
    local enemySpawnTimer = pd.timer.new(5000)
    enemySpawnTimer.repeats = true
    enemySpawnTimer.timerEndedCallback = function(timer)
        spawnEnemy()
    end
end

function spawnEnemy()
    --[[ if pd.getCrankChange() == 0 then
        return
    end ]]
    local enemyToSpawn = enemies[math.random(1, #enemies)]
    local enemy = Enemy(enemyToSpawn)
end
