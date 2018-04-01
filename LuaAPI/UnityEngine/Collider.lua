---@class UnityEngine.Collider : UnityEngine.Component
---@field enabled bool
---@field attachedRigidbody UnityEngine.Rigidbody
---@field isTrigger bool
---@field contactOffset float
---@field material UnityEngine.PhysicMaterial
---@field sharedMaterial UnityEngine.PhysicMaterial
---@field bounds UnityEngine.Bounds
local m = {}
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:ClosestPointOnBounds(position) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:ClosestPoint(position) end
---@param ray UnityEngine.Ray
---@param hitInfo UnityEngine.RaycastHit
---@param maxDistance float
---@return bool
function m:Raycast(ray, hitInfo, maxDistance) end
UnityEngine = {}
UnityEngine.Collider = m
return m