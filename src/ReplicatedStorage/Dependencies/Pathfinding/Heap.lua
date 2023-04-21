--!strict

-- Author: Alex/EnDarke
-- Description: Sorts values through a heap tree efficiently.

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Replicated Modules //--
local Databases: Folder = ReplicatedStorage.Databases
local Types = Databases.Types

--\\ Types //--
type void = Types.void
type Floor = Types.Floor
type HeapTree = Types.HeapTree<any>

--\\ Globals //--
local floor: Floor = math.floor

--\\ Local Utility Functions //--
local function compare(a: any, b: any): boolean
    if ( a > b ) then
        return false
    end
    return true
end

--\\ Class //--
local Heap: HeapTree = {}
Heap.__index = Heap

-- Creates a new heap tree
function Heap.new<T>(compareFunc: (T, T) -> boolean): HeapTree
    local self: { T } = setmetatable({}, Heap)

    -- Properties
    self.Compare = compareFunc and compareFunc or compare

    return self
end

-- Adds object to heap tree
function Heap:Add<T>(item: T)
    table.insert(self, item)
    if #self <= 1 then
        return
    end
    self:SortUp(#self)
end

-- Removes object from heap tree
function Heap:Remove<T>(): T
    -- Make sure heap isn't empty
    if not ( #self > 0 ) then
        return
    end

    -- Save current, shift them down, and remove current.
    local currentItem: T = self[1]
    self[1] = self[#self]
    table.remove(self, #self)

    -- Make sure heap isn't empty
    if ( #self > 0 ) then
        self:SortDown(1)
    end

    return currentItem
end

-- Sorts index'd object up 1 step
function Heap:SortUp(index: number): void
    -- Make sure index isn't the first
    if ( index == 1 ) then
        return
    end

    -- Find the heap object's parent
    local parentIndex = floor(index / 2)

    -- Compare and swap
    if ( self.Compare(self[parentIndex], self[index]) ) then
        self[parentIndex], self[index] = self[index], self[parentIndex]
        self:SortUp(parentIndex)
    end
end

-- Sorts index'd object down 1 step
function Heap:SortDown(index: number): void
    -- Prohibit continuation without necessary information.
    if not ( index ) then
        return
    end

    -- Local Variables
    local leftChildIndex: number = (index * 2)
    local rightChildIndex: number = (index * 2) + 1
    local minIndex = 0

    -- Find the lower of the children
    if ( rightChildIndex > #self ) then
        if ( leftChildIndex > #self ) then
            return
        end
        minIndex = leftChildIndex
    else
        if not ( self.Compare(self[leftChildIndex], self[rightChildIndex]) ) then
            minIndex = leftChildIndex
        else
            minIndex = rightChildIndex
        end
    end

    -- Switch and move places
    if ( self.Compare(self[index], self[minIndex]) ) then
        self[minIndex], self[index] = self[index], self[minIndex]
        self:SortDown(minIndex)
    end
end

-- Finds the top of the tree
function Heap:CurrentTop<T>(): T
    -- Make sure heap isn't empty
    if not ( #self > 0 ) then
        return
    end

    return self[1]
end

-- Clears heap tree
function Heap:Clear<T>()
    for _, item: T in ipairs(self) do
        self[item] = nil
    end
end

-- Clones heap tree
function Heap:Clone(): HeapTree
    -- Local Variables
    local newHeap: HeapTree = Heap.new(self.Compare)

    -- Add all heap objects to new heap
    for i = 1, #self do
        table.insert(newHeap, self[i])
    end

    return newHeap
end

return Heap