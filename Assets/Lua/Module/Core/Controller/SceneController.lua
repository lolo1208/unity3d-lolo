--
-- 场景控制器，用于 管理/切换 项目内的场景
-- 2021/05/10
-- Author LOLO
--

local ProgressView = require("Module.Core.View.ProgressView")

local floor = math.floor


--
---@class Core.SceneController
---
local SceneController = {}



--
--- 更新场景 Loading 进度
local function UpdateLoadingProgress()
    local p = SceneManager.GetProgress()
    local view = ProgressView.GetInstance()
    view.bar.fillAmount = p
    view.text.text = floor(p * 100) .. "%"
    if p == 1 then
        SceneController.HideLoading()
    end
end

--- 显示场景 Loading 界面
function SceneController.ShowLoading()
    AddEventListener(Stage, Event.UPDATE, UpdateLoadingProgress)
    ProgressView.GetInstance():Show()
end

--- 隐藏场景 Loading 界面
function SceneController.HideLoading()
    RemoveEventListener(Stage, Event.UPDATE, UpdateLoadingProgress)
    ProgressView.GetInstance():Hide()
end



--
--- 进入测试场景
function SceneController.EnterTest(...)
    SceneManager.UnloadAllScenes()
    Stage.Clean()
    local TestScene = require("Module.Test.View.TestScene")
    SceneManager.EnterScene(TestScene.SCENE_NAME, TestScene)
end


--
--- 进入地牢场景
function SceneController.EnterDungeon()
    SceneController.ShowLoading()
    SceneManager.UnloadAllScenes()
    Stage.Clean()
    local DungeonScene = require("Module.Dungeon.View.DungeonScene")
    SceneManager.EnterScene(DungeonScene.SCENE_NAME, DungeonScene)
    --SceneManager.LoadScene("Sub1")
    --SceneManager.LoadScene("Sub2")
end



--
return SceneController
