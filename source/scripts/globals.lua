-- some notes for current state and libraries
-- current default FPS for every animation is 30 and the value that is used goes by variable called tickStep = 1
-- so, tickStep = 2 is every second frame, making animation 15fps. As the update still happens frame based, 
-- not sure how float values will work here. TODO: revisit this

-- opening animation
OPENING_ANIMATION = {}
OPENING_ANIMATION.recyclerSpawnDuration = 2000
OPENING_ANIMATION.debrisSpawnDuration = 1000
OPENING_ANIMATION.debrisGroupAtStartCount = 4
-- includes the cloud outside the max screen width
OPENING_ANIMATION.cloudAtStartCount = 7

-- debris
DEBRIS_CONSTANTS = {}
DEBRIS_CONSTANTS.spawnAnimationFPS = 1.2
DEBRIS_CONSTANTS.toRecycleDuration = 1000

-- bullet
BULLET_CONSTANTS = {}
BULLET_CONSTANTS.bulletSpeed = 16
BULLET_CONSTANTS.bulletTrailDistance = 8

-- bulletDisplay
BULLET_DISPLAY_CONSTANTS = {}
-- space between each number 
BULLET_DISPLAY_CONSTANTS.numberPadding = 1

-- recycler
RECYCLER_CONSTANTS = {}
RECYCLER_CONSTANTS.ammoGenerationTime = 500
RECYCLER_CONSTANTS.debrisTravelDuration = 1000
RECYCLER_CONSTANTS.maxHP = 4

-- gun
GUN_CONSTANTS = {}
GUN_CONSTANTS.maxHP = 4

-- gun shooter
GUN_SHOOTER_CONSTANTS = {}
GUN_SHOOTER_CONSTANTS.maxFiringCooldown = 0.5