--
-- 全局变量定义
-- 2017/10/12
-- Author LOLO
--

local require = require
local setmetatable = setmetatable

EventDispatcher = require("Events.EventDispatcher")



--[ C# Class ]--

---@type ShibaInu.ResManager
Res = setmetatable({ _ed = EventDispatcher.New() }, { __index = ShibaInu.ResManager, __newindex = ShibaInu.ResManager })
---@type ShibaInu.AudioManager
Audio = setmetatable({ _ed = EventDispatcher.New() }, { __index = ShibaInu.AudioManager, __newindex = ShibaInu.AudioManager })
---@type ShibaInu.NetHelper
NetHelper = setmetatable({ _ed = EventDispatcher.New() }, { __index = ShibaInu.NetHelper, __newindex = ShibaInu.NetHelper })
---@type App.LuaHelper
LuaHelper = setmetatable({}, { __index = App.LuaHelper, __newindex = App.LuaHelper })
--Stage = ShibaInu.Stage -- 已整合进 Stage.lua
--SceneManager = ShibaInu.SceneManager -- 已整合进 SceneManager.lua
--Logger = ShibaInu.Logger -- 已整合进 Logger.lua


--[ UnityEngine ]--

GameObject = UnityEngine.GameObject
Transform = UnityEngine.Transform
Camera = UnityEngine.Camera
Screen = UnityEngine.Screen
Time = UnityEngine.Time
Application = UnityEngine.Application
Input = UnityEngine.Input
KeyCode = UnityEngine.KeyCode
PlayerPrefs = UnityEngine.PlayerPrefs
Shader = UnityEngine.Shader
Material = UnityEngine.Material



--[ DOTween ]--

DOTween = DG.Tweening.DOTween ---@type DG.Tweening.DOTween
DOTween_Enum = {
    ---@type DG.Tweening.AutoPlay
    AutoPlay = DG.Tweening.AutoPlay,
    ---@type DG.Tweening.AxisConstraint
    AxisConstraint = DG.Tweening.AxisConstraint,
    ---@type DG.Tweening.Ease
    Ease = DG.Tweening.Ease,
    ---@type DG.Tweening.LogBehaviour
    LogBehaviour = DG.Tweening.LogBehaviour,
    ---@type DG.Tweening.LoopType
    LoopType = DG.Tweening.LoopType,
    ---@type DG.Tweening.PathMode
    PathMode = DG.Tweening.PathMode,
    ---@type DG.Tweening.PathType
    PathType = DG.Tweening.PathType,
    ---@type DG.Tweening.RotateMode
    RotateMode = DG.Tweening.RotateMode,
    ---@type DG.Tweening.ScrambleMode
    ScrambleMode = DG.Tweening.ScrambleMode,
    ---@type DG.Tweening.TweenType
    TweenType = DG.Tweening.TweenType,
    ---@type DG.Tweening.UpdateType
    UpdateType = DG.Tweening.UpdateType,
}
DOTweenParams = DG.Tweening.TweenParams ---@type DG.Tweening.TweenParams
DOTween.defaultEaseType = DOTween_Enum.Ease.Linear



--[ Variables ]--

isJIT = jit ~= nil -- 是否在 Lua JIT 环境中
isDebug = LuaHelper.IsDebug() -- 是否在编辑器中运行，并且在开发模式下（非 AB 模式）
isPlaying = Application.isPlaying
isEditor = Application.isEditor
isWindowEditor = Application.platform == UnityEngine.RuntimePlatform.WindowsEditor
isMacEditor = isEditor and not isWindowEditor
isMobile = Application.isMobilePlatform
isAndroid = Application.platform == UnityEngine.RuntimePlatform.Android
isIOS = isMobile and not isAndroid



--[ Lua Class ]--

Constants = require("Core.Constants")
Event = require("Events.Event")
ResEvent = require("Events.ResEvent")
SceneEvent = require("Events.SceneEvent")
DestroyEvent = require("Events.DestroyEvent")
AvailabilityEvent = require("Events.AvailabilityEvent")
VisibilityEvent = require("Events.VisibilityEvent")
PointerEvent = require("Events.PointerEvent")
DragDropEvent = require("Events.DragDropEvent")
TriggerEvent = require("Events.TriggerEvent")
TouchEvent = require("Events.TouchEvent")
DataEvent = require("Events.DataEvent")
ListEvent = require("Events.ListEvent")
PageEvent = require("Events.PageEvent")
NetEvent = require("Events.NetEvent")
HttpEvent = require("Events.HttpEvent")
SocketEvent = require("Events.SocketEvent")
AnimationEvent = require("Events.AnimationEvent")
NativeEvent = require("Events.NativeEvent")

MapList = require("Data.MapList")
LinkedList = require("Data.LinkedList")
RemainTime = require("Data.RemainTime")
Countdown = require("Utils.Countdown")
Random = require("Utils.Random")

JSON = require("Utils.JSON")
Logger = require("Utils.Logging.Logger")
Validator = require("Utils.Validator")
TimeUtil = require("Utils.TimeUtil")
ObjectUtil = require("Utils.ObjectUtil")
StringUtil = require("Utils.StringUtil")
MathUtil = require("Utils.MathUtil")
Fixed3 = require("Utils.Fixed3")
Handler = require("Utils.Handler")
Timer = require("Utils.Timer")
PrefabPool = require("Utils.Optimize.PrefabPool")

HttpRequest = require("Net.HttpRequest")
HttpDownload = require("Net.HttpDownload")
HttpUpload = require("Net.HttpUpload")
TcpSocket = require("Net.TcpSocket")
UdpSocket = require("Net.UdpSocket")

Stage = require("Core.Stage")
SceneManager = require("Core.SceneManager")
FullScreenViewManager = require("Core.FullScreenViewManager")
View = require("Views.View")
Module = require("Views.Module")
Scene = require("Views.Scene")
Window = require("Views.Window")

Picker = require("Components.Picker")
BaseList = require("Components.BaseList")
ScrollList = require("Components.ScrollList")
Waterfall = require("Components.Waterfall")
PageList = require("Components.PageList")
ViewPager = require("Components.ViewPager")
ItemRenderer = require("Components.ItemRenderer")
Animation = require("Components.Animation")
GpuAnimation = require("Components.GpuAnimation")
FrameAnimation = require("Components.FrameAnimation")
TabNavigator = require("Components.TabNavigator")
ToggleSwitch = require("Components.ToggleSwitch")
NumberText = require("Components.NumberText")



--
---@class ShibaInu.VersionInfo
---@field CoreVersion string @ C# 程序版本号（手动维护）
---@field FullVersion string @ 完整版本号（自动获取）
---@field ResVersion string @ 资源版本号（自动获取）
---@field BuildNumber string @ 打包编号（自动获取）
---@field PackID string @ 打包唯一标识符（自动获取）
VersionInfo = JSON.Parse(LuaHelper.GetVersionInfo())

