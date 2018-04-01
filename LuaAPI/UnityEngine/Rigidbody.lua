---@class UnityEngine.Rigidbody : UnityEngine.Component
---@field velocity UnityEngine.Vector3
---@field angularVelocity UnityEngine.Vector3
---@field drag float
---@field angularDrag float
---@field mass float
---@field useGravity bool
---@field maxDepenetrationVelocity float
---@field isKinematic bool
---@field freezeRotation bool
---@field constraints UnityEngine.RigidbodyConstraints
---@field collisionDetectionMode UnityEngine.CollisionDetectionMode
---@field centerOfMass UnityEngine.Vector3
---@field worldCenterOfMass UnityEngine.Vector3
---@field inertiaTensorRotation UnityEngine.Quaternion
---@field inertiaTensor UnityEngine.Vector3
---@field detectCollisions bool
---@field position UnityEngine.Vector3
---@field rotation UnityEngine.Quaternion
---@field interpolation UnityEngine.RigidbodyInterpolation
---@field solverIterations int
---@field solverVelocityIterations int
---@field sleepThreshold float
---@field maxAngularVelocity float
local m = {}
---@param endValue UnityEngine.Vector3
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOMove(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOMoveX(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOMoveY(endValue, duration, snapping) end
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOMoveZ(endValue, duration, snapping) end
---@param endValue UnityEngine.Vector3
---@param duration float
---@param mode DG.Tweening.RotateMode
---@return DG.Tweening.Tweener
function m:DORotate(endValue, duration, mode) end
---@param towards UnityEngine.Vector3
---@param duration float
---@param axisConstraint DG.Tweening.AxisConstraint
---@param up System.Nullable
---@return DG.Tweening.Tweener
function m:DOLookAt(towards, duration, axisConstraint, up) end
---@param endValue UnityEngine.Vector3
---@param jumpPower float
---@param numJumps int
---@param duration float
---@param snapping bool
---@return DG.Tweening.Sequence
function m:DOJump(endValue, jumpPower, numJumps, duration, snapping) end
---@param path table
---@param duration float
---@param pathType DG.Tweening.PathType
---@param pathMode DG.Tweening.PathMode
---@param resolution int
---@param gizmoColor System.Nullable
---@return DG.Tweening.Core.TweenerCore
function m:DOPath(path, duration, pathType, pathMode, resolution, gizmoColor) end
---@param path table
---@param duration float
---@param pathType DG.Tweening.PathType
---@param pathMode DG.Tweening.PathMode
---@param resolution int
---@param gizmoColor System.Nullable
---@return DG.Tweening.Core.TweenerCore
function m:DOLocalPath(path, duration, pathType, pathMode, resolution, gizmoColor) end
---@param density float
function m:SetDensity(density) end
---@overload fun(force:UnityEngine.Vector3):void
---@overload fun(x:float, y:float, z:float):void
---@overload fun(x:float, y:float, z:float, mode:UnityEngine.ForceMode):void
---@param force UnityEngine.Vector3
---@param mode UnityEngine.ForceMode
function m:AddForce(force, mode) end
---@overload fun(force:UnityEngine.Vector3):void
---@overload fun(x:float, y:float, z:float):void
---@overload fun(x:float, y:float, z:float, mode:UnityEngine.ForceMode):void
---@param force UnityEngine.Vector3
---@param mode UnityEngine.ForceMode
function m:AddRelativeForce(force, mode) end
---@overload fun(torque:UnityEngine.Vector3):void
---@overload fun(x:float, y:float, z:float):void
---@overload fun(x:float, y:float, z:float, mode:UnityEngine.ForceMode):void
---@param torque UnityEngine.Vector3
---@param mode UnityEngine.ForceMode
function m:AddTorque(torque, mode) end
---@overload fun(torque:UnityEngine.Vector3):void
---@overload fun(x:float, y:float, z:float):void
---@overload fun(x:float, y:float, z:float, mode:UnityEngine.ForceMode):void
---@param torque UnityEngine.Vector3
---@param mode UnityEngine.ForceMode
function m:AddRelativeTorque(torque, mode) end
---@overload fun(force:UnityEngine.Vector3, position:UnityEngine.Vector3):void
---@param force UnityEngine.Vector3
---@param position UnityEngine.Vector3
---@param mode UnityEngine.ForceMode
function m:AddForceAtPosition(force, position, mode) end
---@overload fun(explosionForce:float, explosionPosition:UnityEngine.Vector3, explosionRadius:float, upwardsModifier:float):void
---@overload fun(explosionForce:float, explosionPosition:UnityEngine.Vector3, explosionRadius:float):void
---@param explosionForce float
---@param explosionPosition UnityEngine.Vector3
---@param explosionRadius float
---@param upwardsModifier float
---@param mode UnityEngine.ForceMode
function m:AddExplosionForce(explosionForce, explosionPosition, explosionRadius, upwardsModifier, mode) end
---@param position UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:ClosestPointOnBounds(position) end
---@param relativePoint UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:GetRelativePointVelocity(relativePoint) end
---@param worldPoint UnityEngine.Vector3
---@return UnityEngine.Vector3
function m:GetPointVelocity(worldPoint) end
---@param position UnityEngine.Vector3
function m:MovePosition(position) end
---@param rot UnityEngine.Quaternion
function m:MoveRotation(rot) end
function m:Sleep() end
---@return bool
function m:IsSleeping() end
function m:WakeUp() end
function m:ResetCenterOfMass() end
function m:ResetInertiaTensor() end
---@overload fun(direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float):bool
---@overload fun(direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit):bool
---@param direction UnityEngine.Vector3
---@param hitInfo UnityEngine.RaycastHit
---@param maxDistance float
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return bool
function m:SweepTest(direction, hitInfo, maxDistance, queryTriggerInteraction) end
---@overload fun(direction:UnityEngine.Vector3, maxDistance:float):table
---@overload fun(direction:UnityEngine.Vector3):table
---@param direction UnityEngine.Vector3
---@param maxDistance float
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return table
function m:SweepTestAll(direction, maxDistance, queryTriggerInteraction) end
UnityEngine = {}
UnityEngine.Rigidbody = m
return m