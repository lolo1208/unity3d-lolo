---@class System.Collections.IEnumerator
---@field Current object
local m = {}
---@return bool
function m:MoveNext() end
function m:Reset() end
System = {}
System.Collections = {}
System.Collections.IEnumerator = m
return m