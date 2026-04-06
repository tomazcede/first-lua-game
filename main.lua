player = require "objects.player.player"
playerCamera = require "ui.playerCamera"
ui = require "ui.ui"

if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()
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
    player.handleMovement()
    player.handleStamina()

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    if player.y < 100 then
        player.y = 100
        player.collider:setPosition(player.collider:getX(), 100)
    end

    player.anim:update(dt)
    playerCamera.handleCamera(gameMap, player)
end

function love.draw()
    playerCamera.attachCam(gameMap, player, world)

    ui.drawUi()
end

local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end