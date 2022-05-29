--
-- 在项目中扩展框架底层（全局）相关功能
-- 2017/10/16
-- Author LOLO
--

local _typeof_class = typeof



--[ functions ]--

-- UnityEngine.*

--- 获取 gameObject 下的 UnityEngine.Animation 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.Animation
function GetComponent.Animation(go)
    return go:GetComponent(_typeof_class(UnityEngine.Animation))
end

--- 获取 gameObject 下的 UnityEngine.Animator 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.Animator
function GetComponent.Animator(go)
    return go:GetComponent(_typeof_class(UnityEngine.Animator))
end

--- 获取 gameObject 下的 UnityEngine.CharacterController 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.CharacterController
function GetComponent.CharacterController(go)
    return go:GetComponent(_typeof_class(UnityEngine.CharacterController))
end

--- 获取 gameObject 下的 UnityEngine.Camera 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.Camera
function GetComponent.Camera(go)
    return go:GetComponent(_typeof_class(UnityEngine.Camera))
end

--- 获取 gameObject 下的 UnityEngine.MeshRenderer 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.MeshRenderer
function GetComponent.MeshRenderer(go)
    return go:GetComponent(_typeof_class(UnityEngine.MeshRenderer))
end

--- 获取 gameObject 下的 UnityEngine.SkinnedMeshRenderer 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.SkinnedMeshRenderer
function GetComponent.SkinnedMeshRenderer(go)
    return go:GetComponent(_typeof_class(UnityEngine.SkinnedMeshRenderer))
end

--- 获取 gameObject 下的 UnityEngine.TextMesh 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.TextMesh
function GetComponent.TextMesh(go)
    return go:GetComponent(_typeof_class(UnityEngine.TextMesh))
end

--- 获取 gameObject 下的 UnityEngine.BoxCollider 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.BoxCollider
function GetComponent.BoxCollider(go)
    return go:GetComponent(_typeof_class(UnityEngine.BoxCollider))
end

--- 获取 gameObject 下的 UnityEngine.ParticleSystem 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.ParticleSystem
function GetComponent.ParticleSystem(go)
    return go:GetComponent(_typeof_class(UnityEngine.ParticleSystem))
end


-- UnityEngine.UI.*

--- 获取 gameObject 下的 UnityEngine.UI.Image 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.UI.Image
function GetComponent.Image(go)
    return go:GetComponent(_typeof_class(UnityEngine.UI.Image))
end

--- 获取 gameObject 下的 UnityEngine.UI.RawImage 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.UI.RawImage
function GetComponent.RawImage(go)
    return go:GetComponent(_typeof_class(UnityEngine.UI.RawImage))
end

--- 获取 gameObject 下的 UnityEngine.UI.Text 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.UI.Text
function GetComponent.Text(go)
    return go:GetComponent(_typeof_class(UnityEngine.UI.Text))
end

--- 获取 gameObject 下的 UnityEngine.UI.InputField 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.UI.InputField
function GetComponent.InputField(go)
    return go:GetComponent(_typeof_class(UnityEngine.UI.InputField))
end

--- 获取 gameObject 下的 UnityEngine.UI.Button 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.UI.Button
function GetComponent.Button(go)
    return go:GetComponent(_typeof_class(UnityEngine.UI.Button))
end

--- 获取 gameObject 下的 UnityEngine.UI.Toggle 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.UI.Toggle
function GetComponent.Toggle(go)
    return go:GetComponent(_typeof_class(UnityEngine.UI.Toggle))
end

--- 获取 gameObject 下的 UnityEngine.UI.ScrollRect 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return UnityEngine.UI.ScrollRect
function GetComponent.ScrollRect(go)
    return go:GetComponent(_typeof_class(UnityEngine.UI.ScrollRect))
end


-- App.*

--- 获取 gameObject 下的 App.ThirdPersonCamera 组件
---@param go UnityEngine.GameObject | UnityEngine.Transform
---@return App.ThirdPersonCamera
function GetComponent.ThirdPersonCamera(go)
    return go:GetComponent(_typeof_class(App.ThirdPersonCamera))
end

--



--[ variables ]--

FadeView = require("Effects.View.FadeView")
FadeWindow = require("Effects.View.FadeWindow")
ScaleView = require("Effects.View.ScaleView")
ScaleWindow = require("Effects.View.ScaleWindow")
MoveView = require("Effects.View.MoveView")
MoveWindow = require("Effects.View.MoveWindow")

Stats = require("UI.Stats")
Profiler = require("Utils.Optimize.Profiler")

--



--[ core ]--

Config = require("Data.Config")

--



--[ project ]--

SceneController = require("Module.Core.Controller.SceneController")

--



--
--- 重启游戏
function Relaunch()
    LuaHelper.Relaunch()
end


--
--- 设备震动反馈
---@param style number @ -可选- 震动方式，见 Constants.VIBRATE_STYLE_ 系列常量。默认：MEDIUM
function DeviceVibrate(style)
    LuaHelper.DeviceVibrate(style or Constants.VIBRATE_STYLE_MEDIUM)
end



--
Stats.Show()


-- 收集报错和异常
Logger.SetUncaughtExceptionHandler(function(type, msg, stackTrace)
    -- print("[UncaughtExceptionHandler]", type, msg, stackTrace)
    -- 在这可以向服务器发送错误收集信息，注意去重！
end)

