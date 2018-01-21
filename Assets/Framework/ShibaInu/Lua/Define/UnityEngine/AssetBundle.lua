---@class UnityEngine.AssetBundle : UnityEngine.Object
---@field mainAsset UnityEngine.Object
---@field isStreamedSceneAssetBundle bool
local m = {}
---@param unloadAllObjects bool
function m.UnloadAllAssetBundles(unloadAllObjects) end
---@return System.Collections.Generic.IEnumerable
function m.GetAllLoadedAssetBundles() end
---@overload fun(path:string, crc:uint):UnityEngine.AssetBundleCreateRequest
---@overload fun(path:string):UnityEngine.AssetBundleCreateRequest
---@param path string
---@param crc uint
---@param offset ulong
---@return UnityEngine.AssetBundleCreateRequest
function m.LoadFromFileAsync(path, crc, offset) end
---@overload fun(path:string, crc:uint):UnityEngine.AssetBundle
---@overload fun(path:string):UnityEngine.AssetBundle
---@param path string
---@param crc uint
---@param offset ulong
---@return UnityEngine.AssetBundle
function m.LoadFromFile(path, crc, offset) end
---@overload fun(binary:table):UnityEngine.AssetBundleCreateRequest
---@param binary table
---@param crc uint
---@return UnityEngine.AssetBundleCreateRequest
function m.LoadFromMemoryAsync(binary, crc) end
---@overload fun(binary:table):UnityEngine.AssetBundle
---@param binary table
---@param crc uint
---@return UnityEngine.AssetBundle
function m.LoadFromMemory(binary, crc) end
---@overload fun(stream:System.IO.Stream):UnityEngine.AssetBundleCreateRequest
---@overload fun(stream:System.IO.Stream, crc:uint, managedReadBufferSize:uint):UnityEngine.AssetBundleCreateRequest
---@param stream System.IO.Stream
---@param crc uint
---@return UnityEngine.AssetBundleCreateRequest
function m.LoadFromStreamAsync(stream, crc) end
---@overload fun(stream:System.IO.Stream):UnityEngine.AssetBundle
---@overload fun(stream:System.IO.Stream, crc:uint, managedReadBufferSize:uint):UnityEngine.AssetBundle
---@param stream System.IO.Stream
---@param crc uint
---@return UnityEngine.AssetBundle
function m.LoadFromStream(stream, crc) end
---@param name string
---@return bool
function m:Contains(name) end
---@overload fun(name:string, type:System.Type):UnityEngine.Object
---@param name string
---@return UnityEngine.Object
function m:LoadAsset(name) end
---@overload fun(name:string, type:System.Type):UnityEngine.AssetBundleRequest
---@param name string
---@return UnityEngine.AssetBundleRequest
function m:LoadAssetAsync(name) end
---@overload fun(name:string, type:System.Type):table
---@param name string
---@return table
function m:LoadAssetWithSubAssets(name) end
---@overload fun(name:string, type:System.Type):UnityEngine.AssetBundleRequest
---@param name string
---@return UnityEngine.AssetBundleRequest
function m:LoadAssetWithSubAssetsAsync(name) end
---@overload fun(type:System.Type):table
---@return table
function m:LoadAllAssets() end
---@overload fun(type:System.Type):UnityEngine.AssetBundleRequest
---@return UnityEngine.AssetBundleRequest
function m:LoadAllAssetsAsync() end
---@param unloadAllLoadedObjects bool
function m:Unload(unloadAllLoadedObjects) end
---@return table
function m:GetAllAssetNames() end
---@return table
function m:GetAllScenePaths() end
UnityEngine = {}
UnityEngine.AssetBundle = m
return m