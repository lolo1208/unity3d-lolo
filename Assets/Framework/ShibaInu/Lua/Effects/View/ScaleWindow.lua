--
-- 重写 Show() 和 Hide()，在显示和隐藏时加入缩放效果
-- * 效果的实现都是在 ScaleView 中完成的，该类是继承至 Window 的版本
-- 2019/3/30
-- Author LOLO
--


local ScaleView = require("Effects.View.ScaleView")


--
---@see Effects.View.ScaleView
---@class Effects.View.ScaleWindow : Window
---@field New fun(...):Effects.View.ScaleWindow
---
local ScaleWindow = class("Effects.View.ScaleWindow", Window)


-- 效果默认参数
ScaleWindow.show_ease = ScaleView.show_ease
ScaleWindow.show_scale = ScaleView.show_scale
ScaleWindow.show_alpha = ScaleView.show_alpha
ScaleWindow.show_duration = ScaleView.show_duration
ScaleWindow.hide_ease = ScaleView.hide_ease
ScaleWindow.hide_scale = ScaleView.hide_scale
ScaleWindow.hide_alpha = ScaleView.hide_alpha
ScaleWindow.hide_duration = ScaleView.hide_duration

-- 覆盖函数
ScaleWindow.OnInitialize = ScaleView.OnInitialize
ScaleWindow.Show = ScaleView.Show
ScaleWindow.Hide = ScaleView.Hide
ScaleWindow.Destroy = ScaleView.Destroy

ScaleWindow.SuperOnInitialize = Window.OnInitialize
ScaleWindow.SuperDestroy = Window.Destroy


--
return ScaleWindow
