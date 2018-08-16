--
-- 射击时，飞行的火焰
-- 2018/2/27
-- Author LOLO
--

local random = math.random
local floor = math.floor

local DISTANCE = 0.3 --- 每帧移动距离
local FRAME_NUM = 90 --- 特效总帧数

local p3 = Vector3.up

--


local IOGameData = require("Module.IOGame.Model.IOGameData")

---@class IOGame.Effects.ShotFire
---@field New fun():IOGame.Effects.ShotFire
---
---@field Effect IOGame.Effects.Effect
---
---@field index number
---@field angle number @ 角度
---@field startPos Vector3 @ 开始位置
---@field startFrame number @ 开始帧号（逻辑帧）
---@field frameNum number @ 已经渲染帧数（渲染帧）
---
---@field avatar IOGame.Avatar
---@field effect UnityEngine.Transform
---
local ShotFire = class("IOGame.Effects.ShotFire")

function ShotFire:Ctor()
    self.startPos = Vector3.New()
end

function ShotFire:GetInfo()
    return {
        index = self.index, startFrame = self.startFrame,
        angle = self.angle, avatarID = self.avatar.id,
        startPos = { x = self.startPos.x, z = self.startPos.z }
    }
end


--


--- 开始特效
function ShotFire:Start(initData)
    self.angle = initData.angle
    self.avatar = IOGameData.map:GetAvatar(initData.avatarID)

    self.effect = Instantiate(
            "Prefabs/IOGame/fire/fire" .. floor(random(3)) .. ".prefab",
            IOGameData.map.effectC
    ).transform

    local frame = IOGameData.frame
    if initData.startFrame ~= nil then
        self.startPos.x = initData.startPos.x
        self.startPos.z = initData.startPos.z
        self.startFrame = initData.startFrame
        self.frameNum = (frame.curFrame - self.startFrame) * frame.frameRatio - 1
        self:Update()
    else
        self.startFrame = frame.curFrame
        self.frameNum = 0
        self.startPos.x = self.avatar.position.x
        self.startPos.z = self.avatar.position.z
    end
end


--


--- 更新状态（每渲染帧）
function ShotFire:Update()
    self.frameNum = self.frameNum + 1

    p3.x = self.startPos.x
    p3.z = self.startPos.z
    Float3.OffsetByAngle(p3, self.angle, DISTANCE * self.frameNum)
    self.effect.localPosition = p3

    if self.frameNum == FRAME_NUM then
        self.Effect.Stop(self)
    end
end


--


--- 结束状态
function ShotFire:Stop()
    if self.effect ~= nil then
        Destroy(self.effect.gameObject, 2)
        self.effect = nil
    end
end



--

return ShotFire