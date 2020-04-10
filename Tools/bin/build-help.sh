#!/usr/bin/env bash

# 在控制台打印帮助信息（build options）


# 脚本所在路径
path_sh=$(cd "$( dirname "$0")" && pwd)/


cd ${path_sh}../lib

node build.js -h