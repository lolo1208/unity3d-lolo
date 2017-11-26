--
-- 全局变量定义
-- 2017/10/12
-- Author LOLO
--

local require = require


EventDispatcher = require("Events.EventDispatcher")


-- C# Class
Res = setmetatable({ _ed = EventDispatcher.New() }, { __index = ShibaInu.ResManager }) ---@type ShibaInu.ResManager
LuaHelper = ShibaInu.LuaHelper
--Stage = ShibaInu.Stage -- 已整合进 Stage.lua


-- UnityEngine
GameObject = UnityEngine.GameObject
Transform = UnityEngine.Transform
PlayerPrefs = UnityEngine.PlayerPrefs



---@type boolean @ 是否在 LuaJIT 环境中
_G.isJIT = jit ~= nil


Constants = require("Core.Constants")
Event = require("Events.Event")
LoadResEvent = require("Events.LoadResEvent")
LoadSceneEvent = require("Events.LoadSceneEvent")
DestroyEvent = require("Events.DestroyEvent")
PointerEvent = require("Events.PointerEvent")

JSON = require("Utils.JSON")
Logger = require("Utils.Logging.Logger")
TimeUtil = require("Utils.TimeUtil")
ObjectUtil = require("Utils.ObjectUtil")
Handler = require("Utils.Handler")
Timer = require("Utils.Timer")

Stage = require("Core.Stage")
View = require("View.View")
Module = require("View.Module")
Scene = require("View.Scene")


print("  isJIT : " .. tostring(isJIT))
