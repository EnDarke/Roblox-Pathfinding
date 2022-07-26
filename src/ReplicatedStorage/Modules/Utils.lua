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
    up = function()
        return Vector3.new(0, 1, 0)
    end,
    down = function()
        return Vector3.new(0, -1, 0)
    end,
    left = function()
        return Vector3.new(-1, 0, 0)
    end,
    right = function()
        return Vector3.new(1, 0, 0)
    end,
    forward = function()
        return Vector3.new(0, 0, 1)
    end,
    backward = function()
        return Vector3.new(0, 0, -1)
    end,
}

return readOnly(utils)