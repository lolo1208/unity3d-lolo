--
-- 场景相关事件
-- 2017/9/29
-- Author LOLO
--

---@class SceneEvent : Event
local SceneEvent = class("SceneEvent", Event)


function SceneEvent:Ctor(type, data)
    self.super:Ctor(type, data)
end


return SceneEvent