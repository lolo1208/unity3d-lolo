---@class UnityEngine.GameObject : UnityEngine.Object
---@field transform UnityEngine.Transform
---@field layer int
---@field activeSelf bool
---@field activeInHierarchy bool
---@field isStatic bool
---@field tag string
---@field scene UnityEngine.SceneManagement.Scene
---@field gameObject UnityEngine.GameObject
local m = {}
---@param type UnityEngine.PrimitiveType
---@return UnityEngine.GameObject
function m.CreatePrimitive(type) end
---@overload fun(type:string):UnityEngine.Component
---@param type System.Type
---@return UnityEngine.Component
function m:GetComponent(type) end
---@overload fun(type:System.Type):UnityEngine.Component
---@param type System.Type
---@param includeInactive bool
---@return UnityEngine.Component
function m:GetComponentInChildren(type, includeInactive) end
---@param type System.Type
---@return UnityEngine.Component
function m:GetComponentInParent(type) end
---@overload fun(type:System.Type, results:table):void
---@param type System.Type
---@return table
function m:GetComponents(type) end
---@overload fun(type:System.Type, includeInactive:bool):table
---@param type System.Type
---@return table
function m:GetComponentsInChildren(type) end
---@overload fun(type:System.Type, includeInactive:bool):table
---@param type System.Type
---@return table
function m:GetComponentsInParent(type) end
---@param value bool
function m:SetActive(value) end
---@param tag string
---@return bool
function m:CompareTag(tag) end
---@param tag string
---@return UnityEngine.GameObject
function m.FindGameObjectWithTag(tag) end
---@param tag string
---@return UnityEngine.GameObject
function m.FindWithTag(tag) end
---@param tag string
---@return table
function m.FindGameObjectsWithTag(tag) end
---@overload fun(methodName:string, value:object):void
---@overload fun(methodName:string):void
---@overload fun(methodName:string, options:UnityEngine.SendMessageOptions):void
---@param methodName string
---@param value object
---@param options UnityEngine.SendMessageOptions
function m:SendMessageUpwards(methodName, value, options) end
---@overload fun(methodName:string, value:object):void
---@overload fun(methodName:string):void
---@overload fun(methodName:string, options:UnityEngine.SendMessageOptions):void
---@param methodName string
---@param value object
---@param options UnityEngine.SendMessageOptions
function m:SendMessage(methodName, value, options) end
---@overload fun(methodName:string, parameter:object):void
---@overload fun(methodName:string):void
---@overload fun(methodName:string, options:UnityEngine.SendMessageOptions):void
---@param methodName string
---@param parameter object
---@param options UnityEngine.SendMessageOptions
function m:BroadcastMessage(methodName, parameter, options) end
---@param componentType System.Type
---@return UnityEngine.Component
function m:AddComponent(componentType) end
---@param name string
---@return UnityEngine.GameObject
function m.Find(name) end
UnityEngine = {}
UnityEngine.GameObject = m
return m