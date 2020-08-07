@echo off


set path_sh=%~dp0
set path_proj=%path_sh%../../
set path_dest=%path_proj%Assets/StreamingAssets/


%~d0
cd %path_sh%../lib

node build.js -i 0 -v 1.2.3 -p ShibaInu -t windows -f %path_proj% -d %path_dest% -y -n

pause