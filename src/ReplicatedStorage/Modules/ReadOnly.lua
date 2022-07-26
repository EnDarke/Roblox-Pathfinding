-- !strict

-- Description: Makes tables and modules read only
-- Author: Alex/EnDarke
-- Date: 06/01/22

return function(t)
	local function freeze(tab)
		for _, value in pairs(tab) do
			if type(value) == "table" then
				freeze(value)
			end
		end
		return table.freeze(tab)
	end
	return freeze(t)
end