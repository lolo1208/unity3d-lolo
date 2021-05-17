--
-- 场景相关事件
-- 2017/11/13
-- Author LOLO
--

---@class SceneEvent : Event
---@field New fun():SceneEvent
---
---@field sceneName string @ 当前正在加载的场景名称
local SceneEvent = class("SceneEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 异步开始加载场景。该事件只会在 SceneManager 上抛出
SceneEvent.LOAD_START = "SceneEvent_LoadStart"

--- 异步加载场景完成。该事件只会在 SceneManager 上抛出
SceneEvent.LOAD_COMPLETE = "SceneEvent_LoadComplete"

--- 场景有改变。该事件只会在 SceneManager 上抛出
SceneEvent.CHANGED = "SceneEvent_Changed"


--
--- 抛出场景相关事件，由 SceneManager.cs 调用
---@param type string
---@param sceneName string
function SceneEvent.DispatchEvent(type, sceneName)
    ---@type SceneEvent
    local event = Event.Get(SceneEvent, type)
    event.sceneName = sceneName
    trycall(DispatchEvent, nil, SceneManager, event)
end

--=----------------------------------------------------------------------=--



--
return SceneEvent

