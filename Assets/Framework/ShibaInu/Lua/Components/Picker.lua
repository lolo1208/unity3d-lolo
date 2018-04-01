--
-- 选择器列表
-- 2018/3/30
-- Author LOLO
--

local error = error
local format = string.format

---@class Picker : View
---@field New fun(go:UnityEngine.GameObject, itemClass:any):Picker
---
---@field protected _picker ShibaInu.Picker
---@field protected _data MapList
---@field protected _itemClass any
---
local Picker = class("Picker", View)
--

--- 构造函数
---@param go UnityEngine.GameObject
---@param itemClass any
function Picker:Ctor(go, itemClass)
    Picker.super.Ctor(self)

    self._itemClass = itemClass
    self.gameObject = go
    self:OnInitialize()

    local picker = GetComponent.BaseList(go)
    if picker == nil then
        error(format(Constants.E2007, self.__classname, go.name))
    end
    picker.luaTarget = self
    self._picker = picker

end



--

return Picker