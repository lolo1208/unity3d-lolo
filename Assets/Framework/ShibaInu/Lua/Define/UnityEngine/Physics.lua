---@class UnityEngine.Physics : object
---@field gravity UnityEngine.Vector3
---@field defaultContactOffset float
---@field bounceThreshold float
---@field defaultSolverIterations int
---@field defaultSolverVelocityIterations int
---@field sleepThreshold float
---@field queriesHitTriggers bool
---@field queriesHitBackfaces bool
---@field autoSimulation bool
---@field autoSyncTransforms bool
---@field IgnoreRaycastLayer int
---@field DefaultRaycastLayers int
---@field AllLayers int
local m = {}
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, maxDistance:float):bool
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3):bool
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int):bool
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float):bool
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit):bool
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@overload fun(ray:UnityEngine.Ray, maxDistance:float, layerMask:int):bool
---@overload fun(ray:UnityEngine.Ray, maxDistance:float):bool
---@overload fun(ray:UnityEngine.Ray):bool
---@overload fun(ray:UnityEngine.Ray, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@overload fun(ray:UnityEngine.Ray, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int):bool
---@overload fun(ray:UnityEngine.Ray, hitInfo:UnityEngine.RaycastHit, maxDistance:float):bool
---@overload fun(ray:UnityEngine.Ray, hitInfo:UnityEngine.RaycastHit):bool
---@overload fun(ray:UnityEngine.Ray, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@param origin UnityEngine.Vector3
---@param direction UnityEngine.Vector3
---@param maxDistance float
---@param layerMask int
---@return bool
function m.Raycast(origin, direction, maxDistance, layerMask) end
---@overload fun(ray:UnityEngine.Ray, maxDistance:float):table
---@overload fun(ray:UnityEngine.Ray):table
---@overload fun(ray:UnityEngine.Ray, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):table
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, maxDistance:float, layermask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):table
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, maxDistance:float, layermask:int):table
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, maxDistance:float):table
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3):table
---@param ray UnityEngine.Ray
---@param maxDistance float
---@param layerMask int
---@return table
function m.RaycastAll(ray, maxDistance, layerMask) end
---@overload fun(ray:UnityEngine.Ray, results:table, maxDistance:float):int
---@overload fun(ray:UnityEngine.Ray, results:table):int
---@overload fun(ray:UnityEngine.Ray, results:table, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):int
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, results:table, maxDistance:float, layermask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):int
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, results:table, maxDistance:float, layermask:int):int
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, results:table, maxDistance:float):int
---@overload fun(origin:UnityEngine.Vector3, direction:UnityEngine.Vector3, results:table):int
---@param ray UnityEngine.Ray
---@param results table
---@param maxDistance float
---@param layerMask int
---@return int
function m.RaycastNonAlloc(ray, results, maxDistance, layerMask) end
---@overload fun(start:UnityEngine.Vector3, end:UnityEngine.Vector3):bool
---@overload fun(start:UnityEngine.Vector3, end:UnityEngine.Vector3, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@overload fun(start:UnityEngine.Vector3, end:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, layerMask:int):bool
---@overload fun(start:UnityEngine.Vector3, end:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit):bool
---@overload fun(start:UnityEngine.Vector3, end:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@param start UnityEngine.Vector3
---@param end UnityEngine.Vector3
---@param layerMask int
---@return bool
function m.Linecast(start, end, layerMask) end
---@overload fun(position:UnityEngine.Vector3, radius:float, layerMask:int):table
---@overload fun(position:UnityEngine.Vector3, radius:float):table
---@param position UnityEngine.Vector3
---@param radius float
---@param layerMask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return table
function m.OverlapSphere(position, radius, layerMask, queryTriggerInteraction) end
---@overload fun(position:UnityEngine.Vector3, radius:float, results:table, layerMask:int):int
---@overload fun(position:UnityEngine.Vector3, radius:float, results:table):int
---@param position UnityEngine.Vector3
---@param radius float
---@param results table
---@param layerMask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return int
function m.OverlapSphereNonAlloc(position, radius, results, layerMask, queryTriggerInteraction) end
---@overload fun(point0:UnityEngine.Vector3, point1:UnityEngine.Vector3, radius:float, layerMask:int):table
---@overload fun(point0:UnityEngine.Vector3, point1:UnityEngine.Vector3, radius:float):table
---@param point0 UnityEngine.Vector3
---@param point1 UnityEngine.Vector3
---@param radius float
---@param layerMask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return table
function m.OverlapCapsule(point0, point1, radius, layerMask, queryTriggerInteraction) end
---@overload fun(point0:UnityEngine.Vector3, point1:UnityEngine.Vector3, radius:float, results:table, layerMask:int):int
---@overload fun(point0:UnityEngine.Vector3, point1:UnityEngine.Vector3, radius:float, results:table):int
---@param point0 UnityEngine.Vector3
---@param point1 UnityEngine.Vector3
---@param radius float
---@param results table
---@param layerMask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return int
function m.OverlapCapsuleNonAlloc(point0, point1, radius, results, layerMask, queryTriggerInteraction) end
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, maxDistance:float):bool
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3):bool
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int):bool
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float):bool
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit):bool
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@param point1 UnityEngine.Vector3
---@param point2 UnityEngine.Vector3
---@param radius float
---@param direction UnityEngine.Vector3
---@param maxDistance float
---@param layerMask int
---@return bool
function m.CapsuleCast(point1, point2, radius, direction, maxDistance, layerMask) end
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float):bool
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit):bool
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@overload fun(ray:UnityEngine.Ray, radius:float, maxDistance:float, layerMask:int):bool
---@overload fun(ray:UnityEngine.Ray, radius:float, maxDistance:float):bool
---@overload fun(ray:UnityEngine.Ray, radius:float):bool
---@overload fun(ray:UnityEngine.Ray, radius:float, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@overload fun(ray:UnityEngine.Ray, radius:float, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int):bool
---@overload fun(ray:UnityEngine.Ray, radius:float, hitInfo:UnityEngine.RaycastHit, maxDistance:float):bool
---@overload fun(ray:UnityEngine.Ray, radius:float, hitInfo:UnityEngine.RaycastHit):bool
---@overload fun(ray:UnityEngine.Ray, radius:float, hitInfo:UnityEngine.RaycastHit, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@param origin UnityEngine.Vector3
---@param radius float
---@param direction UnityEngine.Vector3
---@param hitInfo UnityEngine.RaycastHit
---@param maxDistance float
---@param layerMask int
---@return bool
function m.SphereCast(origin, radius, direction, hitInfo, maxDistance, layerMask) end
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, maxDistance:float, layermask:int):table
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, maxDistance:float):table
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3):table
---@param point1 UnityEngine.Vector3
---@param point2 UnityEngine.Vector3
---@param radius float
---@param direction UnityEngine.Vector3
---@param maxDistance float
---@param layermask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return table
function m.CapsuleCastAll(point1, point2, radius, direction, maxDistance, layermask, queryTriggerInteraction) end
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, results:table, maxDistance:float, layermask:int):int
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, results:table, maxDistance:float):int
---@overload fun(point1:UnityEngine.Vector3, point2:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, results:table):int
---@param point1 UnityEngine.Vector3
---@param point2 UnityEngine.Vector3
---@param radius float
---@param direction UnityEngine.Vector3
---@param results table
---@param maxDistance float
---@param layermask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return int
function m.CapsuleCastNonAlloc(point1, point2, radius, direction, results, maxDistance, layermask, queryTriggerInteraction) end
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, maxDistance:float):table
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3):table
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):table
---@overload fun(ray:UnityEngine.Ray, radius:float, maxDistance:float, layerMask:int):table
---@overload fun(ray:UnityEngine.Ray, radius:float, maxDistance:float):table
---@overload fun(ray:UnityEngine.Ray, radius:float):table
---@overload fun(ray:UnityEngine.Ray, radius:float, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):table
---@param origin UnityEngine.Vector3
---@param radius float
---@param direction UnityEngine.Vector3
---@param maxDistance float
---@param layerMask int
---@return table
function m.SphereCastAll(origin, radius, direction, maxDistance, layerMask) end
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, results:table, maxDistance:float):int
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, results:table):int
---@overload fun(origin:UnityEngine.Vector3, radius:float, direction:UnityEngine.Vector3, results:table, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):int
---@overload fun(ray:UnityEngine.Ray, radius:float, results:table, maxDistance:float, layerMask:int):int
---@overload fun(ray:UnityEngine.Ray, radius:float, results:table, maxDistance:float):int
---@overload fun(ray:UnityEngine.Ray, radius:float, results:table):int
---@overload fun(ray:UnityEngine.Ray, radius:float, results:table, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):int
---@param origin UnityEngine.Vector3
---@param radius float
---@param direction UnityEngine.Vector3
---@param results table
---@param maxDistance float
---@param layerMask int
---@return int
function m.SphereCastNonAlloc(origin, radius, direction, results, maxDistance, layerMask) end
---@overload fun(position:UnityEngine.Vector3, radius:float, layerMask:int):bool
---@overload fun(position:UnityEngine.Vector3, radius:float):bool
---@param position UnityEngine.Vector3
---@param radius float
---@param layerMask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return bool
function m.CheckSphere(position, radius, layerMask, queryTriggerInteraction) end
---@overload fun(start:UnityEngine.Vector3, end:UnityEngine.Vector3, radius:float, layermask:int):bool
---@overload fun(start:UnityEngine.Vector3, end:UnityEngine.Vector3, radius:float):bool
---@param start UnityEngine.Vector3
---@param end UnityEngine.Vector3
---@param radius float
---@param layermask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return bool
function m.CheckCapsule(start, end, radius, layermask, queryTriggerInteraction) end
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, orientation:UnityEngine.Quaternion, layermask:int):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, orientation:UnityEngine.Quaternion):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3):bool
---@param center UnityEngine.Vector3
---@param halfExtents UnityEngine.Vector3
---@param orientation UnityEngine.Quaternion
---@param layermask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return bool
function m.CheckBox(center, halfExtents, orientation, layermask, queryTriggerInteraction) end
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, orientation:UnityEngine.Quaternion, layerMask:int):table
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, orientation:UnityEngine.Quaternion):table
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3):table
---@param center UnityEngine.Vector3
---@param halfExtents UnityEngine.Vector3
---@param orientation UnityEngine.Quaternion
---@param layerMask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return table
function m.OverlapBox(center, halfExtents, orientation, layerMask, queryTriggerInteraction) end
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, results:table, orientation:UnityEngine.Quaternion, layerMask:int):int
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, results:table, orientation:UnityEngine.Quaternion):int
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, results:table):int
---@param center UnityEngine.Vector3
---@param halfExtents UnityEngine.Vector3
---@param results table
---@param orientation UnityEngine.Quaternion
---@param layerMask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return int
function m.OverlapBoxNonAlloc(center, halfExtents, results, orientation, layerMask, queryTriggerInteraction) end
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, orientation:UnityEngine.Quaternion, maxDistance:float, layermask:int):table
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, orientation:UnityEngine.Quaternion, maxDistance:float):table
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, orientation:UnityEngine.Quaternion):table
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3):table
---@param center UnityEngine.Vector3
---@param halfExtents UnityEngine.Vector3
---@param direction UnityEngine.Vector3
---@param orientation UnityEngine.Quaternion
---@param maxDistance float
---@param layermask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return table
function m.BoxCastAll(center, halfExtents, direction, orientation, maxDistance, layermask, queryTriggerInteraction) end
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, results:table, orientation:UnityEngine.Quaternion, maxDistance:float, layermask:int):int
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, results:table, orientation:UnityEngine.Quaternion, maxDistance:float):int
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, results:table, orientation:UnityEngine.Quaternion):int
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, results:table):int
---@param center UnityEngine.Vector3
---@param halfExtents UnityEngine.Vector3
---@param direction UnityEngine.Vector3
---@param results table
---@param orientation UnityEngine.Quaternion
---@param maxDistance float
---@param layermask int
---@param queryTriggerInteraction UnityEngine.QueryTriggerInteraction
---@return int
function m.BoxCastNonAlloc(center, halfExtents, direction, results, orientation, maxDistance, layermask, queryTriggerInteraction) end
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, orientation:UnityEngine.Quaternion, maxDistance:float):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, orientation:UnityEngine.Quaternion):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, orientation:UnityEngine.Quaternion, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, orientation:UnityEngine.Quaternion, maxDistance:float, layerMask:int):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, orientation:UnityEngine.Quaternion, maxDistance:float):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, orientation:UnityEngine.Quaternion):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit):bool
---@overload fun(center:UnityEngine.Vector3, halfExtents:UnityEngine.Vector3, direction:UnityEngine.Vector3, hitInfo:UnityEngine.RaycastHit, orientation:UnityEngine.Quaternion, maxDistance:float, layerMask:int, queryTriggerInteraction:UnityEngine.QueryTriggerInteraction):bool
---@param center UnityEngine.Vector3
---@param halfExtents UnityEngine.Vector3
---@param direction UnityEngine.Vector3
---@param orientation UnityEngine.Quaternion
---@param maxDistance float
---@param layerMask int
---@return bool
function m.BoxCast(center, halfExtents, direction, orientation, maxDistance, layerMask) end
---@overload fun(collider1:UnityEngine.Collider, collider2:UnityEngine.Collider):void
---@param collider1 UnityEngine.Collider
---@param collider2 UnityEngine.Collider
---@param ignore bool
function m.IgnoreCollision(collider1, collider2, ignore) end
---@overload fun(layer1:int, layer2:int):void
---@param layer1 int
---@param layer2 int
---@param ignore bool
function m.IgnoreLayerCollision(layer1, layer2, ignore) end
---@param layer1 int
---@param layer2 int
---@return bool
function m.GetIgnoreLayerCollision(layer1, layer2) end
---@param colliderA UnityEngine.Collider
---@param positionA UnityEngine.Vector3
---@param rotationA UnityEngine.Quaternion
---@param colliderB UnityEngine.Collider
---@param positionB UnityEngine.Vector3
---@param rotationB UnityEngine.Quaternion
---@param direction UnityEngine.Vector3
---@param distance float
---@return bool
function m.ComputePenetration(colliderA, positionA, rotationA, colliderB, positionB, rotationB, direction, distance) end
---@param point UnityEngine.Vector3
---@param collider UnityEngine.Collider
---@param position UnityEngine.Vector3
---@param rotation UnityEngine.Quaternion
---@return UnityEngine.Vector3
function m.ClosestPoint(point, collider, position, rotation) end
---@param step float
function m.Simulate(step) end
function m.SyncTransforms() end
UnityEngine = {}
UnityEngine.Physics = m
return m