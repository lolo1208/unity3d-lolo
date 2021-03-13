--
-- 资源相关事件
-- 2017/11/09
-- Author LOLO
--

---@class ResEvent : Event
---@field New fun():ResEvent
---
---@field assetPath string @ 当前事件对应的资源路径
---@field assetData UnityEngine.Object @ 当前事件对应的资源数据
local ResEvent = class("ResEvent", Event)



--=------------------------------[ static ]------------------------------=--

--- 开始加载某个资源。该事件只会在 Res 上抛出
ResEvent.LOAD_START = "ResEvent_LoadStart"

--- 加载某个资源完成。该事件只会在 Res 上抛出
ResEvent.LOAD_COMPLETE = "ResEvent_LoadComplete"

--- 加载所有资源完成。该事件只会在 Res 上抛出
ResEvent.LOAD_ALL_COMPLETE = "ResEvent_LoadAllComplete"


--
--- 抛出资源相关事件，由 ResManager.cs / AssetLoader.cs 调用
---@param type string
---@param path string
---@param data UnityEngine.Object
function ResEvent.DispatchEvent(type, path, data)
    ---@type NativeEvent
    local event = ResEvent.Get(ResEvent, type)
    event.assetPath = path
    event.assetData = data
    trycall(DispatchEvent, nil, Res, event)
end

--=----------------------------------------------------------------------=--



--
return ResEvent

