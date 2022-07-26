local HttpService = game:GetService("HttpService")
-- !strict

local parent = script.Parent

--\\ Classes //--
local gridClass = require(parent:WaitForChild("Grid"))
local heapClass = require(parent:WaitForChild("Heap"))

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
        local j = #t - i + 1
        t[i], t[j] = t[j], t[i]
    end
    return t
end

--\\ Module Code //--
local pathfindingClass = {}

local function getDistance(nodeA, nodeB)
    local dstX = abs(nodeA.gridX - nodeB.gridX)
    local dstY = abs(nodeA.gridY - nodeB.gridY)

    if (dstX > dstY) then
        return 14 * dstY + 10 * (dstX - dstY)
    end
    return 14 * dstX + 10 * (dstY - dstX)
end

local function retracePath(startNode, endNode)
    local path = {}
    local currentNode = endNode

    while currentNode ~= startNode do
        table.insert(path, currentNode)
        currentNode = currentNode.parent
    end
    reverse(path)

    gridClass.path = path
end

coroutine.wrap(function()
    while task.wait(1) do
        pathfindingClass:findPath(seeker.Position, target.Position)
    end
end)()

function pathfindingClass:findPath(startPos, targetPos)
    local startNode = gridClass:nodeFromWorldPoint(startPos)
    local targetNode = gridClass:nodeFromWorldPoint(targetPos)

    local timeNow = tick()%1

    local openSet = heapClass.new(comparator)
    local closedSet = {}
    openSet:add(startNode)

    coroutine.wrap(function()
        while #openSet > 0 do
            local currentNode = openSet:remove()
            table.insert(closedSet, currentNode)

            if currentNode == targetNode then
                retracePath(startNode, targetNode)
                return
            end

            for _, neighbor in ipairs(gridClass:getNeighbors(currentNode)) do
                if not neighbor.walkable or table.find(closedSet, neighbor) then
                    continue
                end

                local newMovementCostToNeighbor = currentNode.gCost + getDistance(currentNode, neighbor)
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

    print(math.round(((tick()%1) - timeNow) * 1000).."ms")
end

return pathfindingClass