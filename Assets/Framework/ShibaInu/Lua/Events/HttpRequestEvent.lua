--
-- HTTP 网络请求相关事件
-- 2017/12/15
-- Author LOLO
--

---@class HttpRequestEvent : Event
local HttpRequestEvent = class("HttpRequestEvent", Event)

function HttpRequestEvent:Ctor(type, data)
    HttpRequestEvent.super.Ctor(self, type, data)
end



--=------------------------------[ static ]------------------------------=--

--- 请求结束
HttpRequestEvent.ENDED = "HttpRequestEvent_Ended"

--=----------------------------------------------------------------------=--



return HttpRequestEvent