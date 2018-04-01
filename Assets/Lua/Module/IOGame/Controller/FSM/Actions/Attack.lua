--
-- 攻击
-- 2018/2/7
-- Author LOLO
--

local IOGameData = require("Module.IOGame.Model.IOGameData")

---@class IOGame.FSM.Action.Attack
---@field New fun():IOGame.FSM.Action.Attack
---
---@field fsm IOGame.FSM.FSM
---@field index number
---@field startFrame number @ 开始帧号（逻辑帧）
---@field frameNum number @ 已经渲染帧数（渲染帧）
---@field grade number @ 当前攻击阶段
---
local Attack = class("IOGame.FSM.Action.Attack")

function Attack:Ctor()
end

function Attack:GetInfo()
    return { index = self.index, startFrame = self.startFrame, grade = self.grade }
end


--


--- 进入状态
function Attack:Enter(initData)
    self.grade = initData.grade
    IOGameData.joystick.lockAngle = true

    local avatar = self.fsm.avatar
    avatar.canMove = false
    if initData.grade == 4 then
        avatar.ani:Play("punch")
    else
        avatar.ani:Play("attack" .. initData.grade)
    end

    local frame = IOGameData.frame
    if initData.startFrame ~= nil then
        self.startFrame = initData.startFrame
        self.frameNum = (frame.curFrame - self.startFrame) * frame.frameRatio
    else
        self.startFrame = frame.curFrame
        self.frameNum = 0
    end
end


--


--- 更新状态（每渲染帧）
function Attack:Update()
    self.frameNum = self.frameNum + 1
    if self.frameNum == IOGameData.F_N_ATTACK then
        self.fsm:Transition()
    end
end


--


--- 离开状态
function Attack:Exit()
    IOGameData.joystick.lockAngle = false

    local avatar = self.fsm.avatar
    avatar.canMove = true
    if avatar.state:CurrentIs(self.fsm.state_move) then
        avatar.ani:Play("run")
    else
        avatar.state:Transition(self.fsm.state_fightIdle)
    end
end


--

return Attack