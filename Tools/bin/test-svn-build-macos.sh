#!/usr/bin/env bash

# 编译代码和资源，目标平台 MacOS
# 测试 svn 功能


# 脚本所在路径
path_sh=$(cd "$( dirname "$0")" && pwd)/


cd ${path_sh}../lib

node build.js -i 0 -v 1.2.3 -p TestSVN -t macos -s test.svn