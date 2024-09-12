local module = {}
local patterns = require("patterns")

local cellSize = 10
local generation = 0
local count = 0

local cellColor = {0, 1, 0}
local width, height = love.window.getDesktopDimensions()
local screenSize = {['x'] = width, ['y'] = height}
local camera = {pos = {['x'] = 1.5 * cellSize, ['y'] = 1.5 * cellSize}, speed = 25}

local isPlacing = false
local isRemoving = false
local isGridVisible = true
local rainbow = false
local rotate = 1

local place = love.audio.newSource("sfx/place.wav", "static")
local remove = love.audio.newSource("sfx/remove.wav", "static")
local select = love.audio.newSource("sfx/select.wav", "static")
local clear = love.audio.newSource("sfx/clear.wav", "static")

local colors = {
    {0.1, 1, 0.1}, -- Green
    {0.2, 0.2, 1}, -- Blue
    {1, 0.2, 0.2}, -- Red
    {1, 0.6, 0.2}, -- Orange
    {1, 1, 0.1}, -- Yellow
    {0.8, 0.2, 0.8}, -- Purple
    {0.2, 1, 1}, -- Cyan
    {1, 1, 1} -- White
}
local currentColorIndex = 1

function module.debug(isRunning, sfx, pauseOnPlace, showHelpMenu, tickSpeed, tickCount)
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("DEBUG MENU", 10, height - 280)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Gamespeed: " .. tostring(tickSpeed) .. ", time until cells move: " .. tostring(tickCount), 10, height - 260)
    love.graphics.print("showHelpMenu: " .. tostring(showHelpMenu), 10, height - 240)
    love.graphics.print("isGridVisible: " .. tostring(isGridVisible), 10, height - 220)
    love.graphics.print("Pause on Place: " .. tostring(pauseOnPlace), 10, height - 200)
    love.graphics.print("SFX: " .. tostring(sfx), 10, height - 180)
    love.graphics.print("isRunning: " .. tostring(isRunning), 10, height - 160)
    love.graphics.print("Generation: " .. generation, 10, height - 140)
    love.graphics.print("Population: " .. tostring(count), 10, height - 120)
    love.graphics.print("Camera X: " .. camera.pos.x .. ", Camera Y: " .. camera.pos.y, 10, height - 100)
    love.graphics.print(string.format("Zoom Level: %.2fx", cellSize / 10), 10, height - 80)
    love.graphics.print("Camera Speed: " .. camera.speed, 10, height - 60)
    love.graphics.print(tostring(love.timer.getFPS()) .. " fps", 10, height - 40)
    love.graphics.print("V0.0.1 - Pre Alpha", 10, height - 20)
end

function module.helpMenu()
    love.graphics.setColor(0.68, 0.85, 0.90)
    love.graphics.print("HELP MENU", width - 165, height - 460)
    love.graphics.setColor(1, 1, 1)
    -- Tip
    love.graphics.print("TIP: Hold Mouse 1 to place", width - 165, height - 440)
    love.graphics.print("and Mouse 2 to remove", width - 165, height - 420)
    -- Movement
    love.graphics.print("WASD: Move camera pos", width - 165, height - 380)
    love.graphics.print("Ctrl + WASD: Move slower", width - 165, height - 360)
    love.graphics.print("Shift + WASD: Move faster", width - 165, height - 340)
    love.graphics.print("SCROLL: Zoom cam in/out", width - 165, height - 320)
    love.graphics.print("T: Reset camera pos", width - 165, height - 300)
    -- Actions
    love.graphics.print("M1: Place cells", width - 165, height - 280)
    love.graphics.print("M2: Delete cells", width - 165, height - 260)
    love.graphics.print("R: Rotate ", width - 165, height - 240)
    love.graphics.print("P: Pause when placing", width - 165, height - 220)
    love.graphics.print("SPACE: Start/Pause", width - 165, height - 200)
    love.graphics.print("Arrow Up/Down: tick speed", width - 165, height - 180)
    -- Misc
    love.graphics.print("C: Clear all cells", width - 165, height - 160)
    love.graphics.print("G: Hide/Show grid", width - 165, height - 140)
    love.graphics.print("E: Change cell color", width - 165, height - 120)
    love.graphics.print("B: Change background col", width - 165, height - 100)
    love.graphics.print("M: Mute Sfx", width - 165, height - 80)
    love.graphics.print("N: Toggle help menu", width - 165, height - 60)
    love.graphics.print("H: Toggle Debug Menu", width - 165, height - 40)
    love.graphics.print("ESC: Exit game", width - 165, height - 20)
end

function grid()
    if not isGridVisible then return end
    love.graphics.setColor(0.1, 0.1, 0.1)
    local gridSize = cellSize >= 10 and cellSize or cellSize * 10
    for i = 0, screenSize.x / gridSize do
        local lineX = (i * gridSize) - camera.pos.x % gridSize + (screenSize.x / 2) % gridSize
        love.graphics.line(lineX, 0, lineX, screenSize.y)
    end
    for i = 0, screenSize.y / gridSize do
        local lineY = (i * gridSize) - camera.pos.y % gridSize + (screenSize.y / 2) % gridSize
        love.graphics.line(0, lineY, screenSize.x, lineY)
    end
