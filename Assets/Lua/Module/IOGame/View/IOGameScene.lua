--
-- IO游戏场景
-- 2017/11/14
-- Author LOLO
--


local IOGameData = require("Module.IOGame.Model.IOGameData") ---@type IOGame.IOGameData

---@class IOGame.IOGameScene : Scene
---@field New fun():IOGame.IOGameScene
---
---@field protected _frame IOGame.FrameController
---@field protected _map IOGame.Map
---@field protected _joystick IOGame.Joystick
---@field protected _btnBar IOGame.BtnBar
---
local IOGameScene = class("IOGame.IOGameScene", Scene)

function IOGameScene:Ctor()
    IOGameScene.super.Ctor(self, IOGameData.NAME, nil, true)

    --Stage.OpenWindow(require("Module.IOGame.View.IOGameWindow"))
end

function IOGameScene:OnInitialize()
    IOGameScene.super.OnInitialize(self)

    IOGameData.scene = self
    IOGameData.camera = GameObject.Find("Main Camera").transform
    IOGameData.playerName = "player" .. math.floor(math.random(90) + 10)

    self._map = require("Module.IOGame.View.Avatar.Map").New()
    IOGameData.map = self._map

    self._joystick = require("Module.IOGame.View.UI.Joystick").New(GameObject.Find("SceneUICanvas/Joystick"))
    self._joystick:Hide()
    IOGameData.joystick = self._joystick

    self._btnBar = require("Module.IOGame.View.UI.BtnBar").New(GameObject.Find("SceneUICanvas/BtnBar"))
    self._btnBar:Hide()
    IOGameData.btnBar = self._btnBar

    self._frame = require("Module.IOGame.Controller.FrameController").New(self._map)
    IOGameData.frame = self._frame

    require("Module.IOGame.View.UI.Login").New(GameObject.Find("SceneUICanvas/Login"))
end


--


function IOGameScene:OnDestroy()
end

return IOGameScene