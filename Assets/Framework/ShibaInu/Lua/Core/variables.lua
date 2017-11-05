--
-- 全局变量定义
-- 2017/10/12
-- Author LOLO
--

local require = require


--=------------------------------[ C# Class ]------------------------------=--

---@class LuaHelper
---@field GetEventDispatcher fun(go:UnityEngine.GameObject):EventDispatcher @ 获取 gameObject 对应的 EventDispatcher
LuaHelper = ShibaInu.LuaHelper

RES = ShibaInu.ResManager

--=------------------------------------------------------------------------=--


---@type boolean @ 是否在 LuaJIT 环境中
isJIT = jit ~= nil


GameObject = UnityEngine.GameObject
PlayerPrefs = UnityEngine.PlayerPrefs


Event = require("Events.Event")
EventDispatcher = require("Events.EventDispatcher")

JSON = require("Utils.JSON")
Logger = require("Utils.Logging.Logger")
TimeUtil = require("Utils.TimeUtil")
ObjectUtil = require("Utils.ObjectUtil")
Handler = require("Utils.Handler")
Timer = require("Utils.Timer")


---@type Stage
stage = require("Core.Stage").New()
stage._loopHandler = stage._loopHandler -- 该函数供C#调用


