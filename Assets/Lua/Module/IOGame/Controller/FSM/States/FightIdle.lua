--
-- 战斗状态待机
-- 2018/2/2
-- Author LOLO
--


---@class IOGame.FSM.State.FightIdle
---@field New fun():IOGame.FSM.State.FightIdle
---
---@field index number
---@field fsm IOGame.FSM.FSM
---
---@field protected _frameCount number @ 剩余待机帧数
---@field protected _aniState UnityEngine.AnimationState
---@field protected _handler Handler
---
local FightIdle = class("IOGame.FSM.State.FightIdle")

function FightIdle:Ctor()
end

function FightIdle:GetInfo()
    return { index = self.index }
end


--


--- 进入状态
function FightIdle:Enter()
    local avatar = self.fsm.avatar
    if avatar.action.current == nil then
        local ani = avatar.ani
        ani:Play("fight idle")
        self._aniState = ani:get_Item("idle to fight idle")
        self._frameCount = 120
    end
end


--


--- 更新状态（每渲染帧）
function FightIdle:Update()
    if self.fsm.avatar.action.current ~= nil then
        return
    end

    -- 切换到 idle 状态
    self._frameCount = self._frameCount - 1
    if self._frameCount == 0 then
        local fsm = self.fsm
        fsm.avatar.ani:Play("idle to fight idle")
        self._aniState.speed = -1
        self._aniState.time = self._aniState.length
        self._handler = DelayedCall(0.85, function()
            fsm:Transition(fsm.state_idle)
        end)
    end
end


--


--- 离开状态
function FightIdle:Exit()
    if self._handler ~= nil then
        self._handler:Clean()
        self._handler = nil

        self._aniState.speed = 1
        self._aniState.time = 0
    end
end


--


return FightIdle