@echo off


set path_sh=%~dp0
set path_proj=%path_sh%../../


%~d0
cd %path_sh%../lib

node build.js -i 0 -v 1.2.3 -p ShibaInu -t android -f %path_proj% -g -n

pause