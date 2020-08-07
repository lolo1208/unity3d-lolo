#!/usr/bin/env bash

# 编译代码和资源，目标平台 MacOS
# 将生成的内容拷贝至 Assets/StreamingAssets 目录
# 随后可在 Unity Editor 中以 AssetBundle 模式运行


# 脚本所在路径
path_sh=$(cd "$( dirname "$0")" && pwd)/
# 项目所在路径
path_proj=${path_sh}../../
# 项目 StreamingAssets 目录路径
path_dest=${path_proj}Assets/StreamingAssets/


cd ${path_sh}../lib

node build.js -i 0 -v 1.2.3 -p ShibaInu -t macos -f ${path_proj} -d ${path_dest} -y -n