-- some notes for current state and libraries

-- * FPS
-- current default FPS for every animation is 30 and the value that is used goes by variable called tickStep = 1
-- so, tickStep = 2 is every second frame, making animation 15fps. As the update still happens frame based, 
-- not sure how float values will work here. TODO: revisit this

-- * Time/Duration
-- It's in milliseconds, ex put 500 for 0.5 seconds.

-- core game
CORE_GAME_CONSTANTS = {}
CORE_GAME_CONSTANTS.crankCheckWaitDuration = 100

-- title
TITLE_CONSTANTS = {}
TITLE_CONSTANTS.titleDuration = 2000

-- opening animation
OPENING_ANIMATION_CONSTANTS = {}
OPENING_ANIMATION_CONSTANTS.waitDurationToSpawnRecyclers = 1000
OPENING_ANIMATION_CONSTANTS.waitDurationToSpawnDebris = 1000
OPENING_ANIMATION_CONSTANTS.debrisGroupAtStartCount = 4
-- includes the cloud outside the max screen width
OPENING_ANIMATION_CONSTANTS.cloudsAtStartCount = 7

-- debris
DEBRIS_CONSTANTS = {}
DEBRIS_CONSTANTS.spawnAnimationFPS = 1.2
DEBRIS_CONSTANTS.toRecycleDuration = 1000
DEBRIS_CONSTANTS.minDebris, DEBRIS_CONSTANTS.maxDebris = 3, 8

-- recycler
RECYCLER_CONSTANTS = {}
RECYCLER_CONSTANTS.ammoGenerationDuration = 500
RECYCLER_CONSTANTS.debrisTravelDuration = 1000
RECYCLER_CONSTANTS.maxHP = 4
-- connector are the pipes going from recyclers to the gun
RECYCLER_CONSTANTS.connectorAnimationDuration = 500
RECYCLER_CONSTANTS.maxRecyclerCount = 5
RECYCLER_CONSTANTS.debrisHoldDuration = 300

-- gun
GUN_CONSTANTS = {}
GUN_CONSTANTS.maxHP = 4
GUN_CONSTANTS.animationFPS = 2

-- gun shooter
GUN_SHOOTER_CONSTANTS = {}
GUN_SHOOTER_CONSTANTS.maxFiringCooldown = 500

-- gun vacuum
GUN_VACUUM_CONSTANTS = {}
GUN_VACUUM_CONSTANTS.vacuumAreaWidth = 32
GUN_VACUUM_CONSTANTS.vacuumLength = 1000
GUN_VACUUM_CONSTANTS.vacuumVaporDistance = 32
GUN_VACUUM_CONSTANTS.vacuumVaporCount = 10

-- bullet
BULLET_CONSTANTS = {}
BULLET_CONSTANTS.bulletSpeed = 16
BULLET_CONSTANTS.bulletTrailDistance = 8

-- ui
UI_CONSTANTS = {}
UI_CONSTANTS.numberPadding = 1

-- bulletDisplay
BULLET_DISPLAY_CONSTANTS = {}
-- space between each number 
BULLET_DISPLAY_CONSTANTS.bounceTotalDuration = 100
BULLET_DISPLAY_CONSTANTS.bounceHeight = 3

-- game over
GAME_OVER_CONSTANTS = {}
GAME_OVER_CONSTANTS.gameOverWaitDuration = 5000

-- enemy general settings
ENEMY_CONSTANTS = {}
ENEMY_CONSTANTS.minSpeed, ENEMY_CONSTANTS.maxSpeed = 5, 10
ENEMY_CONSTANTS.hitAnimationDuration = 100
ENEMY_CONSTANTS.explosionAnimationLoopCount = 3
ENEMY_CONSTANTS.explosionAnimationFPS = 5
ENEMY_CONSTANTS.minTotalPatrolDuration, ENEMY_CONSTANTS.maxTotalPatrolDuration = 2, 5
ENEMY_CONSTANTS.minPatrolSegmentDuration, ENEMY_CONSTANTS.maxPatrolSegmentDuration = 1, 2

ENEMY_CONSTANTS.enemySpawnWaitDuration = 5000 -- here this is number of seconds instead of miliseconds elsewhere
ENEMY_CONSTANTS.oneWaveDuration = 30000
ENEMY_CONSTANTS.maxEnemyRate = 6

-- enemy data
-- * Go to scripts/enemyManager for setting individual enemy data
-- TODO: Move these settings to a json file

-- high score
HIGH_SCORE_CONSTANTS = {}
HIGH_SCORE_CONSTANTS.maxScores = 5