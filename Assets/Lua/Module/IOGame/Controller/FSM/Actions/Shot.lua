--
-- 射击
-- 2018/2/7
-- Author LOLO
--

local IOGameData = require("Module.IOGame.Model.IOGameData")
local Effect = require("Module.IOGame.Controller.Effects.Effect")

local F_N_FIRE = 39 --- 多少帧后射出火焰

--


---@class IOGame.FSM.Action.Shot
---@field New fun():IOGame.FSM.Action.Shot
---
---@field fsm IOGame.FSM.FSM
---@field index number
---@field startFrame number @ 开始帧号（逻辑帧）
---@field frameNum number @ 已经渲染帧数（渲染帧）
---
local Shot = class("IOGame.FSM.Action.Shot")

function Shot:GetInfo()
    return { index = self.index, startFrame = self.startFrame }
end


--


--- 进入状态
function Shot:Enter(initData)
    local avatar = self.fsm.avatar
    avatar.canMove = false
    avatar.ani:Play("shot")

    local frame = IOGameData.frame
    if initData ~= nil then
        self.startFrame = initData.startFrame
        self.frameNum = (frame.curFrame - self.startFrame) * frame.frameRatio - 1
        self:Update()
    else
        self.startFrame = frame.curFrame
        self.frameNum = 0
    end
end


--


--- 更新状态（每渲染帧）
function Shot:Update()
    self.frameNum = self.frameNum + 1
    if self.frameNum == F_N_FIRE then
        -- 射出火焰
        local avatar = self.fsm.avatar
        Effect.Start(Effect.shotFire, { avatarID = avatar.id, angle = avatar.angle })

    elseif self.frameNum == IOGameData.F_N_SHOT then
        -- 动作结束
        self.fsm:Transition()
    end
end


--


--- 离开状态
function Shot:Exit()
    local avatar = self.fsm.avatar
    avatar.canMove = true
    if avatar.state:CurrentIs(self.fsm.state_move) then
        avatar.ani:Play("run")
    else
        avatar.state:Transition(self.fsm.state_fightIdle)
    end
end


--

return Shot