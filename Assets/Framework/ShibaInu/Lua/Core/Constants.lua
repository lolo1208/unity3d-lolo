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


    -- 获取本机权限（Android）时，向 Native 发消息所用的 action
    UN_ACT_REQUEST_PERMISSIONS = "requestPermissions",
    -- Android 需申请的权限组
    ANDROID_PERMISSION = {
        -- 存储
        STORAGE = { "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE" },
        -- 定位
        LOCATION = { "android.permission.ACCESS_COARSE_LOCATION", "android.permission.ACCESS_FINE_LOCATION" },
        -- 麦克风
        MICROPHONE = { "android.permission.RECORD_AUDIO" },
        -- 摄像头
        CAMERA = { "android.permission.CAMERA" },
    },


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
    LKEY_TR_MINUTE = "time.relative.minute",
    LKEY_TR_MINUTES = "time.relative.minutes",
    LKEY_TR_HOUR = "time.relative.hour",
    LKEY_TR_HOURS = "time.relative.hours",
    LKEY_TR_DAY = "time.relative.day",
    LKEY_TR_DAYS = "time.relative.days",
    LKEY_TR_MONTH = "time.relative.month",
    LKEY_TR_MONTHS = "time.relative.months",
    LKEY_TR_YEAR = "time.relative.year",
    LKEY_TR_YEARS = "time.relative.years",
    LKEY_TR_BEFORE = "time.relative.before",
    LKEY_TR_AFTER = "time.relative.after",
    LKEY_TR_NOW = "time.relative.justNow",
    LKEY_TR_SOON = "time.relative.soon",


    -- 错误信息
    E1001 = "请勿创建全局变量或全局函数！",
    E1002 = "协程已被禁用！协程的实现代码充满不稳定性，结果也常背离预期。请使用其他方式实现业务逻辑！",
    E1004 = "Event 对象已在缓存池中，不能重复回收。重要：请务必检查调用 Recycle() 函数的相关逻辑！",

    E2001 = "不存在的图层：%s",
    E2002 = "必须设定场景名称（moduleName）。className：%s",
    E2004 = "View 只能被初始化一次。className：%s",
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
    E3009 = "HttpUpload.filePath 不能为 nil",
    E3010 = "Countdown.intervalTime 的值不能为 %s",

    -- 警告信息
    W1001 = "{1} 缓存池中实例数量过多！请尽量使用 Event.Get() 来获取实例，减少 {1}.New() 的使用。",
    W1002 = "Handler 缓存池中实例数量过多！请减少 NewHandler() 的使用。只会触发一次的回调，请使用 handler() 或 OnceHandler() 来获取 Handler 实例。",
    W1003 = "HandlerRef 不匹配，请检查 Handler 或 DelayedCall 的引用和调用逻辑！",
}

return Constants