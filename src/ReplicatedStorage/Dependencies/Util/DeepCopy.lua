--!strict

return function (t: {}): {}
    local copy = {}
    local function deepCopy(dictionary: {})
        for index: string | number, value: {}? in pairs(dictionary) do
            if type(value) == "table" then
                value = deepCopy() :: {}
            end
            copy[index] = value
        end
    end
    return deepCopy(copy)
end