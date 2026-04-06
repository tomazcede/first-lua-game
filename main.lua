player = require "objects.player.player"

if arg[2] == "debug" then
    require("lldebugger").start()
end

function drawUi()
    -- top bar
    love.graphics.setColor(40/255, 40/255, 40/255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)

    -- hp bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("HP:", 5, 5)
    love.graphics.setColor(80/255, 30/255, 30/255)
    love.graphics.rectangle("fill", 30, 2.5, player.max_hp + 10, 20)
    love.graphics.setColor(220/255, 60/255, 60/255)
    love.graphics.rectangle("fill", 35, 7.5, player.hp, 10)

    -- stamina bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("ST:", 5, 30)
    love.graphics.setColor(25/255, 100/255, 60/255)
    love.graphics.rectangle("fill", 30, 27.5, player.max_stamina + 10, 20)
    love.graphics.setColor(80/255, 220/255, 120/255)
    love.graphics.rectangle("fill", 35, 32.5, player.stamina, 10)
    love.graphics.setColor(20/255, 20/255, 20/255)
    love.graphics.line(player.stamina_run_threshold + 35, 32.5, player.stamina_run_threshold + 35, 42.5)

    love.graphics.setColor(1, 1, 1)
end

function handleCamera()
    cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local mapW = gameMap.width * gameMap.tilewidth
    local h = love.graphics.getHeight()
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x < w/2 then
        cam.x = w/2
    end

    if cam.y < h/2 then
        cam.y = h/2
    end

    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end
end

function love.load()
    camera = require "libraries.camera"
    cam = camera()

    anim8 = require "libraries/anim8"
    sti = require "libraries/sti"
    wf = require "libraries.windfield"
    world = wf.newWorld(0, 0)
    gameMap = sti("maps/testMap.lua")

    love.graphics.setDefaultFilter("nearest", "nearest")

    player.init(world)
    
    walls = {}
    if gameMap.layers["walls"] then
        for i, obj in pairs(gameMap.layers["walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(walls, wall)
        end
    end
end

function love.update(dt)
    player:handleMovement()
    player:handleStamina()

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    if player.y < 100 then
        player.y = 100
        player.collider:setPosition(player.collider:getX(), 100)
    end

    player.anim:update(dt)
    handleCamera()
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["ground"])
        gameMap:drawLayer(gameMap.layers["trees"])

        player.anim:draw(player.sheet, player.x, player.y, nil, 6, nil, 16, 16)
        --world:draw()
    cam:detach()

    drawUi()
end

local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end