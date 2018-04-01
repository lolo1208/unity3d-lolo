---@class UnityEngine.Rect
---@field zero UnityEngine.Rect
---@field x float
---@field y float
---@field position UnityEngine.Vector2
---@field center UnityEngine.Vector2
---@field min UnityEngine.Vector2
---@field max UnityEngine.Vector2
---@field width float
---@field height float
---@field size UnityEngine.Vector2
---@field xMin float
---@field yMin float
---@field xMax float
---@field yMax float
local m = {}
---@param xmin float
---@param ymin float
---@param xmax float
---@param ymax float
---@return UnityEngine.Rect
function m.MinMaxRect(xmin, ymin, xmax, ymax) end
---@param x float
---@param y float
---@param width float
---@param height float
function m:Set(x, y, width, height) end
---@overload fun(point:UnityEngine.Vector3):bool
---@overload fun(point:UnityEngine.Vector3, allowInverse:bool):bool
---@param point UnityEngine.Vector2
---@return bool
function m:Contains(point) end
---@overload fun(other:UnityEngine.Rect, allowInverse:bool):bool
---@param other UnityEngine.Rect
---@return bool
function m:Overlaps(other) end
---@param rectangle UnityEngine.Rect
---@param normalizedRectCoordinates UnityEngine.Vector2
---@return UnityEngine.Vector2
function m.NormalizedToPoint(rectangle, normalizedRectCoordinates) end
---@param rectangle UnityEngine.Rect
---@param point UnityEngine.Vector2
---@return UnityEngine.Vector2
function m.PointToNormalized(rectangle, point) end
---@param lhs UnityEngine.Rect
---@param rhs UnityEngine.Rect
---@return bool
function m.op_Inequality(lhs, rhs) end
---@param lhs UnityEngine.Rect
---@param rhs UnityEngine.Rect
---@return bool
function m.op_Equality(lhs, rhs) end
---@return int
function m:GetHashCode() end
---@param other object
---@return bool
function m:Equals(other) end
---@overload fun(format:string):string
---@return string
function m:ToString() end
UnityEngine = {}
UnityEngine.Rect = m
return m