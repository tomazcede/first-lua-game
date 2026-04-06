local ui = {}

function ui.drawUi()
    local maxValue = player.max_hp
    if player.max_stamina > maxValue then
        maxValue = player.max_stamina
    end

    local bars = {
        {
            label = "HP:", 
            maxVal = player.max_hp, 
            val = player.hp, 
            y = 7.5, 
            bgColor = {
                r = 80 / 255,
                g = 30 / 255,
                b = 30 / 255
            }, 
            color = {
                r = 220 / 255,
                g = 60 / 255,
                b = 60 / 255
            }, 
            line = false
        },
        {
            label = "ST:", 
            maxVal = player.max_stamina, 
            val = player.stamina, 
            y = 40, 
            bgColor = {
                r = 25 / 255,
                g = 100 / 255,
                b = 60 / 255
            }, 
            color = {
                r = 80 / 255,
                g = 220 / 255,
                b = 120 / 255
            }, 
            line = player.stamina_run_threshold
        }
    }

    local maxY = bars[1].y
    for i = 2, #bars do
        if bars[i].y > maxY then
            maxY = bars[i].y
        end
    end

    love.graphics.setColor(40/255, 40/255, 40/255)
    love.graphics.rectangle("fill", 0, 0, maxValue + 50, maxY + 35)

    for key, value in pairs(bars) do
        drawValueBar(value.label, value.maxVal, value.val, value.y, value.bgColor, value.color, value.line)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function drawValueBar(label, maxValue, value, y, bgColor, color, line)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label, 5, y)
    love.graphics.setColor(bgColor.r, bgColor.g, bgColor.b)
    love.graphics.rectangle("fill", 30, y - 2.5, maxValue + 10, 20)
    love.graphics.setColor(color.r, color.g, color.b)
    love.graphics.rectangle("fill", 35, y + 2.5, value, 10)

    if line then
        love.graphics.setColor(20/255, 20/255, 20/255)
        love.graphics.line(line + 35, y + 2.5, line + 35, y + 12.5)
    end
end

return ui