--
-- 逻辑帧控制器
-- 2018/2/1
-- Author LOLO
--

local pairs = pairs
local tonumber = tonumber
local remove = table.remove

local FSM = require("Module.IOGame.Controller.FSM.FSM")
local commands = require("Module.IOGame.Controller.commands")
local IOGameData = require("Module.IOGame.Model.IOGameData") ---@type IOGame.IOGameData
local Effect = require("Module.IOGame.Controller.Effects.Effect")

---@class IOGame.FrameController
---@field New fun(map:IOGame.Map):IOGame.FrameController
---
---@field frameRatio number @ 逻辑帧跑一帧，渲染帧跑几帧
---@field curFrame number @ 当前帧编号
---
---@field protected _map IOGame.Map
---@field protected _running boolean @ 是否正在运行中
---@field protected _undoneFrames table @ 还未执行的帧数据列表
---@field protected _frameCount number @ 当前渲染帧已跑帧数
---
local FrameController = class("IOGame.FrameController")

function FrameController:Ctor(map)
    self._map = map

    self.frameRatio = 3
    self.curFrame = 0
    self._running = false
    self._frameCount = 0
    self._undoneFrames = {}
end


--


--- 添加一帧数据
---@param data table
function FrameController:AppendFrameData(data)
    self._undoneFrames[#self._undoneFrames + 1] = data
    if not self._running then
        self._running = true
        AddEventListener(Stage, Event.UPDATE, self.RenderNextFrame, self)
        self:LogicNextFrame()
    end
end

--

--- 逻辑帧进入下一帧
function FrameController:LogicNextFrame()
    --print(#self._undoneFrames)
    if #self._undoneFrames == 0 then
        self._running = false
        RemoveEventListener(Stage, Event.UPDATE, self.RenderNextFrame, self)
        if self.curFrame == commands.reportFrameNum then
            commands.doReportMapInfo()
        end
        return
    end

    local data = remove(self._undoneFrames, 1)
    local avatars = self._map.avatars
    self.curFrame = data.num

    -- 创建新角色
    local newAvatars = data.avatars
    if newAvatars ~= nil then
        for i = 1, #newAvatars do
            self._map:CreateAvatar(newAvatars[i])
        end
    end

    -- 角色角度有变化
    local angles = data.angles
    if angles ~= nil then
        for id, angle in pairs(angles) do
            id = tonumber(id)
            avatars[id]:SetAngle(angle)
        end
    end

    -- 移动状态有变化
    local moves = data.moves
    if moves ~= nil then
        for id, moveing in pairs(moves) do
            id = tonumber(id)
            avatars[id].state:Transition(moveing and FSM.state_move or FSM.state_fightIdle)
        end
    end

    -- 跳跃动作
    local jumps = data.jumps
    if jumps ~= nil then
        for id, val in pairs(jumps) do
            id = tonumber(id)
            avatars[id].action:Transition(FSM.action_jump)
        end
    end

    -- 攻击动作
    local attacks = data.attacks
    if attacks ~= nil then
        for id, grade in pairs(attacks) do
            id = tonumber(id)
            avatars[id].action:Transition(FSM.action_attack, { grade = grade })
        end
    end

    -- 射击动作
    local shots = data.shots
    if shots ~= nil then
        for id, val in pairs(shots) do
            id = tonumber(id)
            avatars[id].action:Transition(FSM.action_shot)
        end
    end

    self:RenderNextFrame()
end

--

--- 视图帧进入下一帧
---@param event Event
function FrameController:RenderNextFrame(event)
    self._frameCount = self._frameCount + 1
    if self._frameCount > self.frameRatio then
        self._frameCount = 0
        self:LogicNextFrame()
        return
    end

    self._map:NextFrame()
    IOGameData.btnBar:NextFrame()
    Effect.Update()

    -- 丢帧时加速
    if event ~= nil then
        for i = 1, #self._undoneFrames do
            self:RenderNextFrame()
        end
    end
end



--


return FrameController