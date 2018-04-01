---@class LuaInterface.Debugger
---@field useLog bool
---@field threadStack string
---@field logger LuaInterface.ILogger
local m = {}
---@overload fun(message:object):void
---@overload fun(str:string, arg0:object):void
---@overload fun(str:string, arg0:object, arg1:object):void
---@overload fun(str:string, arg0:object, arg1:object, arg2:object):void
---@overload fun(str:string, param:table):void
---@param str string
function m.Log(str) end
---@overload fun(message:object):void
---@overload fun(str:string, arg0:object):void
---@overload fun(str:string, arg0:object, arg1:object):void
---@overload fun(str:string, arg0:object, arg1:object, arg2:object):void
---@overload fun(str:string, param:table):void
---@param str string
function m.LogWarning(str) end
---@overload fun(message:object):void
---@overload fun(str:string, arg0:object):void
---@overload fun(str:string, arg0:object, arg1:object):void
---@overload fun(str:string, arg0:object, arg1:object, arg2:object):void
---@overload fun(str:string, param:table):void
---@param str string
function m.LogError(str) end
---@overload fun(str:string, e:System.Exception):void
---@param e System.Exception
function m.LogException(e) end
LuaInterface = {}
LuaInterface.Debugger = m
return m