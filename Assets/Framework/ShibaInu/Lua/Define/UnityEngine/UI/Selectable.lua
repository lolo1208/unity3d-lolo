---@class UnityEngine.UI.Selectable : UnityEngine.EventSystems.UIBehaviour
---@field allSelectables table
---@field navigation UnityEngine.UI.Navigation
---@field transition UnityEngine.UI.Selectable.Transition
---@field colors UnityEngine.UI.ColorBlock
---@field spriteState UnityEngine.UI.SpriteState
---@field animationTriggers UnityEngine.UI.AnimationTriggers
---@field targetGraphic UnityEngine.UI.Graphic
---@field interactable bool
---@field image UnityEngine.UI.Image
---@field animator UnityEngine.Animator
local m = {}
---@return bool
function m:IsInteractable() end
---@param dir UnityEngine.Vector3
---@return UnityEngine.UI.Selectable
function m:FindSelectable(dir) end
---@return UnityEngine.UI.Selectable
function m:FindSelectableOnLeft() end
---@return UnityEngine.UI.Selectable
function m:FindSelectableOnRight() end
---@return UnityEngine.UI.Selectable
function m:FindSelectableOnUp() end
---@return UnityEngine.UI.Selectable
function m:FindSelectableOnDown() end
---@param eventData UnityEngine.EventSystems.AxisEventData
function m:OnMove(eventData) end
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnPointerDown(eventData) end
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnPointerUp(eventData) end
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnPointerEnter(eventData) end
---@param eventData UnityEngine.EventSystems.PointerEventData
function m:OnPointerExit(eventData) end
---@param eventData UnityEngine.EventSystems.BaseEventData
function m:OnSelect(eventData) end
---@param eventData UnityEngine.EventSystems.BaseEventData
function m:OnDeselect(eventData) end
function m:Select() end
UnityEngine = {}
UnityEngine.UI = {}
UnityEngine.UI.Selectable = m
return m