--
-- 操作按钮条
-- 2018/2/7
-- Author LOLO
--


local IOGameData = require("Module.IOGame.Model.IOGameData") ---@type IOGame.IOGameData

---@class IOGame.BtnBar : View
---@field New fun(go:UnityEngine.GameObject):IOGame.BtnBar
---
---@field _attackBtn UnityEngine.UI.Image
---
---@field protected _zoomInFrameCount number
---@field protected _zoomPosTweener DG.Tweening.Tweener
---@field protected _zoomAngTweener DG.Tweening.Tweener
---
---@field protected _cdTotal number @ CD总帧数
---@field protected _cdCurrent number @ CD已触发帧数
---
---@field protected _btnImgList table<number, UnityEngine.UI.Image> @ 触发按钮点击的图像列表
---@field protected _cdImgList table<number, ShibaInu.CircleImage> @ 按钮 CD 效果的 CircleImage 列表
---
---@field protected _attackGrade number @ 当前攻击阶段
---
local BtnBar = class("IOGame.BtnBar", View)

local F_N_CD_ADD = 3 --- CD 默认多加几帧

local camera = IOGameData.camera
local camTweenDurationTime = 0.4
local camTweenDurationFrame = 24
local p3 = Vector3.zero
local attackBtnColor = {
    Color.New(1, 1, 1, 1),
    Color.New(1, 1, 0, 1),
    Color.New(1, 0.4, 0, 1),
    Color.New(1, 0.7, 0, 1),
}

function BtnBar:Ctor(go)
    BtnBar.super.Ctor(self)

    self._zoomIn = true
    self._cdTotal = 0
    self._cdCurrent = 0
    self._attackGrade = 0
    local transform = go.transform

    --
    local zoomGO = transform:Find("zoom").gameObject
    AddEventListener(zoomGO, PointerEvent.DOWN, self.ZoomInOut, self)
    AddEventListener(zoomGO, PointerEvent.UP, self.ZoomInOut, self)

    --
    local jumpTF = transform:Find("jump")
    local jumpGO = jumpTF.gameObject
    AddEventListener(jumpGO, PointerEvent.DOWN, self.JumpBtn_Click, self)

    --
    local attackTF = transform:Find("attack")
    local attackGO = attackTF.gameObject
    self._attackBtn = GetComponent.Image(attackGO)
    AddEventListener(attackGO, PointerEvent.DOWN, self.AttackBtn_Click, self)

    --
    local shotTF = transform:Find("shot")
    local shotGO = shotTF.gameObject
    AddEventListener(shotGO, PointerEvent.DOWN, self.ShotBtn_Click, self)

    --
    self._btnImgList = {
        GetComponent.Image(jumpGO),
        self._attackBtn,
        GetComponent.Image(shotGO),
    }
    self._cdImgList = {
        GetComponent.CircleImage(jumpTF:Find("cd").gameObject),
        GetComponent.CircleImage(attackTF:Find("cd").gameObject),
        GetComponent.CircleImage(shotTF:Find("cd").gameObject),
    }

    --
    self.gameObject = go
    self:OnInitialize()
    self:EnableDestroyListener()
end

--


--- 开始或结束 CD
---@param frameNum number @ CD 持续帧数[ 0=结束 ]
function BtnBar:SetCD(frameNum)
    self._cdTotal = frameNum > 0 and frameNum + F_N_CD_ADD or 0
    self._cdCurrent = 0

    local raycastTarget = frameNum == 0
    for i = 1, #self._btnImgList do
        self._btnImgList[i].raycastTarget = raycastTarget
    end
end

--- 进入下一帧
function BtnBar:NextFrame()
    if self._cdTotal == 0 then
        return
    end
    self._cdCurrent = self._cdCurrent + 1

    -- 更新 CD CircleImage
    local fan = self._cdCurrent / self._cdTotal
    for i = 1, #self._cdImgList do
        self._cdImgList[i].fan = fan
    end

    -- CD 已结束
    if self._cdCurrent == self._cdTotal then
        self:SetCD(0)
    end
end


--


--- 点击【跳跃】按钮
---@param event Event
function BtnBar:JumpBtn_Click(event)
    self:SetCD(IOGameData.F_N_JUMP)

    IOGameData.socket:Send(JSON.Stringify({
        cmd = IOGameData.CMD_JUMP,
        id = IOGameData.playerID
    }))
end

--- 点击【攻击】按钮
---@param event Event
function BtnBar:AttackBtn_Click(event)
    self:SetCD(IOGameData.F_N_ATTACK)

    self._attackGrade = self._attackGrade == 4 and 1 or self._attackGrade + 1
    IOGameData.socket:Send(JSON.Stringify({
        cmd = IOGameData.CMD_ATTACK,
        id = IOGameData.playerID,
        grade = self._attackGrade
    }))

    local colorType = self._attackGrade == 4 and 1 or self._attackGrade + 1
    self._attackBtn:DOColor(attackBtnColor[colorType], 1.1)
end

--- 点击【射击】按钮
---@param event Event
function BtnBar:ShotBtn_Click(event)
    self:SetCD(IOGameData.F_N_SHOT)

    IOGameData.socket:Send(JSON.Stringify({
        cmd = IOGameData.CMD_SHOT,
        id = IOGameData.playerID
    }))
end


--


--- 拉近或拉远主镜头
---@param event PointerEvent
function BtnBar:ZoomInOut(event)
    IOGameData.map.cameraLocked = true

    if self._zoomPosTweener ~= nil then
        self._zoomPosTweener:Kill(false)
    end
    if self._zoomAngTweener ~= nil then
        self._zoomAngTweener:Kill(false)
    end

    -- zoom out
    if event.type == PointerEvent.DOWN then
        RemoveEventListener(Stage, Event.UPDATE, self.CameraZoomInUpdate, self)
        self._zoomPosTweener = camera:DOLocalMove(IOGameData.cameraOutPos, camTweenDurationTime)
        self._zoomAngTweener = camera:DOLocalRotate(IOGameData.cameraOutAng, camTweenDurationTime)
    else
        self._zoomAngTweener = camera:DOLocalRotate(IOGameData.cameraInAng, camTweenDurationTime)
        self._zoomInFrameCount = 0
        AddEventListener(Stage, Event.UPDATE, self.CameraZoomInUpdate, self)
    end
end

function BtnBar:CameraZoomInUpdate(event)
    self._zoomInFrameCount = self._zoomInFrameCount + 1
    if self._zoomInFrameCount == camTweenDurationFrame then
        RemoveEventListener(Stage, Event.UPDATE, self.CameraZoomInUpdate, self)
        IOGameData.map.cameraLocked = false
        IOGameData.map:Focus()
        return
    end

    local count = camTweenDurationFrame - self._zoomInFrameCount
    local cp = camera.localPosition
    local ap = IOGameData.map.playerAvatar.position
    local ip = IOGameData.cameraInPos
    local ox, oy, oz = (ap.x + ip.x - cp.x) / count, (ap.y + ip.y - cp.y) / count, (ap.z + ip.z - cp.z) / count
    p3:Set(cp.x + ox, cp.y + oy, cp.z + oz)
    camera.localPosition = p3
end


--

function BtnBar:OnDestroy()
    RemoveEventListener(Stage, Event.UPDATE, self.CameraZoomInUpdate, self)
end

--

return BtnBar