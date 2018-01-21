--
-- 与代码无关的IDE提示等定义
-- 该文件不会被require，不会被打包发布
-- 2017/9/27
-- Author LOLO
--


--=------------------------------[ C# Class ]------------------------------=--

ShibaInu = ShibaInu
ShibaInu.Stage = ShibaInu.Stage ---@type ShibaInu.Stage
ShibaInu.ResManager = ShibaInu.ResManager ---@type ShibaInu.ResManager
ShibaInu.LuaHelper = ShibaInu.LuaHelper ---@type ShibaInu.LuaHelper
ShibaInu.HttpRequest = ShibaInu.HttpRequest ---@type ShibaInu.HttpRequest
ShibaInu.BaseList = ShibaInu.BaseList ---@type ShibaInu.BaseList
ShibaInu.ScrollList = ShibaInu.ScrollList ---@type ShibaInu.ScrollList



---@class ShibaInu.Stage
---@field bgLayer UnityEngine.Transform @ 背景层
---@field uiLayer UnityEngine.Transform @ UI层
---@field windowLayer UnityEngine.Transform @ 窗口层
---@field uiTopLayer UnityEngine.Transform @ 顶级UI层
---@field alertLayer UnityEngine.Transform @ 提示层
---@field guideLayer UnityEngine.Transform @ 引导层
---@field topLayer UnityEngine.Transform @ 顶级层
---
---@field Clean fun():void @ 清空场景
---@field AddDontDestroy fun(go:UnityEngine.GameObject):void @ 添加一个在清除场景时，不需被销毁的 GameObject
---@field RemoveDontDestroy fun(go:UnityEngine.GameObject):void @ 移除一个在清除场景时，不需被销毁的 GameObject
---@field LoadScene fun(sceneName:string):void @ 同步加载场景（sceneName : 场景名称）
---@field LoadSceneAsync fun(sceneName:string):void @ 异步加载场景（sceneName : 场景名称）
---@field GetProgress fun():number @ 获取当前异步加载进度 0~1



---@class ShibaInu.ResManager : EventDispatcher
---@field LoadAsset fun(path:string, groupName:string):UnityEngine.Object @ 通过路径获取一个资源（同步）
---@field LoadAssetAsync fun(path:string, groupName:string):void @ 异步加载资源
---@field GetProgress fun():number @ 获取当前异步加载总进度 0~1
---@field Unload fun(groupName:string):void @ 卸载指定资源组所包含的所有资源



---@class ShibaInu.LuaHelper
---@field AddDestroyEvent fun(go:UnityEngine.GameObject, ed:EventDispatcher):void @ 在指定的 gameObject 上添加 DestroyEventDispatcher 脚本。当 gameObject 销毁时，在 lua 层（gameObject上）派发 DestroyEvent.DESTROY 事件
---@field AddPointerEvent fun(go:UnityEngine.GameObject, ed:EventDispatcher):void @ 在指定的 gameObject 上添加 PointerEventDispatcher 脚本。当 gameObject 与鼠标指针（touch）交互时，派发相关事件
---@field CreateGameObject fun(name:string, parent:UnityEngine.Transform, notUI:boolean):UnityEngine.GameObject @ 创建并返回一个空 GameObject
---@field SetParent fun(target:UnityEngine.Transform, parent:UnityEngine.Transform):void @ 设置 target 的父节点为 parent。
---@field SendHttpRequest fun(url:string, callbak:fun(statusCode:number, content:string), postData:string):ShibaInu.HttpRequest



---@class ShibaInu.HttpRequest
---@field New fun():ShibaInu.HttpRequest
---
---@field url string
---@field method string
---@field timeout number
---@field postData string
---@field requeting boolean
---
---@field AppedPostData fun(key:string, value:string):void
---@field CleanPostData fun():void
---@field SetProxy fun(host:string, port:number):void
---@field SetLuaCallback fun(callbak:fun(statusCode:number, content:string)):void
---@field Send fun():void
---@field Abort fun():void



---@class ShibaInu.BaseList
---@field luaTarget BaseList
---@field content UnityEngine.RectTransform
---@field itemPrefab UnityEngine.GameObject
---@field rowCount number
---@field columnCount number
---@field horizontalGap number
---@field verticalGap number
---
---@field SyncPropertys fun(itemPrefab:UnityEngine.GameObject, rowCount:number, columnCount:number, horizontalGap:number, verticalGap:number):void



---@class ShibaInu.ScrollList : ShibaInu.BaseList
---@field isVertical boolean @ 是否为垂直方向滚动
---@field viewport UnityEngine.RectTransform @ 显示区域容器
---@field scrollRect UnityEngine.UI.ScrollRect @ 对应的 ScrollRect 组件
---
---@field SetContentSize fun(width:number, height:number):void @ 设置滚动内容宽高
---@field SetViewportSize fun(width:number, height:number):void @ 设置显示区域宽高
---@field ResetContentPosition fun():void @ 在 viewportSize 和 isVertical 更改时，需要根据 isVertical 重新设置内容的位置
---
---@field SyncPropertys fun(itemPrefab:UnityEngine.GameObject, rowCount:number, columnCount:number, horizontalGap:number, verticalGap:number, isVertical:boolean, viewportWidth:number, viewportHeight:number):void

