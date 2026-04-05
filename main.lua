if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()
    anim8 = require "libraries/anim8"
    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.x = 0
    player.y = 0
    player.speed = 3
    player.stamina_run_threshold = 200
    player.max_stamina = 500
    player.walk_speed = 3
    player.run_speed = 6

    player.stamina = player.max_stamina

    player.walk_sheet = love.graphics.newImage("sprites/Fox/Fox_walk.png")
    player.idle_sheet = love.graphics.newImage("sprites/Fox/Fox_Idle.png")
    player.run_sheet = love.graphics.newImage("sprites/Fox/Fox_Run.png")
    player.shadow_sheet = love.graphics.newImage("sprites/Fox/Fox_Shadow.png")

    player.six_grid = anim8.newGrid(32, 32, player.walk_sheet:getWidth(), player.walk_sheet:getHeight() )
    player.four_grid = anim8.newGrid(32, 32, player.idle_sheet:getWidth(), player.idle_sheet:getHeight() )
    player.shadow_grid = anim8.newGrid(32, 16, player.idle_sheet:getWidth(), player.idle_sheet:getHeight() )

    player.animations = {}
    player.animations.move_down = anim8.newAnimation( player.six_grid("1-6", 1), 0.2 )
    player.animations.move_up = anim8.newAnimation( player.six_grid("1-6", 2), 0.2 )
    player.animations.move_left = anim8.newAnimation( player.six_grid("1-6", 3), 0.2 )
    player.animations.move_right = anim8.newAnimation( player.six_grid("1-6", 4), 0.2 )

    player.animations.idle_down = anim8.newAnimation( player.four_grid("1-4", 1), 0.2 )
    player.animations.idle_up = anim8.newAnimation( player.four_grid("1-4", 2), 0.2 )
    player.animations.idle_left = anim8.newAnimation( player.four_grid("1-4", 3), 0.2 )
    player.animations.idle_right = anim8.newAnimation( player.four_grid("1-4", 4), 0.2 )

    player.anim = player.animations.idle_down
    player.direction = "down"
    player.sheet = player.idle_sheet

    background = love.graphics.newImage("sprites/background.png")
end

function handleMovement(dt) 
    local playerX = player.x
    local playerY = player.y

    if (love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")) and player.stamina > 0 then
        player.speed = player.run_speed
        player.sheet = player.run_sheet
    else
        player.speed = player.walk_speed
        player.sheet = player.walk_sheet
    end

    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed
        if player.speed == player.run_speed then
            player.anim = player.animations.move_left
        else
            player.anim = player.animations.move_right
        end
        player.direction = "right"
    end

    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
        if player.speed == player.run_speed then
            player.anim = player.animations.move_right
        else
            player.anim = player.animations.move_left
        end
       
        player.direction = "left"
    end

    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed
        player.anim = player.animations.move_down
        player.direction = "down"
    end

    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed
        player.anim = player.animations.move_up
        player.direction = "up"
    end

    if player.x == playerX and player.y == playerY then
        player.sheet = player.idle_sheet
        if(player.stamina < player.max_stamina) then
            player.stamina = player.stamina + 4
        end

        if player.direction == "down" then
            player.anim = player.animations.idle_down
        elseif player.direction == "up" then
            player.anim = player.animations.idle_up
        elseif player.direction == "left" then
            player.anim = player.animations.idle_left
        elseif player.direction == "right" then
            player.anim = player.animations.idle_right
        end
    elseif player.speed == player.run_speed and player.stamina > 0 then
        player.stamina = player.stamina - 2
    elseif player.stamina > player.stamina_run_threshold and player.stamina < player.max_stamina then
        player.stamina = player.stamina + 2
    end

    if(player.stamina > player.max_stamina) then
        player.stamina = player.max_stamina
    end

    if(player.stamina < 0) then
        player.stamina = 0
    end
end

function love.update(dt)
    handleMovement(dt)

    player.anim:update(dt)
end

function love.draw()
    love.graphics.draw(background, 0, 0)
    player.anim:draw(player.sheet, player.x, player.y, nil, 4)
    love.graphics.rectangle("fill", 0, 0, player.stamina, 10)
    love.graphics.setColor(255,0,0)
    love.graphics.line(player.stamina_run_threshold, 0, player.stamina_run_threshold, 10)
    love.graphics.setColor(255,255,255)
end

local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end