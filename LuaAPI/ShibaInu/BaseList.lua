---@class ShibaInu.BaseList : UnityEngine.EventSystems.UIBehaviour
---@field luaTarget LuaInterface.LuaTable
---@field itemPrefab UnityEngine.GameObject
---@field rowCount uint
---@field columnCount uint
---@field horizontalGap int
---@field verticalGap int
---@field content UnityEngine.RectTransform
local m = {}
---@param itmePrefab UnityEngine.GameObject
---@param rowCount uint
---@param columnCount uint
---@param horizontalGap int
---@param verticalGap int
function m:SyncPropertys(itmePrefab, rowCount, columnCount, horizontalGap, verticalGap) end
ShibaInu = {}
ShibaInu.BaseList = m
return m