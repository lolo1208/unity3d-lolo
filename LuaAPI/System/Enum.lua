---@class System.Enum
local m = {}
---@return System.TypeCode
function m:GetTypeCode() end
---@param enumType System.Type
---@return table
function m.GetValues(enumType) end
---@param enumType System.Type
---@return table
function m.GetNames(enumType) end
---@param enumType System.Type
---@param value object
---@return string
function m.GetName(enumType, value) end
---@param enumType System.Type
---@param value object
---@return bool
function m.IsDefined(enumType, value) end
---@param enumType System.Type
---@return System.Type
function m.GetUnderlyingType(enumType) end
---@overload fun(enumType:System.Type, value:string, ignoreCase:bool):object
---@param enumType System.Type
---@param value string
---@return object
function m.Parse(enumType, value) end
---@param target object
---@return int
function m:CompareTo(target) end
---@overload fun(format:string):string
---@return string
function m:ToString() end
---@overload fun(enumType:System.Type, value:short):object
---@overload fun(enumType:System.Type, value:int):object
---@overload fun(enumType:System.Type, value:long):object
---@overload fun(enumType:System.Type, value:object):object
---@overload fun(enumType:System.Type, value:sbyte):object
---@overload fun(enumType:System.Type, value:ushort):object
---@overload fun(enumType:System.Type, value:uint):object
---@overload fun(enumType:System.Type, value:ulong):object
---@param enumType System.Type
---@param value byte
---@return object
function m.ToObject(enumType, value) end
---@param obj object
---@return bool
function m:Equals(obj) end
---@return int
function m:GetHashCode() end
---@param enumType System.Type
---@param value object
---@param format string
---@return string
function m.Format(enumType, value, format) end
System = {}
System.Enum = m
return m