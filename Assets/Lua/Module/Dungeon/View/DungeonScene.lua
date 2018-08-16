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
---@field New fun():Dungeon.DungeonScene
---
---@field joystick Dungeon.Joystick
---@field avatarContainer UnityEngine.Transform @ avatar 容器
---
---@field avatar Dungeon.Avatar.Avatar
---@field tpc ShibaInu.ThirdPersonCamera
---
local DungeonScene = class("Dungeon.DungeonScene", Scene)

local bornList = {
    Vector3.New(-55, 2, -40),
    Vector3.New(-38, 2, 43),
    Vector3.New(-31, 2, 46),
    Vector3.New(-45, 2, -40),
    Vector3.New(-60, 2, -14),
    Vector3.New(-35, 2, 51),
}

--
function DungeonScene:Ctor()
    DungeonScene.super.Ctor(self, DungeonData.NAME, nil, true)
    DungeonData.scene = self
end


--
function DungeonScene:OnInitialize()
    DungeonScene.super.OnInitialize(self)

    self.avatarContainer = GameObject.New("avatars").transform

    local canvasTra = GameObject.Find("SceneUICanvas").transform
    self.joystick = require("Module.Dungeon.View.UI.Joystick").New(canvasTra:Find("Joystick").gameObject)
    self.joystick:AddEventListener(JoystickEvent.STATE_CHANGED, self.JoystickEventHandler, self)
    self.joystick:AddEventListener(JoystickEvent.ANGLE_CHANGED, self.JoystickEventHandler, self)

    self.avatar = Avatar.New("Skeleton")
    self.avatar:SetPosition(bornList[1], nil, nil, true)

    self.tpc = GetComponent.ThirdPersonCamera(Camera.main.gameObject)
    self.tpc.target = self.avatar.transform


    -- test
    local testBtns = canvasTra:Find("TestBtns")
    local backBtn = testBtns:Find("backBtn").gameObject
    local mosaicBtn = testBtns:Find("mosaicBtn").gameObject
    local radialBlurBtn = testBtns:Find("radialBlurBtn").gameObject
    local doubleImageShakeBtn = testBtns:Find("doubleImageShakeBtn").gameObject

    local hide = function()
        mosaicBtn:SetActive(false)
        radialBlurBtn:SetActive(false)
        backBtn:SetActive(true)
    end
    backBtn:SetActive(false)

    AddEventListener(backBtn, PointerEvent.CLICK, self.Click_BackBtn, self)
    AddEventListener(mosaicBtn, PointerEvent.CLICK, self.Click_TestBtn, self, 0, self.PlayMosaic, hide)
    AddEventListener(radialBlurBtn, PointerEvent.CLICK, self.Click_TestBtn, self, 0, self.PlayRadialBlur, hide)
    AddEventListener(doubleImageShakeBtn, PointerEvent.CLICK, function()
        LuaHelper.PlayDoubleImageShake(1.5)
    end)


end

--
function DungeonScene:Click_BackBtn(event)
    CancelDelayedCall(self.testDC)
    Stage.ShowScene(require("Module.Test.View.TestScene"))
end

--
function DungeonScene:Click_TestBtn(event, fn, hide)
    fn(self)
    hide()
end

--
function DungeonScene:PlayMosaic()
    self.testDC = DelayedCall(1.5, function()
        LuaHelper.PlayMosaic(0.06, 0.5, function()
            self.avatar:SetPosition(bornList[math.random(#bornList)], nil, nil, true)
            self.testDC = DelayedCall(0.1, function()
                LuaHelper.PlayMosaic(0, 0.5, function()
                    self:PlayMosaic()
                end)
            end)
        end)
    end)
end

--
function DungeonScene:PlayRadialBlur()
    self.testDC = DelayedCall(1.5, function()
        LuaHelper.PlayRadialBlur(30, 0.5, function()
            self.avatar:SetPosition(bornList[math.random(#bornList)], nil, nil, true)
            self.testDC = DelayedCall(0.1, function()
                LuaHelper.PlayRadialBlur(0, 0.5, function()
                    self:PlayRadialBlur()
                end)
            end)
        end)
    end)
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
function DungeonScene:OnDestroy()
    DungeonScene.super.OnDestroy(self)
end




--
return DungeonScene