end

function module.draw()
    for y, row in pairs(cell) do
        for x, value in pairs(row) do
            module.DrawTile(x, y)
        end
    end

    grid()
    love.graphics.setColor(1, 1, 1)
end

function module.rainbowMode()

    rainbow = not rainbow

end

function module.DrawTile(x, y)
    if cell[y][x] == 1 and rainbow == false then
        love.graphics.setColor(cellColor) -- Alive cell (green)
    elseif cell[y][x] == 1 and rainbow == true then
        love.graphics.setColor(math.random(0.01, 1), math.random(0.01, 1), math.random(0.01, 1))
    else
        love.graphics.setColor(0, 0, 0) -- Dead cell (black)
    end
    love.graphics.rectangle("fill", (x * cellSize) - camera.pos.x + (screenSize.x / 2), (y * cellSize) - camera.pos.y + (screenSize.y / 2), cellSize, cellSize)
end

function module.wheelmoved(x, y)
    local oldcellSize = cellSize

    if y > 0 and cellSize < 100 then
        cellSize = cellSize + 1
    elseif y < 0 and cellSize > 1 then
        cellSize = cellSize - 1
    end

    local scaleFactor = cellSize / oldcellSize
    camera.pos.x = camera.pos.x * scaleFactor
    camera.pos.y = camera.pos.y * scaleFactor
end

function module.clearCells()
    cell = {}
end

function module.Camera()
    if love.keyboard.isDown('w') then
        camera.pos.y = camera.pos.y - camera.speed
    end

    if love.keyboard.isDown('s') then
        camera.pos.y = camera.pos.y + camera.speed
    end

    if love.keyboard.isDown('a') then
        camera.pos.x = camera.pos.x - camera.speed
    end

    if love.keyboard.isDown('d') then
        camera.pos.x = camera.pos.x + camera.speed
    end

    if love.keyboard.isDown('lshift') then
        camera.speed = 37.5
    elseif love.keyboard.isDown('lctrl') then
        camera.speed = 5
    else
        camera.speed = 25
    end
end

function module.spawnCell(cellX, cellY, sfx)

    if not cell[cellY] then
        cell[cellY] = {}
    end

    if cell[cellY][cellX] ~= 1 then
        cell[cellY][cellX] = 1
    end

    if sfx then
        love.audio.play(place)
    end

end

function module.placeCell(x, y, sfx, brush)
    local cellX = math.floor((x - (screenSize.x / 2) + camera.pos.x) / cellSize)
    local cellY = math.floor((y - (screenSize.y / 2) + camera.pos.y) / cellSize)

    if brush == 1 then
        module.spawnCell(cellX, cellY, sfx)
    elseif brush == 2 then
        module.placeGlider(x, y, sfx, brush)
    elseif brush == 3 then
        module.placeGliderGun(x, y, sfx, brush)
    elseif brush == 4 then
        module.placeFlyingship(x, y, sfx, brush)
    elseif brush == 5 then
        module.placePulsar(x, y, sfx, brush)
    elseif brush == 6 then
        module.placeHWSS(x, y, sfx, brush)
    elseif brush == 7 then
        module.placePulsating(x, y, sfx, brush)
    elseif brush == 8 then
        module.placeSpaceship(x, y, sfx, brush)
    elseif brush == 9 then
        module.placeWheelOfFire(x, y, sfx, brush)
    end
end

local function removeCell(x, y, sfx)
    local cellX = math.floor((x - (screenSize.x / 2) + camera.pos.x) / cellSize)
    local cellY = math.floor((y - (screenSize.y / 2) + camera.pos.y) / cellSize)

    if cell[cellY] and cell[cellY][cellX] == 1 then
        cell[cellY][cellX] = 0
        if sfx then
            love.audio.play(remove)
        end
    end
end

function module.mousepressed(x, y, button, istouch, presses, sfx, uiBool, brush)
    if uiBool == false and y > 125 then
        if button == 1 then
            isPlacing = true
            module.placeCell(x, y, sfx, brush)
        elseif button == 2 then
            isRemoving = true
            removeCell(x, y, sfx)
        end
    elseif uiBool == false and y <= 125 then
        if x <= 100 then
            setBrush(1)
        elseif x > 100 and x <= 200 then
            setBrush(2)
        elseif x > 200 and x <= 500 then
            setBrush(3)
        elseif x > 500 and x <= 650 then
            setBrush(4)
        elseif x > 650 and x <= 750 then
            setBrush(5)
        elseif x > 750 and x <= 830 then
            setBrush(6)
        elseif x > 750 and x <= 900 then
            setBrush(7)
        elseif x > 900 and x <= 1030 then
            setBrush(8)
        elseif x > 1030 and x <= 1120 then
            setBrush(9)
        end
    elseif uiBool == true then
        if button == 1 then
            isPlacing = true
            module.placeCell(x, y, sfx, brush)
        elseif button == 2 then
            isRemoving = true
            removeCell(x, y, sfx)
        end
    end
