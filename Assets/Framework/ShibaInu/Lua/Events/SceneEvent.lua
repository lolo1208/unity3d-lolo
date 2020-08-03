--
-- 场景相关事件
-- 2017/11/13
-- Author LOLO
--

---@class SceneEvent : Event
---@field sceneName string @ 当前正在加载的场景名称
local SceneEvent = class("SceneEvent", Event)

function SceneEvent:Ctor(type, data)
    SceneEvent.super.Ctor(self, type, data)
end




--=------------------------------[ static ]------------------------------=--

-- 在异步加载场景（包括 SubScene）的过程中，可以调用 Stage.GetProgress() 获取加载进度

--- 异步开始加载场景。该事件只会在 Stage 上抛出
SceneEvent.LOAD_START = "SceneEvent_LoadStart"

--- 异步加载场景完成。该事件只会在 Stage 上抛出
SceneEvent.LOAD_COMPLETE = "SceneEvent_LoadComplete"

--- 异步开始加载 Sub 场景。该事件只会在 Stage 上抛出
SceneEvent.LOAD_SUB_START = "SceneEvent_LoadSubStart"

--- 异步加载 Sub 场景完成。该事件只会在 Stage 上抛出
SceneEvent.LOAD_SUB_COMPLETE = "SceneEvent_LoadSubComplete"

--- 场景有改变。该事件只会在 Stage 上抛出
SceneEvent.CHANGED = "SceneEvent_Changed"


--
local event = SceneEvent.New()

--- 抛出场景相关事件，由 Stage.cs 调用
---@param type string
---@param sceneName string
function SceneEvent.DispatchEvent(type, sceneName)
    event.data = nil
    event.target = nil
    event.isPropagationStopped = false

    event.type = type
    event.sceneName = sceneName
    trycall(DispatchEvent, nil, Stage, event, false, false)
end


--=----------------------------------------------------------------------=--



return SceneEvent
