---@class UnityEngine.UI.Button : UnityEngine.UI.Selectable
---@field onClick UnityEngine.UI.Button.ButtonClickedEvent
local m = {}
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnPointerClick(eventData) end
---@param eventData UnityEngine.EventSystems.BaseEventData
function m:OnSubmit(eventData) end
UnityEngine = {}
UnityEngine.UI = {}
UnityEngine.UI.Button = m
return m