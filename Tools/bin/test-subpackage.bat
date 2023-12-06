@echo off


set path_sh=%~dp0
set path_cfg=%path_sh%../lib/config/subpackage.json
set path_zip=%path_sh%../../../TestSubpackage/res.zip
set path_dest=%path_sh%../../../TestSubpackage/dest


%~d0
cd %path_sh%../lib

node subpackage.js -c %path_cfg% -s %path_zip% -d %path_dest%

pause