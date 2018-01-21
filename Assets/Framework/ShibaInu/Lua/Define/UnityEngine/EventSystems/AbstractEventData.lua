---@class UnityEngine.EventSystems.AbstractEventData : object
---@field used bool
local m = {}
function m:Reset() end
function m:Use() end
UnityEngine = {}
UnityEngine.EventSystems = {}
UnityEngine.EventSystems.AbstractEventData = m
return m