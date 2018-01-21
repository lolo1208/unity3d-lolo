---@class UnityEngine.UI.Slider : UnityEngine.UI.Selectable
---@field fillRect UnityEngine.RectTransform
---@field handleRect UnityEngine.RectTransform
---@field direction UnityEngine.UI.Slider.Direction
---@field minValue float
---@field maxValue float
---@field wholeNumbers bool
---@field value float
---@field normalizedValue float
---@field onValueChanged UnityEngine.UI.Slider.SliderEvent
local m = {}
---@param endValue float
---@param duration float
---@param snapping bool
---@return DG.Tweening.Tweener
function m:DOValue(endValue, duration, snapping) end
---@param executing UnityEngine.UI.CanvasUpdate
function m:Rebuild(executing) end
function m:LayoutComplete() end
function m:GraphicUpdateComplete() end
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnPointerDown(eventData) end
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnDrag(eventData) end
---@param eventData UnityEngine.EventSystems.AxisEventData
function m:OnMove(eventData) end
---@return UnityEngine.UI.Selectable
function m:FindSelectableOnLeft() end
---@return UnityEngine.UI.Selectable
function m:FindSelectableOnRight() end
---@return UnityEngine.UI.Selectable
function m:FindSelectableOnUp() end
---@return UnityEngine.UI.Selectable
function m:FindSelectableOnDown() end
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnInitializePotentialDrag(eventData) end
---@param direction UnityEngine.UI.Slider.Direction
---@param includeRectLayouts bool
function m:SetDirection(direction, includeRectLayouts) end
UnityEngine = {}
UnityEngine.UI = {}
UnityEngine.UI.Slider = m
return m