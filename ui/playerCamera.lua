camera = require "libraries.camera"

local playerCamera = {}
playerCamera.cam = camera()

function playerCamera.handleCamera(gameMap, player)
    playerCamera.cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local mapW = gameMap.width * gameMap.tilewidth
    local h = love.graphics.getHeight()
    local mapH = gameMap.height * gameMap.tileheight

    if playerCamera.cam.x < w/2 then
        playerCamera.cam.x = w/2
    end

    if playerCamera.cam.y < h/2 then
        playerCamera.cam.y = h/2
    end

    if playerCamera.cam.x > (mapW - w/2) then
        playerCamera.cam.x = (mapW - w/2)
    end

    if playerCamera.cam.y > (mapH - h/2) then
        playerCamera.cam.y = (mapH - h/2)
    end
end

function playerCamera.attachCam(gameMap, player, world)
    playerCamera.cam:attach()
        gameMap:drawLayer(gameMap.layers["ground"])
        gameMap:drawLayer(gameMap.layers["trees"])

        player.anim:draw(player.sheet, player.x, player.y, nil, 6, nil, 16, 16)
        --world:draw()
    playerCamera.cam:detach()
end

return playerCamera