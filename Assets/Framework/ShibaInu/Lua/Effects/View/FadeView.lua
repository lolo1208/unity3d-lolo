--
-- 重写 Show() 和 Hide()，在显示和隐藏时加入淡入淡出效果
-- 2019/3/30
-- Author LOLO
--


--
---@class Effects.View.FadeView : View
---@field New fun(...):Effects.View.FadeView
---
---@field showed boolean @ 是否已经显示。用于重复调用 Show() 和 Hide() 时做判断
---
---@field SuperOnInitialize fun()
---@field SuperDestroy fun()
---
---@field show_ease DG.Tweening.Ease
---@field show_alpha number
---@field show_duration number
---@field hide_ease DG.Tweening.Ease
---@field hide_alpha number
---@field hide_duration number
---
---@field canvasGroup UnityEngine.CanvasGroup
---@field tweener DG.Tweening.Tweener
---
local FadeView = class("Effects.View.FadeView", View)


-- 效果默认参数
FadeView.show_ease = DOTween_Enum.Ease.Linear
FadeView.show_alpha = 1
FadeView.show_duration = 0.25
FadeView.hide_ease = DOTween_Enum.Ease.Linear
FadeView.hide_alpha = 0
FadeView.hide_duration = 0.15

-- 覆盖的函数
FadeView.SuperOnInitialize = View.OnInitialize
FadeView.SuperDestroy = View.Destroy


--
function FadeView:OnInitialize()
    self:SuperOnInitialize()

    if self.canvasGroup == nil then
        self.canvasGroup = AddOrGetComponent(self.gameObject, UnityEngine.CanvasGroup)
    end

    self.canvasGroup.alpha = self.hide_alpha
    if self.initShow then
        self.visible = false
        self:Show()
    end
end


--
function FadeView:Show()
    if self.showed then
        return
    end
    self.showed = true

    if self.tweener ~= nil then
        self.tweener:Kill(false)
    end

    self.gameObject:SetActive(true)
    self.tweener = self.canvasGroup:DOFade(self.show_alpha, self.show_duration):SetEase(self.show_ease)
    self.tweener:OnComplete(function()
        self.tweener = nil
        if not self.visible then
            self.visible = true
            self:OnShow()
        end
    end)
end


--
function FadeView:Hide()
    if not self.showed then
        return
    end
    self.showed = false

    if self.tweener ~= nil then
        self.tweener:Kill(false)
    end

    self.tweener = self.canvasGroup:DOFade(self.hide_alpha, self.hide_duration):SetEase(self.hide_ease)
    self.tweener:OnComplete(function()
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
function FadeView:Destroy(dispatchEvent, delay)
    self:Hide()
    DelayedCall(self.hide_duration, self.SuperDestroy, self, dispatchEvent, delay)
end




--
return FadeView
