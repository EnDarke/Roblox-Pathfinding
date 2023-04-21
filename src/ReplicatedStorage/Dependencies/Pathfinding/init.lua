--!strict

-- Author: Alex/EnDarke
-- Description: Handles pathfinding with the A* algorithm

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Imports //--
local Imports: Folder = ReplicatedStorage.Imports
local Component = require(Imports.Component)

--\\ Databases //--
local Databases: Folder = ReplicatedStorage.Databases
local Types = Databases.Types

--\\ Types //--
type Node = Types.Node
type Grid = Types.Grid
type PathList = Types.PathList
type HeapTree = Types.HeapTree<Node>

type Floor = Types.Floor
type Abs = Types.Abs

--\\ Globals //--
local floor: Floor = math.floor
local abs: Abs = math.abs

--\\ Classes //--
local Grid: Grid = require(script.Grid)
local Heap: HeapTree = require(script.Heap)

--\\ Local Utility Functions //--
local function comparator(a: Node, b: Node): boolean
    -- Prohibit continuation without necessary information.
    if not ( a and b ) then
        return
    end

    return a:fCost() > b:fCost()
end

-- Reverses all values within inputted table
local function reverse<T>(array: T): T
    -- Prohibit continuation without necessary information.
    if not ( array ) then
        return
    end

    for i = 1, floor(#array / 2) do
        local j: number = #array - i + 1
        array[i], array[j] = array[j], array[i]
    end

    return array
end

-- Find the distance between 2 nodes
local function getDistance(a: Node, b: Node)
    -- Prohibit continuation without necessary information.
    if not ( a and b ) then
        return
    end

    -- Local Variables
    local dstX: number = abs(a.x - b.x)
    local dstY: number = abs(a.y - b.y)

    -- Check the distance
    if ( dstX > dstY ) then
        return 14 * dstY + 10 * (dstX - dstY)
    end
    return 14 * dstX + 10 * (dstY - dstX)
end

--\\ Class //--
local Pathfinding = Component.new { Tag = "Pathfinding" }

function Pathfinding:Construct()
    self.grid = Grid.new(self.Instance)

    return self
end

function Pathfinding:RetracePath(startNode: Node, endNode: Node)
    -- Prohibit continuation without necessary information.
    if not ( startNode and endNode ) then
        return
    end

    -- Local Variables
    local path: PathList = {}
    local currentNode: Node = endNode

    -- Retrace
    while ( currentNode ~= startNode ) do
        table.insert(path, currentNode)
        currentNode = currentNode.parent
    end

    return reverse(path) :: PathList
end

function Pathfinding:FindPath(startPos: Vector3, targetPos: Vector3)
    -- Prohibit continuation without necessary information.
    if not ( startPos and targetPos ) then
        return
    end

    -- Local Variables
    local startNode: Node = self.grid:NodeFromWorldPoint(startPos)
    local targetNode: Node = self.grid:NodeFromWorldPoint(targetPos)

    local openSet: HeapTree = Heap.new(comparator)
    local closedSet: PathList = {}
    openSet:Add(startNode)

    -- Initiate path finding algorithm
    task.spawn(function()
        while ( #openSet > 0 ) do
            local currentNode: Node = openSet:Remove()
            table.insert(closedSet, currentNode)

            -- If path has been completed
            if ( currentNode == targetNode ) then
                break
            end

            -- Find next node from neighbors
            for _, neighbor: Node in ipairs(self.grid:GetNeighbors(currentNode)) do
                if not ( neighbor.walkable or table.find(closedSet, neighbor) ) then
                    continue
                end

                -- Set next node based on neighbor cost
                local newMovementCostToNeighbor: number = currentNode.gCost + getDistance(currentNode, neighbor)
                if ( newMovementCostToNeighbor < neighbor.gCost or not table.find(openSet, neighbor) ) then
                    neighbor.gCost = newMovementCostToNeighbor
                    neighbor.hCost = getDistance(neighbor, targetNode)
                    neighbor.parent = currentNode
                end

                -- Add neighbor to set!
                if not ( table.find(openSet, neighbor) ) then
                    openSet:Add(neighbor)
                end
            end
        end
    end)

    openSet:Destroy()
    return self:RetracePath(startNode, targetNode)
end

function Pathfinding:Stop()
    
end