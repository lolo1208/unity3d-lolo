--
-- 窗口模块
-- 2017/11/20
-- Author LOLO
--

---@class Window : Module
---@field New fun():Window
---
---@field _closeBtn UnityEngine.GameObject @ 关闭按钮
local Window = class("Window", Module)


function Window:Ctor(prefab, parent)

end


function Window:SetCloseBtn(closeBtn)
    self._closeBtn = closeBtn
end


return Window