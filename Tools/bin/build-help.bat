@echo off


set path_sh=%~dp0


%~d0
cd %path_sh%../lib

node build.js -h

pause