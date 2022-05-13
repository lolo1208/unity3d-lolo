--
-- CircleImage 组件测试范例
-- 2018/4/3
-- Author LOLO
--

---@class Test.Samples.ToggleSwitch_iOS : ToggleSwitch
---@field New fun(transform:UnityEngine.RectTransform, checked:boolean, hitArea:UnityEngine.GameObject):Test.Samples.ToggleSwitch_iOS
---
---@field protected _bgOff UnityEngine.CanvasGroup
---@field protected _bgOn UnityEngine.CanvasGroup
---@field protected _bgDisabled UnityEngine.CanvasGroup
---@field protected _handle UnityEngine.RectTransform
---@field protected _onTweener DG.Tweening.Tweener
---@field protected _offTweener DG.Tweening.Tweener
---@field protected _handleTweener DG.Tweening.Tweener
---@field protected _pos Vector3
---
local ToggleSwitch_iOS = class("Test.Samples.Test_ToggleSwitch", ToggleSwitch)

--
--- 构造函数
---@param transform UnityEngine.RectTransform
---@param checked boolean
---@param hitArea UnityEngine.GameObject
function ToggleSwitch_iOS:Ctor(transform, checked, hitArea)
    ToggleSwitch_iOS.super.Ctor(self)

    self._checked = checked == true
    self._bgOff = AddOrGetComponent(transform:Find("BgOff").gameObject, UnityEngine.CanvasGroup)
    self._bgOn = AddOrGetComponent(transform:Find("BgOn").gameObject, UnityEngine.CanvasGroup)
    self._bgDisabled = AddOrGetComponent(transform:Find("BgDisabled").gameObject, UnityEngine.CanvasGroup)
    self._handle = transform:Find("Handle")
    self._pos = self._handle.localPosition
    self._bgDisabled.alpha = 0
    self:PlayToggleEffect(true)

    hitArea = hitArea or transform.gameObject
    AddEventListener(hitArea, PointerEvent.CLICK, self.InteractiveToggle, self)
end


--
--- 播放状态切换时的效果
function ToggleSwitch_iOS:PlayToggleEffect(immediate)
    local duration = 0.15
    local offAlpha = self._checked and 0 or 1
    local onAlpha = self._checked and 1 or 0
    self._pos.x = self._checked and 10 or -10

    if immediate then
        if self._offTweener then
            self._offTweener:Kill(false)
            self._onTweener:Kill(false)
            self._handleTweener:Kill(false)
        end
        self._bgOff.alpha = offAlpha
        self._bgOn.alpha = onAlpha
        self._handle.localPosition = self._pos
        return
    end

    self._offTweener = self._bgOff:DOFade(offAlpha, duration)
    self._onTweener = self._bgOn:DOFade(onAlpha, duration)
    self._handleTweener = self._handle:DOLocalMove(self._pos, duration)
end



--
--- 设置是否可交互（响应点击）
---@param value boolean
function ToggleSwitch_iOS:SetEnabled(value)
    ToggleSwitch_iOS.super.SetEnabled(self, value)

    self._bgDisabled.alpha = self._enabled and 0 or 1
end



--
return ToggleSwitch_iOS
