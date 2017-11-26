--
-- 基础视图对象
-- 可包含一个对应的 GameObject，并对其进行扩展和封装
-- 2017/11/7
-- Author LOLO
--

local error = error
local format = string.format


---@class View
---@field New fun(prefab:UnityEngine.GameObject | string, parent:string | UnityEngine.Transform, groupName:string, isAsync:boolean):View
---
---@field gameObject UnityEngine.GameObject
---@field visibled boolean
---
---@field _initialized boolean @ 是否已经初始化完成了
local View = class("View")



--- 异步资源加载完成时，初始化
local function InitializeAsync(self, go)
    self.gameObject = go
    self:OnInitialize()
end


--- 构造函数
--- 参数详情可参考 Instantiate() 和 InstantiateAsync() 函数使用范例
--- 如果不使用 prefab 来创建 gameObject，或该 view 没有对应的 gameObject，请手动调用 OnInitialize() 函数
---@param optional prefab UnityEngine.GameObject | string @ 预设对象 或 预设路径
---@param optional parent string | UnityEngine.Transform @ 图层名称 或 父节点(Transform)
---@param optional groupName string @ 资源组名称。参数 prefab 为预设路径时，才需要传入该值
---@param optional isAsync boolean @ 是否异步加载资源
function View:Ctor(prefab, parent, groupName, isAsync)
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
--- 注意：该函数只能被调用一次，子类可以在该函数内做一些初始化的工作。子类覆盖该函数时，记得调用 self.super:OnInitialize()
function View:OnInitialize()
    if self._initialized then
        error(format(Constants.E1004, self.__classname))
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
        error(format(Constants.E1005, self.__classname))
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





return View