end

function module.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        isPlacing = false
    elseif button == 2 then
        isRemoving = false
    end
end

function module.mousemoved(x, y, dx, dy, istouch, sfx, brush)
    if isPlacing then
        module.placeCell(x, y, sfx, brush)
    elseif isRemoving then
        removeCell(x, y, sfx)
    end
end

function module.setRunning(state)
    isRunning = state
end

function module.mute(state)
    sfx = state
end

function module.cellColor(color)
    cellColor = color
end

function module.cycleColor()
    currentColorIndex = currentColorIndex % #colors + 1
    module.cellColor(colors[currentColorIndex])
end

function module.rotate()
    if rotate == 4 then
        rotate = 1
    else
        rotate = rotate + 1
    end
end

function module.toggleGridVisibility()
    isGridVisible = not isGridVisible
end

function module.playSFX(sfx, sound)
    if sfx and sound == "select" then
        love.audio.play(select)
    elseif sfx and sound == "clear" then
        love.audio.play(clear)
    end
end

function module.updateCells()
    local newCells = {}
    count = 0
    for x, row in pairs(cell) do
        for y, _ in pairs(row) do
            count = count + 1
            for dx = -1, 1 do
                for dy = -1, 1 do
                    local nx, ny = x + dx, y + dy
                    if not newCells[nx] then newCells[nx] = {} end

                    local population = 0
                    for ddx = -1, 1 do
                        for ddy = -1, 1 do
                            local nnx, nny = nx + ddx, ny + ddy
                            if not (ddx == 0 and ddy == 0) and cell[nnx] and cell[nnx][nny] == 1 then
                                population = population + 1
                            end
                        end
                    end

                    if cell[nx] and cell[nx][ny] == 1 then
                        newCells[nx][ny] = (population == 2 or population == 3) and 1 or 0
                    else
                        newCells[nx][ny] = (population == 3) and 1 or 0
                    end
                end
            end
        end
    end

    for x, row in pairs(newCells) do
        for y, value in pairs(row) do
            if value == 0 then
                newCells[x][y] = nil
            end
        end
    end

    cell = newCells
    generation = generation + 1
end

function module.resetCamera()
    camera.pos.x = 1.5 * cellSize
    camera.pos.y = 1.5 * cellSize
end

function module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
    local cellX = math.floor((x - (screenSize.x / 2) + camera.pos.x) / cellSize)
    local cellY = math.floor((y - (screenSize.y / 2) + camera.pos.y) / cellSize)

    for dy, row in ipairs(pattern) do
        for dx, value in ipairs(row) do
            if value == 1 then  
                local finalX = cellX + dx + offsetX
                local finalY = cellY + dy + offsetY
                module.spawnCell(finalX, finalY, sfx)
            end
        end
    end
end

function module.placeGlider(x, y, sfx, brush)
    local offsetX = -2
    local offsetY = -2
    local patternKey = "glider_" .. rotate
    local pattern = patterns[patternKey]
    module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
end

function module.placeGliderGun(x, y, sfx, brush)
    local offsetX = -19
    local offsetY = -6
    local patternKey = "gliderGun_" .. rotate
    local pattern = patterns[patternKey]
    module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
end

function module.placeFlyingship(x, y, sfx, brush)
    local offsetX = -10
    local offsetY = -7
    local patternKey = "flyingship_" .. rotate
    local pattern = patterns[patternKey]
    module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
end

function module.placePulsar(x, y, sfx, brush)
    local offsetX = -7
    local offsetY = -7
    local patternKey = "pulsar_" .. rotate
    local pattern = patterns[patternKey]
    module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
end

function module.placeHWSS(x, y, sfx, brush)
    local offsetX = -4
    local offsetY = -3
    local patternKey = "hwss_" .. rotate
    local pattern = patterns[patternKey]
    module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
end

function module.placePulsating(x, y, sfx, brush)
    local offsetX = -4
    local offsetY = -5
    local patternKey = "pulsating_" .. rotate
    local pattern = patterns[patternKey]
    module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
end

function module.placeSpaceship(x, y, sfx, brush)
    local offsetX = -10
    local offsetY = -9
    local patternKey = "spaceship_" .. rotate
    local pattern = patterns[patternKey]
    module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
end

function module.placeWheelOfFire(x, y, sfx, brush)
    local offsetX = -6
    local offsetY = -6
    local patternKey = "wheelOfFire_" .. rotate
    local pattern = patterns[patternKey]
    module.placePattern(x, y, pattern, sfx, offsetX, offsetY, brush)
end

return module