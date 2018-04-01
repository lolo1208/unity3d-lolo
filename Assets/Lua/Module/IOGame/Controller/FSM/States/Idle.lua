--
-- 待机
-- 2018/2/2
-- Author LOLO
--

---@class IOGame.FSM.State.Idle
---@field New fun():IOGame.FSM.State.Idle
---
---@field fsm IOGame.FSM.FSM
---@field index number
---
local Idle = class("IOGame.FSM.State.Idle")

function Idle:Ctor()
end

function Idle:GetInfo()
    return { index = self.index }
end


--


--- 进入状态
function Idle:Enter()
    if self.fsm.avatar.action.current ~= nil then
        return
    end

    self.fsm.avatar.ani:Play("idle")
end


--


--- 更新状态（每渲染帧）
function Idle:Update()

end


--


--- 离开状态
function Idle:Exit()

end


--


return Idle