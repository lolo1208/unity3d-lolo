--
-- 向上飘动效果
--  * step1: 从 alpha=0 到 alpha=1 ，并向下飘动目标
--  * step2: 向上飘动目标
--  * step3: 停留指定时间后，再向上飘动目标，并将 alpha 设置为 0
--  * step4: 飘动结束后，将目标从父容器中移除，并将 alpha 设置为 1
-- 2018/8/4
-- Author LOLO
--


local remove = table.remove

---@type table<number, Effects.UI.FlyUp> @ 缓存池
local _pool = {}

local tmpVec3 = Vector3.zero


--
---@class Effects.UI.FlyUp
---@field New fun():Effects.UI.FlyUp
---
---@field target UnityEngine.Transform @ 应用该效果的目标
---@field onComplete HandlerRef @ 飘动结束后的回调。调用该方法时，将会传递一个boolean类型的参数，表示效果是否正常结束。onComplete(complete:boolean, flyUp:FlyUp)
---@field running boolean @ 是否正在运行中
---@field once boolean @ 是否只播放一次，播放完毕后，将会自动回收到池中
---@field recycleKey string @ 播放结束后，target 回收到 PrefabPool 时使用的 prefabPath（默认值：nil 不回收）
---
---@field targetCG UnityEngine.CanvasGroup @ target 上挂着的 CanvasGroup 组件
---@field tweener DG.Tweening.Tweener
---
---@field step1_duration number @ step1 的持续时长（秒）
---@field step1_y number @ step1 的飘动距离（Y）
---
---@field step2_duration number @ step2 的持续时长（秒）
---@field step2_y number @ step2 的飘动距离（Y）
---
---@field step3_delay number @ step3 的停留时长（秒）
---@field step3_duration number @ step3 的持续时长（秒）
---@field step3_y number @ step3 的飘动距离（Y）
---
local FlyUp = class("Effects.UI.FlyUp")


--
--- Ctor
function FlyUp:Ctor()
    self.running = false
    self:Initialize()
end


--
function FlyUp:Initialize()
    self.step1_duration = 0.1
    self.step1_y = -10

    self.step2_duration = 0.05
    self.step2_y = -5

    self.step3_delay = 0.3
    self.step3_duration = 0.65
    self.step3_y = 30
end


--
--- 开始播放效果
function FlyUp:Start()
    if self.target == nil then
        return
    end

    self.running = true
    if self.tweener ~= nil then
        self.tweener:Kill(false)
    end

    local target = self.target
    local p = target.localPosition
    local tx = p.x
    local ty = p.y

    local y1 = ty + self.step1_y
    local y2 = ty + self.step2_y
    local y3 = ty + self.step3_y

    self.targetCG = GetComponent.CanvasGroup(target)
    local hasCanvasGroup = self.targetCG ~= nil
    if hasCanvasGroup then
        self.targetCG.alpha = 0
    end

    local tweener = DOTween.Sequence()
    tmpVec3.x = tx
    tmpVec3.y = y1
    tweener:Append(target:DOLocalMove(tmpVec3, self.step1_duration))
    if hasCanvasGroup then
        tweener:Join(self.targetCG:DOFade(1, self.step1_duration))
    end

    tmpVec3.y = y2
    tweener:Append(target:DOLocalMove(tmpVec3, self.step2_duration))

    tweener:AppendInterval(self.step3_delay)

    tmpVec3.y = y3
    tweener:Append(target:DOLocalMove(tmpVec3, self.step3_duration))
    if hasCanvasGroup then
        tweener:Join(self.targetCG:DOFade(0, self.step3_duration))
    end

    tweener:AppendCallback(function()
        self:Finish()
    end)
    self.tweener = tweener
end


--
--- 播放效果完成
function FlyUp:Finish()
    self.tweener = nil
    if self.targetCG ~= nil then
        self.targetCG.alpha = 1
    end
    self:End(true)
end


--
--- 结束播放效果
---@param complete boolean @ -可选- 效果是否正常结束。默认：false
function FlyUp:End(complete)
    self.running = false
    if self.tweener ~= nil then
        self.tweener:Kill(false)
    end

    if self.once then
        if self.recycleKey ~= nil then
            PrefabPool.Recycle(self.target.gameObject, self.recycleKey)
        end
        self:Initialize()
        _pool[#_pool + 1] = self
    end

    local handler = self.onComplete
    self.onComplete = nil
    if handler ~= nil then
        CallHandler(handler, complete == true, self)
    end
    self.target = nil
end




-- [ static ]
--- 创建，或从池中获取一个 FlyUp 实例。
--- !!!
--- 注意：使用 FlyUp.Once() 创建的实例 once 属性默认为 true。
--- 播放完毕后，实例(_pool) 和 target(PrefabPool) 将会自动回收到池中。
--- !!!
---@param target UnityEngine.Transform @ -可选- 应用该效果的目标
---@param recycleKey string @ -可选- 播放结束后，target 回收到 PrefabPool 时使用的 prefabPath（默认值：nil 不回收）
---@param onComplete HandlerRef @ -可选- 飘动结束后的回调。onComplete(complete:boolean, float:IFloat)
---@param start boolean @ -可选- 是否立即开始播放。默认：true
function FlyUp.Once(target, recycleKey, onComplete, start)
    local count = #_pool
    local flyUp = count > 0 and remove(_pool) or FlyUp.New()
    flyUp.once = true
    flyUp.target = target
    flyUp.recycleKey = recycleKey
    flyUp.onComplete = onComplete
    if start ~= false then
        flyUp:Start()
    end
    return flyUp
end




--
return FlyUp