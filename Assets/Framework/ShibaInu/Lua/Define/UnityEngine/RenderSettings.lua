---@class UnityEngine.RenderSettings : UnityEngine.Object
---@field ambientProbe UnityEngine.Rendering.SphericalHarmonicsL2
---@field customReflection UnityEngine.Cubemap
---@field fog bool
---@field fogStartDistance float
---@field fogEndDistance float
---@field fogMode UnityEngine.FogMode
---@field fogColor UnityEngine.Color
---@field fogDensity float
---@field ambientMode UnityEngine.Rendering.AmbientMode
---@field ambientSkyColor UnityEngine.Color
---@field ambientEquatorColor UnityEngine.Color
---@field ambientGroundColor UnityEngine.Color
---@field ambientIntensity float
---@field ambientLight UnityEngine.Color
---@field subtractiveShadowColor UnityEngine.Color
---@field skybox UnityEngine.Material
---@field sun UnityEngine.Light
---@field reflectionIntensity float
---@field reflectionBounces int
---@field defaultReflectionMode UnityEngine.Rendering.DefaultReflectionMode
---@field defaultReflectionResolution int
---@field haloStrength float
---@field flareStrength float
---@field flareFadeSpeed float
local m = {}
UnityEngine = {}
UnityEngine.RenderSettings = m
return m