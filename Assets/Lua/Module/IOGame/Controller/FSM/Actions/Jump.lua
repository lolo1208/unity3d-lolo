--
-- 跳跃
-- 2018/2/7
-- Author LOLO
--

local IOGameData = require("Module.IOGame.Model.IOGameData")

---@class IOGame.FSM.Action.Jump
---@field New fun():IOGame.FSM.Action.Jump
---
---@field fsm IOGame.FSM.FSM
---@field index number
---@field startFrame number @ 开始帧号（逻辑帧）
---@field frameNum number @ 已经渲染帧数（渲染帧）
---
local Jump = class("IOGame.FSM.Action.Jump")

local FRAME_OFS_NUM = 18
local FRAME_NUM = 90 - FRAME_OFS_NUM * 2
local FRAME_NUM_HALF = FRAME_NUM / 2
local JUMP_Y = 0.8

function Jump:Ctor()
end

function Jump:GetInfo()
    return { index = self.index, startFrame = self.startFrame }
end


--


--- 进入状态
function Jump:Enter(initData)
    self.fsm.avatar.ani:Play("jump")

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
function Jump:Update()
    self.frameNum = self.frameNum + 1
    local num = self.frameNum - FRAME_OFS_NUM

    -- 结束
    if self.frameNum == FRAME_NUM + FRAME_OFS_NUM * 2 then
        self.fsm:Transition()
    else
        -- 起跳和降落
        if num < 1 or num > FRAME_NUM then
            return
        end

        local pos = self.fsm.avatar.position
        if num< FRAME_NUM_HALF then
            -- 上升
            pos.y = num / FRAME_NUM_HALF * JUMP_Y
        else
            -- 下落
            pos.y = (FRAME_NUM_HALF - (num - FRAME_NUM_HALF)) / FRAME_NUM_HALF * JUMP_Y
        end
        self.fsm.avatar.transform.localPosition = pos

        if self.fsm.avatar.isSelf then
            self.fsm.avatar.map:Focus()
        end
    end
end


--


--- 离开状态
function Jump:Exit()
    local avatar = self.fsm.avatar
    local pos = avatar.position
    pos.y = 0
    avatar.transform.localPosition = pos

    if avatar.state:CurrentIs(self.fsm.state_move) then
        avatar.ani:Play("run")
    else
        avatar.state:Transition(self.fsm.state_idle)
    end
end


--

return Jump