-- !strict

-- Description: Handles drawing out the grid
-- Author: Alex/EnDarke
-- Date: 07/24/22

local parent: Instance = script.Parent

--\\ Services //--
local collectionService: CollectionService = game:GetService("CollectionService")

--\\ Modules //--
local gameSettings: {} = require(parent:WaitForChild("GameSettings"))
local utils: {} = require(parent:WaitForChild("Utils"))

--\\ Types //--
type GridObject = {GridObject}
type NodeObject = {NodeObject}

type NodeList = {[any]: any}
type Array2D = {
    X: {Y: {[any]: any}}
}

--\\ Classes //--
local nodeClass: {} = require(parent:WaitForChild("Node"))

--\\ Settings //--
local gridSettings: {} = gameSettings.Grid

--\\ Variables //--
local nodeRadius: number = gridSettings.NodeRadius

local round: (num: number) -> (number) = math.round
local clamp: (num: number, min: number, max: number) -> (number) = math.clamp
local ceil: (num: number) -> (number) = math.ceil

local instance: () -> (Instance) = Instance.new
local overlapParams: () -> (OverlapParams) = OverlapParams.new

local params = overlapParams()
params.FilterType = Enum.RaycastFilterType.Whitelist

--\\ Util Tools //--
local vector3: {} = utils.Vector3

--\\ Local Utility Functions //--
local function new2DArray(xCount, yCount): Array2D
    local array: Array2D = {}
    for x = 1, xCount do
        array[x] = {}
        for y = 1, yCount do
            array[x][y] = 0
        end
    end
    return array
end

local function roundToWholeOrOne(num: number, gridMax: number): number
    num = ceil(num)
    if num <= 0 then
        num = 1
    elseif num >= gridMax + 1 then
        num = gridMax
    end
    return num
end

--\\ Module Code //--
local gridClass = {}
gridClass.__index = gridClass

function gridClass.new(model: Part, gridWorldSize: Vector3): GridObject
    local self = setmetatable({}, gridClass)

    self.Model = model
    self.plane = model

    self.nodeDiameter = nodeRadius * 2
    self.gridWorldSize = gridWorldSize
    self.gridSizeX = round(self.gridWorldSize.X / self.nodeDiameter)
    self.gridSizeY = round(self.gridWorldSize.Y / self.nodeDiameter)

    self.grid = self:createGrid()

    return self
end

-- Creates the grid within a 2D Array using the Node class
function gridClass:createGrid(): Array2D
    local newGrid: Array2D = new2DArray(self.gridSizeX, self.gridSizeY)
    local worldBottomLeft: Vector3 = self.plane.Position + (vector3.left() * self.gridWorldSize.X / 2) + (vector3.backward() * self.gridWorldSize.Y / 2)

    params.FilterDescendantsInstances = collectionService:GetTagged("Obstacle")

    for x = 1, self.gridSizeX, 1 do
        for y = 1, self.gridSizeY, 1 do
            local worldPoint: Vector3 = Vector3.one * worldBottomLeft + vector3.right() * ((x - 1) * self.nodeDiameter + nodeRadius) + vector3.forward() * ((y - 1) * self.nodeDiameter + nodeRadius)
            local walkable: boolean = not workspace:GetPartBoundsInRadius(worldPoint, nodeRadius, params)[1] and true or false
            newGrid[x][y] = nodeClass.new(walkable, worldPoint, x, y)
        end
    end

    return newGrid
end

-- Finds the neighboring grid pieces for the pathfinding module to use
function gridClass:getNeighbors(node): NodeList
    local neighbors: NodeList = {}
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            if (x == 0 and y == 0) then
                continue
            end

            local checkX: number = node.gridX + x
            local checkY: number = node.gridY + y

            if checkX >= 1 and checkX <= self.gridSizeX and checkY >= 1 and checkY <= self.gridSizeY then
                table.insert(neighbors, self.grid[checkX][checkY])
            end
        end
    end
    return neighbors
end

-- Finds the node that the position is based on
function gridClass:nodeFromWorldPoint(worldPosition): NodeObject
    local percentX: number = (worldPosition.X + self.gridWorldSize.X / 2) / self.gridWorldSize.X
    local percentY: number = (worldPosition.Z + self.gridWorldSize.Y / 2) / self.gridWorldSize.Y
    percentX = clamp(percentX, 0, 1)
    percentY = clamp(percentY, 0, 1)

    local x: number = roundToWholeOrOne((self.gridSizeX) * percentX, self.gridSizeX)
    local y: number = roundToWholeOrOne((self.gridSizeY) * percentY, self.gridSizeY)

    return self.grid[x][y]
end

return gridClass