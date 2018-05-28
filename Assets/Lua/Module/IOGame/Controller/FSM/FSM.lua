--
-- 有限状态机
-- 2018/2/2
-- Author LOLO
--

local require = require
local remove = table.remove

--

---@class IOGame.FSM.FSM
---@field New fun(avatar:IOGame.Avatar, stateIndex:number, initData:table):IOGame.FSM.FSM
---
---@field avatar IOGame.Avatar
---@field current IOGame.FSM.IState
---
local FSM = class("IOGame.FSM.FSM")


--


--- 池列表
local _pool = {}

---@type table<string, IOGame.FSM.IState> @ 状态列表
local states = {
    require("Module.IOGame.Controller.FSM.States.Idle"), -- 1
    require("Module.IOGame.Controller.FSM.States.FightIdle"), -- 2
    require("Module.IOGame.Controller.FSM.States.Move"), -- 3

    require("Module.IOGame.Controller.FSM.Actions.Jump"), -- 4
    require("Module.IOGame.Controller.FSM.Actions.Attack"), -- 5
    require("Module.IOGame.Controller.FSM.Actions.Shot"), -- 6
}
for i = 1, #states do
    states[i].index = i
end

FSM.state_idle = 1
FSM.state_fightIdle = 2
FSM.state_move = 3

FSM.action_jump = 4
FSM.action_attack = 5
FSM.action_shot = 6


--


function FSM:Ctor(avatar, stateIndex, initData)
    self.avatar = avatar
    if stateIndex ~= nil then
        self:Transition(stateIndex, initData)
    end
end

--

--- 切换状态
---@param stateIndex number
---@param initData table
function FSM:Transition(stateIndex, initData)
    -- 退出并回收当前状态
    local state = self.current
    self.current = nil
    if state ~= nil then
        state:Exit()
        local pool = _pool[state.index]
        if pool == nil then
            pool = {}
            _pool[state.index] = pool
        end
        pool[#pool + 1] = state
    end

    -- 进入新状态
    if stateIndex ~= nil then
        local StateClass = states[stateIndex]
        local pool = _pool[StateClass.index]
        if pool ~= nil and #pool > 0 then
            state = remove(pool)
        else
            state = StateClass.New()
        end
        self.current = state
        state.fsm = self
        state:Enter(initData)
    end
end

--- 当前状态是否为 index
---@param index number
function FSM:CurrentIs(index)
    if self.current == nil then
        return false
    end
    return self.current.index == index
end


--

return FSM


--


---@class IOGame.FSM.IState
---@field index number
---@field fsm IOGame.FSM.FSM
---@field GetInfo fun():table
---@field Enter fun(initData:table):void
---@field Update fun():void
---@field Exit fun():void