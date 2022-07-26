-- !strict

-- Description: Holds all game settings
-- Author: Alex/EnDarke
-- Date: 07/24/22

local parent = script.Parent

--\\ Modules //--
local readOnly = require(parent:WaitForChild("ReadOnly"))

--\\ Module Code //--
local gameSettings = {}

gameSettings.Grid = {
    DisplayGrid = true;
    DisplayOnlyPath = true;
    GridWorldSize = Vector2.new(56, 56);
    NodeRadius = 2;
}

return readOnly(gameSettings)