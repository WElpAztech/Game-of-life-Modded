local module = require("module")
local ui = require("ui")

cell = {}

local debug = false
local isRunning = false
local sfx = true
local pauseOnPlace = false
local showHelpMenu = true
local brush = 1
local tickSpeed = 1
local tickCount = 0.0

local upPressed = false
local downPressed = false
local ctrlPressed = false
local incrementTimer = 0
local incrementInterval = 0.1

function love.update(dt)
    module.Camera()
    if isRunning and tickSpeed >= 1 then
        for i = 1, tickSpeed do
            module.updateCells()
        end
    elseif isRunning and tickSpeed < 1 then
        tickCount = tickCount + tickSpeed
        if tickCount >= 1 then
            tickCount = 0.0
            module.updateCells()
        end
    end

    incrementTimer = incrementTimer + dt
    if incrementTimer >= incrementInterval then
        if upPressed and tickSpeed < 20 then
            if ctrlPressed then
                tickSpeed = tickSpeed + 0.1
            else
                tickSpeed = tickSpeed + 1
            end
        elseif downPressed and tickSpeed > 0.1 then
            if ctrlPressed then
                tickSpeed = tickSpeed - 0.1
            else
                tickSpeed = tickSpeed - 1
            end
        end
        incrementTimer = 0
    end

    if tickSpeed < 0.1 then
        tickSpeed = 0.1
    end
end

function love.draw()
    love.graphics.clear(40/255, 40/255, 40/255)

    module.draw()
    ui.draw(brush)

    if showHelpMenu then module.helpMenu() end
    if debug then
        local stats = love.graphics.getStats()
        local drawcallsbatched = stats.drawcallsbatched
        local drawcalls = stats.drawcalls
        module.debug(isRunning, sfx, pauseOnPlace, showHelpMenu, tickSpeed, tickCount, drawcallsbatched, drawcalls)
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
        isRunning = not isRunning
        module.setRunning(isRunning)
        module.playSFX(sfx, "select")
    elseif key == "m" then
        sfx = not sfx
        module.mute(sfx)
    elseif key == "r" then
        ui.setrotation()
        module.rotate()
        module.playSFX(sfx, "select")
    elseif key == "t" then
        module.resetCamera()
        module.playSFX(sfx, "select")
    elseif key == "p" then
        pauseOnPlace = not pauseOnPlace
        module.playSFX(sfx, "select")
    elseif key == "e" then
        module.setAndCycleColor()
        module.playSFX(sfx, "select")
    elseif key == "q" then
        pauseOnPlace = not pauseOnPlace
        module.playSFX(sfx, "select")
    elseif key == "g" then
        module.toggleGridVisibility()
        module.playSFX(sfx, "select")
    elseif key == "n" then
        showHelpMenu = not showHelpMenu
        module.playSFX(sfx, "select")
    elseif key >= "1" and key <= "9" then
        brush = tonumber(key)
    elseif key == "up" then
        upPressed = true
    elseif key == "down" then
        downPressed = true
    elseif key == "lctrl" or key == "rctrl" then
        ctrlPressed = true
    end
end

function love.keyreleased(key)
    if key == "up" then
        upPressed = false
    elseif key == "down" then
        downPressed = false
    elseif key == "lctrl" or key == "rctrl" then
        ctrlPressed = false
    end
end

function setBrush(variable)
    brush = variable
end