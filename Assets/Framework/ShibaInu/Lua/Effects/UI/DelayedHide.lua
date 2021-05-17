--
-- 原地停留一段时间后隐藏
--  * step1: 渐显，alpha 从 0 至 1
--  * step2: 停留指定时间后，渐隐
--  * step3: 渐隐后，将目标从父容器中移除，并将 alpha 设置为 1
-- 2018/8/13
-- Author LOLO
--


local remove = table.remove

---@type table<number, Effects.UI.DelayedHide> @ 缓存池
local _pool = {}


--
---@class Effects.UI.DelayedHide
---@field New fun():Effects.UI.DelayedHide
---
---@field target UnityEngine.Transform @ 应用该效果的目标
---@field onComplete HandlerRef @ 飘动结束后的回调。调用该方法时，将会传递一个boolean类型的参数，表示效果是否正常结束。onComplete(complete:boolean, delayedHide:DelayedHide)
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
---@field step2_delay number @ step2 的停留时长（秒）
---@field step2_duration number @ step2 的持续时长（秒）
---
local DelayedHide = class("Effects.UI.DelayedHide")


--
--- Ctor
function DelayedHide:Ctor()
    self.running = false
    self:Initialize()
end


--
function DelayedHide:Initialize()
    self.step1_duration = 0.2
    self.step2_delay = 0.5
    self.step2_duration = 0.5
end


--
--- 开始播放效果
function DelayedHide:Start()
    if self.target == nil then
        return
    end
    self.running = true
    if self.tweener ~= nil then
        self.tweener:Kill(false)
    end

    local target = self.target
    self.targetCG = GetComponent.CanvasGroup(target)
    self.targetCG.alpha = 0

    local tweener = DOTween.Sequence()
    tweener:Append(self.targetCG:DOFade(1, self.step1_duration))

    tweener:AppendInterval(self.step2_delay)

    tweener:Append(self.targetCG:DOFade(0, self.step2_duration))

    tweener:AppendCallback(function()
        self:Finish()
    end)
    self.tweener = tweener
end


--
--- 播放效果完成
function DelayedHide:Finish()
    self.tweener = nil
    self.targetCG.alpha = 1
    self:End(true)
end


--
--- 结束播放效果
---@param complete boolean @ -可选- 效果是否正常结束。默认：false
function DelayedHide:End(complete)
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
--- 创建，或从池中获取一个 DelayedHide 实例。
--- !!!
--- 注意：使用 DelayedHide.Once() 创建的实例 once 属性默认为 true。
--- 播放完毕后，实例(_pool) 和 target(PrefabPool) 将会自动回收到池中。
--- !!!
---@param target UnityEngine.Transform @ -可选- 应用该效果的目标
---@param recycleKey string @ -可选- 播放结束后，target 回收到 PrefabPool 时使用的 prefabPath（默认值：nil 不回收）
---@param onComplete HandlerRef @ -可选- 飘动结束后的回调。onComplete(complete:boolean, float:IFloat)
---@param start boolean @ -可选- 是否立即开始播放。默认：true
function DelayedHide.Once(target, recycleKey, onComplete, start)
    local count = #_pool
    local delayedHide = count > 0 and remove(_pool) or DelayedHide.New()
    delayedHide.once = true
    delayedHide.target = target
    delayedHide.recycleKey = recycleKey
    delayedHide.onComplete = onComplete
    if start ~= false then
        delayedHide:Start()
    end
    return delayedHide
end




--
return DelayedHide