---@class UnityEngine.MonoBehaviour : UnityEngine.Behaviour
---@field useGUILayout bool
local m = {}
---@param methodName string
---@param time float
function m:Invoke(methodName, time) end
---@param methodName string
---@param time float
---@param repeatRate float
function m:InvokeRepeating(methodName, time, repeatRate) end
---@overload fun(methodName:string):void
function m:CancelInvoke() end
---@overload fun():bool
---@param methodName string
---@return bool
function m:IsInvoking(methodName) end
---@overload fun(methodName:string, value:object):UnityEngine.Coroutine
---@overload fun(methodName:string):UnityEngine.Coroutine
---@param routine System.Collections.IEnumerator
---@return UnityEngine.Coroutine
function m:StartCoroutine(routine) end
---@overload fun(routine:System.Collections.IEnumerator):void
---@overload fun(routine:UnityEngine.Coroutine):void
---@param methodName string
function m:StopCoroutine(methodName) end
function m:StopAllCoroutines() end
---@param message object
function m.print(message) end
UnityEngine = {}
UnityEngine.MonoBehaviour = m
return m