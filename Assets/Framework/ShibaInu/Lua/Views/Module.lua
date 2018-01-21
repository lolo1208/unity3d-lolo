--
-- 模块基类
-- 2017/11/14
-- Author LOLO
--


---@class Module : View
---@field New fun(...):Module
---
---@field moduleName string @ 模块名称。该值还会用来做为资源加载 groupName 使用
local Module = class("Module", View)


function Module:Ctor(...)
    Module.super.Ctor(self, ...)
end




return Module