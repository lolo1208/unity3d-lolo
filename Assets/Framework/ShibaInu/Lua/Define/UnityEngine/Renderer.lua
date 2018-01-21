---@class UnityEngine.Renderer : UnityEngine.Component
---@field isPartOfStaticBatch bool
---@field worldToLocalMatrix UnityEngine.Matrix4x4
---@field localToWorldMatrix UnityEngine.Matrix4x4
---@field enabled bool
---@field shadowCastingMode UnityEngine.Rendering.ShadowCastingMode
---@field receiveShadows bool
---@field material UnityEngine.Material
---@field sharedMaterial UnityEngine.Material
---@field materials table
---@field sharedMaterials table
---@field bounds UnityEngine.Bounds
---@field lightmapIndex int
---@field realtimeLightmapIndex int
---@field lightmapScaleOffset UnityEngine.Vector4
---@field motionVectorGenerationMode UnityEngine.MotionVectorGenerationMode
---@field realtimeLightmapScaleOffset UnityEngine.Vector4
---@field isVisible bool
---@field lightProbeUsage UnityEngine.Rendering.LightProbeUsage
---@field lightProbeProxyVolumeOverride UnityEngine.GameObject
---@field probeAnchor UnityEngine.Transform
---@field reflectionProbeUsage UnityEngine.Rendering.ReflectionProbeUsage
---@field sortingLayerName string
---@field allowOcclusionWhenDynamic bool
---@field sortingLayerID int
---@field sortingOrder int
local m = {}
---@param properties UnityEngine.MaterialPropertyBlock
function m:SetPropertyBlock(properties) end
---@param dest UnityEngine.MaterialPropertyBlock
function m:GetPropertyBlock(dest) end
---@param result table
function m:GetClosestReflectionProbes(result) end
UnityEngine = {}
UnityEngine.Renderer = m
return m