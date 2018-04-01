---@class UnityEngine.UI.Graphic : UnityEngine.EventSystems.UIBehaviour
---@field defaultGraphicMaterial UnityEngine.Material
---@field color UnityEngine.Color
---@field raycastTarget bool
---@field depth int
---@field rectTransform UnityEngine.RectTransform
---@field canvas UnityEngine.Canvas
---@field canvasRenderer UnityEngine.CanvasRenderer
---@field defaultMaterial UnityEngine.Material
---@field material UnityEngine.Material
---@field materialForRendering UnityEngine.Material
---@field mainTexture UnityEngine.Texture
local m = {}
function m:SetAllDirty() end
function m:SetLayoutDirty() end
function m:SetVerticesDirty() end
function m:SetMaterialDirty() end
---@param update UnityEngine.UI.CanvasUpdate
function m:Rebuild(update) end
function m:LayoutComplete() end
function m:GraphicUpdateComplete() end
function m:SetNativeSize() end
---@param sp UnityEngine.Vector2
---@param eventCamera UnityEngine.Camera
---@return bool
function m:Raycast(sp, eventCamera) end
---@param point UnityEngine.Vector2
---@return UnityEngine.Vector2
function m:PixelAdjustPoint(point) end
---@return UnityEngine.Rect
function m:GetPixelAdjustedRect() end
---@overload fun(targetColor:UnityEngine.Color, duration:float, ignoreTimeScale:bool, useAlpha:bool, useRGB:bool):void
---@param targetColor UnityEngine.Color
---@param duration float
---@param ignoreTimeScale bool
---@param useAlpha bool
function m:CrossFadeColor(targetColor, duration, ignoreTimeScale, useAlpha) end
---@param alpha float
---@param duration float
---@param ignoreTimeScale bool
function m:CrossFadeAlpha(alpha, duration, ignoreTimeScale) end
---@param action UnityEngine.Events.UnityAction
function m:RegisterDirtyLayoutCallback(action) end
---@param action UnityEngine.Events.UnityAction
function m:UnregisterDirtyLayoutCallback(action) end
---@param action UnityEngine.Events.UnityAction
function m:RegisterDirtyVerticesCallback(action) end
---@param action UnityEngine.Events.UnityAction
function m:UnregisterDirtyVerticesCallback(action) end
---@param action UnityEngine.Events.UnityAction
function m:RegisterDirtyMaterialCallback(action) end
---@param action UnityEngine.Events.UnityAction
function m:UnregisterDirtyMaterialCallback(action) end
UnityEngine = {}
UnityEngine.UI = {}
UnityEngine.UI.Graphic = m
return m