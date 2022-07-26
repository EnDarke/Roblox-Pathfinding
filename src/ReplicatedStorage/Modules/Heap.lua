-- !strict

-- Description: Heap algorithm for sorting items
-- Author: Alex/EnDarke
-- Date: 07/26/22

--\\ Variables //--
local floor = math.floor

--\\ Local Utility Functions //--
local function sortUp(t: table, index: number)
    local parentIndex
    if index ~= 1 then
        parentIndex = floor(index / 2)
        if t.Compare(t[parentIndex], t[index]) then
            t[parentIndex], t[index] = t[index], t[parentIndex]
            sortUp(t, parentIndex)
        end
    end
end

local function sortDown(t: table, index: number)
    local leftChildIndex, rightChildIndex, minIndex
    leftChildIndex = index * 2
    rightChildIndex = index * 2 + 1
    if rightChildIndex > #t then
        if leftChildIndex > #t then
            return
        else
            minIndex = leftChildIndex
        end
    else
        if not t.Compare(t[leftChildIndex], t[rightChildIndex]) then
            minIndex = leftChildIndex
        else
            minIndex = rightChildIndex
        end
    end

    if t.Compare(t[index], t[minIndex]) then
        t[minIndex], t[index] = t[index], t[minIndex]
        sortDown(t, minIndex)
    end
end

--\\ Module Code //--
local sort = {}
sort.__index = sort

local function compare(a: any, b: any)
    if a > b then
        return true
    else
        return false
    end
end

function sort.new(compareFunc: RBXScriptConnection)
    local self = setmetatable({}, sort)
    if compareFunc then
        self.Compare = compareFunc
    else
        self.Compare = compare
    end
    return self
end

function sort:add(item: any)
    table.insert(self, item)
    if #self <= 1 then
        return
    end
    sortUp(self, #self)
end

function sort:remove()
    if #self > 0 then
        local currentItem = self[1]
        self[1] = self[#self]
        table.remove(self, #self)
        if #self > 0 then
            sortDown(self, 1)
        end
        return currentItem
    else
        return nil
    end
end

function sort:currenTop()
    if #self > 0 then
        return self[1]
    end
end

function sort:clear()
    for _, item in pairs(self) do
        self[item] = nil
    end
end

function sort:clone()
    local newSort = sort.new(self.Compare)
    for i = 1, #self do
        table.insert(newSort, self[i])
    end
    return newSort
end

return sort