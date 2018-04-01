--
-- 资源加载相关事件
-- 2017/11/09
-- Author LOLO
--

---@class LoadResEvent : Event
---@field assetPath string @ 当前事件对应的资源路径
---@field assetData UnityEngine.Object @ 当前事件对应的资源数据
local LoadResEvent = class("LoadResEvent", Event)


function LoadResEvent:Ctor(type, data)
    LoadResEvent.super.Ctor(self, type, data)
end




--=------------------------------[ static ]------------------------------=--

--- 开始加载某个资源。该事件只会在 Res(ShibaInu.ResManager) 上抛出
LoadResEvent.START = "LoadResEvent_Start"

--- 加载某个资源完成。该事件只会在 Res(ShibaInu.ResManager) 上抛出
LoadResEvent.COMPLETE = "LoadResEvent_Complete"

--- 加载所有资源完成。该事件只会在 Res(ShibaInu.ResManager) 上抛出
LoadResEvent.ALL_COMPLETE = "LoadResEvent_All_Complete"



local event = LoadResEvent.New()

--- 抛出加载相关事件，由 ABLoader.cs / ResManager.cs 调用
---@param type string
---@param path string
---@param data UnityEngine.Object
function LoadResEvent.DispatchEvent(type, path, data)
    event.type = type
    event.assetPath = path
    event.assetData = data
    trycall(DispatchEvent, nil, Res, event, false, false)
end


--=----------------------------------------------------------------------=--



return LoadResEvent