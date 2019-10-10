#!/usr/bin/env bash

# 将已经打包好的 AssetBundle 和 Lua 等资源，拷贝（解压）到 Android 项目资源目录（src/main/assets/）


# 脚本所在路径
path_sh=$(cd "$( dirname "$0")" && pwd)/


# 要拷贝的资源所在目录（或 zip 文件路径）
path_src=/Users/limylee/Downloads/res.zip
# 要拷贝至的平台项目路径
path_dest=../build/ShibaInu/platform/android


cd ${path_sh}../lib

node copyPlatformRes.js -s ${path_src} -d ${path_dest} -t android