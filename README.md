
# 介绍

本项目是基于 [Unity](https://unity.com) 与 [ToLua](https://github.com/topameng/tolua) 的框架。

#### * 目前默认使用的环境和版本：
  - [Unity Editor 2018.4.8f1](https://unity3d.com/cn/unity/whats-new/2018.4.8) 可升级至任意版本
  - [IntelliJ IDEA CE 2018.1.8](https://www.jetbrains.com/idea/download/other.html) 使用 Community 版本即可。如果要升级版本，需配合 EmmyLua 插件一同升级
  - [EmmyLua 1.2.6](https://emmylua.github.io) 该插件安装包放在 Templates/EmmyLua-1.2.6-IDEA172-181.zip
  - Visual Studio Community 2019 / 8.0.3 for Mac
  - [tolua 1.0.7](https://github.com/topameng/tolua) lua 5.1, [release encoder](https://github.com/lolo1208/unity3d-lolo/blob/master/Tools/tools/luaEncoder/readme.txt)

#### * 目录和文件介绍：

#### * 编码环境：


# Build
项目打包功能的实现代码分为两部分：
  - [C#] Assets/Framework/ShibaInu/Editor/Builder.cs
  - [Node.js] Tools/lib/* 
  - (run) Tools/bin/*

Tools/bin 目录下为各操作系统和产出需求下的打包脚本，可用文本编辑器打开查看(*.sh)，有详细描述。

Tools 为独立项目，bin 目录下的脚本是为当前项目打包所用。
也可将 Tools 单独架设在 MacOS 或 Windows 机器上，作为打包服务器使用。

可运行 build-help.sh 或 build-help.bat 查看帮助信息(build options)

#### * 以导出 Android 项目为例：

第一次运行脚本前，需要先下载 Tools 项目所需 node_modules：
```bash
# Go into the repository
cd Tools

# Install dependencies
npm install
```

然后，编辑 Tools/lib/config/config.js 文件，根据当前操作系统，只需在 macUnityPath 或 winUnityPath 填入 Unity Editor 绝对路径即可。
*变量 unityVersion 和路径中的 [UnityVersion] 替换符，配合 build -u 参数，可用于同一台机器的多个版本 Unity 打包。*

接下来，可运行 startup-web.sh(MacOS) 或 startup-web.bat(Windows) 脚本，开启查看打包进度与日志的 Web 程序。
浏览器 URL 参数 packid 为打包时的唯一标识 ID，bin 目录下的脚本默认都是用 packid=0 来打包。
*也可以跳过这一步，不启动 web 服务*

运行 build-android-as.sh 或 build-android-as.bat 脚本。
*第一次打包速度会比较慢，需要生成 Unity/Library(Android) 资源。*

默认生成的 AndroidStudio 项目路径为 Tools/build/ShibaInu/platform/android

Unity Android 项目需要添加的配置和常见问题，可参考：Templates/AndroidStudio.docx

*注意：打包前，请在 Unity Editor 中关闭当前项目。*

###### 打包进度与日志页面：

![console](https://raw.githubusercontent.com/lolo1208/unity3d-lolo/master/Templates/Screenshots/build-web-page.jpg)

