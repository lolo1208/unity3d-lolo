--
-- 统计界面
-- 2018/2/26
-- Author LOLO
--

local min = math.min
local floor = math.floor

local FpsSampler = require("Utils.Optimize.FpsSampler")

---@class Stats
local Stats = {}

Stats.netDelay = 0 --- 网络延时（毫秒）

local _go ---@type UnityEngine.GameObject @ 创建的 GameObject（值为 nil 表示还未显示）
local _text ---@type UnityEngine.UI.Text

--

local function TimerHandler()
    local fps = min(floor(FpsSampler.GetFpsAve() + 0.5), 60)
    _text.text = fps .. " FPS,   " .. Stats.netDelay .. " ms"
end

local _timer = Timer.New(1, Handler.New(TimerHandler))

--


--- 显示
function Stats.Show()
    if _go ~= nil then
        return
    end

    _go = CreateGameObject("Stats", Constants.LAYER_TOP)
    _text = AddOrGetComponent(_go, UnityEngine.UI.Text)
    _text.raycastTarget = false

    local Font = UnityEngine.Font
    _text.font = Font.CreateDynamicFontFromOSFont("Arial", 16)
    _text.fontSize = 16

    local rt = GetComponent.RectTransform(_go)
    rt.anchorMin = Vector2.zero
    rt.anchorMax = Vector2.one
    rt.sizeDelta = Vector2.zero
    rt.localPosition = Vector3.New(10, -10, 0)

    _timer:Start()
    FpsSampler.Start()
end

--

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

--

--- 显示或隐藏
function Stats.ShowOrHide()
    if _go == nil then
        Stats.Hide()
    else
        Stats.Show()
    end
end



--

return Stats