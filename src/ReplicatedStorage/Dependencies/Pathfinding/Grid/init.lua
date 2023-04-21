--!strict

-- Author: Alex/EnDarke
-- Description: Handles drawing a grid

local Parent: ModuleScript = script.Parent

--\\ Services //--
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--\\ Databases //--
local Databases: Folder = ReplicatedStorage.Databases
local Types = Databases.Types

local Find = require(Databases.Find)
local GameSettings = Find("GameSettings")
local Objects = Find("Objects")

--\\ Types //--
type void = Types.void
type Node = Types.Node
type Grid = Types.Grid
type NodeList = Types.NodeList
type Array2D = { X: { Y: {any} } }

type NewInstance = Types.NewInstance
type NewOverlapParams = Types.NewOverlapParams
type NewVector2Int16 = Types.NewVector2Int16
type Round = Types.Round
type Clamp = Types.Clamp
type Ceil = Types.Ceil

--\\ Globals //--
local newOverlapParams: NewOverlapParams = OverlapParams.new
local newVector2Int16: NewVector2Int16 = Vector2int16.new
local round: Round = math.round
local clamp: Clamp = math.clamp
local ceil: Ceil = math.ceil

local vector3: { Vector3 } = Objects.vector3

--\\ Game Settings //--
local GridSettings: {} = GameSettings.Grid

--\\ Constants //--
local OBSTACLE_TAG: string = GridSettings.OBSTACLE_TAG
local NODE_RADIUS: number = GridSettings.NODE_RADIUS
local NODE_DIAMETER: number = (NODE_RADIUS * 2)

--\\ Adaptables //--
local params: OverlapParams = newOverlapParams()

--\\ Classes //--
local Node: Node = require(script.Node)

--\\ Local Utility Functions //--
local function new2DArray(xSize: number, ySize: number): Array2D
    -- Prohibit continuation without necessary information.
    if not ( xSize and ySize ) then
        return
    end

    -- Make sure there's an array
    local array: Array2D = {}

    -- Setup array
    for x = 1, xSize, 1 do
        array[x] = {}

        -- Setup y within x
        for y = 1, ySize, 1 do
            array[x][y] = "" -- Strings use up the least amount of data
        end
    end

    return array :: Array2D
end

local function roundToWholeOrOne(num: number, gridMax: number): number
    -- Make sure num is whole
    num = ceil(num)

    -- Set to one or whole
    if ( num <= 0 ) then
        num = 1
    elseif ( num >= (gridMax + 1) ) then
        num = gridMax
    end

    return num :: number
end

--\\ Class //--
local Grid: Grid = {}
Grid.__index = Grid

function Grid.new(part: Part): Grid
    local self = setmetatable({}, Grid)

    self.base = part

    self.gridWorldSize = newVector2Int16(part.Size.X, part.Size.Z)
    self.gridSizeX = round(self.gridWorldSize.X / NODE_DIAMETER)
    self.gridSizeY = round(self.gridWorldSize.Y / NODE_DIAMETER)

    self.grid:CreateGrid()

    return self
end

function Grid:CreateGrid(): Array2D
    -- Local Variables
    local newGrid: Array2D = new2DArray(self.gridSizeX, self.gridSizeY)
    local worldBottomLeft: Vector3 = self.base.Position + (vector3.left * self.gridWorldSize.X / 2) + (vector3.backward * self.gridWorldSize.Y / 2)

    -- Set param settings
    params.FilterDescendantsInstances = CollectionService:GetTagged(OBSTACLE_TAG)

    -- Draw grid
    for x = 1, self.gridSizeX, 1 do
        for y = 1, self.gridSizeY, 1 do
            -- Find position within world
            local worldPoint: Vector3 = Vector3.one * worldBottomLeft + vector3.right
                * ((x - 1) * NODE_DIAMETER + NODE_RADIUS) + vector3.forward
                * ((y - 1) * NODE_DIAMETER + NODE_RADIUS)

            -- Find out if the node is available or not!
            local walkable: boolean = not workspace:GetPartBoundsInRadius(worldPoint, NODE_RADIUS, params)[1] and true or false
            newGrid[x][y] = Node.new(walkable, worldPoint, newVector2Int16(x, y))
        end
    end

    return newGrid
end

-- Finds node's neighbors
function Grid:GetNeighbors(node: Node): NodeList
    -- Prohibit continuation without necessary information.
    if not ( node ) then
        return
    end

    -- Local Variables
    local neighbors: NodeList = {}

    -- Find all neighboring nodes!
    for x: number = -1, 1, 1 do
        for y: number = -1, 1, 1 do
            if  ( x == 0 and y == 0 ) then
                continue
            end

            -- Find which neighbor to check
            local checkX: number = node.x + x
            local checkY: number = node.y + y

            -- Are the neighbors accessible?
            if ( checkX >= 1 and checkX <= self.gridSizeX and checkY >= 1 and checkY <= self.gridSizeY ) then
                table.insert(neighbors, self.grid[checkX][checkY])
            end
        end
    end

    return neighbors
end

-- Finds node based off world position
function Grid:NodeFromWorldPoint(worldPos: Vector3): Node
    -- Prohibit continuation without necessary information.
    if not ( worldPos ) then
        return
    end

    -- Local Variables
    local percentX: number = (worldPos.X + self.gridWorldSize.X / 2) / self.gridWorldSize.X
    local percentY: number = (worldPos.Z + self.gridWorldSize.Y / 2) / self.gridWorldSize.Y
    percentX = clamp(percentX, 0, 1)
    percentY = clamp(percentY, 0, 1)

    -- Find node position based off grid percentage
    local x: number = roundToWholeOrOne((self.gridSizeX) * percentX, self.gridSizeX)
    local y: number = roundToWholeOrOne((self.gridSizeY) * percentY, self.gridSizeY)

    return self.grid[x][y]
end