-- !strict

-- Description: Handles drawing out the grid
-- Author: Alex/EnDarke
-- Date: 07/24/22

local parent = script.Parent

--\\ Services //--
local collectionService = game:GetService("CollectionService")

--\\ Modules //--
local gameSettings = require(parent:WaitForChild("GameSettings"))
local utils = require(parent:WaitForChild("Utils"))

--\\ Classes //--
local nodeClass = require(parent:WaitForChild("Node"))

--\\ Settings //--
local gridSettings = gameSettings.Grid

--\\ Variables //--
local displayGrid = gridSettings.DisplayGrid
local displayOnlyPath = gridSettings.DisplayOnlyPath
local gridWorldSize = gridSettings.GridWorldSize
local nodeRadius = gridSettings.NodeRadius
local grid = {}

local nodeDiameter
local gridSizeX, gridSizeY
local plane

local round = math.round
local clamp = math.clamp
local ceil = math.ceil

local instance = Instance.new
local overlapParams = OverlapParams.new

local params = overlapParams()
params.FilterType = Enum.RaycastFilterType.Whitelist

--\\ Util Tools //--
local vector3 = utils.Vector3

--\\ Local Utility Functions //--
local function new2DArray(x, y)
    local array = {}
    for x = 1, x do
        array[x] = {}
        for y = 1, y do
            array[x][y] = 0
        end
    end
    return array
end

local function drawParts(_pos, _size, _color)
    local part = instance("Part")
    part.Size = _size
    part.Position = _pos
    part.Anchored = true
    part.BrickColor = _color
    part.Parent = workspace.Grid
end

local function roundToWholeOrOne(num)
    num = ceil(num)
    if num <= 0 then
        num = 1
    elseif num >= gridSizeX + 1 then
        num = gridSizeX
    end
    return num
end

--\\ Module Code //--
local gridClass = {}
gridClass.__index = gridClass

function gridClass.new(model: Part)
    local self = setmetatable({}, gridClass)

    local timeNow = tick()%1

    self.Model = model
    plane = model

    nodeDiameter = nodeRadius * 2
    gridSizeX = round(gridWorldSize.X / nodeDiameter)
    gridSizeY = round(gridWorldSize.Y / nodeDiameter)

    gridClass:createGrid()

    print(round(((tick()%1) - timeNow) * 1000).."ms")

    return self
end

function gridClass:maxSize()
    return gridSizeX * gridSizeY
end

-- Creates the grid within a 2D Array using the Node class
function gridClass:createGrid()
    grid = new2DArray(gridSizeX, gridSizeY)
    local worldBottomLeft = plane.Position + (vector3.left() * gridWorldSize.X / 2) + (vector3.backward() * gridWorldSize.Y / 2)

    params.FilterDescendantsInstances = collectionService:GetTagged("PlacedObject")

    for x = 1, gridSizeX, 1 do
        for y = 1, gridSizeY, 1 do
            local worldPoint = Vector3.one * worldBottomLeft + vector3.right() * ((x - 1) * nodeDiameter + nodeRadius) + vector3.forward() * ((y - 1) * nodeDiameter + nodeRadius)
            local walkable = not workspace:GetPartBoundsInRadius(worldPoint, nodeRadius, params)[1] and true or false
            grid[x][y] = nodeClass.new(walkable, worldPoint, x, y)
        end
    end
end

-- Finds the neighboring grid pieces for the pathfinding module to use
function gridClass:getNeighbors(node)
    local neighbors = {}
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            if (x == 0 and y == 0) then
                continue
            end

            local checkX = node.gridX + x
            local checkY = node.gridY + y

            if checkX >= 1 and checkX <= gridSizeX and checkY >= 1 and checkY <= gridSizeY then
                table.insert(neighbors, grid[checkX][checkY])
            end
        end
    end
    return neighbors
end

-- Finds the node that the position is based on
function gridClass:nodeFromWorldPoint(worldPosition)
    local percentX = (worldPosition.X + gridWorldSize.X / 2) / gridWorldSize.X
    local percentY = (worldPosition.Z + gridWorldSize.Y / 2) / gridWorldSize.Y
    percentX = clamp(percentX, 0, 1)
    percentY = clamp(percentY, 0, 1)

    local x = roundToWholeOrOne((gridSizeX) * percentX)
    local y = roundToWholeOrOne((gridSizeY) * percentY)

    return grid[x][y]
end

-- Used to display the grid and path that is created
function gridClass:onDrawParts()
    local path = self.path
    workspace.Grid:ClearAllChildren()

    if displayOnlyPath then
        if path then
            for _, node in ipairs(path) do
                drawParts(node.worldPosition, Vector3.new(4, 1, 4), BrickColor.Black())
            end
        end
    else
        if grid then
            for _, yAxis in ipairs(grid) do
                for _, node in ipairs(yAxis) do
                    if path then
                        if table.find(path, node) then
                            drawParts(node.worldPosition, Vector3.new(4, 1, 4), node.walkable and BrickColor.Black() or BrickColor.Red())
                        else
                            drawParts(node.worldPosition, Vector3.new(4, 1, 4), node.walkable and BrickColor.White() or BrickColor.Red())
                        end
                    else
                        drawParts(node.worldPosition, Vector3.new(4, 1, 4), node.walkable and BrickColor.White() or BrickColor.Red())
                    end
                end
            end
        end
    end
end

return gridClass