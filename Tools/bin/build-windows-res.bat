@echo off


set path_sh=%~dp0
set path_proj=%path_sh%../../
set path_zip=%path_proj%../res.zip


%~d0
cd %path_sh%../lib

node build.js -i 0 -v 1.2.3 -p ShibaInu -t windows -f %path_proj% -z %path_zip% -n

pause