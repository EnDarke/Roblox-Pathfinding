-- This code may be messy as it was used for testing purposes
local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")

local modules = replicatedStorage.Modules

local grid = require(modules.Grid)
local pathfindingClass = require(modules.Pathfinding)

local plane = workspace["1"].Floors:WaitForChild("1")

for _, block in pairs(workspace[1].PlacedObjects:GetChildren()) do
    collectionService:AddTag(block, "PlacedObject")
end

local newGrid = grid.new(plane)