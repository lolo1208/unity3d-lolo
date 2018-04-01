--
-- 特效
-- 2018/2/27
-- Author LOLO
--

local require = require
local remove = table.remove


--

---@class IOGame.Effects.Effect
---@field New fun():IOGame.Effects.Effect
---
local Effect = {}

local runningList = {} ---@type table<number, IOGame.FSM.IEffect> @ 运行中的特效列表

--


--- 池列表
local _pool = {}

---@type table<string, IOGame.FSM.IState> @ 状态列表
local effects = {
    require("Module.IOGame.Controller.Effects.ShotFire"), -- 1
}
for i = 1, #effects do
    effects[i].index = i
end

Effect.shotFire = 1


--


--- Start & Get
---@param effectIndex number
---@param initData table
---@return IOGame.FSM.IEffect
function Effect.Start(effectIndex, initData)
    local EffectClass = effects[effectIndex]
    local pool = _pool[EffectClass.index]
    local effect ---@type IOGame.FSM.IEffect
    if pool ~= nil and #pool > 0 then
        effect = remove(pool)
    else
        EffectClass.Effect = Effect
        effect = EffectClass.New()
    end

    runningList[#runningList + 1] = effect
    effect:Start(initData)

    return effect
end

--

--- Stop & Recycle
---@param effect IOGame.FSM.IEffect
function Effect.Stop(effect)
    effect:Stop()
    local pool = _pool[effect.index]
    if pool == nil then
        pool = {}
        pool[effect.index] = pool
    end
    pool[#pool + 1] = effect

    for i = 1, #runningList do
        if runningList[i] == effect then
            remove(runningList, i)
            break
        end
    end
end

--

--- 正在运行的特效全部进入下一帧
function Effect.Update()
    for i = 1, #runningList do
        runningList[i]:Update()
    end
end


--


return Effect


--


---@class IOGame.FSM.IEffect
---@field Effect IOGame.Effects.Effect
---@field index number
---@field GetInfo fun():table
---@field Start fun(initData:table):void
---@field Update fun():void
---@field Stop fun():void