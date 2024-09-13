local module = {}
local patterns = require("patterns")
local ui = require("ui")

local cellSize = 5
local generation = 0
local count = 0

local cellColor = {1, 0, 0}
local width, height = love.window.getDesktopDimensions()
local screenSize = {['x'] = width, ['y'] = height}
local camera = {pos = {['x'] = 0, ['y'] = 0}, speed = 25}

local isPlacing = false
local isRemoving = false
local isGridVisible = true
local rotate = 1

local place = love.audio.newSource("sfx/place.wav", "static")
local remove = love.audio.newSource("sfx/remove.wav", "static")
local select = love.audio.newSource("sfx/select.wav", "static")
local clear = love.audio.newSource("sfx/clear.wav", "static")

local colors = {
    {1, 0, 0}, -- Red
    {0, 1, 0}, -- Green
    {0, 0.5, 1}, -- Blue
    {1, 0.6, 0.2}, -- Orange
    {0.8, 0.2, 0.8}, -- Purple
    {1, 0.75, 0.8}, -- Pink
    {1, 1, 1} -- White
}
local colorIndex = 1

function module.debug(isRunning, sfx, pauseOnPlace, showHelpMenu, tickSpeed, tickCount, drawcallsbatched, drawcalls)
    love.graphics.setColor(1, 1, 0)
    love.graphics.setNewFont(20)
    love.graphics.print("DEBUG MENU", 10, height - 440)
    love.graphics.setNewFont(11)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Note: Holding down ctrl while Arrow Up/Down", 10, height - 400)
    love.graphics.print("will increment/decrement by 0.1", 10, height - 380)
    love.graphics.print("Draw Calls Batched: " .. tostring(drawcallsbatched), 10, height - 340)
    love.graphics.print("Draw Calls: " .. tostring(drawcalls), 10, height - 320)
    love.graphics.print(string.format("Memory Usage: %.2f KB", collectgarbage("count")), 10, height - 300)
    love.graphics.print("Time Until Cells Update: " .. tostring(tickCount), 10, height - 280)
    love.graphics.print("Tick speed: " .. string.format("%.1f", tickSpeed) .. "X", 10, height - 260)
    love.graphics.print("Show Help Menu: " .. tostring(showHelpMenu), 10, height - 240)
    love.graphics.print("Grid Visibility: " .. tostring(isGridVisible), 10, height - 220)
    love.graphics.print("Pause on Place/Delete: " .. tostring(pauseOnPlace), 10, height - 200)
    love.graphics.print("SFX Enabled: " .. tostring(sfx), 10, height - 180)
    love.graphics.print("Running: " .. tostring(isRunning), 10, height - 160)
    love.graphics.print("Current Gen: " .. generation, 10, height - 140)
    love.graphics.print("Current Cells: " .. tostring(count), 10, height - 120)
    love.graphics.print("Camera X: " .. camera.pos.x .. ", Camera Y: " .. camera.pos.y, 10, height - 100)
    love.graphics.print(string.format("Zoom: %.2fx", cellSize / 10), 10, height - 80)
    love.graphics.print("Camera Speed: " .. camera.speed, 10, height - 60)
    love.graphics.print("Current FPS " .. tostring(love.timer.getFPS()), 10, height - 40)
    love.graphics.print("V1.0.0 WelpAztech Mod", 10, height - 20)
end

function module.helpMenu()
    love.graphics.setColor(0.68, 0.85, 1)
    love.graphics.setNewFont(20)
    love.graphics.print("CONTROLS", width - 170, height - 440)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(11)
    -- Tip
    love.graphics.print("TIP: Hold M1 to auto place", width - 170, height - 400)
    love.graphics.print("and hold M2 to auto remove", width - 170, height - 380)
    -- Movement
    love.graphics.print("WASD: Move camera pos", width - 170, height - 340)
    love.graphics.print("Ctrl + WASD: Move slower", width - 170, height - 320)
    love.graphics.print("Shift + WASD: Move faster", width - 170, height - 300)
    love.graphics.print("SCROLL: Zoom cam in/out", width - 170, height - 280)
    love.graphics.print("T: Reset camera position", width - 170, height - 260)
    -- Actions
    love.graphics.print("M1: Place cells", width - 170, height - 240)
    love.graphics.print("M2: Remove cells", width - 170, height - 220)
    love.graphics.print("R: Rotate prefabs clockwise", width - 170, height - 200)
    love.graphics.print("Q: Pause when placing/del", width - 170, height - 180)
    love.graphics.print("SPACE: Start/Pause game", width - 170, height - 160)
    love.graphics.print("Arrow Up/Down: tick speed", width - 170, height - 140)
    -- Misc
    love.graphics.print("C: Clear all current cells", width - 170, height - 120)
    love.graphics.print("G: Hide/Show grid", width - 170, height - 100)
    love.graphics.print("M: Mute all sound effcts", width - 170, height - 80)
    love.graphics.print("N: Toggle help menu", width - 170, height - 60)
    love.graphics.print("H: Toggle Debug Menu", width - 170, height - 40)
    love.graphics.print("ESC: Exit game (No save)", width - 170, height - 20)
