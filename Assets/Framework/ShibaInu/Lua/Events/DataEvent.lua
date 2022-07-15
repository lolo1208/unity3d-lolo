--
-- 数据相关事件
-- 2017/12/15
-- Author LOLO
--

---@class DataEvent : Event
---@field New fun():DataEvent
---
---@field reason number @ 数据改变的原因。[1:初始化，2:清空，3:修改所有数据，4:修改单项数据，5:添加一条数据，6:移除一条数据]
---@field index number @ 值在 MapList 中的索引
---@field oldValue any @ 原值
---@field newValue any @ 新值
local DataEvent = class("DataEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 数据已改变
DataEvent.DATA_CHANGED = "DataEvent_DataChanged"

--=----------------------------------------------------------------------=--



--
return DataEvent

