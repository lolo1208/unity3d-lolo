--
-- 重写 Show() 和 Hide()，在显示和隐藏时加入移动效果
-- 2019/3/30
-- Author LOLO
--


--
---@class Effects.View.MoveView : View
---@field New fun(...):Effects.View.MoveView
---
---@field showed boolean @ 是否已经显示。用于重复调用 Show() 和 Hide() 时做判断
---
---@field SuperOnInitialize fun()
---@field SuperDestroy fun()
---@field SuperOnDestroy fun()
---
---@field isAnchored boolean @ [ true:更改 anchoredPosition, false:更改 localPosition]。默认：false
---@field startTime number
---@field startPos Vector2
---@field startAlpha number
---
---@field show_ease DG.Tweening.Ease
---@field show_position Vector3
---@field show_alpha number
---@field show_duration number
---@field hide_ease DG.Tweening.Ease
---@field hide_position Vector3
---@field hide_alpha number
---@field hide_duration number
---
---@field canvasGroup UnityEngine.CanvasGroup
---@field tweener DG.Tweening.Tweener
---
local MoveView = class("Effects.View.MoveView", View)

local tmpVec2 = Vector2.New()


-- 效果默认参数
MoveView.isAnchored = false
MoveView.show_ease = DOTween_Enum.Ease.OutCubic
MoveView.show_position = Vector3.New(0, 0, 0)
MoveView.show_alpha = 1
MoveView.show_duration = 0.25
MoveView.hide_ease = DOTween_Enum.Ease.Linear
MoveView.hide_position = Vector3.New(-100, 0, 0)
MoveView.hide_alpha = 0.05
MoveView.hide_duration = 0.2

-- 覆盖的函数
MoveView.SuperOnInitialize = View.OnInitialize
MoveView.SuperDestroy = View.Destroy
MoveView.SuperOnDestroy = View.OnDestroy


--
function MoveView:OnInitialize()
    self:SuperOnInitialize()

    if self.canvasGroup == nil then
        self.canvasGroup = AddOrGetComponent(self.gameObject, UnityEngine.CanvasGroup)
    end

    self.canvasGroup.alpha = self.hide_alpha
    if self.isAnchored then
        self.transform.anchoredPosition = self.hide_position
    else
        self.transform.localPosition = self.hide_position
    end
    if self.initShow then
        self.visible = false
        self:Show()
    end
end


--
function MoveView:Show()
    if self.showed then
        return
    end
    self.showed = true
    self.gameObject:SetActive(true)

    if self.isAnchored then
        self.startTime = TimeUtil.time
        self.startPos = self.transform.anchoredPosition
        self.startAlpha = self.canvasGroup.alpha
        AddEventListener(Stage, Event.UPDATE, self.UpdateAnchoredPosition, self)
    else
        if self.tweener ~= nil then
            self.tweener:Kill(false)
        end
        self.tweener = DOTween.Sequence()
        self.tweener:Append(self.transform:DOLocalMove(self.show_position, self.show_duration):SetEase(self.show_ease))
        self.tweener:Join(self.canvasGroup:DOFade(self.show_alpha, self.show_duration):SetEase(self.show_ease))
        self.tweener:AppendCallback(function()
            self.tweener = nil
            if not self.visible then
                self.visible = true
                self:OnShow()
            end
        end)
    end

end


--
function MoveView:Hide()
    if not self.showed then
        return
    end
    self.showed = false

    if self.isAnchored then
        self.startTime = TimeUtil.time
        self.startPos = self.transform.anchoredPosition
        self.startAlpha = self.canvasGroup.alpha
        AddEventListener(Stage, Event.UPDATE, self.UpdateAnchoredPosition, self)
    else
        if self.tweener ~= nil then
            self.tweener:Kill(false)
        end
        self.tweener = DOTween.Sequence()
        self.tweener:Append(self.transform:DOLocalMove(self.hide_position, self.hide_duration):SetEase(self.hide_ease))
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
end


--
function MoveView:UpdateAnchoredPosition()
    local duration, endPos, endAlpha
    if self.showed then
        duration = self.show_duration
        endPos = self.show_position
        endAlpha = self.show_alpha
    else
        duration = self.hide_duration
        endPos = self.hide_position
        endAlpha = self.hide_alpha
    end
    local startPos = self.startPos
    local startAlpha = self.startAlpha

    local time = TimeUtil.time - self.startTime
    -- 效果结束
    if time >= duration then
        RemoveEventListener(Stage, Event.UPDATE, self.UpdateAnchoredPosition, self)
        self.transform.anchoredPosition = endPos
        self.canvasGroup.alpha = endAlpha
        if self.showed then
            if not self.visible then
                self.visible = true
                self:OnShow()
            end
        else
            self.gameObject:SetActive(false)
            if self.visible then
                self.visible = false
                self:OnHide()
            end
        end
    else
        local p = time / duration -- 进度
        tmpVec2:Set(startPos.x + (endPos.x - startPos.x) * p, startPos.y + (endPos.y - startPos.y) * p)
        self.transform.anchoredPosition = tmpVec2
        self.canvasGroup.alpha = startAlpha + (endAlpha - startAlpha) * p
    end
end


--
function MoveView:Destroy(dispatchEvent, delay)
    self:Hide()
    DelayedCall(self.hide_duration, self.SuperDestroy, self, dispatchEvent, delay)
end


--
function MoveView:OnDestroy()
    RemoveEventListener(Stage, Event.UPDATE, self.UpdateAnchoredPosition, self)
    self:SuperOnDestroy()
end




--
return MoveView
