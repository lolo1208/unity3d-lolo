--
-- 框架中用到的常量
-- 2017/11/7
-- Author LOLO
--


---@class Constants
local Constants = {

    -- 核心资源组名称（不会被销毁）
    ASSET_GROUP_CORE = "core",


    -- 场景图层
    LAYER_SCENE = "sceneLayer", -- 场景层
    LAYER_UI = "uiLayer", -- UI层
    LAYER_WINDOW = "windowLayer", -- 窗口层
    LAYER_UI_TOP = "uiTopLayer", -- 顶级UI层
    LAYER_ALERT = "alertLayer", -- 提示层
    LAYER_GUIDE = "guideLayer", -- 引导层
    LAYER_TOP = "topLayer", -- 顶级层


    -- 事件侦听优先级
    PRIORITY_LOW = -99,
    PRIORITY_NORMAL = 0,
    PRIORITY_HIGH = 99,


    -- HTTP 相关常量
    HTTP_EXCEPTION_CREATE_THREAD = -1, -- HTTP 异常状态码：创建线程时发生异常
    HTTP_EXCEPTION_SEND_REQUEST = -2, -- HTTP 异常状态码：发送请求时发生异常
    HTTP_EXCEPTION_GET_RESPONSE = -3, -- HTTP 异常状态码：获取内容时发生异常
    HTTP_EXCEPTION_ABORTED = -4, -- HTTP 异常状态码：发送请求或获取内容过程中被取消了
    HTTP_EXCEPTION_GET_HEAD = -5, -- HTTP 异常状态码：获取目标文件大小时发生异常
    HTTP_EXCEPTION_FILE_ERROE = -6, -- HTTP 异常状态码：要上传的本地文件不存在

    HTTP_METHOD_POST = "POST", -- 请求方式：POST
    HTTP_METHOD_GET = "GET", -- 请求方式：GET
    HTTP_METHOD_HEAD = "HEAD", -- 请求方式：只获取 response handers (content length)


    -- 网络类型
    NET_TYPE_NOT = 0, -- 无网络
    NET_TYPE_WIFI = 1, -- WiFi
    NET_TYPE_MOBILE = 2, -- 4G


    -- 设备震动方式
    VIBRATE_STYLE_CONTINUED = 0, -- 持续 UnityEngine.Handheld.Vibrate()
    VIBRATE_STYLE_LIGHT = 1, -- 轻微
    VIBRATE_STYLE_MEDIUM = 2, -- 明显
    VIBRATE_STYLE_HEAVY = 3, -- 强烈


    -- 框架中用到到语言包 key
    LKEY_SFU_BYTE = "string.format.unit.byte",
    LKEY_SFU_KG = "string.format.unit.kb",
    LKEY_SFU_MB = "string.format.unit.mb",
    LKEY_SFU_GB = "string.format.unit.gb",


    -- 错误信息
    E1001 = "请勿创建全局变量或全局函数！",
    E1002 = "协程已被禁用！协程的实现代码充满不稳定性，结果也常脱离预期。请使用其他方式实现业务逻辑！",

    E2001 = "不存在的图层：%s",
    E2002 = "必须设定场景名称（moduleName）。className：%s",
    E2004 = "View 只能被初始化一次。className：%s",
    E2005 = "View 还未被初始化。className：%s",
    E2006 = "View 实例.gameObject 值为 nil，不能监听（或取消监听）销毁事件。className：%s",
    E2007 = "gameObject 上未能找到组件 %s。gameObject.name：%s",

    E3001 = "无法解析JSON字符串：%s",
    E3002 = "不能将table转换成JSON字符串：%s",
    E3003 = "HttpRequest.url 不能为 nil",
    E3004 = "定时器的间隔不能为 0",
    E3005 = "AddEventListener() 的参数 callback 不能为 nil",
    E3006 = "HttpDownload.url 不能为 nil",
    E3007 = "HttpDownload.savePath 不能为 nil",
    E3008 = "HttpUpload.url 不能为 nil",
    E3009 = "Httpupload.filePath 不能为 nil",
    E3010 = "Countdown.intervalTime 的值不能为 %s",


}

return Constants