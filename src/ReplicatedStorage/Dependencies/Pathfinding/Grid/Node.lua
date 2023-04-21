--!strict

-- Author: Alex/EnDarke
-- Description: Runs the node class for each grid tile.

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Replicated Modules //--
local Databases: Folder = ReplicatedStorage.Databases
local Types = Databases.Types

--\\ Types //--
type Node = Types.Node

--\\ Class //--
local Node: { Node } = {}
Node.__index = Node

function Node.new(walkable: boolean, worldPos: Vector3, gridPos: Vector2int16): Node
    local self = setmetatable({}, Node)

    -- Node settings
    self.walkable = walkable
    self.worldPos = worldPos
    self.x = gridPos.X
    self.y = gridPos.Y
    self.parent = nil

    -- Node properties
    self.gCost = 0
    self.hCost = 0

    return self
end

function Node:fCost(): number
    return self.gCost + self.hCost
end

return Node