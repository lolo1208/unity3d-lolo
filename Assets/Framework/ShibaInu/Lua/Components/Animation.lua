--
-- 动画控制器
-- 2018/11/13
-- Author LOLO
--

local floor = math.floor


--
---@class Animation : EventDispatcher
---@field New fun(animator:UnityEngine.Animator, defaultAniName:string):Animation
---
---@field animator UnityEngine.Animator
---@field aniName string @ 当前动画名称（状态机名称）
---@field speed number @ 当前动画播放速度。默认：1
---@field isDispatchEvent boolean @ 是否抛出动画播放事件。默认：false
---@field protected handlerRef HandlerRef
---
local Animation = class("Animation", EventDispatcher)


--
function Animation:Ctor(animator, defaultAniName)
    Animation.super.Ctor(self)

    self.speed = 1
    self.isDispatchEvent = false
    self.animator = animator
    if defaultAniName ~= nil then
        self:Play(defaultAniName)
    end
end



--
local function DispatchAnimationEvent(ani, type)
    ---@type AnimationEvent
    local event = Event.Get(AnimationEvent, type)
    event.aniName = ani.aniName
    ani:DispatchEvent(event)
end



--
--- 播放指定动画
---@param aniName string @ 动画名称（状态机名称）
---@param restart boolean @ 如果正在播放该动画，是否需要重新开始播放。默认：true
function Animation:Play(aniName, restart)
    if restart == nil then
        restart = true
    end
    if not restart and aniName == self.aniName then
        return
    end

    self.aniName = aniName
    self.animator:Play(aniName)
    self.animator:Update(0) -- 手动调用一次才能拿到 Current State Info

    local length = self.animator:GetCurrentAnimatorStateInfo(0).length
    if length == 0 then
        return -- 可能 self.animator.gameObject.activeSelf = false
    end
    self:SetAniEndDelayedCall(length / self.speed)

    if self.isDispatchEvent then
        DispatchAnimationEvent(self, AnimationEvent.ANI_START)
    end
end


--
--- 动态融合切换至指定动画
---@param aniName string @ 动画名称（状态机名称）
---@param duration number @ 融合时间。默认：0.15（秒）
function Animation:TransitionTo(aniName, duration)
    self.aniName = aniName
    self.animator:CrossFadeInFixedTime(aniName, duration or 0.15)
    self.animator:Update(0) -- 手动调用一次才能拿到 Next State Info

    local length = self.animator:GetNextAnimatorStateInfo(0).length
    if length == 0 then
        return -- 可能 self.animator.gameObject.activeSelf = false
    end
    self:SetAniEndDelayedCall(length / self.speed)

    if self.isDispatchEvent then
        DispatchAnimationEvent(self, AnimationEvent.ANI_START)
    end
end


--
--- 当前动画播放完成
function Animation:AniCompleteHandler()
    CancelDelayedCall(self.handlerRef)

    if isnull(self.animator) then
        return
    end

    -- 动画状态机在当前动画播放完毕时，切换到了别的动画
    -- 只有循环播放的动画，self.aniName 才会继续保留
    if not self:IsAniName(self.aniName) then
        self.aniName = nil
    end

    if self.isDispatchEvent then
        DispatchAnimationEvent(self, AnimationEvent.ANI_COMPLETE)
    end
end


--
--- 设置在指定时长（动画播放完成时），触发回调
---@param delay number
function Animation:SetAniEndDelayedCall(delay)
    CancelDelayedCall(self.handlerRef)
    self.handlerRef = DelayedCall(delay, self.AniCompleteHandler, self)
end


--
--- 状态机当前是否正在播放 aniName
---@param aniName string
---@return boolean
function Animation:IsAniName(aniName)
    return self.animator:GetCurrentAnimatorStateInfo(0):IsName(aniName)
end


--
--- 当前动画名称是否为 aniName 或 nil（画播放完毕时，切换到了别的动画）
--- 该函数比 IsAniName() 函数效率更高，但精准稍逊
---@param aniName string
---@return boolean
function Animation:IsAniNameOrNil(aniName)
    return self.aniName == aniName or self.aniName == nil
end


--
--- 设置动画播放速度
---@param value number
function Animation:SetSpeed(value)
    if value ~= self.speed then
        self.speed = value
        self.animator.speed = value
        if self.isDispatchEvent then
            self:SetAniEndDelayedCall(self:GetRemainTime() / value)
        end
    end
end


--
--- 获取当前动画距离播放完成还剩多少时间。单位：秒
---@return number
function Animation:GetRemainTime()
    local info = self.animator:GetCurrentAnimatorStateInfo(0)
    local p = info.normalizedTime
    p = p - floor(p) -- 已耗时百分比
    p = 1 - p -- 剩余时间百分比
    return p * info.length / self.speed -- 剩余时间
end




--
return Animation
