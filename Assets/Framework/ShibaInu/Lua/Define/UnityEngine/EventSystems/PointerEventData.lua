---@class UnityEngine.EventSystems.PointerEventData : UnityEngine.EventSystems.BaseEventData
---@field pointerEnter UnityEngine.GameObject
---@field lastPress UnityEngine.GameObject
---@field rawPointerPress UnityEngine.GameObject
---@field pointerDrag UnityEngine.GameObject
---@field pointerCurrentRaycast UnityEngine.EventSystems.RaycastResult
---@field pointerPressRaycast UnityEngine.EventSystems.RaycastResult
---@field eligibleForClick bool
---@field pointerId int
---@field position UnityEngine.Vector2
---@field delta UnityEngine.Vector2
---@field pressPosition UnityEngine.Vector2
---@field clickTime float
---@field clickCount int
---@field scrollDelta UnityEngine.Vector2
---@field useDragThreshold bool
---@field dragging bool
---@field button UnityEngine.EventSystems.PointerEventData.InputButton
---@field enterEventCamera UnityEngine.Camera
---@field pressEventCamera UnityEngine.Camera
---@field pointerPress UnityEngine.GameObject
---@field hovered table
local m = {}
---@return bool
function m:IsPointerMoving() end
---@return bool
function m:IsScrolling() end
---@return string
function m:ToString() end
UnityEngine = {}
UnityEngine.EventSystems = {}
UnityEngine.EventSystems.PointerEventData = m
return m