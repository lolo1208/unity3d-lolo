---@class UnityEngine.WWW : object
---@field assetBundle UnityEngine.AssetBundle
---@field bytes table
---@field bytesDownloaded int
---@field error string
---@field isDone bool
---@field progress float
---@field responseHeaders table
---@field text string
---@field texture UnityEngine.Texture2D
---@field textureNonReadable UnityEngine.Texture2D
---@field threadPriority UnityEngine.ThreadPriority
---@field uploadProgress float
---@field url string
---@field keepWaiting bool
local m = {}
---@param texture UnityEngine.Texture2D
function m:LoadImageIntoTexture(texture) end
function m:Dispose() end
---@overload fun(s:string, e:System.Text.Encoding):string
---@param s string
---@return string
function m.EscapeURL(s) end
---@overload fun(s:string, e:System.Text.Encoding):string
---@param s string
---@return string
function m.UnEscapeURL(s) end
---@overload fun(url:string, version:int, crc:uint):UnityEngine.WWW
---@overload fun(url:string, hash:UnityEngine.Hash128):UnityEngine.WWW
---@overload fun(url:string, hash:UnityEngine.Hash128, crc:uint):UnityEngine.WWW
---@overload fun(url:string, cachedBundle:UnityEngine.CachedAssetBundle, crc:uint):UnityEngine.WWW
---@param url string
---@param version int
---@return UnityEngine.WWW
function m.LoadFromCacheOrDownload(url, version) end
UnityEngine = {}
UnityEngine.WWW = m
return m