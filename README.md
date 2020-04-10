# 介绍

本项目是基于 Unity3D 与 [ToLua](https://github.com/topameng/tolua) 的框架。

#### * 目录和文件介绍：


# Build
项目打包功能的实现代码分为两部分：
  - [C#] Assets/Framework/ShibaInu/Editor/Builder.cs
  - [Node.js] Tools/lib/* 
  - (run) Tools/bin/*

Tools/bin 目录下为各环境和需求下的打包脚本，可用文本编辑器打开查看（*.sh），有详细描述。

Tools 为独立项目，bin 目录下的脚本是为当前项目打包所用。
也可将 Tools 单独架设在 MacOS 或 Windows 机器上，作为打包服务器使用。
可运行 build-help.sh 或 build-help.bat 查看帮助信息（build options）

#### * 以导出 Android 项目为例：

第一次运行脚本前，需要先下载 Tools 项目所需 node_modules：
```bash
# Go into the repository
cd Tools

# Install dependencies
npm install
```

运行 startup-web.sh(MacOS) 或 startup-web.bat(Windows) 脚本，开启查看打包进度与日志的 Web 程序。
浏览器 URL 参数 packid 为打包时的唯一识别 ID，bin 目录下的脚本默认都是用 0 来打包。
*（也可以跳过这一步，不启动 web 服务）*

运行 build-android-as.sh 或 build-android-as.bat 脚本。

第一次打包速度会比较慢，需要生成 Unity/Library(Android) 资源。

默认生成的 AndroidStudio 项目路径为 Tools/build/ShibaInu/platform/android

Unity Android 项目需要添加的配置和常见问题，可参考：Templates/AndroidStudio.docx

*注意：打包前，请在 Unity Editor 中关闭当前项目。*

###### 打包进度与日志页面：

![console](https://raw.githubusercontent.com/lolo1208/unity3d-lolo/master/Templates/Screenshots/build-web-page.jpg)

