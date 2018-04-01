---@class ShibaInu.ResManager : object
local m = {}
function m.Initialize() end
---@param path string
---@param groupName string
---@return UnityEngine.Object
function m.LoadAsset(path, groupName) end
---@param path string
---@param groupName string
function m.LoadAssetAsync(path, groupName) end
---@return float
function m.GetProgress() end
---@param groupName string
---@param delay float
function m.Unload(groupName, delay) end
---@param path string
---@return string
function m.GetPathMD5(path) end
---@param abPathMD5 string
---@return ShibaInu.ABI
function m.GetAbi(abPathMD5) end
---@param path string
---@return ShibaInu.ABI
function m.GetAbiWithAssetPath(path) end
---@param path string
---@return table
function m.GetLuaFileBytes(path) end
ShibaInu = {}
ShibaInu.ResManager = m
return m