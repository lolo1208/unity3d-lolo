--
-- 类描述
-- 2018/2/1
-- Author LOLO
--

---@class IOGame.IOGameData
local IOGameData = {}


-- 引用
IOGameData.scene = nil ---@type IOGame.IOGameScene
IOGameData.camera = nil ---@type UnityEngine.Transform
IOGameData.socket = TcpSocketClient.New()
IOGameData.joystick = nil ---@type IOGame.Joystick
IOGameData.btnBar = nil ---@type IOGame.BtnBar
IOGameData.map = nil ---@type IOGame.Map
IOGameData.frame = nil ---@type IOGame.FrameController


-- 常量
IOGameData.NAME = "IOGame"
IOGameData.F_N_JUMP = 90 --- 跳跃动作帧数
IOGameData.F_N_ATTACK = 66 --- 攻击动作帧数
IOGameData.F_N_SHOT = 120 --- 射击动作帧数


-- 主摄像机位置和角度
IOGameData.cameraInPos = Vector3.New(-19, 9, -10) -- 需要加上玩家角色位置
IOGameData.cameraInAng = Vector3.New(45, 90, 0)
IOGameData.cameraOutPos = Vector3.New(-28, 20, 0)
IOGameData.cameraOutAng = Vector3.New(25, 90, 0)


-- player data
IOGameData.playerID = 0 --- 当前玩家ID
IOGameData.playerName = "" --- 当前玩家名称


-- commands
IOGameData.CMD_MAP_INFO = "mapInfo"
IOGameData.CMD_ANGLE = "angle"
IOGameData.CMD_MOVE = "move"
IOGameData.CMD_JUMP = "jump"
IOGameData.CMD_ATTACK = "attack"
IOGameData.CMD_SHOT = "shot"


--


return IOGameData


-- 帧数据相关信息

---@class IOGame.FrameData.NewAvatar @ 创建新角色
---@field id number
---@field name string
---@field pic string
---@field x number
---@field z number
---@field angle number
---@field state table
---@field action table

