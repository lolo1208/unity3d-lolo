---@class UnityEngine.RenderSettings : UnityEngine.Object
---@field fog bool
---@field fogMode UnityEngine.FogMode
---@field fogColor UnityEngine.Color
---@field fogDensity float
---@field fogStartDistance float
---@field fogEndDistance float
---@field ambientMode UnityEngine.Rendering.AmbientMode
---@field ambientSkyColor UnityEngine.Color
---@field ambientEquatorColor UnityEngine.Color
---@field ambientGroundColor UnityEngine.Color
---@field ambientLight UnityEngine.Color
---@field ambientIntensity float
---@field ambientProbe UnityEngine.Rendering.SphericalHarmonicsL2
---@field subtractiveShadowColor UnityEngine.Color
---@field reflectionIntensity float
---@field reflectionBounces int
---@field haloStrength float
---@field flareStrength float
---@field flareFadeSpeed float
---@field skybox UnityEngine.Material
---@field sun UnityEngine.Light
---@field defaultReflectionMode UnityEngine.Rendering.DefaultReflectionMode
---@field defaultReflectionResolution int
---@field customReflection UnityEngine.Cubemap
local m = {}
UnityEngine = {}
UnityEngine.RenderSettings = m
return m