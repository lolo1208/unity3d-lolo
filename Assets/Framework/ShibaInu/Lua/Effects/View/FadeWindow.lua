--
-- 重写 Show() 和 Hide()，在显示和隐藏时加入淡入淡出效果
-- * 效果的实现都是在 FadeView 中完成的，该类是继承至 Window 的版本
-- 2019/3/30
-- Author LOLO
--


local FadeView = require("Effects.View.FadeView")


--
---@see Effects.View.FadeView
---@class Effects.View.FadeWindow : Window
---@field New fun(...):Effects.View.FadeWindow
---
local FadeWindow = class("Effects.View.FadeWindow", Window)


-- 效果默认参数
FadeWindow.show_ease = FadeView.show_ease
FadeWindow.show_scale = FadeView.show_scale
FadeWindow.show_alpha = FadeView.show_alpha
FadeWindow.show_duration = FadeView.show_duration
FadeWindow.hide_ease = FadeView.hide_ease
FadeWindow.hide_scale = FadeView.hide_scale
FadeWindow.hide_alpha = FadeView.hide_alpha
FadeWindow.hide_duration = FadeView.hide_duration

-- 覆盖函数
FadeWindow.OnInitialize = FadeView.OnInitialize
FadeWindow.Show = FadeView.Show
FadeWindow.Hide = FadeView.Hide
FadeWindow.Destroy = FadeView.Destroy

FadeWindow.SuperOnInitialize = Window.OnInitialize
FadeWindow.SuperDestroy = Window.Destroy


--
return FadeWindow
