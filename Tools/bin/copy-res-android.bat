@echo off


set path_sh=%~dp0


path_src=/Users/limylee/Downloads/res.zip
path_dest=../build/ShibaInu/platform/android


%~d0
cd %path_sh%../lib

node copyPlatformRes.js -s %path_src% -d %path_dest% -t android

pause