--
-- 使用 GpuAnimationWindow 从 fbx 文件中提取（合并）mesh，生成动画对应的纹理
-- 使用 shader "ShibaInu/Component/FrameAnimation"
--     或 "ShibaInu/Component/FrameAnimationTex2"
--     依靠 C#ShibaInu.FrameAnimationController 播放 GPU 动画
-- 2019/07/02
-- Author LOLO
--


--
---@class FrameAnimation : EventDispatcher
---@field New fun(go:UnityEngine.GameObject, fac:ShibaInu.FrameAnimationController, assetDirPath:string, useMainTex:boolean):FrameAnimation
---
---@field go UnityEngine.GameObject @ 对应的 GameObject
---@field fac ShibaInu.FrameAnimationController @ 对应的 FrameAnimationController
---@field id number @ 在 fac 中的 ID
---@field assetDirPath string @ 动画资源所在目录路径（GpuAnimationWindow 中设置的 导出目录）
---@field aniName string @ 当前动画名称
---@field frameCount number @ 当前动画总帧数
---@field loop boolean @ 当前动画是否循环播放
---@field playing boolean @ 当前动画是否正在播放中
---@field isDispatchEvent boolean @ 是否抛出动画播放事件。默认：false
---
local FrameAnimation = class("FrameAnimation", EventDispatcher)



-- [ local ] --

local function DispatchAnimationEvent(ani, type)
    ---@type AnimationEvent
    local event = Event.Get(AnimationEvent, type)
    event.aniName = ani.aniName
    ani:DispatchEvent(event)
end



--
--- 构造函数
---@param go UnityEngine.GameObject
---@param fac ShibaInu.FrameAnimationController
---@param assetDirPath string
---@param useMainTex boolean
function FrameAnimation:Ctor(go, fac, assetDirPath, useMainTex)
    FrameAnimation.super.Ctor(self)

    self.frameCount = 0
    self.loop = false
    self.playing = false
    self.isDispatchEvent = false

    self.go = go
    self.fac = fac
    self:SetAssetDirPath(assetDirPath)
    self:SetUseMainTex(useMainTex ~= false)
end


--
--- 设置动画资源所在目录路径（GpuAnimationWindow 中设置的 导出目录）
---@param assetDirPath string
function FrameAnimation:SetAssetDirPath(assetDirPath)
    if not StringUtil.EndsWith(assetDirPath, "/") then
        assetDirPath = assetDirPath .. "/"
    end
    if assetDirPath ~= self.assetDirPath then
        self.assetDirPath = assetDirPath
        if self.id == nil then
            self.id = self.fac:AddAnimation(self.go, assetDirPath)
        else
            self.fac:SetAssetDir(self.id, assetDirPath)
        end
    end
end


--
--- 设置是否使用 MainTex
---@param value boolean @ true: 使用 MainTex, false: 使用 SecondTex
function FrameAnimation:SetUseMainTex(value)
    self.fac:SetUseMainTex(self.id, value)
end


--
--- 播放动画
---@param aniName string @ 动画名称
---@param loop boolean @ -可选- 是否循环播放，默认：false
---@param restart boolean @ -可选- 是否重新开始播放，默认：true
---@param randomFrame boolean @ -可选- 是否随机当前帧号，默认：false
function FrameAnimation:Play(aniName, loop, restart, randomFrame)
    loop = loop == true
    restart = restart == nil or restart == true

    if aniName == self.aniName and loop == self.loop and self.playing then
        return self.frameCount
    end

    self.playing = true
    self.frameCount = self.fac:PlayAnimation(self.id, aniName, loop, restart, randomFrame)

    if self.isDispatchEvent then
        DispatchAnimationEvent(self, AnimationEvent.ANI_START)
    end
end


--
--- 停止动画
function FrameAnimation:Stop()
    self.playing = false
    self.fac:StopAnimation(self.id)
end




--
--- 销毁动画对象（不是 gameObject）
function FrameAnimation:Destroy()
    self.playing = false
    self.fac:RemoveAnimation(self.id)
end




--
return FrameAnimation
