--
-- 摇杆
-- 2018/1/31
-- Author LOLO
--

local max = math.max
local min = math.min
local sqrt = math.sqrt
local atan2 = math.atan2
local floor = math.floor
local abs = math.abs
local pi = math.pi

local IOGameData = require("Module.IOGame.Model.IOGameData") ---@type IOGame.IOGameData


--

---@class IOGame.Joystick : View
---@field New fun(go:UnityEngine.GameObject):IOGame.Joystick
---
---@field lockAngle boolean @ 是否锁定摇杆，不能变换角度
---
---@field protected _radius number @ 可摇动半径
---
---@field protected _sight UnityEngine.Transform
---@field protected _container UnityEngine.Transform
---@field protected _canvasGroup UnityEngine.CanvasGroup
---
---@field protected _sightTweener DG.Tweening.Tweener
---@field protected _cgTweener DG.Tweening.Tweener
---
---@field protected _screenWidth number
---@field protected _screenHeight number
---@field protected _uiWidth number
---@field protected _uiHeight number
---
---@field protected _curPos Vector3
---@field protected _pointerId number
---@field protected _enabled boolean
---
---@field protected _angleTimer Timer
---@field protected _curAngle number
---@field protected _tarAngle number
---@field protected _moveing boolean @ 是否正在移动中
---
local Joystick = class("IOGame.Joystick", View)

local tmpPos = Vector3.zero
local MAX_ANGLE = 15

function Joystick:Ctor(go)
    Joystick.super.Ctor(self)

    self.lockAngle = false
    self._radius = 45
    self._enabled = true
    self._curPos = Vector3.zero

    self._container = go.transform:Find("container")
    self._sight = self._container:Find("sight")
    self._canvasGroup = GetComponent.CanvasGroup(self._container.gameObject)

    self._screenWidth = Screen.width
    self._screenHeight = Screen.height
    local canvasRect = GetComponent.RectTransform(GameObject.Find("SceneUICanvas"))
    self._uiWidth = canvasRect.rect.width
    self._uiHeight = canvasRect.rect.height

    self._angleTimer = Timer.New(0.04, Handler.New(self.AngleTimerHandler, self))
    self._curAngle = 180
    self._tarAngle = 0
    self._moveing = false

    self.gameObject = go
    self:OnInitialize()
end


function Joystick:AngleTimerHandler()
    local cur = self._curAngle
    local tar = self._tarAngle
    if cur == tar and self._pointerId ~= nil then
        return
    end

    local moveing = true

    -- 锁定了角度
    if self.lockAngle then
        -- 已松开摇杆
        if self._pointerId == nil then
            self._angleTimer:Stop()
            moveing = false
        end

    else
        local ofs = abs(tar - cur)
        if ofs > MAX_ANGLE then
            local add = tar > cur
            if add then
                add = ofs < 180
            else
                add = ofs > 180
            end
            if add then
                cur = cur + MAX_ANGLE
            else
                cur = cur - MAX_ANGLE
            end

            if cur < 0 then
                cur = cur + 360
            elseif cur > 360 then
                cur = cur - 360
            end

            self._curAngle = cur
        else
            self._curAngle = tar
            -- 已松开摇杆
            if self._pointerId == nil then
                self._angleTimer:Stop()
                moveing = false
            end
        end

        -- 变换角度
        IOGameData.socket:Send(JSON.Stringify({
            cmd = IOGameData.CMD_ANGLE,
            id = IOGameData.playerID,
            angle = self._curAngle
        }))
    end

    -- 移动状态有改变
    if moveing ~= self._moveing then
        self._moveing = moveing
        IOGameData.socket:Send(JSON.Stringify({
            cmd = IOGameData.CMD_MOVE,
            id = IOGameData.playerID,
            moveing = moveing
        }))
    end
end


--


---PointerEventHandler
---@param event PointerEvent
function Joystick:PointerEventHandler(event)
    local eventData = event.data --- @type UnityEngine.EventSystems.PointerEventData
    local p = eventData.position
    local x = p.x / self._screenWidth * self._uiWidth
    local y = p.y / self._screenHeight * self._uiHeight

    -- 按下
    if event.type == PointerEvent.DOWN then
        if self._pointerId ~= nil then
            return
        end

        self._pointerId = eventData.pointerId
        if self._sightTweener ~= nil then
            self._sightTweener:Kill(false)
        end

        self._curPos.x = min(max(x, 90), 370)
        self._curPos.y = min(max(y, 90), 240)
        self._container.localPosition = self._curPos

        self:Fade(true)
        AddEventListener(self.gameObject, DragDropEvent.DRAG, self.PointerEventHandler, self)
        AddEventListener(self.gameObject, PointerEvent.UP, self.PointerEventHandler, self)

    elseif event.type == PointerEvent.UP then
        -- 拖动结束
        if eventData.pointerId == self._pointerId then
            self:End()
            return
        end
    end

    -- 拖动中
    if eventData.pointerId ~= self._pointerId then
        return
    end

    x = x - self._curPos.x
    y = y - self._curPos.y
    if x == 0 and y == 0 then
        return
    end

    local angle = atan2(x, y) * 180 / pi
    if x < 0 then
        angle = angle + 360
    end
    self._tarAngle = floor(angle + 0.5)
    self._angleTimer:Start()

    local radius = sqrt(x * x + y * y)
    if radius > self._radius then
        local relativeThickness = self._radius / radius
        x = x * relativeThickness
        y = y * relativeThickness
    end

    tmpPos.x = x
    tmpPos.y = y
    self._sight.localPosition = tmpPos
end


--


--- 是否启用
---@param value boolean
function Joystick:SetEnabled(value)
    self._enabled = value
    if value and self.visible then
        AddEventListener(self.gameObject, PointerEvent.DOWN, self.PointerEventHandler, self)
    else
        RemoveEventListener(self.gameObject, PointerEvent.DOWN, self.PointerEventHandler, self)
        self:End()
    end
end

function Joystick:GetEnabled()
    return self._enabled
end

--

--- 显示或逐渐隐藏（半透）
---@param fadeIn boolean
function Joystick:Fade(fadeIn)
    if self._cgTweener ~= nil then
        self._cgTweener:Kill(false)
    end

    if fadeIn then
        self._cgTweener = self._canvasGroup:DOFade(1, 0.2)
    else
        self._cgTweener = DOTween.Sequence()
        self._cgTweener:PrependInterval(0.8)
        self._cgTweener:Append(self._canvasGroup:DOFade(0.4, 0.3))
    end
end

--- 结束使用虚拟摇杆
function Joystick:End()
    self._pointerId = nil
    RemoveEventListener(self.gameObject, DragDropEvent.DRAG, self.PointerEventHandler, self)
    RemoveEventListener(self.gameObject, PointerEvent.UP, self.PointerEventHandler, self)
    if self._sightTweener ~= nil then
        self._sightTweener:Kill(false)
    end
    self._sightTweener = self._sight:DOLocalMove(Vector3.zero, 0.15)
    self:Fade(false)
end

--


function Joystick:OnShow()
    Joystick.super.OnShow(self)

    self:Fade(false)
    if self._enabled then
        self:SetEnabled(true)
    end
end

function Joystick:OnHide()
    Joystick.super.OnHide(self)

    if self._enabled then
        self:SetEnabled(true)
    end
end

return Joystick