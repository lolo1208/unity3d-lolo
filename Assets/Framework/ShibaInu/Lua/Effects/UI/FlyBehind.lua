--
-- 向背后飘动效果
--  * step1: 向背后飘动目标，并且 alpha 从 0 至 1（duration 为持续时间的一半）
--  * step2: 向背后再飘动一段距离，并将 alpha 设置为 0
--  * step3: 飘动结束后，将目标从父容器中移除，并将 alpha 设置为 1
-- 2018/8/11
-- Author LOLO
--

local remove = table.remove
local abs = math.abs
local min = math.min

---@type table<number, Effects.UI.FlyBehind> @ 缓存池
local _pool = {}

local tmpVec3 = Vector3.zero



--
---@class Effects.UI.FlyBehind
---@field New fun():Effects.UI.FlyBehind
---
---@field target UnityEngine.Transform @ 应用该效果的目标
---@field onComplete HandlerRef @ 飘动结束后的回调。调用该方法时，将会传递一个boolean类型的参数，表示效果是否正常结束。onComplete(complete:boolean, flyBehind:FlyBehind)
---@field running boolean @ 是否正在运行中
---@field once boolean @ 是否只播放一次，播放完毕后，将会自动回收到池中
---@field recycleKey string @ 播放结束后，target 回收到 PrefabPool 时使用的 prefabPath（默认值：nil 不回收）
---
---@field targetCG UnityEngine.CanvasGroup @ target 上挂着的 CanvasGroup 组件
---@field tweener DG.Tweening.Tweener
---
---@field actionPoint Vector3 @ 作用点（正面的位置）
---
---@field step1_duration number @ step1 的持续时长（秒）
---@field step1_distance number @ step1 的飘动距离
---
---@field step2_delay number @ step2 的延迟时长（秒）
---@field step2_duration number @ step2 的持续时长（秒）
---@field step2_distance number @ step2 的飘动距离
---
local FlyBehind = class("Effects.UI.FlyBehind")


--
--- Ctor
function FlyBehind:Ctor()
    self.running = false
    self:Initialize()
end


--
function FlyBehind:Initialize()
    self.actionPoint = nil

    self.step1_duration = 0.2
    self.step1_distance = 40

    self.step2_delay = 0.3
    self.step2_duration = 0.4
    self.step2_distance = 20
end


--
--- 开始播放效果
function FlyBehind:Start()
    if self.target == nil or self.actionPoint == nil then
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

    -- 得出偏移位置
    tmpVec3:Set(tx - self.actionPoint.x, ty - self.actionPoint.y, 0)
    local op = tmpVec3

    -- 取较小的偏移倍数
    local mx = abs(1 / op.x)
    local my = abs(1 / op.y)
    local m = min(mx, my)

    -- 得出距离偏移值
    op.x = op.x * m
    op.y = op.y * m

    local hd = self.step1_distance / 2
    local hx = op.x * hd
    local hy = op.y * hd
    local d1_h = self.step1_duration / 2

    local x1 = tx + hx
    local y1 = ty + hy

    local x2 = x1 + hx
    local y2 = y1 + hy

    local x3 = x2 + op.x * self.step2_distance
    local y3 = y2 + op.y * self.step2_distance

    self.targetCG = GetComponent.CanvasGroup(target)
    local hasCanvasGroup = self.targetCG ~= nil
    if hasCanvasGroup then
        self.targetCG.alpha = 0
    end

    local tweener = DOTween.Sequence()
    tmpVec3:Set(x1, y1, 0)
    tweener:Append(target:DOLocalMove(tmpVec3, d1_h))
    if hasCanvasGroup then
        tweener:Join(self.targetCG:DOFade(1, d1_h))
    end

    tmpVec3:Set(x2, y2, 0)
    tweener:Append(target:DOLocalMove(tmpVec3, d1_h))

    tweener:AppendInterval(self.step2_delay)

    tmpVec3:Set(x3, y3, 0)
    tweener:Append(target:DOLocalMove(tmpVec3, self.step2_duration))
    if hasCanvasGroup then
        tweener:Join(self.targetCG:DOFade(0, self.step2_duration))
    end

    tweener:AppendCallback(function()
        self:Finish()
    end)
    self.tweener = tweener
end


--
--- 播放效果完成
function FlyBehind:Finish()
    self.tweener = nil
    if self.targetCG ~= nil then
        self.targetCG.alpha = 1
    end
    self:End(true)
end


--
--- 结束播放效果
---@param complete boolean @ -可选- 效果是否正常结束。默认：false
function FlyBehind:End(complete)
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
--- 创建，或从池中获取一个 FlyBehind 实例。
--- !!!
--- 注意：使用 FlyBehind.Once() 创建的实例 once 属性默认为 true。
--- 播放完毕后，实例(_pool) 和 target(PrefabPool) 将会自动回收到池中。
--- !!!
---@param target UnityEngine.Transform @ -可选- 应用该效果的目标
---@param actionPoint Vector3 @ -可选- 作用点（正面的位置）
---@param recycleKey string @ -可选- 播放结束后，target 回收到 PrefabPool 时使用的 prefabPath（默认值：nil 不回收）
---@param onComplete HandlerRef @ -可选- 飘动结束后的回调。onComplete(complete:boolean, float:IFloat)
---@param start boolean @ -可选- 是否立即开始播放。默认：true
function FlyBehind.Once(target, actionPoint, recycleKey, onComplete, start)
    local count = #_pool
    local flyBehind = count > 0 and remove(_pool) or FlyBehind.New()
    flyBehind.once = true
    flyBehind.target = target
    flyBehind.actionPoint = actionPoint
    flyBehind.recycleKey = recycleKey
    flyBehind.onComplete = onComplete
    if start ~= false then
        flyBehind:Start()
    end
    return flyBehind
end




--
return FlyBehind