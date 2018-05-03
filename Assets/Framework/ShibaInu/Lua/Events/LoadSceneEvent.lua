--
-- 场景加载相关事件
-- 2017/11/13
-- Author LOLO
--

---@class LoadSceneEvent : Event
---@field sceneName string @ 当前正在加载的场景名称
local LoadSceneEvent = class("LoadSceneEvent", Event)

function LoadSceneEvent:Ctor(type, data)
    LoadSceneEvent.super.Ctor(self, type, data)
end




--=------------------------------[ static ]------------------------------=--

--- 异步开始加载场景。该事件只会在 Stage(ShibaInu.Stage) 上抛出
LoadSceneEvent.START = "LoadSceneEvent_Start"

--- 异步加载场景完成。该事件只会在 Stage(ShibaInu.Stage) 上抛出
LoadSceneEvent.COMPLETE = "LoadSceneEvent_Complete"


--
local event = LoadSceneEvent.New()

--- 抛出加载相关事件，由 Stage.cs 调用
---@param type string
---@param sceneName string
function LoadSceneEvent.DispatchEvent(type, sceneName)
    event.data = nil
    event.target = nil
    event.isPropagationStopped = false

    event.type = type
    event.sceneName = sceneName
    trycall(DispatchEvent, nil, Stage, event, false, false)
end


--=----------------------------------------------------------------------=--



return LoadSceneEvent