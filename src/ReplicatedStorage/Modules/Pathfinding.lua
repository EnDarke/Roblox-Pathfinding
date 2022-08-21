local HttpService = game:GetService("HttpService")
-- !strict

local parent = script.Parent

--\\ Classes //--
local gridClass = require(parent:WaitForChild("Grid"))
local heapClass = require(parent:WaitForChild("Heap"))

--\\ Types //--
type GridObject = {GridObject}
type NodeObject = {NodeObject}

type HeapList = {[any]: any}
type PathList = {[any]: any}

--\\ Variables //--
local seeker = workspace.seeker
local target = workspace.target

local abs = math.abs

--\\ Local Utility Functions //--
local function comparator(a, b)
    if a:fCost() > b:fCost() then
        return true
    else
        return false
    end
end

local function reverse(t: table)
    for i = 1, math.floor(#t / 2) do
        local j: number = #t - i + 1
        t[i], t[j] = t[j], t[i]
    end
    return t
end

--\\ Module Code //--
local pathfindingClass = {}
pathfindingClass.__index = pathfindingClass

function pathfindingClass.new(grid: GridObject)
    local self = setmetatable({}, pathfindingClass)

    self.grid = grid

    return self
end

local function getDistance(nodeA: NodeObject, nodeB: NodeObject)
    local dstX: number = abs(nodeA.gridX - nodeB.gridX)
    local dstY: number = abs(nodeA.gridY - nodeB.gridY)

    if (dstX > dstY) then
        return 14 * dstY + 10 * (dstX - dstY)
    end
    return 14 * dstX + 10 * (dstY - dstX)
end

function pathfindingClass:retracePath(startNode: NodeObject, endNode: NodeObject)
    local path: PathList = {}
    local currentNode: NodeObject = endNode

    while currentNode ~= startNode do
        table.insert(path, currentNode)
        currentNode = currentNode.parent
    end
    reverse(path)

    self.grid.path = path
end

function pathfindingClass:findPath(startPos: Vector3, targetPos: Vector3)
    local startNode: NodeObject = self.grid:nodeFromWorldPoint(startPos)
    local targetNode: NodeObject = self.grid:nodeFromWorldPoint(targetPos)

    local timeNow: number = tick()%1

    local openSet: HeapList = heapClass.new(comparator)
    local closedSet: PathList = {}
    openSet:add(startNode)

    coroutine.wrap(function()
        while #openSet > 0 do
            local currentNode: NodeObject = openSet:remove()
            table.insert(closedSet, currentNode)

            if currentNode == targetNode then
                self:retracePath(startNode, targetNode)
                return
            end

            for _, neighbor in ipairs(self.grid:getNeighbors(currentNode)) do
                if not neighbor.walkable or table.find(closedSet, neighbor) then
                    continue
                end

                local newMovementCostToNeighbor: number = currentNode.gCost + getDistance(currentNode, neighbor)
                if newMovementCostToNeighbor < neighbor.gCost or not table.find(openSet, neighbor) then
                    neighbor.gCost = newMovementCostToNeighbor
                    neighbor.hCost = getDistance(neighbor, targetNode)
                    neighbor.parent = currentNode

                    if not table.find(openSet, neighbor) then
                        openSet:add(neighbor)
                    end
                end
            end
        end
    end)()

    openSet:Destroy()
end

return pathfindingClass