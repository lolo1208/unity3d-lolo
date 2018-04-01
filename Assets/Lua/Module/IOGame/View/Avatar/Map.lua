--
-- 地图
-- 2018/2/1
-- Author LOLO
--

local pairs = pairs

local Avatar = require("Module.IOGame.View.Avatar.Avatar")
local IOGameData = require("Module.IOGame.Model.IOGameData") ---@type IOGame.IOGameData
local FSM = require("Module.IOGame.Controller.FSM.FSM")

local p3 = Vector3.zero

---@class IOGame.Map : View
---@field New fun():IOGame.Map
---
---@field avatarC UnityEngine.Transform
---@field effectC UnityEngine.Transform
---
---@field avatars table<number, IOGame.Avatar> @ id 为 key
---@field cameraLocked boolean @ 主摄像机是否已锁定，锁定时，不能跟随玩家角色
---
---@field playerAvatar IOGame.Avatar @ 当前玩家自己的角色
---
local Map = class("IOGame.Map", View)

local camera = IOGameData.camera
local CAMERA_POS = IOGameData.cameraInPos

function Map:Ctor()
    Map.super.Ctor(self)

    self.avatars = {}
    self.cameraLocked = false

    self.gameObject = CreateGameObject("Map", nil, true)
    p3:Set(-12, 0.82, -10)
    self.gameObject.transform.localPosition = p3

    self.avatarC = CreateGameObject("Avatars", self.gameObject.transform, true).transform
    self.effectC = CreateGameObject("Effects", self.gameObject.transform, true).transform

    camera.localPosition = IOGameData.cameraOutPos
    camera.localEulerAngles = IOGameData.cameraOutAng

    self:OnInitialize()
end

function Map:OnInitialize()
    Map.super.OnInitialize(self)
end


--


--- 进入到下一帧
function Map:NextFrame()
    -- 更新所有角色状态机
    for id, avatar in pairs(self.avatars) do
        -- state 状态机
        if avatar.state ~= nil then
            avatar.state.current:Update()
        end
        -- action 状态机
        if avatar.action ~= nil and avatar.action.current ~= nil then
            avatar.action.current:Update()
        end
    end
end


--


--- 创建一个 Avatar
---@param data IOGame.FrameData.NewAvatar
function Map:CreateAvatar(data)
    local avatar = Avatar.New(self, data)
    self.avatars[data.id] = avatar
    avatar.action = FSM.New(avatar)

    if data.id == IOGameData.playerID then
        self:StartFocus(avatar)
    else
        avatar.state = FSM.New(avatar, data.state.index, data.state)
        if data.action ~= nil then
            avatar.action:Transition(data.action.index, data.action)
        end
    end

    return avatar
end

--- 移除一个角色
function Map:RemoveAvatar(id)
    Destroy(self.avatars[id].gameObject)
    self.avatars[id] = nil
end

--- 获取 id 对应的 avatar
---@param id number
---@return IOGame.Avatar
function Map:GetAvatar(id)
    return self.avatars[id]
end


--

--- 刚进游戏，聚焦到玩家自己的 Avatar
---@param avatar IOGame.Avatar
function Map:StartFocus(avatar)
    self.playerAvatar = avatar
    camera:DOLocalRotate(IOGameData.cameraInAng, 1)
    p3:Set(
            CAMERA_POS.x + avatar.position.x + 2,
            CAMERA_POS.y + avatar.position.y - 3,
            CAMERA_POS.z + avatar.position.z
    )
    avatar.ani:Play("idle break")
    camera:DOLocalMove(p3, 1):OnComplete(function()
        avatar.ani:Play("salute")
        DelayedCall(1.7, function()

            avatar.ani:Play("idle to fight idle")
            DelayedCall(0.8, function()
                avatar.state = FSM.New(avatar, FSM.state_fightIdle)
                IOGameData.joystick:Show()
                IOGameData.btnBar:Show()
            end)

            local pos = avatar.position
            p3:Set(CAMERA_POS.x + pos.x, CAMERA_POS.y + pos.y, CAMERA_POS.z + pos.z)
            camera:DOLocalMove(p3, 0.8)
        end)
    end)
    avatar:SetAngle(180)
end

--- 聚焦到玩家自己的 Avatar
function Map:Focus()
    if not self.cameraLocked then
        local pos = self.playerAvatar.position
        p3:Set(CAMERA_POS.x + pos.x, CAMERA_POS.y + pos.y, CAMERA_POS.z + pos.z)
        camera.localPosition = p3
    end
end


--


--- 获取上报数据
function Map:GetReportData()
    local avatars = {}
    local index = 0
    for id, avatar in pairs(self.avatars) do
        index = index + 1
        ---@type IOGame.FrameData.NewAvatar
        local avtData = {
            id = avatar.id,
            name = avatar.name,
            pic = avatar.pic,
            x = avatar.position.x,
            z = avatar.position.z,
            angle = avatar.angle
        }

        local state = avatar.state.current
        avtData.state = state:GetInfo()

        local action = avatar.action.current
        if action ~= nil then
            avtData.action = action:GetInfo()
        end

        avatars[index] = avtData
    end

    return avatars
end

return Map