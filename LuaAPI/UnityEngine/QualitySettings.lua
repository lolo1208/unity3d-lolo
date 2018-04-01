---@class UnityEngine.QualitySettings : UnityEngine.Object
---@field names table
---@field pixelLightCount int
---@field shadows UnityEngine.ShadowQuality
---@field shadowProjection UnityEngine.ShadowProjection
---@field shadowCascades int
---@field shadowDistance float
---@field shadowResolution UnityEngine.ShadowResolution
---@field shadowNearPlaneOffset float
---@field shadowCascade2Split float
---@field shadowCascade4Split UnityEngine.Vector3
---@field shadowmaskMode UnityEngine.ShadowmaskMode
---@field masterTextureLimit int
---@field anisotropicFiltering UnityEngine.AnisotropicFiltering
---@field lodBias float
---@field maximumLODLevel int
---@field particleRaycastBudget int
---@field softParticles bool
---@field softVegetation bool
---@field realtimeReflectionProbes bool
---@field billboardsFaceCameraPosition bool
---@field maxQueuedFrames int
---@field vSyncCount int
---@field antiAliasing int
---@field desiredColorSpace UnityEngine.ColorSpace
---@field activeColorSpace UnityEngine.ColorSpace
---@field blendWeights UnityEngine.BlendWeights
---@field asyncUploadTimeSlice int
---@field asyncUploadBufferSize int
---@field resolutionScalingFixedDPIFactor float
local m = {}
---@return int
function m.GetQualityLevel() end
---@overload fun(index:int):void
---@param index int
---@param applyExpensiveChanges bool
function m.SetQualityLevel(index, applyExpensiveChanges) end
---@overload fun():void
---@param applyExpensiveChanges bool
function m.IncreaseLevel(applyExpensiveChanges) end
---@overload fun():void
---@param applyExpensiveChanges bool
function m.DecreaseLevel(applyExpensiveChanges) end
UnityEngine = {}
UnityEngine.QualitySettings = m
return m