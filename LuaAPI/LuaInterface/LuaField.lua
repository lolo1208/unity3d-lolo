---@class LuaInterface.LuaField : object
local m = {}
---@param L System.IntPtr
---@return int
function m:Get(L) end
---@param L System.IntPtr
---@return int
function m:Set(L) end
LuaInterface = {}
LuaInterface.LuaField = m
return m