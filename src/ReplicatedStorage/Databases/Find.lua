--!strict

-- Author: Alex/EnDarke
-- Description: Handles finding, instancing, and freezing modules.

local Parent: Folder = script.Parent

--\\ Dependencies //--
local Dependencies: Folder = Parent.Parent:WaitForChild("Dependencies", 1)
local Util: {} = require(Dependencies.Util)

--\\ Prefab Functions //--
local readOnly: ({}) -> {} = Util.ReadOnly

return function (moduleName: string)
    -- Prohibit continuation without necessary information.
    if not ( moduleName ) then
        return false, "Can't find a module under that name!"
    end

    -- Search for module in need
    local foundModule = Parent:FindFirstChild(moduleName, true)
    if not ( foundModule ) then
        return
    end

    -- Return frozen database table of module
    return readOnly(require(foundModule))
end