-- dig.lua
-- program to dig out a space underneath the turtle, to its left.

-- relative position of the turtle, starts at 0 in everything:
posX, posY, posZ = 0, 0, 0

-- some extra things:
turtleDir = 0  -- 0 = north, 1 = east, 2 = south, 3 = west

local oldForward = turtle.forward
turtle.forward = function()
    local success = oldForward()
    if success then
        if turtleDir == 0 then posZ = posZ - 1
        elseif turtleDir == 1 then posX = posX + 1
        elseif turtleDir == 2 then posZ = posZ + 1
        elseif turtleDir == 3 then posX = posX - 1
        end
    end
    return success
end
 
local oldUp = turtle.up
turtle.up = function()
    local success = oldUp()
    if success then posY = posY + 1 end
    return success
end
 
local oldDown = turtle.down
turtle.down = function()
    local success = oldDown()
    if success then posY = posY - 1 end
    return success
end

local oldTurnRight = turtle.turnRight
turtle.turnRight = function()
    oldTurnRight()
    turtleDir = (turtleDir + 1) % 4
end
 
local oldTurnLeft = turtle.turnLeft
turtle.turnLeft = function()
    oldTurnLeft()
    turtleDir = (turtleDir + 3) % 4
end

function face(direction)
    local target
    if direction == "north" then target = 0
    elseif direction == "east" then target = 1
    elseif direction == "south" then target = 2
    elseif direction == "west" then target = 3
    else error("Invalid direction "..tostring(direction))
    end
 
    while turtleDir ~= target do
        turtle.turnRight()
    end
end

-- turtle things:
function isFull()
    for i = 1,16 do
        if turtle.getItemSpace(i) == 64 then
            return false
        end
    end
    return true
end

function goTo(x,y,z)
    -- Go vertical first
    while posY < y do
        while not turtle.up() do turtle.digUp() end
    end
    while posY > y do
        while not turtle.down() do turtle.digDown() end
    end
 
    -- Go x axis
    if posX < x then
        face("east")
        while posX < x do
            while not turtle.forward() do turtle.dig() end
        end
    elseif posX > x then
        face("west")
        while posX > x do
            while not turtle.forward() do turtle.dig() end
        end
    end
 
    -- Go z axis
    if posZ < z then
        face("south")
        while posZ < z do
            while not turtle.forward() do turtle.dig() end
        end
    elseif posZ > z then
        face("north")
        while posZ > z do
            while not turtle.forward() do turtle.dig() end
        end
    end
end

function depositAndResume()
    local sx, sy, sz, sd = posX, posY, posZ, turtleDir
    goTo(0, 0, 0)
    for slot = 1, 16 do
        turtle.select(slot)
        turtle.dropUp()
    end
    turtle.select(1)
    goTo(sx, sy, sz)
    while turtleDir ~= sd do turtle.turnRight() end
end

-- main mining things
function mine(x)
    local xt = 1
    repeat
        turtle.dig()
        if isFull() then
            depositAndResume()
        end
        turtle.forward()
        xt = xt + 1
    until (xt >= x)
end

function mineRight(x)
    mine(x)
    turtle.turnRight()
    turtle.dig()
    turtle.forward()
    turtle.turnRight()
end

function mineLeft(x)
    mine(x)
    turtle.turnLeft()
    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
end

function clear(x, y, z, yt)
    local zt = 1
    repeat
        mineLeft(x)
        zt = zt + 1
        mineRight(x)
        zt = zt + 1
    until (zt >= z)
    mine(x)
end

function dig(x, y, z)
    local yt = 0
    repeat
        turtle.digDown()
        turtle.down()
        clear(x, y, z)
        turtle.turnLeft()
        turtle.turnLeft()
        yt = yt + 1
    until (yt >= y)
end

function quarry(x, y, z)
    dig(x, y, z)
end

args = {...}
for i = 1, 3 do
    if tonumber(args[i]) <= 0 then
        print("Cannot use negative numbers or zero")
        exit()
    end
end
 
quarry(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
goTo(0, 0, 0)
