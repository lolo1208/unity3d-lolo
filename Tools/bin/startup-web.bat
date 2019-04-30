@echo off

:: 启动 web 服务器，用于查看打包进度等信息


:: 脚本所在路径
set path_sh=%~dp0


cd %path_sh%../lib

node web.js -p 1207