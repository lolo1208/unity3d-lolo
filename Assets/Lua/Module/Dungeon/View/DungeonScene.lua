--
-- 地牢场景模块
-- 2018/6/15
-- Author LOLO
--

local DungeonData = require("Module.Dungeon.Model.DungeonData")
local JoystickEvent = require("Module.Dungeon.Model.JoystickEvent")
local Avatar = require("Module.Dungeon.View.Avatar.Avatar")


--
---@class Dungeon.DungeonScene : Scene
---
---@field joystick Dungeon.Joystick
---@field avatarContainer UnityEngine.Transform @ avatar 容器
---
---@field avatar Dungeon.Avatar.Avatar
---@field tpc App.ThirdPersonCamera
---
local DungeonScene = class("Dungeon.DungeonScene", Scene)
DungeonScene.SCENE_NAME = "Dungeon"

local bornList = {
    Vector3.New(-55, 2, -40),
    Vector3.New(-38, 2, 43),
    Vector3.New(-31, 2, 46),
    Vector3.New(-45, 2, -40),
    Vector3.New(-60, 2, -14),
    Vector3.New(-35, 2, 51),
}


--
function DungeonScene:OnInitialize()
    DungeonScene.super.OnInitialize(self)

    DungeonData.scene = self
    self.avatarContainer = CreateGameObject("avatars", self.transform, true).transform

    local canvasTra = self.transform:Find("SceneUICanvas")
    self.joystick = require("Module.Dungeon.View.UI.Joystick").New(canvasTra:Find("Joystick").gameObject)
    self.joystick:AddEventListener(JoystickEvent.STATE_CHANGED, self.JoystickEventHandler, self)
    self.joystick:AddEventListener(JoystickEvent.ANGLE_CHANGED, self.JoystickEventHandler, self)

    self.avatar = Avatar.New("Skeleton")
    self.avatar:SetPosition(bornList[1], nil, nil, true)

    self.tpc = GetComponent.ThirdPersonCamera(self.transform:Find("Main Camera"))
    self.tpc.target = self.avatar.transform


    -- test
    local testBtns = canvasTra:Find("TestBtns")
    local backBtn = testBtns:Find("backBtn").gameObject
    AddEventListener(backBtn, PointerEvent.CLICK, self.Click_BackBtn, self)
end


--
function DungeonScene:Click_BackBtn(event)
    SceneController.EnterTest()
end



--
---@param event Dungeon.Events.JoystickEvent
function DungeonScene:JoystickEventHandler(event)
    if event.type == JoystickEvent.ANGLE_CHANGED then
        self.avatar:SetAngle(event.angle, true)
    else
        self.avatar:SetJoystickMoveing(event.using)
    end
end



--
function DungeonScene:OnShow()
    DungeonScene.super.OnShow(self)

    self.joystick:SetEnabled(true)
end

--
function DungeonScene:OnHide()
    DungeonScene.super.OnHide(self)

    self.joystick:SetEnabled(false)
end



--
function DungeonScene:OnDestroy()
    DungeonScene.super.OnDestroy(self)
end




--
return DungeonScene