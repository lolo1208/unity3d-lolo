---@class UnityEngine.RenderTexture : UnityEngine.Texture
---@field width int
---@field height int
---@field vrUsage UnityEngine.VRTextureUsage
---@field depth int
---@field isPowerOfTwo bool
---@field sRGB bool
---@field format UnityEngine.RenderTextureFormat
---@field useMipMap bool
---@field autoGenerateMips bool
---@field dimension UnityEngine.Rendering.TextureDimension
---@field volumeDepth int
---@field memorylessMode UnityEngine.RenderTextureMemoryless
---@field antiAliasing int
---@field bindTextureMS bool
---@field enableRandomWrite bool
---@field useDynamicScale bool
---@field colorBuffer UnityEngine.RenderBuffer
---@field depthBuffer UnityEngine.RenderBuffer
---@field active UnityEngine.RenderTexture
---@field descriptor UnityEngine.RenderTextureDescriptor
local m = {}
---@overload fun(width:int, height:int, depthBuffer:int, format:UnityEngine.RenderTextureFormat, readWrite:UnityEngine.RenderTextureReadWrite, antiAliasing:int, memorylessMode:UnityEngine.RenderTextureMemoryless):UnityEngine.RenderTexture
---@overload fun(width:int, height:int, depthBuffer:int, format:UnityEngine.RenderTextureFormat, readWrite:UnityEngine.RenderTextureReadWrite, antiAliasing:int):UnityEngine.RenderTexture
---@overload fun(width:int, height:int, depthBuffer:int, format:UnityEngine.RenderTextureFormat, readWrite:UnityEngine.RenderTextureReadWrite):UnityEngine.RenderTexture
---@overload fun(width:int, height:int, depthBuffer:int, format:UnityEngine.RenderTextureFormat):UnityEngine.RenderTexture
---@overload fun(width:int, height:int, depthBuffer:int):UnityEngine.RenderTexture
---@overload fun(width:int, height:int):UnityEngine.RenderTexture
---@overload fun(width:int, height:int, depthBuffer:int, format:UnityEngine.RenderTextureFormat, readWrite:UnityEngine.RenderTextureReadWrite, antiAliasing:int, memorylessMode:UnityEngine.RenderTextureMemoryless, vrUsage:UnityEngine.VRTextureUsage, useDynamicScale:bool):UnityEngine.RenderTexture
---@overload fun(desc:UnityEngine.RenderTextureDescriptor):UnityEngine.RenderTexture
---@param width int
---@param height int
---@param depthBuffer int
---@param format UnityEngine.RenderTextureFormat
---@param readWrite UnityEngine.RenderTextureReadWrite
---@param antiAliasing int
---@param memorylessMode UnityEngine.RenderTextureMemoryless
---@param vrUsage UnityEngine.VRTextureUsage
---@return UnityEngine.RenderTexture
function m.GetTemporary(width, height, depthBuffer, format, readWrite, antiAliasing, memorylessMode, vrUsage) end
---@param temp UnityEngine.RenderTexture
function m.ReleaseTemporary(temp) end
---@overload fun(target:UnityEngine.RenderTexture):void
function m:ResolveAntiAliasedSurface() end
---@return bool
function m:Create() end
function m:Release() end
---@return bool
function m:IsCreated() end
---@overload fun(discardColor:bool, discardDepth:bool):void
function m:DiscardContents() end
function m:MarkRestoreExpected() end
function m:GenerateMips() end
---@return System.IntPtr
function m:GetNativeDepthBufferPtr() end
---@param propertyName string
function m:SetGlobalShaderProperty(propertyName) end
---@param rt UnityEngine.RenderTexture
---@return bool
function m.SupportsStencil(rt) end
UnityEngine = {}
UnityEngine.RenderTexture = m
return m