---@class UnityEngine.Texture : UnityEngine.Object
---@field masterTextureLimit int
---@field anisotropicFiltering UnityEngine.AnisotropicFiltering
---@field width int
---@field height int
---@field dimension UnityEngine.Rendering.TextureDimension
---@field filterMode UnityEngine.FilterMode
---@field anisoLevel int
---@field wrapMode UnityEngine.TextureWrapMode
---@field wrapModeU UnityEngine.TextureWrapMode
---@field wrapModeV UnityEngine.TextureWrapMode
---@field wrapModeW UnityEngine.TextureWrapMode
---@field mipMapBias float
---@field texelSize UnityEngine.Vector2
---@field imageContentsHash UnityEngine.Hash128
local m = {}
---@param forcedMin int
---@param globalMax int
function m.SetGlobalAnisotropicFilteringLimits(forcedMin, globalMax) end
---@return System.IntPtr
function m:GetNativeTexturePtr() end
UnityEngine = {}
UnityEngine.Texture = m
return m