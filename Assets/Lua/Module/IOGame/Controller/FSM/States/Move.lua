--
-- 移动
-- 2018/2/2
-- Author LOLO
--

local DISTANCE = 0.035 -- 每帧移动距离


--


---@class IOGame.FSM.State.Move
---@field New fun():IOGame.FSM.State.Move
---
---@field fsm IOGame.FSM.FSM
---@field index number
---
local Move = class("IOGame.FSM.State.Move")

function Move:GetInfo()
    return { index = self.index }
end


--


--- 进入状态
function Move:Enter()
    local avatar = self.fsm.avatar
    if avatar.action.current ~= nil then
        return
    end

    avatar.ani:Play("run")
end


--


--- 更新状态（每渲染帧）
function Move:Update()
    local avatar = self.fsm.avatar
    if not avatar.canMove then
        return
    end

    Float3.OffsetByAngle(avatar.position, avatar.angle, DISTANCE)
    avatar.transform.localPosition = avatar.position

    if avatar.isSelf then
        avatar.map:Focus()
    end
end


--


--- 离开状态
function Move:Exit()

end


--


return Move