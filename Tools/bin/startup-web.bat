@echo off


set path_sh=%~dp0


%~d0
cd %path_sh%../lib

node web.js -p 1207