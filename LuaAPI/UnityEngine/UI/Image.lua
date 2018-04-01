---@class UnityEngine.UI.Image : UnityEngine.UI.MaskableGraphic
---@field sprite UnityEngine.Sprite
---@field overrideSprite UnityEngine.Sprite
---@field type UnityEngine.UI.Image.Type
---@field preserveAspect bool
---@field fillCenter bool
---@field fillMethod UnityEngine.UI.Image.FillMethod
---@field fillAmount float
---@field fillClockwise bool
---@field fillOrigin int
---@field alphaHitTestMinimumThreshold float
---@field defaultETC1GraphicMaterial UnityEngine.Material
---@field mainTexture UnityEngine.Texture
---@field hasBorder bool
---@field pixelsPerUnit float
---@field material UnityEngine.Material
---@field minWidth float
---@field preferredWidth float
---@field flexibleWidth float
---@field minHeight float
---@field preferredHeight float
---@field flexibleHeight float
---@field layoutPriority int
local m = {}
---@param endValue UnityEngine.Color
---@param duration float
---@return DG.Tweening.Tweener
function m:DOColor(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOFade(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOFillAmount(endValue, duration) end
---@param gradient UnityEngine.Gradient
---@param duration float
---@return DG.Tweening.Sequence
function m:DOGradientColor(gradient, duration) end
---@param endValue UnityEngine.Color
---@param duration float
---@return DG.Tweening.Tweener
function m:DOBlendableColor(endValue, duration) end
function m:OnBeforeSerialize() end
function m:OnAfterDeserialize() end
function m:SetNativeSize() end
function m:CalculateLayoutInputHorizontal() end
function m:CalculateLayoutInputVertical() end
---@param screenPoint UnityEngine.Vector2
---@param eventCamera UnityEngine.Camera
---@return bool
function m:IsRaycastLocationValid(screenPoint, eventCamera) end
UnityEngine = {}
UnityEngine.UI = {}
UnityEngine.UI.Image = m
return m