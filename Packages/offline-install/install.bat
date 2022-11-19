:: 将当前脚本目录下的 packages 目录中的内容，拷贝到本机 packages.unity.com 目录中
:: Created by LOLO on 2021/07/12
@echo off


set pkg_dir=%~dp0packages\
set unity_pkg_dir=%LocalAppData%\Unity\cache\npm\packages.unity.com\

xcopy /s /y %pkg_dir%* %unity_pkg_dir%

echo complete!
pause
