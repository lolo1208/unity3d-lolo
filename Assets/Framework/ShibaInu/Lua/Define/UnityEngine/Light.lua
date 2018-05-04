---@class UnityEngine.Light : UnityEngine.Behaviour
---@field shadows UnityEngine.LightShadows
---@field shadowStrength float
---@field shadowResolution UnityEngine.Rendering.LightShadowResolution
---@field cookieSize float
---@field cookie UnityEngine.Texture
---@field renderMode UnityEngine.LightRenderMode
---@field commandBufferCount int
---@field type UnityEngine.LightType
---@field spotAngle float
---@field color UnityEngine.Color
---@field colorTemperature float
---@field intensity float
---@field bounceIntensity float
---@field shadowCustomResolution int
---@field shadowBias float
---@field shadowNormalBias float
---@field shadowNearPlane float
---@field range float
---@field flare UnityEngine.Flare
---@field bakingOutput UnityEngine.LightBakingOutput
---@field cullingMask int
local m = {}
---@param endValue UnityEngine.Color
---@param duration float
---@return DG.Tweening.Tweener
function m:DOColor(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOIntensity(endValue, duration) end
---@param endValue float
---@param duration float
---@return DG.Tweening.Tweener
function m:DOShadowStrength(endValue, duration) end
---@param endValue UnityEngine.Color
---@param duration float
---@return DG.Tweening.Tweener
function m:DOBlendableColor(endValue, duration) end
---@overload fun(evt:UnityEngine.Rendering.LightEvent, buffer:UnityEngine.Rendering.CommandBuffer, shadowPassMask:UnityEngine.Rendering.ShadowMapPass):void
---@param evt UnityEngine.Rendering.LightEvent
---@param buffer UnityEngine.Rendering.CommandBuffer
function m:AddCommandBuffer(evt, buffer) end
---@param evt UnityEngine.Rendering.LightEvent
---@param buffer UnityEngine.Rendering.CommandBuffer
function m:RemoveCommandBuffer(evt, buffer) end
---@param evt UnityEngine.Rendering.LightEvent
function m:RemoveCommandBuffers(evt) end
function m:RemoveAllCommandBuffers() end
---@param evt UnityEngine.Rendering.LightEvent
---@return table
function m:GetCommandBuffers(evt) end
---@param type UnityEngine.LightType
---@param layer int
---@return table
function m.GetLights(type, layer) end
UnityEngine = {}
UnityEngine.Light = m
return m