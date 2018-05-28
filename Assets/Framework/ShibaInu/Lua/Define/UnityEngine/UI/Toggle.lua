---@class UnityEngine.UI.Toggle : UnityEngine.UI.Selectable
---@field group UnityEngine.UI.ToggleGroup
---@field isOn bool
---@field toggleTransition UnityEngine.UI.Toggle.ToggleTransition
---@field graphic UnityEngine.UI.Graphic
---@field onValueChanged UnityEngine.UI.Toggle.ToggleEvent
local m = {}
---@param executing UnityEngine.UI.CanvasUpdate
function m:Rebuild(executing) end
function m:LayoutComplete() end
function m:GraphicUpdateComplete() end
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnPointerClick(eventData) end
---@param eventData UnityEngine.EventSystems.BaseEventData
function m:OnSubmit(eventData) end
UnityEngine = {}
UnityEngine.UI = {}
UnityEngine.UI.Toggle = m
return m