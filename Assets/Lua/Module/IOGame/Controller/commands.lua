--
-- 服务端发来的指令处理列表
-- 2018/2/6
-- Author LOLO
--

local IOGameData = require("Module.IOGame.Model.IOGameData")

local commands = {}
commands.reportFrameNum = -1 --- 逻辑帧到达这一帧时，上报当前数据

--


--- 初始化
function commands.init(data)
    IOGameData.playerID = data.id
    math.randomseed(data.randomSeed)
end

--

--- 上报当前数据
function commands.reportMapInfo(data)
    commands.reportFrameNum = data.frameNum
end

--- FrameController 调用
function commands.doReportMapInfo()
    IOGameData.socket:Send(JSON.Stringify({
        cmd = IOGameData.CMD_MAP_INFO,
        avatars = IOGameData.map:GetReportData()
    }))
end


--


--- 有客户端离开
function commands.exit(data)
    IOGameData.map:RemoveAvatar(data.id)
end


--

return commands