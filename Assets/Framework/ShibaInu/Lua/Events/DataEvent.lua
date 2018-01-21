--
-- 数据相关事件
-- 2017/12/15
-- Author LOLO
--

---@class DataEvent : Event
---@field index number @ 值在 MapList 中的索引
---@field oldValue any @ 原值
---@field newValue any @ 新值
local DataEvent = class("DataEvent", Event)


function DataEvent:Ctor(type, data)
    DataEvent.super.Ctor(self, type, data)
end



--=------------------------------[ static ]------------------------------=--

---@type string @ 数据已改变
DataEvent.DATA_CHANGED = "DataEvent_dataChanged"


--=----------------------------------------------------------------------=--



return DataEvent