local ui = {}
local module

local colorNames = {"Red", "Green", "Blue", "Orange", "Purple", "Pink", "White"}
local defaultColorIndex = 1

local brushText = {
    [1] = "Pixel [" .. colorNames[defaultColorIndex] .. "]",
    [2] = "Glider [" .. colorNames[defaultColorIndex] .. "]",
    [3] = "Glider gun [" .. colorNames[defaultColorIndex] .. "]",
    [4] = "Flying ship [" .. colorNames[defaultColorIndex] .. "]",
    [5] = "Pulsar [" .. colorNames[defaultColorIndex] .. "]",
    [6] = "Heavy ship [" .. colorNames[defaultColorIndex] .. "]",
    [7] = "Pulsating glider [" .. colorNames[defaultColorIndex] .. "]",
    [8] = "Space ship [" .. colorNames[defaultColorIndex] .. "]",
    [9] = "Wheel of fire [" .. colorNames[defaultColorIndex] .. "]"
}

local width, height = love.window.getDesktopDimensions()
local debounce = false
local play = false
local UI = false
local darkened = false
local darkeningReset = false
local rotation = 1

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

function ui.updateBrushTextWithColor(colorIndex)
    for i = 1, #brushText do
        brushText[i] = brushText[i]:gsub("%[.-%]", "[" .. colorNames[colorIndex] .. "]")
    end
end

function ui.draw(brush)
    if not module then
        module = require("module")
    end

    local mouseX, mouseY = love.mouse.getPosition()
    local arrow = ""
    if darkened == true then
        love.graphics.setColor(0.5, 0.5, 0.5)
    else
        love.graphics.setColor(1, 1, 1)
    end
    if rotation == 1 then
        arrow = "Left / "
    elseif rotation == 2 then
        arrow = "Up / "
    elseif rotation == 3 then
        arrow = "Right / "
    elseif rotation == 4 then
        arrow = "Down / "
    end
    love.graphics.print(arrow .. brushText[brush], mouseX + 15, mouseY + 15)
end

return ui