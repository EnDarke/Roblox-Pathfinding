-- !strict

-- Description: A Utility module for ease of access/use
-- Author: Alex/EnDarke
-- Date: 07/24/22

local parent = script.Parent

--\\ Modules //--
local readOnly = require(parent:WaitForChild("ReadOnly"))

--\\ Module Code //--
local utils = {}

-- New Vector3 Keywords
utils.Vector3 = {
    up = Vector3.new(0, 1, 0);
    down = Vector3.new(0, -1, 0);
    left = Vector3.new(-1, 0, 0);
    right = Vector3.new(1, 0, 0);
    forward = Vector3.new(0, 0, 1);
    backward = Vector3.new(0, 0, -1);
}

return readOnly(utils)