--
-- 模块基类
-- 2017/11/14
-- Author LOLO
--


---@class Module : View
---@field New fun():Module
---
---@field moduleName string @ 模块名称。请在构造函数内设置该值，该值一般会用来做为资源加载 groupName 使用
local Module = class("Module", View)


function Module:Ctor()
end



return Module