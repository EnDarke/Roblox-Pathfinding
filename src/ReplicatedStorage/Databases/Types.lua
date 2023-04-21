--!strict

--\\ General //--
export type void = nil

--\\ Globals //--
export type NewInstance = (string) -> Instance
export type NewOverlapParams = () -> OverlapParams
export type NewVector2Int16 = () -> Vector2int16
export type Floor = (num: number) -> number
export type Round = (num: number) -> number
export type Clamp = (num: number, min: number, max: number) -> number
export type Ceil = (num: number) -> number
export type Abs = (num: number) -> number

--\\ Pathfinding //--
export type Node = {
    gCost: number;
    hCost: number;
    fCost: () -> number;
}

export type Grid = {
    x: { y: { Node } };
}

export type NodeList = { Node }
export type PathList = { Node }
export type HeapTree<T> = { T }