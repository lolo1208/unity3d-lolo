---@class UnityEngine.CharacterController : UnityEngine.Collider
---@field isGrounded bool
---@field velocity UnityEngine.Vector3
---@field collisionFlags UnityEngine.CollisionFlags
---@field radius float
---@field height float
---@field center UnityEngine.Vector3
---@field slopeLimit float
---@field stepOffset float
---@field skinWidth float
---@field minMoveDistance float
---@field detectCollisions bool
---@field enableOverlapRecovery bool
local m = {}
---@param speed UnityEngine.Vector3
---@return bool
function m:SimpleMove(speed) end
---@param motion UnityEngine.Vector3
---@return UnityEngine.CollisionFlags
function m:Move(motion) end
UnityEngine = {}
UnityEngine.CharacterController = m
return m