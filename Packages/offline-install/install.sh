#!/usr/bin/env bash
# 将当前脚本目录下的 packages 目录中的内容，拷贝到本机 packages.unity.com 目录中
# Created by LOLO on 2021/07/12


pkg_dir=$(cd "$( dirname "$0")" && pwd)/packages/
unity_pkg_dir="${HOME}/Library/Unity/cache/npm/packages.unity.com/"

cp -rf "${pkg_dir}"* ${unity_pkg_dir}

echo "complete!"
