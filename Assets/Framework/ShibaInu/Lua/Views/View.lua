--
-- 基础视图对象
-- 可包含一个对应的 GameObject，并对其进行扩展和封装
-- 2017/11/7
-- Author LOLO
--

local error = error
local format = string.format


--
---@class View : EventDispatcher
---@field New fun(prefab:UnityEngine.GameObject | string, parent:string | UnityEngine.Transform, groupName:string, isAsync:boolean):View
---
---@field gameObject UnityEngine.GameObject
---@field transform UnityEngine.Transform | UnityEngine.RectTransform
---@field asyncHandlerRef HandlerRef @ 异步初始化时，创建的回调
---@field initShow boolean @ 初始化时是否直接显示（默认是否显示）。默认值：true
---@field showed boolean @ 是否已经显示。用于初始化显示时做判断
---@field visible boolean @ 当前是否可见
---@field initialized boolean @ 是否已经初始化完成了
---@field destroyed boolean @ 是否已经被销毁
---@field dispatchVisibility boolean @ 在显示或隐藏时，是否需要抛出 VisibilityEvent.SHOWED 和 VisibilityEvent.HIDDEN 事件。默认：false
---@field isFullScreen boolean @ 是否已为全屏界面。值为 true 时，将会在界面显示时关闭场景主相机。请使用 SetIsFullScreen() 设置该值。默认值：false
---@field isCameraBlur boolean @ 是否使用相机模糊模态背景，请使用 SetIsFullScreen() 设置该值。默认值：false
---
local View = class("View", EventDispatcher)
View.initShow = true
View.dispatchVisibility = false
View.isFullScreen = false
View.isCameraBlur = false


--
--- 异步资源加载完成时，初始化
local function InitializeAsync(view, go)
    view.gameObject = go
    view:OnInitialize()
end


--
--- 构造函数
--- 参数详情可参考 Instantiate() 和 InstantiateAsync() 函数使用范例
--- 如果不使用 prefab 来创建 gameObject，或该 view 没有对应的 gameObject，请手动调用 OnInitialize() 函数
---@param prefab UnityEngine.GameObject | string @ -可选- 预设对象 或 预设路径
---@param parent string | UnityEngine.Transform @ -可选- 图层名称 或 父节点(Transform)
---@param groupName string @ -可选- 资源组名称。参数 prefab 为预设路径时，才需要传入该值。默认值为当前场景名称
---@param isAsync boolean @ -可选- 是否异步加载资源。默认：false
function View:Ctor(prefab, parent, groupName, isAsync)
    View.super.Ctor(self)

    self.initialized = false
    self.showed = false
    self.visible = false
    self.destroyed = false

    if prefab == nil then
        return -- 无需在该构造函数初始化
    end

    if isAsync then
        self.asyncHandlerRef = handler(InitializeAsync, self)
        InstantiateAsync(prefab, groupName, self.asyncHandlerRef, parent)
    else
        self.gameObject = Instantiate(prefab, parent, groupName)
        self:OnInitialize()
    end
end


--
--- 初始化时（已创建 prefab 实例），并设置 self.gameObject
--- 注意：该函数只能被调用一次，子类可以在该函数内做一些初始化的工作。子类覆盖该函数时，记得调用 Class.super.OnInitialize(self)
function View:OnInitialize()
    if self.initialized then
        error(format(Constants.E2004, self.__classname))
    end
    self.initialized = true
    self.asyncHandlerRef = nil

    self.visible = self.initShow
    if self.gameObject ~= nil then
        -- 子类有重写 OnDestroy()
        if self.OnDestroy ~= View.OnDestroy then
            -- 当 initShow=false，让 DestroyEventDispatcher.cs 先触发 Awake()，再 go.SetActive(false)
            self:EnableDestroyListener()
        end

        self.transform = self.gameObject.transform
        if self.gameObject.activeSelf ~= self.visible then
            self.gameObject:SetActive(self.visible)
        end
    end

    -- 默认如果可见，需在 LATE_UPDATE 时间中调用 OnShow()，避免 OnShow() 在子类 OnInitialize() 未执行完毕前触发
    if self.visible then
        local doOnShow
        doOnShow = function()
            RemoveEventListener(Stage, Event.LATE_UPDATE, doOnShow)
            if self.visible and not self.showed then
                self.showed = true
                self:OnShow()
            end
        end
        AddEventListener(Stage, Event.LATE_UPDATE, doOnShow, nil, Constants.PRIORITY_HIGH)
    end
