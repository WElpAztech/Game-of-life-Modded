module = require("module")
local ui = {}
local brushText = {[1] = "Single", [2] = "Glider", [3] = "Glider gun", [4] = "Flying ship", [5] = "Pulsar", [6] = "Heavy ship", [7] = "Pulsating glider", [8] = "Space ship", [9] = "Wheel of fire"}

local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

local pauseImage = love.graphics.newImage("picture/pause.png")
local playImage = love.graphics.newImage("picture/play.png")
local resetImage = love.graphics.newImage("picture/reset.png")
local gliderGun = love.graphics.newImage("picture/glider-gun.png")
local glider = love.graphics.newImage("picture/glider.png")
local flyingShip = love.graphics.newImage("picture/flying-ship.png")
local pulsar = love.graphics.newImage("picture/pulsar.png")
local heavyShip = love.graphics.newImage("picture/heavy-ship.png")
local pulsatingGlider = love.graphics.newImage("picture/pulsating-glider.png")
local spaceship = love.graphics.newImage("picture/spaceship.png")
local wheelOfFire = love.graphics.newImage("picture/wheel-of-fire.png")
local block = love.graphics.newImage("picture/block.png")

local debounce = false
local play = false
local UI = false
local darkened = false
local darkeningReset = false

local rotation = 1

function ui.changePlayPauseButton(running)

    play = not running

end

function ui.returnUI()

    return UI

end

function ui.setrotation()

    if rotation == 4 then
        rotation = 1
    else
        rotation = rotation + 1
    end

end

function ui.buttons()

    if play == true then
        button = playImage
    elseif play == false then
        button = pauseImage
    end

    if UI == false then
        hide = "hide UI"
    elseif UI == true then
        hide = "show UI"
    end

end

function ui.draw(brush)

    local mouseX, mouseY = love.mouse.getPosition()
    local arrow = ""
    
    if UI == false then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
        love.graphics.rectangle("fill", 0, 0, width, 125)
    end

    if darkened == true then
        love.graphics.setColor(0.5, 0.5, 0.5)
    else
        love.graphics.setColor(1, 1, 1)
    end

    if rotation == 1 then
        arrow = "< "
    elseif rotation == 2 then
        arrow = "/\\ "
    elseif rotation == 3 then
        arrow = "> "
    elseif rotation == 4 then
        arrow = "\\/ "
    end

    --love.graphics.print("MouseX: " .. tostring(mouseX) .. ",MouseY:" .. tostring(mouseY), mouseX - 15, mouseY - 15)
    love.graphics.print(arrow .. brushText[brush], mouseX + 15, mouseY + 15)
    love.graphics.print(hide, width - 225, 35)
    if UI == false then
        love.graphics.draw(resetImage, width - 175, 25, 0, 0.4, 0.4)
        love.graphics.draw(button, width - 125, 25, 0, 0.4, 0.4)
        love.graphics.draw(block, width - 1500, 50, 0, 0.3, 0.3)
        love.graphics.print("1", width - 1450, 90, 0, 1.4, 1.4)
        love.graphics.draw(glider, width - 1425, 42, 0, 0.4, 0.4)
        love.graphics.print("2", width - 1375, 90, 0, 1.4, 1.4)
        love.graphics.draw(gliderGun, width - 1300, 40, 0, 0.27, 0.27)
        love.graphics.print("3", width - 1090, 90, 0, 1.4, 1.4)
        love.graphics.draw(flyingShip, width - 1010, 25, 0, 0.23, 0.23)
        love.graphics.print("4", width - 910, 90, 0, 1.4, 1.4)
        love.graphics.draw(pulsar, width - 870, 25, 0, 0.23, 0.23)
        love.graphics.print("5", width - 800, 90, 0, 1.4, 1.4)
        love.graphics.draw(heavyShip, width - 775, 50, 0, 0.3, 0.3)
        love.graphics.print("6", width - 725, 90, 0, 1.4, 1.4)
        love.graphics.draw(pulsatingGlider, width - 700, 25, 0, 0.23, 0.23)
        love.graphics.print("7", width - 660, 90, 0, 1.4, 1.4)
        love.graphics.draw(spaceship, width - 625, 15, 0, 0.23, 0.23)
        love.graphics.print("8", width - 525, 90, 0, 1.4, 1.4)
        love.graphics.draw(wheelOfFire, width - 500, 20, 0, 0.23, 0.23)
        love.graphics.print("9", width - 435, 90, 0, 1.4, 1.4)
    end

end

function ui.controls(isRunning)
    
    local mouseX, mouseY = love.mouse.getPosition()
    if love.mouse.isDown(1) and not debounce then
        debounce = true
        if UI == false then
            if mouseX >= width - 175 and mouseX <= width - 145 and mouseY >= 23 and mouseY <= 60 then --reset
                darkened = true
                darkeningReset = true
            elseif mouseX >= width - 125 and mouseX <= width - 95 and mouseY >= 23 and mouseY <= 60 then
                if play == false then --play
                    play = true
                    isRunning = true
                    module.setRunning(isRunning)
                    module.playSFX(sfx, "select")
                elseif play == true then --pause
                    play = false
                    isRunning = false
                    module.setRunning(isRunning)
                    module.playSFX(sfx, "select")
                end
            end
        end
        if mouseX >= width - 225 and mouseX <= width - 185 and mouseY >= 36 and mouseY <= 46 then --hide UI
            UI = not UI
        end
    elseif not love.mouse.isDown(1) then
        debounce = false
    end

    if darkeningReset == true and not love.mouse.isDown(1) then
        module.clearCells()
        module.playSFX(sfx, "clear")
        darkened = false
        darkeningReset = false
    end

    return isRunning

end

return ui