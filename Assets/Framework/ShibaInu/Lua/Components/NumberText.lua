--
-- 显示数字的文本
-- 在值上升或下降时，闪动颜色，滚动数字
-- 2019/05/07
-- Author LOLO
--

local round = MathUtil.Round


--
---@class NumberText
---@field New fun(text:UnityEngine.UI.Text, defaultValue:number):NumberText
---
---@field text UnityEngine.UI.Text @ 对应的 Text 组件
---@field normalColor Color @ 正常颜色
---@field upColor Color @ 值上升时闪烁的颜色
---@field downColor Color @ 值下降时闪烁的颜色
---@field delay number @ 切换间隔
---@field count number @ 总切换次数
---@field value number @ 对应的值
---@field callback HandlerRef @ 完成时的回调
---@field formatText fun(value:number):string
---@field curValue number @ 递增过程中的当前值
---@field addValue number @ 每次递增的值
---@field isBlink boolean @ 是否闪烁
---@field isRoll boolean @ 是否滚动
---@field dc HandlerRef
---
local NumberText = class("NumberText")



-- 默认上升时切换的颜色
local upColor = Color.New(0.411, 0.819, 0.462)
-- 默认下降时切换的颜色
local downColor = Color.New(0.917, 0.38, 0.321)



--
function NumberText:Ctor(text, defaultValue)
    self.text = text
    self.value = defaultValue or 0
    self.curValue = self.value
    self.normalColor = text.color
    self.delay = 0.07
    self.count = 13
    self.isBlink = true
    self.isRoll = true
    self.upColor = upColor
    self.downColor = downColor
    self.formatText = round

    self:ShowText(self.value)
    AddEventListener(text.gameObject, DestroyEvent.DESTROY, self.OnTextDestroy, self)
end


--
--- 设置值
function NumberText:SetValue(value, callback)
    if value == self.value then
        if callback ~= nil then
            CallHandler(self.callback, self.value)
        end
        return
    end

    if self.dc ~= nil then
        CancelDelayedCall(self.dc)
    end

    if not self.isBlink and not self.isRoll then
        self.value = value
        self:ShowText(value)
        if callback ~= nil then
            CallHandler(self.callback, self.value)
        end
        return
    end

    local isUp = value > self.value
    self.value = value
    self.addValue = (value - self.curValue) / self.count
    self:PlayEffect(isUp, 0)
end


--
--- 切换效果
function NumberText:PlayEffect(isUp, count)
    count = count + 1

    if self.isBlink then
        self.text.color = count % 2 == 0 and self.normalColor or (isUp and self.upColor or self.downColor)
    end

    if count < self.count then
        if self.isRoll then
            self:ShowText(self.curValue + self.addValue)
        end

        self.dc = DelayedCall(self.delay, self.PlayEffect, self, isUp, count)
    else
        self:EffectEnd(isUp)
    end
end


--
--- 效果播放结束
function NumberText:EffectEnd(isUp)
    self:ShowText(self.value)

    if self.isBlink then
        self.text.color = self.normalColor
    end

    self.dc = nil
    local callback = self.callback
    self.callback = nil
    if callback ~= nil then
        CallHandler(callback, self.value, isUp)
    end
end


--
--- 显示值内容
function NumberText:ShowText(value)
    self.curValue = value
    self.text.text = self.formatText(self.curValue)
end


--
--- 取消滚动，立即显示目标值
function NumberText:SetValueImmediately(value)
    if self.dc ~= nil then
        CancelDelayedCall(self.dc)
    end
    self.value = value
    self.curValue = value
    self.text.text = self.formatText(self.curValue)
end


--
--- 设置颜色（正常颜色）
function NumberText:SetColor(color)
    self.normalColor = color
    self.text.color = color
end




--
--- 销毁
function NumberText:Destroy()
    if self.dc ~= nil then
        CancelDelayedCall(self.dc)
        self.dc = nil
    end
end


--
--- 对应的文本被销毁时
function NumberText:OnTextDestroy()
    self:Destroy()
end



--
return NumberText
