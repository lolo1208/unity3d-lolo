--
-- 基础视图对象
-- 可包含一个对应的 GameObject，并对其进行扩展和封装
-- 2017/11/7
-- Author LOLO
--

local error = error
local format = string.format

---@class View : EventDispatcher
---@field New fun(prefab:UnityEngine.GameObject | string, parent:string | UnityEngine.Transform, groupName:string, isAsync:boolean):View
---
---@field gameObject UnityEngine.GameObject
---@field visibled boolean
---
---@field _initialized boolean @ 是否已经初始化完成了
local View = class("View", EventDispatcher)

--- 异步资源加载完成时，初始化
local function InitializeAsync(view, go)
    view.gameObject = go
    view:OnInitialize()
end

--- 构造函数
--- 参数详情可参考 Instantiate() 和 InstantiateAsync() 函数使用范例
--- 如果不使用 prefab 来创建 gameObject，或该 view 没有对应的 gameObject，请手动调用 OnInitialize() 函数
---@param optional prefab UnityEngine.GameObject | string @ 预设对象 或 预设路径
---@param optional parent string | UnityEngine.Transform @ 图层名称 或 父节点(Transform)
---@param optional groupName string @ 资源组名称。参数 prefab 为预设路径时，才需要传入该值
---@param optional isAsync boolean @ 是否异步加载资源
function View:Ctor(prefab, parent, groupName, isAsync)
    View.super.Ctor(self)

    self._initialized = false
    self.visibled = false
    if prefab == nil then
        return -- 无需在该构造函数初始化
    end

    if isAsync then
        InstantiateAsync(prefab, groupName, handler(InitializeAsync, self), parent)
    else
        self.gameObject = Instantiate(prefab, parent, groupName)
        self:OnInitialize()
    end
end

--- 初始化时（已创建 prefab 实例），并设置 self.gameObject
--- 注意：该函数只能被调用一次，子类可以在该函数内做一些初始化的工作。子类覆盖该函数时，记得调用 Class.super.OnInitialize(self)
function View:OnInitialize()
    if self._initialized then
        error(format(Constants.E2004, self.__classname))
    end
    self._initialized = true

    local showed = true
    if self.gameObject ~= nil then
        showed = self.gameObject.activeSelf
    end
    if showed then
        self.visibled = showed
        self:OnShow()
    end
end


-- visibility

--- 设置是否可见
---@param self View
---@param value boolean
local function SetVisibled(self, value)
    if not self._initialized then
        error(format(Constants.E2005, self.__classname))
    end

    self.visibled = value
    local go = self.gameObject
    if isnull(go) then
        self.gameObject = nil
    else
        go:SetActive(value)
    end

    if value then
        self:OnShow()
    else
        self:OnHide()
    end
end

--- 显示 gameObject
function View:Show()
    if not self.visibled then
        SetVisibled(self, true)
    end
end

--- 隐藏 gameObject
function View:Hide()
    if self.visibled then
        SetVisibled(self, false)
    end
end

--- 显示／隐藏 gameObject
function View:ToggleVisibility()
    if self.visibled then
        SetVisibled(self, false)
    else
        SetVisibled(self, true)
    end
end

--- 显示时
function View:OnShow()
end

--- 隐藏时
function View:OnHide()
end

--- 监听或取消监听 self.gameObject 销毁事件。
--- 推荐在 OnInitialize() 中调用该方法。
--- 注意：不要在调用该方法后，立即调用 Destroy(self.gameObject) 这样可能会收到不到事件。
---@param optional enabled boolean @ 默认：true，监听 self.gameObject 销毁事件。false：取消监听
function View:EnableDestroyListener(enabled)
    enabled = enabled == nil and true or false

    local go = self.gameObject
    if isnull(go) then
        error(format(Constants.E2006, self.__classname))
    end

    if enabled then
        AddEventListener(go, DestroyEvent.DESTROY, self.OnDestroy, self)
    else
        RemoveEventListener(go, DestroyEvent.DESTROY, self.OnDestroy, self)
    end
end

--- self.gameObject 被销毁时
--- 请通过 self:EnableDestroyListener() 来设置监听
function View:OnDestroy()
end

--- 销毁界面对应的 gameObject
---@param optional dispatchEvent boolean @ 是否抛出 DestroyEvent.DESTROY 事件，默认：nil(false)，不抛出事件
---@param optional delay number @ 延时删除（秒）。默认：nil，表示立即销毁
function View:Destroy(dispatchEvent, delay)
    local go = self.gameObject
    if isnull(go) then
        return
    end

    if dispatchEvent then
        AddEventListener(go, DestroyEvent.DESTROY, self.OnDestroy, self)
    end

    Destroy(go, delay)
end

return View