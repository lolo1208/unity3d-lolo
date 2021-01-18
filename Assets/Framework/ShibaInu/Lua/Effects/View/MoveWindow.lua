--
-- 重写 Show() 和 Hide()，在显示和隐藏时加入移动效果
-- * 效果的实现都是在 MoveView 中完成的，该类是继承至 Window 的版本
-- 2019/3/30
-- Author LOLO
--


local MoveView = require("Effects.View.MoveView")


--
---@see Effects.View.MoveView
---@class Effects.View.MoveWindow : Window
---@field New fun(...):Effects.View.MoveWindow
---
local MoveWindow = class("Effects.View.MoveWindow", Window)


-- 效果默认参数
MoveWindow.show_ease = MoveView.show_ease
MoveWindow.show_position = MoveView.show_position
MoveWindow.show_alpha = MoveView.show_alpha
MoveWindow.show_duration = MoveView.show_duration
MoveWindow.hide_ease = MoveView.hide_ease
MoveWindow.hide_position = MoveView.hide_position
MoveWindow.hide_alpha = MoveView.hide_alpha
MoveWindow.hide_duration = MoveView.hide_duration

-- 覆盖函数
MoveWindow.OnInitialize = MoveView.OnInitialize
MoveWindow.Show = MoveView.Show
MoveWindow.Hide = MoveView.Hide
MoveWindow.Destroy = MoveView.Destroy
MoveWindow.OnDestroy = MoveView.OnDestroy

MoveWindow.SuperOnInitialize = Window.OnInitialize
MoveWindow.SuperDestroy = Window.Destroy
MoveWindow.SuperOnDestroy = Window.OnDestroy


--
return MoveWindow
