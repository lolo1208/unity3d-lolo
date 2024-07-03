--
-- 统计界面
-- 2018/2/26
-- Author LOLO
--

local min = math.min
local floor = math.floor
local format = string.format

local FpsSampler = require("Utils.Optimize.FpsSampler")


--
---@class Stats
local Stats = {}
--- 网络延时（毫秒）
Stats.netDelay = nil

local _go ---@type UnityEngine.GameObject @ 创建的 GameObject（值为 nil 表示还未显示）
local _text ---@type UnityEngine.UI.Text
local strFormat1 = "%s FPS,   %s ms"
local strFormat2 = "%s FPS"


--
local function TimerHandler()
    local fps = min(floor(FpsSampler.GetFpsAve() + 0.5), 60)
    local netDelay = Stats.netDelay
    _text.text = format(netDelay ~= nil and strFormat1 or strFormat2, fps, netDelay)
end

local _timer = Timer.New(1, NewHandler(TimerHandler))



--
--- 显示
function Stats.Show()
    if _go ~= nil then
        return
    end

    _go = CreateGameObject("Stats", Constants.LAYER_TOP)
    Stage.AddDontDestroy(_go)
    _text = AddOrGetComponent(_go, UnityEngine.UI.Text)
    _text.raycastTarget = false
    AddOrGetComponent(_go, UnityEngine.UI.Shadow)
    AddOrGetComponent(_go, ShibaInu.SafeAreaLayout)

    _text.font = UnityEngine.Font.CreateDynamicFontFromOSFont("Arial", 16)
    _text.fontSize = 16

    local rt = GetComponent.RectTransform(_go)
    rt.anchorMin = Vector2.up
    rt.anchorMax = Vector2.one
    rt.sizeDelta = Vector2.New(-20, 20)
    rt.anchoredPosition = Vector2.New(0, -20)

    _timer:Start()
    FpsSampler.Start()
end

--- 隐藏
function Stats.Hide()
    if _go == nil then
        return
    end

    Destroy(_go)
    _go = nil
    _text = nil

    _timer:Stop()
    FpsSampler.Stop()
end

--- 显示或隐藏
function Stats.ShowOrHide()
    if _go == nil then
        Stats.Hide()
    else
        Stats.Show()
    end
end



--
--- 获取 Stats 使用的 GameObject
---@return UnityEngine.GameObject
function Stats.GetGameObject()
    return _go
end

--- 获取 Stats 使用的 Text
---@return UnityEngine.UI.Text
function Stats.GetGameObject()
    return _text
end



--
return Stats
