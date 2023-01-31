--
-- Waterfall item
-- 2018/4/2
-- Author LOLO
--

---@class Test.Samples.Waterfall.Test_WaterfallItem : ItemRenderer
---@field New fun():Test.Samples.Waterfall.Test_WaterfallItem
---@field protected _list Waterfall
---
---@field indexText UnityEngine.UI.Text
---@field vState1 UnityEngine.GameObject
---@field vState1Border UnityEngine.GameObject
---@field vState2 UnityEngine.GameObject
---@field vState2Border UnityEngine.GameObject
---@field vState3 UnityEngine.GameObject
---@field vState3Border UnityEngine.GameObject
---@field vState4 UnityEngine.GameObject
---@field vState4Border UnityEngine.GameObject
---
---@field hState UnityEngine.GameObject
---@field hStateTra UnityEngine.RectTransform
---@field hStateText UnityEngine.UI.Text
---@field hStateBorder UnityEngine.GameObject
---
---@field curState UnityEngine.GameObject
---@field curBorder UnityEngine.GameObject
---
local Test_WaterfallItem = class("Test.Samples.Waterfall.Test_WaterfallItem", ItemRenderer)


--
function Test_WaterfallItem:OnInitialize()
    Test_WaterfallItem.super.OnInitialize(self)

    local transform = self.transform
    self.indexText = GetComponent.Text(transform:Find("IndexText"))
    local vState1 = transform:Find("VState1")
    local vState2 = transform:Find("VState2")
    local vState3 = transform:Find("VState3")
    local vState4 = transform:Find("VState4")
    self.vState1 = vState1.gameObject
    self.vState2 = vState2.gameObject
    self.vState3 = vState3.gameObject
    self.vState4 = vState4.gameObject
    self.vState1Border = vState1:Find("Border").gameObject
    self.vState2Border = vState2:Find("Border").gameObject
    self.vState3Border = vState3:Find("Border").gameObject
    self.vState4Border = vState4:Find("Border").gameObject

    self.hStateTra = transform:Find("HState")
    self.hState = self.hStateTra.gameObject
    self.hStateBorder = self.hStateTra:Find("Border").gameObject
    self.hStateText = GetComponent.Text(self.hStateTra:Find("Text"))

    self.vState1:SetActive(false)
    self.vState2:SetActive(false)
    self.vState3:SetActive(false)
    self.vState4:SetActive(false)
    self.hState:SetActive(false)
    self.vState1Border:SetActive(false)
    self.vState2Border:SetActive(false)
    self.vState3Border:SetActive(false)
    self.vState4Border:SetActive(false)
    self.hStateBorder:SetActive(false)
end


--
function Test_WaterfallItem:Update(data, index)
    Test_WaterfallItem.super.Update(self, data, index)

    self.indexText.text = index

    if self.curState then
        self.curState:SetActive(false)
    end

    if self._list._isVertical then
        local stateNum = data
        self.curState = self["vState" .. stateNum]
        self.curBorder = self["vState" .. stateNum .. "Border"]
    else
        self.hStateTra.sizeDelta = Vector2.New(data, 150)
        self.hStateText.text = "W:" .. data
        self.curState = self.hState
        self.curBorder = self.hStateBorder
    end

    self:CalcSizeAndOffset(self.curState.transform)
    self.curState:SetActive(true)
end


--
function Test_WaterfallItem:SetSelected(value)
    Test_WaterfallItem.super.SetSelected(self, value)

    if self.curBorder.activeSelf ~= value then
        self.curBorder:SetActive(value)
    end
end


--
return Test_WaterfallItem

