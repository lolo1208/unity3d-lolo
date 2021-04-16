--
-- 使用 GpuAnimationWindow 从 fbx 文件中提取（合并）mesh，生成动画对应的纹理
-- 再使用 shader "ShibaInu/Component/GpuAnimation" 播放 GPU 动画
-- 2019/6/5
-- Author LOLO
--

local abs = math.abs


--
---@class GpuAnimation : EventDispatcher
---@field New fun(go:UnityEngine.GameObject, assetDirPath:string):GpuAnimation
---
---@field go UnityEngine.GameObject @ 对应的 GameObject
---@field meshFilter UnityEngine.MeshFilter @ 对应的 MeshFilter
---@field meshRenderer UnityEngine.MeshRenderer @ 对应的 MeshRenderer
---@field assetDirPath string @ 动画资源所在目录路径（GpuAnimationWindow 中设置的 导出目录）
---
---@field aniName string @ 当前动画名称
---@field aniLength number @ 当前动画时长（秒）
---@field loop boolean @ 当前动画是否循环播放
---@field speed number @ 当前动画播放速度
---
---@field protected completeTimer Timer
---
local GpuAnimation = class("GpuAnimation", EventDispatcher)



-- [ local ] --

local pool = {}
local props = UnityEngine.MaterialPropertyBlock.New()

local function DispatchAnimationEvent(ani, type)
    ---@type AnimationEvent
    local event = Event.Get(AnimationEvent, type)
    event.aniName = ani.aniName
    ani:DispatchEvent(event)
end



--
--- 构造函数
---@param go UnityEngine.GameObject
---@param assetDirPath string
function GpuAnimation:Ctor(go, assetDirPath)
    GpuAnimation.super.Ctor(self)

    self.completeTimer = Timer.New(1, NewHandler(self.CompleteHandler, self))

    self.go = go
    self.meshFilter = AddOrGetComponent(go, UnityEngine.MeshFilter)
    self.meshRenderer = AddOrGetComponent(go, UnityEngine.MeshRenderer)
    self:SetAssetDirPath(assetDirPath)
end


--
--- 设置动画资源所在目录路径（GpuAnimationWindow 中设置的 导出目录）
---@param assetDirPath string
function GpuAnimation:SetAssetDirPath(assetDirPath)
    if not StringUtil.EndsWith(assetDirPath, "/") then
        assetDirPath = assetDirPath .. "/"
    end
    self.assetDirPath = assetDirPath
    local mesh = Res.LoadAsset(assetDirPath .. "Mesh.asset")
    if mesh ~= nil then
        self.meshFilter.sharedMesh = mesh
    end
end


--
--- 播放动画
---@param aniName string @ 动画名称
---@param loop boolean @ -可选- 是否循环播放，默认：false
---@param startTime number @ -可选- 动画的开始播放时间（时间偏移），默认：TimeUtil.timeSinceLevelLoad
---@param speed number @ -可选- 动画播放速度，默认：1。值为负数时，将会反向播放动画
---@param dispatchEvent boolean @ -可选- 是否抛出动画播放事件，循环播放的动画只会触发一次 start 和 complete 事件，默认：false
function GpuAnimation:Play(aniName, loop, startTime, speed, dispatchEvent)
    loop = loop == true
    startTime = startTime or TimeUtil.timeSinceLevelLoad
    speed = speed or 1
    dispatchEvent = dispatchEvent == true

    if aniName ~= self.aniName then
        self.aniName = aniName
        local mat, len = GpuAnimation.GetMaterial(self.assetDirPath .. aniName .. ".mat")
        self.meshRenderer.sharedMaterial = mat
        self.aniLength = len
    end
    self.meshRenderer:GetPropertyBlock(props)

    if loop ~= self.loop then
        self.loop = loop
        props:SetFloat("_Loop", loop == true and 1 or 0)
    end

    if speed ~= self.speed then
        self.speed = speed
        props:SetFloat("_Speed", speed)
    end

    props:SetFloat("_StartTime", startTime)
    self.meshRenderer:SetPropertyBlock(props)

    if dispatchEvent then
        DispatchAnimationEvent(self, AnimationEvent.ANI_START)
        self.completeTimer:SetDelay(self.aniLength / abs(self.speed))
        self.completeTimer:Start()
    else
        self.completeTimer:Stop()
    end
end


--
--- 动画播放完成
function GpuAnimation:CompleteHandler()
    self.completeTimer:Stop()
    if isnull(self.go) then
        return
    end
    DispatchAnimationEvent(self, AnimationEvent.ANI_COMPLETE)
end


--
--- 设置动画播放速度
---@param speed number
function GpuAnimation:SetSpeed(speed)
    if speed == self.speed then
        return
    end
    self.speed = speed
    self.meshRenderer:GetPropertyBlock(props)
    props:SetFloat("_Speed", speed)
    self.meshRenderer:SetPropertyBlock(props)
end


--
--- 设置是否循环播放
---@param loop boolean
function GpuAnimation:SetLoop(loop)
    if loop == self.loop then
        return
    end
    self.loop = loop
    self.meshRenderer:GetPropertyBlock(props)
    props:SetFloat("_Loop", loop == true and 1 or 0)
    self.meshRenderer:SetPropertyBlock(props)
end


--
--- 设置动画的开始播放时间（时间偏移）
---@param time number @ -可选- 默认：TimeUtil.timeSinceLevelLoad
function GpuAnimation:SetStartTime(time)
    self.meshRenderer:GetPropertyBlock(props)
    props:SetFloat("_StartTime", time or TimeUtil.timeSinceLevelLoad)
    self.meshRenderer:SetPropertyBlock(props)
end


--
--- 当前是否正在播放 aniName 的动画
---@param aniName string
---@return boolean
function GpuAnimation:IsAniName(aniName)
    return self.aniName == aniName
end



-- [ static] --

--
--- 从池中获取或加载 matPath 对应的动画材质球
--- 返回材质球，以及动画的时长（秒）
---@return UnityEngine.Material, number
function GpuAnimation.GetMaterial(matPath)
    local cache = pool[matPath]
    if cache ~= nil then
        return cache[1], cache[2]
    end

    local mat = Res.LoadAsset(matPath)
    local len = mat:GetFloat("_AniLen")
    pool[matPath] = { mat, len }
    return mat, len
end


--
--- 清空材质球和动画时长缓存池
function GpuAnimation.Clean()
    pool = {}
end



--
return GpuAnimation

