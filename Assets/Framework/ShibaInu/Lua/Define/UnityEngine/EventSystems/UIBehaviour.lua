---@class UnityEngine.EventSystems.UIBehaviour : UnityEngine.MonoBehaviour
local m = {}
---@return bool
function m:IsActive() end
---@return bool
function m:IsDestroyed() end
UnityEngine = {}
UnityEngine.EventSystems = {}
UnityEngine.EventSystems.UIBehaviour = m
return m