end

function grid()
    if not isGridVisible then return end

    love.graphics.setColor(78/255, 78/255, 78/255, 0.25)
    for i = 0, screenSize.x / cellSize do
        local lineX = (i * cellSize) - camera.pos.x % cellSize + (screenSize.x / 2) % cellSize
        love.graphics.line(lineX, 0, lineX, screenSize.y)
    end
    for i = 0, screenSize.y / cellSize do
        local lineY = (i * cellSize) - camera.pos.y % cellSize + (screenSize.y / 2) % cellSize
        love.graphics.line(0, lineY, screenSize.x, lineY)
    end

    local biggerGridSize = cellSize * 10
    love.graphics.setColor(110/255, 110/255, 110/255, 0.25)
    for i = 0, screenSize.x / biggerGridSize do
        local lineX = (i * biggerGridSize) - camera.pos.x % biggerGridSize + (screenSize.x / 2) % biggerGridSize
        love.graphics.line(lineX, 0, lineX, screenSize.y)
    end
    for i = 0, screenSize.y / biggerGridSize do
        local lineY = (i * biggerGridSize) - camera.pos.y % biggerGridSize + (screenSize.y / 2) % biggerGridSize
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

function module.DrawTile(x, y)
    if cell[y][x].state == 1 then
        love.graphics.setColor(cell[y][x].color)
    else
        love.graphics.setColor(0, 0, 0)
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

    if cellSize < 2 then
        cellSize = 2
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
        camera.speed = 16
    elseif love.keyboard.isDown('lctrl') then
        camera.speed = 4
    else
        camera.speed = 8
    end
end

function module.spawnCell(cellX, cellY, sfx)
    if not cell[cellY] then
        cell[cellY] = {}
    end

    cell[cellY][cellX] = {state = 1, color = colors[colorIndex]}

    if sfx then love.audio.play(place) end
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

    if cell[cellY] and cell[cellY][cellX] and cell[cellY][cellX].state == 1 then
        cell[cellY][cellX] = nil
        if sfx then love.audio.play(remove) end
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

function module.setAndCycleColor()
    colorIndex = colorIndex % #colors + 1
    cellColor = colors[colorIndex]
    ui.updateBrushTextWithColor(colorIndex)
end

function module.rotate()
    rotate = (rotate % 4) + 1
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
        for y, cellData in pairs(row) do
            count = count + 1
            for dx = -1, 1 do
                for dy = -1, 1 do
                    local nx, ny = x + dx, y + dy
                    if not newCells[nx] then newCells[nx] = {} end

                    local population = 0
                    for ddx = -1, 1 do
                        for ddy = -1, 1 do
                            local nnx, nny = nx + ddx, ny + ddy
                            if not (ddx == 0 and ddy == 0) and cell[nnx] and cell[nnx][nny] and cell[nnx][nny].state == 1 then
                                population = population + 1
                            end
                        end
                    end

                    if cell[nx] and cell[nx][ny] and cell[nx][ny].state == 1 then
                        newCells[nx][ny] = {state = (population == 2 or population == 3) and 1 or 0, color = cell[nx][ny].color}
                    else
                        if population == 3 then
                            newCells[nx][ny] = {state = 1, color = cellData.color}
                        end
                    end
                end
            end
        end
    end

    for x, row in pairs(newCells) do
        for y, cellData in pairs(row) do
            if cellData.state == 0 then
                newCells[x][y] = nil
            end
        end
    end

    cell = newCells
    generation = generation + 1
end

function module.resetCamera()
    camera.pos.x = 0
    camera.pos.y = 0
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