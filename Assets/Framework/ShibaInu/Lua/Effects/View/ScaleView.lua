--
-- 重写 Show() 和 Hide()，在显示和隐藏时加入缩放效果
-- 2019/3/30
-- Author LOLO
--


--
---@class Effects.View.ScaleView : View
---@field New fun(...):Effects.View.ScaleView
---
---@field showed boolean @ 是否已经显示。用于重复调用 Show() 和 Hide() 时做判断
---
---@field SuperOnInitialize fun()
---@field SuperDestroy fun()
---
---@field show_ease DG.Tweening.Ease
---@field show_scale Vector3
---@field show_alpha number
---@field show_duration number
---@field hide_ease DG.Tweening.Ease
---@field hide_scale Vector3
---@field hide_alpha number
---@field hide_duration number
---
---@field canvasGroup UnityEngine.CanvasGroup
---@field tweener DG.Tweening.Tweener
---
local ScaleView = class("Effects.View.ScaleView", View)


-- 效果默认参数
ScaleView.show_ease = DOTween_Enum.Ease.OutBack
ScaleView.show_scale = Vector3.New(1, 1, 1)
ScaleView.show_alpha = 1
ScaleView.show_duration = 0.25
ScaleView.hide_ease = DOTween_Enum.Ease.Linear
ScaleView.hide_scale = Vector3.New(0.3, 0.3, 0.3)
ScaleView.hide_alpha = 0
ScaleView.hide_duration = 0.15

-- 覆盖的函数
ScaleView.SuperOnInitialize = View.OnInitialize
ScaleView.SuperDestroy = View.Destroy


--
function ScaleView:OnInitialize()
    self:SuperOnInitialize()

    if self.canvasGroup == nil then
        self.canvasGroup = AddOrGetComponent(self.gameObject, UnityEngine.CanvasGroup)
    end

    self.canvasGroup.alpha = self.hide_alpha
    self.transform.localScale = self.hide_scale
    if self.initShow then
        self.visible = false
        self:Show()
    end
end


--
function ScaleView:Show()
    if self.showed then
        return
    end
    self.showed = true

    if self.tweener ~= nil then
        self.tweener:Kill(false)
    end

    self.gameObject:SetActive(true)
    self.tweener = DOTween.Sequence()
    self.tweener:Append(self.transform:DOScale(self.show_scale, self.show_duration):SetEase(self.show_ease))
    self.tweener:Join(self.canvasGroup:DOFade(self.show_alpha, self.show_duration):SetEase(self.show_ease))
    self.tweener:AppendCallback(function()
        self.tweener = nil
        if not self.visible then
            self.visible = true
            self:OnShow()
        end
    end)
end


--
function ScaleView:Hide()
    if not self.showed then
        return
    end
    self.showed = false

    if self.tweener ~= nil then
        self.tweener:Kill(false)
    end

    self.tweener = DOTween.Sequence()
    self.tweener:Append(self.transform:DOScale(self.hide_scale, self.hide_duration):SetEase(self.hide_ease))
    self.tweener:Join(self.canvasGroup:DOFade(self.hide_alpha, self.hide_duration):SetEase(self.hide_ease))
    self.tweener:AppendCallback(function()
        self.tweener = nil
        if not isnull(self.gameObject) then
            self.gameObject:SetActive(false)
        end
        if self.visible then
            self.visible = false
            self:OnHide()
        end
    end)
end


--
function ScaleView:Destroy(dispatchEvent, delay)
    self:Hide()
    DelayedCall(self.hide_duration, self.SuperDestroy, self, dispatchEvent, delay)
end




--
return ScaleView
