--
-- 动画相关事件
-- 2018/11/13
-- Author LOLO
--

---@class AnimationEvent : Event
---@field New fun():AnimationEvent
---
---@field target Animation
---@field currentTarget Animation
---@field aniName string @ 当前动画的名称
local AnimationEvent = class("AnimationEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 动画开始
AnimationEvent.ANI_START = "AnimationEvent_AnimationStart"

--- 动画播放完成
AnimationEvent.ANI_COMPLETE = "AnimationEvent_AnimationComplete"

--=----------------------------------------------------------------------=--



--
return AnimationEvent

