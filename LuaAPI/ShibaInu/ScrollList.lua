---@class ShibaInu.ScrollList : ShibaInu.BaseList
---@field luaTarget LuaInterface.LuaTable
---@field isVertical bool
---@field viewport UnityEngine.RectTransform
---@field scrollRect UnityEngine.UI.ScrollRect
local m = {}
---@param width uint
---@param height uint
function m:SetViewportSize(width, height) end
---@param width uint
---@param height uint
function m:SetContentSize(width, height) end
---@param itmePrefab UnityEngine.GameObject
---@param rowCount uint
---@param columnCount uint
---@param horizontalGap int
---@param verticalGap int
---@param isVertical bool
---@param viewportWidth uint
---@param viewportHeight uint
function m:SyncPropertys(itmePrefab, rowCount, columnCount, horizontalGap, verticalGap, isVertical, viewportWidth, viewportHeight) end
function m:ResetContentPosition() end
ShibaInu = {}
ShibaInu.ScrollList = m
return m