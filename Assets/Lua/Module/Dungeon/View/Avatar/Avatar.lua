--
-- Avatar
-- 2018/6/20
-- Author LOLO
--

local DungeonData = require("Module.Dungeon.Model.DungeonData")


--
---@class Dungeon.Avatar.Avatar : View
---@field New fun(pic:string, id:number):Dungeon.Avatar.Avatar
---
---@field id number
---@field pic string
---@field angle number
---@field lastMoveTime number
---@field moveSpeed number @ 移动速度。默认：1
---
---@field picTra UnityEngine.Transform @ 根据 pic 创建的外形 prefab 实例
---@field container UnityEngine.Transform @ 子容器，该容器不会跟着 avatar 旋转
---
---@field animator UnityEngine.Animator
---@field aniSpeed number @ 当前动画播放速度。默认：1
---@field aniName string @ 当前动画名称
---@field aniLengthList table<string, number> @ 动画时长列表
---@field protected aniEndHandler HandlerRef
---
---@field cc UnityEngine.CharacterController @
---@field cameraTra UnityEngine.Transform
---
local Avatar = class("Dungeon.Avatar.Avatar", View)

local ID = 0
local MOVE_DISTANCE = 6.5 -- 每秒移动距离
local tmpVec3 = Vector3.zero


--
--- Ctor
function Avatar:Ctor(pic, id)
    Avatar.super.Ctor(self)
    if id == nil then
        ID = ID + 1
        id = ID
    end
    self.id = id
    self.pic = pic
    self.angle = 0
    self.moveSpeed = 1
    self.aniSpeed = 1

    self.gameObject = GameObject.New("avatar_" .. id)
    self:OnInitialize()
    self:EnableDestroyListener()
end


--
function Avatar:OnInitialize()
    Avatar.super.OnInitialize(self)

    local path = "Prefabs/Dungeon/" .. self.pic .. "/" .. self.pic .. ".prefab"
    local picGO = Instantiate(path, self.transform)
    self.container = CreateGameObject("container", self.transform, true).transform
    SetParent(self.transform, DungeonData.scene.avatarContainer)

    self.picTra = picGO.transform
    self.animator = GetComponent.Animator(picGO)
    if self.animator ~= nil then
        self.aniLengthList = {}
        local clips = self.animator.runtimeAnimatorController.animationClips
        for i = 0, clips.Length - 1 do
            local clip = clips[i]
            self.aniLengthList[clip.name] = clip.length
        end
    end

    local cc = GetComponent.CharacterController(picGO)
    self.cc = AddOrGetComponent(self.gameObject, UnityEngine.CharacterController)
    self.cc.center = cc.center
    self.cc.radius = cc.radius
    self.cc.height = cc.height
    Destroy(cc)
end



--=---------------------------[ 旋转和移动 ]---------------------------=-

--
--- 设置当前位置
function Avatar:SetPosition(posOrX, y, z, useController)
    local pos
    if y ~= nil then
        tmpVec3:Set(posOrX, y, z)
        pos = tmpVec3
    else
        pos = posOrX
    end

    self.transform.localPosition = pos
    if useController then
        self.cc:Move(Vector3.New(0, -99, 0))
    end
end


--
--- 设置当前角度
---@param angle number
---@param offsetCamera boolean
function Avatar:SetAngle(angle, offsetCamera)
    self.angle = angle

    if offsetCamera then
        if self.cameraTra == nil then
            self.cameraTra = Camera.main.transform
        end
        local offsetAngle = MathUtil.Angle(self.transform.position, self.cameraTra.position)
        angle = angle + offsetAngle + 90
    end

    tmpVec3:Set(0, angle, 0)
    self.transform.localEulerAngles = tmpVec3
    tmpVec3:Set(0, -angle, 0)
    self.container.localEulerAngles = tmpVec3
end


--
---

--
--- 设置是否是否正在使用摇杆移动
function Avatar:SetJoystickMoveing(value)
    if value then
        self:PlayAnimation("Walk")
        self.lastMoveTime = TimeUtil.time
        AddEventListener(Stage, Event.UPDATE, self.Update_JoystickMove, self)
    else
        self:PlayAnimation("Stand")
        RemoveEventListener(Stage, Event.UPDATE, self.Update_JoystickMove, self)
    end
end

--
function Avatar:Update_JoystickMove(event)
    self:SetAngle(self.angle, true)

    local deltaTime = TimeUtil.time - self.lastMoveTime
    self.lastMoveTime = TimeUtil.time

    local motion = self.picTra.forward * deltaTime * MOVE_DISTANCE * self.moveSpeed
    motion.y = -99
    self.cc:Move(motion)
end




--=---------------------------[ 播放动画 ]---------------------------=-

--
--- 播放指定动画
---@param aniName string @ 要播放的动画名称
---@param callback HandlerRef @ 动画播放完成的回调（会传回参数 aniName）
---@param transitionDuration number
function Avatar:PlayAnimation(aniName, callback, transitionDuration)
    if self.animator == nil or aniName == self.aniName then
        return
    end
    self.aniName = aniName

    transitionDuration = transitionDuration or 0.15
    self.animator:CrossFadeInFixedTime(aniName, transitionDuration)

    -- 清除之前的回调
    if self.aniEndHandler ~= nil then
        CancelDelayedCall(self.aniEndHandler)
        self.aniEndHandler = nil
    end
    -- 注册新回调
    if callback ~= nil then
        local aniLength = self.aniLengthList[aniName]
        self.aniEndHandler = DelayedCall(aniLength / self.aniSpeed, function()
            self.aniEndHandler = nil
            CallHandler(callback, aniName)
        end)
    end
end


--
--- 设置动画播放速度。获取方式：avatar.aniSpeed
function Avatar:SetAniSpeed(value)
    if value ~= self.aniSpeed and self.animator ~= nil then
        self.animator.speed = value
        self.aniSpeed = value
    end
end





--
function Avatar:OnDestroy()
    RemoveEventListener(Stage, Event.UPDATE, self.Update_JoystickMove, self)
end




--
return Avatar