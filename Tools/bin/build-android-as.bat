@echo off

:: 编译代码和资源，目标平台 Android
:: 生成或更新 AndroidStudio 项目，项目路径 Tools/build/ShibaInu/platform/android


:: 脚本所在路径
set path_sh=%~dp0
:: 项目所在路径
set path_proj=%path_sh%../../


cd %path_sh%../lib

node build.js -i 0 -v 1.2.3 -p ShibaInu -t android -f %path_proj% -g