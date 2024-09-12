local module = require("module")
local ui = require("ui")

cell = {}
local colors = {
    {0, 0, 0}, -- Black
    {0.05, 0.5, 0.05}, -- Dark Green
    {0.1, 0.1, 0.5}, -- Dark Blue
    {0.5, 0.1, 0.1}, -- Dark Red
    {0.5, 0.3, 0.1}, -- Dark Orange
    {0.5, 0.5, 0.05}, -- Dark Yellow
    {0.4, 0.1, 0.4}, -- Dark Purple
    {0.1, 0.5, 0.5}, -- Dark Cyan
    {0.5, 0.5, 0.5}, -- Dark White (Gray)
    {0.12, 0.12, 0.12} -- dark gray
}

local debug = true
local isRunning = false
local sfx = true
local pauseOnPlace = false
local showHelpMenu = true

local brush = 1
local tickSpeed = 1
local tickCount = 0.0
local standardColorIndex = 1

function love.update(dt)
    ui.buttons()
    module.Camera()
    isRunning = ui.controls(isRunning)
    if isRunning and tickSpeed >= 1 then
        for i = 1,tickSpeed do
            module.updateCells()
        end
    elseif isRunning and tickSpeed < 1 then
        tickCount = tickCount + tickSpeed
        if tickCount >= 1 then
            tickCount = 0.0
            module.updateCells()
        end
    end
end

function love.draw()
    love.graphics.clear(colors[standardColorIndex])

    module.draw()
    ui.draw(brush)

    if showHelpMenu then
        module.helpMenu()
    end
    if debug then
        module.debug(isRunning, sfx, pauseOnPlace, showHelpMenu, tickSpeed, tickCount)
    end
end

function love.wheelmoved(x, y)
    module.wheelmoved(x, y)
end

function love.mousepressed(x, y, button, istouch, presses)
    if pauseOnPlace and isRunning then
        isRunning = false
        module.setRunning(isRunning)
    end
    local uiBool = ui.returnUI()
    module.mousepressed(x, y, button, istouch, presses, sfx, uiBool, brush)
end

function love.mousereleased(x, y, button, istouch, presses)
    module.mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    module.mousemoved(x, y, dx, dy, istouch, sfx, brush)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "c" then
        module.clearCells()
        module.playSFX(sfx, "clear")
    elseif key == "h" then
        debug = not debug
        module.playSFX(sfx, "select")
    elseif key == "space" then
        ui.changePlayPauseButton(isRunning)
        isRunning = not isRunning
        module.setRunning(isRunning)
        module.playSFX(sfx, "select")
    elseif key == "m" then
        sfx = not sfx
        module.mute(sfx)
    elseif key == "r" then
        ui.setrotation()
        module.rotate()
        module.playSFX(sfx, "random")
    elseif key == "t" then
        module.resetCamera()
        module.playSFX(sfx, "select")
    elseif key == "p" then
        pauseOnPlace = not pauseOnPlace
        module.playSFX(sfx, "select")
    elseif key == "g" then
        module.toggleGridVisibility()
        module.playSFX(sfx, "select")
    elseif key == "n" then
        showHelpMenu = not showHelpMenu
        module.playSFX(sfx, "select")
    elseif key == "e" then
        module.cycleColor()
        module.playSFX(sfx, "select")
    elseif key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" then
        brush = tonumber(key)
    elseif key == "up" and tickSpeed < 20  then
        if tickSpeed > 1 then
            tickSpeed = tickSpeed + 1
        else
            tickSpeed = tickSpeed * 2
        end
    elseif key == "down" and tickSpeed >= 0.01 then
        if tickSpeed > 1 then
            tickSpeed = tickSpeed - 1
        else
            tickSpeed = tickSpeed / 2
        end
    elseif key == "b" then
        standardColorIndex = standardColorIndex % #colors + 1
    elseif key == "0" then
        module.rainbowMode()
    end
end

function setBrush(variable)

    brush = variable

end
