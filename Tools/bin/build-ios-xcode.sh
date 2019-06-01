#!/usr/bin/env bash

# 编译代码和资源，目标平台 iOS
# 并生成或更新 XCode 项目，项目路径 Tools/build/ShibaInu/platform/ios


# 脚本所在路径
path_sh=$(cd "$( dirname "$0")" && pwd)/
# 项目所在路径
path_proj=${path_sh}../../


cd ${path_sh}../lib

node build.js -i 0 -v 1.2.3 -p ShibaInu -t ios -f ${path_proj} -g -n