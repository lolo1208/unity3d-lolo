--
-- 贝塞尔飞行效果
-- 2018/8/10
-- Author LOLO
--


local remove = table.remove
local abs = math.abs
local atan2 = math.atan2
--- 角度换算值
local RAD2DEG = 180 / math.pi

---@type table<number, Effects.UI.FlyBezier> @ 缓存池
local _pool = {}

local tmpVec3 = Vector3.zero


--
---@class Effects.UI.FlyBezier
---@field New fun():Effects.UI.FlyBezier
---
---@field target UnityEngine.Transform @ 应用该效果的目标
---@field onComplete HandlerRef @ 飘动结束后的回调。调用该方法时，将会传递一个boolean类型的参数，表示效果是否正常结束。onComplete(complete:boolean, flyBezier:FlyBezier)
---@field running boolean @ 是否正在运行中
---@field once boolean @ 是否只播放一次，播放完毕后，将会自动回收到池中
---@field recycleKey string @ 播放结束后，target 回收到 PrefabPool 时使用的 prefabPath（默认值：nil 不回收）
---
---@field pStrat Vector3 @ 起始点
---@field pEnd Vector3 @ 结束点
---@field distance number @ 贝塞尔取点距离（值越大，曲线幅度越大）。默认：0.5
---
---@field duration number @ 飞行时长（秒，默认值：0）。值为 0 时，将会根据 飞行距离 和 durationFactor，动态计算飞行时长
---@field durationFactor number @ 动态时长的计算参数，值越大，数度越快。默认：800
---@field orientToBezier boolean @ 目标是否跟随贝塞尔曲线旋转
---
---@field protected _pCenter Vector3 @ 动态计算出的贝塞尔点
---@field protected _startTime number @ 开始时间
---@field protected _duration number @ 计算出来的持续时间（秒）
---
local FlyBezier = class("Effects.UI.FlyBezier")


--
--- Ctor
function FlyBezier:Ctor()
    self.running = false
    self:Initialize()
end


--
function FlyBezier:Initialize()
    self.pStrat = nil
    self.pEnd = nil

    self.distance = 0.5
    self.duration = 0
    self.durationFactor = 800
    self.orientToBezier = 0.5
end


--
--- 开始播放效果
function FlyBezier:Start()
    if self.target == nil or self.pEnd == nil then
        return
    end
    self.running = true

    if self.pStrat == nil then
        self.pStrat = self.target.localPosition
    end
    self._pCenter = Vector3.Lerp(self.pStrat, self.pEnd, 0.5)
    self._pCenter.y = self._pCenter.y + abs(self._pCenter.x - self.pStrat.x) * self.distance;
    self._duration = self.duration
    if self._duration <= 0 then
        self._duration = Vector3.Distance(self.pStrat, self.pEnd) / self.durationFactor
    end

    self._startTime = TimeUtil.time
    AddEventListener(Stage, Event.LATE_UPDATE, self.Stage_LateUpdate, self)
end


--
function FlyBezier:Stage_LateUpdate(event)
    local p = (TimeUtil.time - self._startTime) / self._duration
    if p > 1 then
        p = 1
    end

    local target = self.target
    local pos = target.localPosition
    local nx = (1 - p) * (1 - p) * self.pStrat.x + 2 * p * (1 - p) * self._pCenter.x + p * p * self.pEnd.x
    local ny = (1 - p) * (1 - p) * self.pStrat.y + 2 * p * (1 - p) * self._pCenter.y + p * p * self.pEnd.y

    if self.orientToBezier then
        local ox = pos.x
        local oy = pos.y
        tmpVec3.z = atan2(ny - oy, nx - ox) * RAD2DEG
        target.localEulerAngles = tmpVec3
    end

    pos.x = nx
    pos.y = ny
    target.localPosition = pos

    if p == 1 then
        self:Finish()
    end
end


--
--- 播放效果完成
function FlyBezier:Finish()
    self:End(true)
end


--
--- 结束播放效果
---@param complete boolean @ -可选- 效果是否正常结束。默认：false
function FlyBezier:End(complete)
    RemoveEventListener(Stage, Event.LATE_UPDATE, self.Stage_LateUpdate, self)
    self.running = false

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
--- 创建，或从池中获取一个 FlyBezier 实例。
--- !!!
--- 注意：使用 FlyBezier.Once() 创建的实例 once 属性默认为 true。
--- 播放完毕后，实例(_pool) 和 target(PrefabPool) 将会自动回收到池中。
--- !!!
---@param target UnityEngine.Transform @ -可选- 应用该效果的目标
---@param pStrat Vector3 @ -可选- 起始点。默认值：nil，表示使用 target 当前位置
---@param pEnd Vector3 @ -可选- 结束点
---@param recycleKey string @ -可选- 播放结束后，target 回收到 PrefabPool 时使用的 prefabPath（默认值：nil 不回收）
---@param onComplete HandlerRef @ -可选- 飘动结束后的回调。onComplete(complete:boolean, float:IFloat)
---@param start boolean @ -可选- 是否立即开始播放。默认：true
---@param orientToBezier boolean @ 目标是否跟随贝塞尔曲线旋转。默认：true
function FlyBezier.Once(target, pStrat, pEnd, recycleKey, onComplete, start, orientToBezier)
    local count = #_pool
    local flyBezier = count > 0 and remove(_pool) or FlyBezier.New()
    flyBezier.once = true
    flyBezier.target = target
    flyBezier.pStrat = pStrat
    flyBezier.pEnd = pEnd
    flyBezier.recycleKey = recycleKey
    flyBezier.onComplete = onComplete
    flyBezier.orientToBezier = orientToBezier ~= false
    if start ~= false then
        flyBezier:Start()
    end
    return flyBezier
end




--
return FlyBezier