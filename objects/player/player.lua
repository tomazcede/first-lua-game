anim8 = require "libraries.anim8"
camera = require "libraries.camera"
    
local player = {}

player.cam = camera()
love.graphics.setDefaultFilter("nearest", "nearest")

player.max_stamina = 300
player.max_hp = 300
player.walk_speed = 3
player.run_speed = 6
player.vx = 0
player.vy = 0

player.state = "idle"
player.direction = "down"
player.lastDirection = "down"
player.sheet = player.idle_sheet
player.speed = player.walk_speed

player.stamina = player.max_stamina
player.stamina_run_threshold = (player.max_stamina * 2) / 7
player.hp = player.max_hp

player.walk_sheet = love.graphics.newImage("objects/player/sprites/Fox/Fox_walk.png")
player.idle_sheet = love.graphics.newImage("objects/player/sprites/Fox/Fox_Idle.png")
player.run_sheet = love.graphics.newImage("objects/player/sprites/Fox/Fox_Run.png")
player.shadow_sheet = love.graphics.newImage("objects/player/sprites/Fox/Fox_Shadow.png")

player.six_grid = anim8.newGrid(32, 32, player.walk_sheet:getWidth(), player.walk_sheet:getHeight() )
player.four_grid = anim8.newGrid(32, 32, player.idle_sheet:getWidth(), player.idle_sheet:getHeight() )
player.shadow_grid = anim8.newGrid(32, 16, player.idle_sheet:getWidth(), player.idle_sheet:getHeight() )

player.animations = {}
player.animations.move = {}
player.animations.move["down"] = anim8.newAnimation( player.six_grid("1-6", 1), 0.2 )
player.animations.move["up"] = anim8.newAnimation( player.six_grid("1-6", 2), 0.2 )
player.animations.move["left"] = anim8.newAnimation( player.six_grid("1-6", 3), 0.2 )
player.animations.move["right"] = anim8.newAnimation( player.six_grid("1-6", 4), 0.2 )

player.animations.idle = {}
player.animations.idle["down"] = anim8.newAnimation( player.four_grid("1-4", 1), 0.2 )
player.animations.idle["up"] = anim8.newAnimation( player.four_grid("1-4", 2), 0.2 )
player.animations.idle["left"] = anim8.newAnimation( player.four_grid("1-4", 3), 0.2 )
player.animations.idle["right"] = anim8.newAnimation( player.four_grid("1-4", 4), 0.2 )

player.anim = player.animations.idle["down"]

function player.updateCollider()
    player.colliderV:setLinearVelocity(player.vx, player.vy)
    player.colliderH:setLinearVelocity(player.vx, player.vy)

    player.colliderV:setPosition(player.collider:getPosition())
    player.colliderH:setPosition(player.collider:getPosition())

    if player.direction == "up" or player.direction == "down" then
        player.colliderV:setSensor(false)
        player.colliderH:setSensor(true)

        player.collider = player.colliderV
    else
        player.colliderH:setSensor(false)
        player.colliderV:setSensor(true)

        player.collider = player.colliderH
    end
end

function player.handleStamina()
    if player.state == "idle" then
        if(player.stamina < player.max_stamina) then
            player.stamina = player.stamina + 4
        end
    elseif player.state == "running" and player.stamina > 0 then
        player.stamina = player.stamina - 2
    elseif player.stamina >= player.stamina_run_threshold and player.stamina < player.max_stamina then
        player.stamina = player.stamina + 2
    elseif player.stamina < player.stamina_run_threshold and player.stamina < player.max_stamina then
        player.stamina = player.stamina + 0.25
    end

    if(player.stamina > player.max_stamina) then
        player.stamina = player.max_stamina
    end

    if(player.stamina < 0) then
        player.stamina = 0
    end
end

function player.setRunning()
    player.speed = player.run_speed
    player.sheet = player.run_sheet
    player.state = "running"
end

function player.setWalking()
    player.speed = player.walk_speed
    player.sheet = player.walk_sheet
    player.state = "walking"
end

function player.setIdle()
    player.state = "idle"
    player.sheet = player.idle_sheet

    player.anim = player.animations.idle[player.direction]
end

function player.moveInDirection(direction)
    local moveIn = direction

    if direction == "right" then
        player.vx = player.speed * 100
        if player.state == "running" then
            moveIn = "left"
        end
    elseif direction == "left" then
        player.vx = player.speed * -100
        if player.state == "running" then
            moveIn = "right"
        end
    elseif direction == "up" then
        player.vy = player.speed * -100
    elseif direction == "down" then
        player.vy = player.speed * 100
    end
    
    player.direction = direction
    player.anim = player.animations.move[moveIn]
end

function player.handleMovement() 
    player.vx = 0
    player.vy = 0

    if (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")) and player.stamina > 0 then
        player:setRunning()
    else
        player:setWalking()
    end

    if love.keyboard.isDown("d") then
        player.moveInDirection("right")
    end

    if love.keyboard.isDown("a") then
        player.moveInDirection("left")
    end

    if love.keyboard.isDown("s") then
        player.moveInDirection("down")
    end

    if love.keyboard.isDown("w") then
        player.moveInDirection("up")
    end

    player:updateCollider()

    if player.vx == 0 and player.vy == 0 then
        player.setIdle()
    end
end

function player.init(world)
    player.x = 500
    player.y = 300

    -- vertical (up/down)
    player.colliderV = world:newBSGRectangleCollider(500, 200, 70, 120, 14)
    player.colliderV:setFixedRotation(true)

    -- horizontal (left/right)
    player.colliderH = world:newBSGRectangleCollider(500, 200, 200, 120, 14)
    player.colliderH:setFixedRotation(true)

    player.collider = player.colliderV
    player.colliderH:setSensor(true)
end

return player