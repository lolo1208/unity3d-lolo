--
-- 窗口模块
-- 2017/11/20
-- Author LOLO
--

---@class Window : Module
---
---@field moduleName string @ 见构造函数参数
local Window = class("Window", Module)


--- 构造函数
--- 参数详情可参考 Instantiate() 和 InstantiateAsync() 函数使用范例
---@param moduleName string @ 模块名称（windowName）
---@param prefab UnityEngine.GameObject | string @ 预设对象 或 预设路径
---@param optional isAsync boolean @ 是否异步加载，默认：false
---@param optional parent string | UnityEngine.Transform @ 图层名称 或 父节点(Transform)。默认：nil，表示在 Constants.LAYER_WINDOW 层显示
function Window:Ctor(moduleName, prefab, isAsync, parent)
    self.moduleName = moduleName
    Window.super.Ctor(self, prefab, parent or Constants.LAYER_WINDOW, moduleName, isAsync)
end


---@see View#OnInitialize
function Window:OnInitialize()
    Window.super.OnInitialize(self)

    local closeBtn = self.gameObject.transform:Find("closeBtn")
    if closeBtn ~= nil then
        AddEventListener(closeBtn.gameObject, PointerEvent.CLICK, self.Close, self)
    end
end


---@see View#Hide
function Window:Hide()
    self:Close() -- Window.super.Hide(self) 在 Stage.CloseWindow() 中调用
end


--- 关闭窗口
--- 也可作为关闭按钮的点击函数，例：AddEventListener(closeBtn.gameObject, PointerEvent.CLICK, self.Close, self)
function Window:Close()
    Stage.CloseWindow(self)
end



return Window