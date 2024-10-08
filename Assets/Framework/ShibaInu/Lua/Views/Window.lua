--
-- 窗口模块
-- 2017/11/20
-- Author LOLO
--


--
---@class Window : Module
---
---@field moduleName string @ 见构造函数参数
local Window = class("Window", Module)


--
--- 构造函数
--- 参数详情可参考 Instantiate() 和 InstantiateAsync() 函数使用范例
---@param moduleName string @ 模块名称（windowName）
---@param prefab UnityEngine.GameObject | string @ 预设对象 或 预设路径
---@param isAsync boolean @ -可选- 是否异步加载，默认：false
---@param parent string | UnityEngine.Transform @ -可选- 图层名称 或 父节点(Transform)。默认：nil，表示在 Constants.LAYER_WINDOW 层显示
function Window:Ctor(moduleName, prefab, isAsync, parent)
    self.moduleName = moduleName
    Window.super.Ctor(self, prefab, parent or Constants.LAYER_WINDOW, moduleName, isAsync)
end


--
---@see View#OnInitialize
function Window:OnInitialize()
    Window.super.OnInitialize(self)

    local closeBtn = self.transform:Find("closeBtn")
    if closeBtn ~= nil then
        AddEventListener(closeBtn.gameObject, PointerEvent.CLICK, self.Close, self)
    end
end


--
---@see View#Hide
function Window:Hide()
    if self.visible then
        self:VisibilityChanged(false)
        Stage.CloseWindow(self)
    end
end


--
--- 关闭窗口
--- 也可作为关闭按钮的点击函数，例：AddEventListener(closeBtn.gameObject, PointerEvent.CLICK, self.Close, self)
function Window:Close()
    self:Hide()
end




--
--- 窗口单例的实例列表
local instances = {}

--
--- [static] 打开窗口（创建单例实例）
---@param closeOthers boolean @ -可选- 是否关闭其他窗口，默认：true
---@vararg any @ -可选- 创建该窗口时，传入构造函数的参数
---@return Window
function Window:Open(closeOthers, ...)
    -- self 值为 WindowClass，而不是 Window 实例
    local wnd = instances[self.__classname]
    if wnd == nil then
        wnd = self.New(...)
        instances[self.__classname] = wnd
    end
    Stage.OpenWindow(wnd, closeOthers)
    return wnd
end

--
--- [static] 获取单例实例
---@return Window
function Window:GetInstance()
    -- self 值为 WindowClass，而不是 Window 实例
    return instances[self.__classname]
end




--
function Window:OnDestroy()
    Window.super.OnDestroy(self)
    instances[self.__classname] = nil
    Stage.CloseWindow(self)
end



--
return Window
