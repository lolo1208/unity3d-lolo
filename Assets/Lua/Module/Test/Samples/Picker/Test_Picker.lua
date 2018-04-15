--
-- Picker 组件测试范例
-- 2018/4/2
-- Author LOLO
--

---@class Test.Samples.Picker.Test_Picker : View
---@field New fun():Test.Samples.Picker.Test_Picker
---
---@field timeText UnityEngine.UI.Text
---@field hPicker Picker
---@field mPicker Picker
---
local Test_Picker = class("Test.Samples.Picker.Test_Picker", View)

function Test_Picker:Ctor(...)
    Test_Picker.super.Ctor(self, ...)
end

function Test_Picker:OnInitialize()
    Test_Picker.super.OnInitialize(self)

    local transform = self.gameObject.transform



    -- 时间 Picker
    local timeTra = transform:Find("time")
    self.timeText = GetComponent.Text(timeTra:Find("timeText"))

    -- 小时
    self.hPicker = Picker.New(
            timeTra:Find("hPicker").gameObject,
            require("Module.Test.Samples.Picker.Test_TimePickerItem")
    )
    local hData = MapList.New()
    for i = 0, 23 do
        hData:Add(i < 10 and "0" .. i or i)
    end
    self.hPicker:AddEventListener(ListEvent.ITEM_SELECTED, self.TimePicker_Selected, self)
    self.hPicker:SetData(hData)

    -- 分钟
    self.mPicker = Picker.New(
            timeTra:Find("mPicker").gameObject,
            require("Module.Test.Samples.Picker.Test_TimePickerItem")
    )
    local mData = MapList.New()
    for i = 0, 59 do
        mData:Add(i < 10 and "0" .. i or i)
    end
    self.mPicker:AddEventListener(ListEvent.ITEM_SELECTED, self.TimePicker_Selected, self)
    self.mPicker:SetData(mData)

    self.hPicker:SelectItemByIndex(math.ceil(math.random() * 24))
    self.mPicker:SelectItemByIndex(math.ceil(math.random() * 60))



    -- 卡牌 Picker
    local cardTra = transform:Find("card")

    -- 垂直
    local vPicker = Picker.New(
            cardTra:Find("vPicker").gameObject,
            require("Module.Test.Samples.Picker.Test_CardPickerItem")
    )
    local data = MapList.New()
    for i = 1, 999 do
        data:Add(i)
    end
    vPicker:SetData(data)

    -- 水平
    local hPicker = Picker.New(
            cardTra:Find("hPicker").gameObject,
            require("Module.Test.Samples.Picker.Test_CardPickerItem")
    )
    data = MapList.New()
    for i = 1, 30 do
        data:Add(i)
    end
    hPicker:SetData(data)

    vPicker:SelectItemByIndex(math.ceil(math.random() * 799 + 99))
    hPicker:SelectItemByIndex(math.ceil(math.random() * 19 + 9))
end



--
---@param event ListEvent
function Test_Picker:TimePicker_Selected(event)
    local h = self.hPicker:GetSelectedItemData()
    local m = self.mPicker:GetSelectedItemData()
    if h ~= nil and m ~= nil then
        self.timeText.text = h .. ":" .. m
    end
end



--

return Test_Picker