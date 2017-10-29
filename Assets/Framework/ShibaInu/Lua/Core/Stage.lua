--
-- 舞台（UI 和 场景管理）
-- 2017/10/16
-- Author LOLO
--

---@class Stage
---@field uiCanvas UnityEngine.Canvas @ UI最底层容器，UI's Canvas
local Stage = class("Stage")

local event = Event.New()
local ed = EventDispatcher.New()



function Stage:Ctor()
    self.uiCanvas = GameObject.Find("UICanvas")
    self._ed = ed
end


function Stage:ShowScene()
end



--- Update / LateUpdate / FixedUpdate 回调。由 StageLooper.cs 调用
--- 在全局变量 stage 上抛出 Event.UPDATE / Event.LATE_UPDATE  / Event.FIXED_UPDATE 事件
---@param type string
---@param time number
---@return void
function Stage._loopHandler(type, time)
    TimeUtil.time = time
    event.type = type
    ed:DispatchEvent(event, false, false)
end





return Stage