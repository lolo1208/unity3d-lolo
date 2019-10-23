@echo off


set path_sh=%~dp0


%~d0
cd %path_sh%../lib

node build.js -i 0 -v 1.2.3 -p TestSVN -t windows -s test.svn

pause