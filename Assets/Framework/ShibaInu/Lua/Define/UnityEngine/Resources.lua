---@class UnityEngine.Resources : object
local m = {}
---@param type System.Type
---@return table
function m.FindObjectsOfTypeAll(type) end
---@overload fun(path:string, systemTypeInstance:System.Type):UnityEngine.Object
---@param path string
---@return UnityEngine.Object
function m.Load(path) end
---@overload fun(path:string, type:System.Type):UnityEngine.ResourceRequest
---@param path string
---@return UnityEngine.ResourceRequest
function m.LoadAsync(path) end
---@overload fun(path:string):table
---@param path string
---@param systemTypeInstance System.Type
---@return table
function m.LoadAll(path, systemTypeInstance) end
---@param type System.Type
---@param path string
---@return UnityEngine.Object
function m.GetBuiltinResource(type, path) end
---@param assetToUnload UnityEngine.Object
function m.UnloadAsset(assetToUnload) end
---@return UnityEngine.AsyncOperation
function m.UnloadUnusedAssets() end
UnityEngine = {}
UnityEngine.Resources = m
return m