end


-- visibility

--- 设置是否可见
---@param value boolean
function View:SetVisible(value)
    if value then
        self:Show()
    else
        self:Hide()
    end
end

--- 可见性有改变
---@param value boolean
function View:VisibilityChanged(value)
    self.showed = value
    self.visible = value
    local go = self.gameObject
    if isnull(go) then
        self.gameObject = nil
    else
        go:SetActive(value)
    end

    if self.initialized and not self.destroyed then
        if value then
            self:OnShow()
        else
            self:OnHide()
        end
    end
end

--- 显示 gameObject
function View:Show()
    if not self.visible then
        self:VisibilityChanged(true)
    end
end

--- 隐藏 gameObject
function View:Hide()
    if self.visible then
        self:VisibilityChanged(false)
    end
end

--- 显示/隐藏 gameObject
function View:ToggleVisibility()
    if self.visible then
        self:Hide()
    else
        self:Show()
    end
end

--- 显示时
function View:OnShow()
    if self.dispatchVisibility or self.isFullScreen then
        self:DispatchEvent(Event.Get(VisibilityEvent, VisibilityEvent.SHOWED))
    end
end

--- 隐藏时
function View:OnHide()
    if self.dispatchVisibility or self.isFullScreen then
        self:DispatchEvent(Event.Get(VisibilityEvent, VisibilityEvent.HIDDEN))
    end
end


--
--- 设置是否为全屏界面
---@param isFullScreen boolean @ 否已为全屏界面。值为 true 时，将会在界面显示时关闭场景主相机
---@param isCameraBlur boolean @ -可选- 是否使用相机模糊模态背景
function View:SetIsFullScreen(isFullScreen, isCameraBlur)
    self.isFullScreen = isFullScreen
    self.isCameraBlur = isCameraBlur == true
    if isFullScreen then
        FullScreenViewManager.RegisterFullScreenView(self)
    else
        FullScreenViewManager.UnregisterFullScreenView(self)
    end
end



--
--- 监听或取消监听 self.gameObject 销毁事件。
--- 推荐在 OnInitialize() 中调用该方法。
--- 注意：不要在调用该方法后，立即调用 Destroy(self.gameObject) 这样可能会收到不到事件。
---@param enabled boolean @ -可选- 默认：true，监听 self.gameObject 销毁事件。false：取消监听
function View:EnableDestroyListener(enabled)
    enabled = enabled == nil and true or enabled

    local go = self.gameObject
    if isnull(go) then
        error(format(Constants.E2006, self.__classname))
    end

    if enabled and not self.isScene then
        AddEventListener(go, DestroyEvent.DESTROY, self.OnDestroy, self)
    else
        RemoveEventListener(go, DestroyEvent.DESTROY, self.OnDestroy, self)
    end
end

--- self.gameObject 被销毁时
--- 子类重写 OnDestroy() 方法，将会自动调用 EnableDestroyListener() 设置监听
function View:OnDestroy()
    self.destroyed = true
    if self.asyncHandlerRef ~= nil then
        CancelHandler(self.asyncHandlerRef)
        self.asyncHandlerRef = nil
    end
end

--- 销毁界面对应的 gameObject
---@param delay number @ -可选- 延时销毁（秒）。默认：nil，表示立即销毁
function View:Destroy(delay)
    Destroy(self.gameObject, delay)
end



--
return View
