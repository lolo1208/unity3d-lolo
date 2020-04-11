
# 介绍

本项目是基于 [Unity](https://unity.com) 与 [ToLua](https://github.com/topameng/tolua) 的框架。

git clone 完毕后，可在 Unity Editor 菜单栏中点击 [ShibaInu]->[Run the Application] 直接运行项目。
也可在场景中的任意 GameObject 上 [Add Component]->[Main]，然后点击 [Play] 按钮运行项目。

#### * 默认使用的环境和版本：
  - [Unity Editor 2018.4.8f1](https://unity3d.com/cn/unity/whats-new/2018.4.8) 可升级至任意版本
  - [IntelliJ IDEA CE 2018.1.8](https://www.jetbrains.com/idea/download/other.html) 使用 Community 版本即可。如果要升级版本，需配合 EmmyLua 插件一同升级
  - [EmmyLua 1.2.6](https://emmylua.github.io) 该插件安装包放在 Templates/EmmyLua-1.2.6-IDEA172-181.zip
  - Visual Studio Community 2019 / 8.0.3 for Mac
  - [tolua 1.0.7](https://github.com/topameng/tolua), lua 5.1, [release encoder](https://github.com/lolo1208/unity3d-lolo/blob/master/Tools/tools/luaEncoder/readme.txt)

#### * 目录和文件：
  - **Assets/Framework/ShibaInu/** 核心框架代码目录，包含 C# 和 Lua 代码。
  - **Assets/Framework/ToLua/** ToLua 框架代码目录，包含 C# 和 Lua 代码。
  - **Assets/Lua/** 项目 Lua 代码目录，与框架无关，可单独储存在代码库。
  - **Assets/Res/** 项目资源目录，与框架无关，可单独储存在代码库。
  - **Assets/Res/Scenes/** 场景资源目录。
    在该目录下的 *.unity 文件（不包括子目录中的 *.unity 文件）在打包时会被打包成 AssetBundle。
    会被打入底包的场景有 Launcher.unity 启动场景 和 Empty.unity 空场景。
  - **Assets/Res/BuildRules.txt** 打包规则配置文件，包含 忽略，合并，拆分 三种规则。
  - **Assets/Res/Shaders/Shaders.shadervariants** 需要被预热的 Shader 变体。
    默认会在游戏启动时（launcher.lua 中）调用 [Lua]Res.PreloadShaders() 加载所有 Shader 和预热该文件中包含的变体。
  - **Templates/** 项目用到的模版和说明文档，以及其他杂项。
  - **Templates/EmptyProjectAssets/** 如果你想得到一个不包含任何资源文件的 XCode 或 AndroidStudio 项目，
    可将 Assets/Lua 和 Assets/Res 目录删除，然后将本目录下的内容拷贝到 Assets 目录下，再进行打包操作。
  - **Tools/** 工具目录，目前主要包含了打包相关工具。本文 Build 段落有详解。
  - **Tools/templates/cs/** 第三方的工具或类库，有需要可以拷贝至 Assets/Framework/3rdParty
  - **Tools/templates/java/** 框架包含的 Java 代码，打包 Andorid 时，会自动拷贝到 Android 项目中。
  - **Logs/Running.log** 运行时产生的日志。详细介绍可查看 Templates/Logger.docx
  - **LuaAPI/** 所有提供给 Lua 访问的 C# 类，属性，方法等，配合 EmmyLua 插件可在 IDEA 中实现 代码提示，快速访问，查看数据/参数类型，注释 等。
    可用 [ShibaInu]->[Generate Lua API] 自动生成。
    该目录的内容不会在 Lua 代码中 require()，也不会参与打包。

#### * 编码环境：


# Build
构建打包功能的代码分为两部分：
  - [C#] Assets/Framework/ShibaInu/Editor/Builder.cs
  - [Node.js] Tools/lib/*
  - (sh / bat) Tools/bin/*

Tools/bin 目录下为各操作系统和产出需求下的打包脚本，可用文本编辑器打开查看(*.sh)，有详细描述。

Tools 为独立项目，bin 目录下的脚本是为当前项目打包所用。
也可将 Tools 单独架设在 MacOS 或 Windows 机器上，作为打包服务器使用。

Tools 项目核心功能基于 [Node.js](https://nodejs.org/en/download) 实现，在使用前，请确保已安装好 Node.js 与 npm

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
*也可以跳过这一步，不启动 web 服务。*

运行 build-android-as.sh 或 build-android-as.bat 脚本。
*第一次打包速度会比较慢，需要生成 Unity/Library(Android) 资源（和 libil2cpp.symbols.zip）。*

默认生成的 AndroidStudio 项目路径为 Tools/build/ShibaInu/platform/android

Unity Android 项目需要添加的配置和常见问题，可参考：Templates/AndroidStudio.docx

***注意：打包前，请在 Unity Editor 中关闭当前项目。***

###### 打包进度与日志页面：

![console](https://raw.githubusercontent.com/lolo1208/unity3d-lolo/master/Templates/Screenshots/build-web-page.jpg)

