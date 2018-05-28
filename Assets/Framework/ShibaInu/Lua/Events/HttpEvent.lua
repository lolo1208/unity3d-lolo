--
-- HTTP 网络请求相关事件
-- 2017/12/15
-- Author LOLO
--

---@class HttpEvent : Event
---@field New fun():HttpEvent
---
local HttpEvent = class("HttpEvent", Event)

function HttpEvent:Ctor(type, data)
    HttpEvent.super.Ctor(self, type, data)
end



--=------------------------------[ static ]------------------------------=--

--- HTTP 请求结束
HttpEvent.ENDED = "HttpEvent_Ended"

--=----------------------------------------------------------------------=--



return HttpEvent