---@class ShibaInu.LuaHelper
local m = {}
---@param go UnityEngine.GameObject
---@param ed LuaInterface.LuaTable
function m.AddDestroyEvent(go, ed) end
---@param go UnityEngine.GameObject
---@param ed LuaInterface.LuaTable
function m.AddPointerEvent(go, ed) end
---@param go UnityEngine.GameObject
---@param ed LuaInterface.LuaTable
function m.AddDragDropEvent(go, ed) end
---@param name string
---@param parent UnityEngine.Transform
---@param notUI bool
---@return UnityEngine.GameObject
function m.CreateGameObject(name, parent, notUI) end
---@param target UnityEngine.Transform
---@param parent UnityEngine.Transform
function m.SetParent(target, parent) end
---@param url string
---@param callback LuaInterface.LuaFunction
---@param postData string
---@return ShibaInu.HttpRequest
function m.SendHttpRequest(url, callback, postData) end
ShibaInu = {}
ShibaInu.LuaHelper = m
return m