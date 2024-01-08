# 介绍

[本项目](https://github.com/lolo1208/unity3d-lolo) 是基于 [Unity](https://unity.com) 与 [ToLua](https://github.com/topameng/tolua) 的框架项目，以及部分示例内容。
主要内容包括：C# 代码，Lua 代码，Node.js 代码，sh / bat 脚本，开发环境，以及打包工具。

git clone 完毕后，可在 Unity Editor 菜单栏中点击 `ShibaInu`->`Run the Application` 直接运行项目。
也可在场景中的任意 GameObject 上 `Add Component`->`Main`，然后点击 `Play` 按钮运行项目。

#### * 默认环境和版本
  - [Unity Editor 2021.3.33f1](https://unity3d.com/cn/unity/whats-new/2021.3.33) 可升级至任意版本
  - [IntelliJ IDEA CE 2022.3.3](https://www.jetbrains.com/idea/download/other.html) 使用 Community 版本即可。如果要升级版本，需配合 EmmyLua 插件一同升级
  - [EmmyLua 1.3.8](https://plugins.jetbrains.com/plugin/9768-emmylua/versions/stable) 该插件可用于 [lua 代码提示](https://emmylua.github.io)。安装包放在 Templates/IntelliJ-EmmyLua-1.3.8-IDEA223.zip
  - `EmmyLua AttachDebugger 1.0.9` 该插件可用于断点调试 lua 代码。安装包放在 Templates/EmmyLua-AttachDebugger-1.0.9.zip
  - [VS Code](https://code.visualstudio.com/) latest / [Visual Studio Community](https://visualstudio.microsoft.com/zh-hans/free-developer-offers) 2019 / 8.10.17 for Mac
  - [tolua 1.0.7](https://github.com/topameng/tolua), lua 5.1, [release encoder](https://github.com/lolo1208/unity3d-lolo/blob/master/Tools/tools/luaEncoder/readme.txt)
  - 其他：[ndk-r21-darwin-x86_64](https://dl.google.com/android/repository/android-ndk-r21-darwin-x86_64.zip), [Universal Render Pipeline](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@10.5/manual/index.html)

#### * 特殊目录和文件
  - `Assets/Framework/ShibaInu/` 核心框架代码目录，包含 C# 和 Lua 代码。

  - `Assets/Framework/ToLua/` ToLua 框架代码目录，包含 C# 和 Lua 代码。
  - `Assets/Lua/` 项目 Lua 代码目录，与框架无关，可单独存储在代码库。
  - `Assets/Res/` 项目资源目录，与框架无关，可单独存储在代码库。
  - `Assets/Res/Scenes/` 场景资源目录。
    在该目录下的 \*.unity 文件（不包括子目录中的 \*.unity 文件）在打包时会被打包成 AssetBundle。
    会被打入底包的场景有 Launcher.unity（启动场景）和 Empty.unity（空场景）。
  - `Assets/Res/BuildRules.txt` 打包规则配置文件，包含 忽略，合并，拆分以及直接拷贝 几种规则。
  - `Assets/Res/Shaders/Shaders.shadervariants` 需要被预热的 Shader 变体。
    默认会在游戏启动时（launcher.lua 中）调用 [Lua]Res.WarmUpShaders() 加载所有 Shader 和预热该文件中包含的变体。
  - `Templates/` 项目用到的模版和说明文档，以及其他杂项。
  - `Templates/EmptyProject_Assets/` 如果你想打出一个不包含任何资源文件的 XCode 或 AndroidStudio 项目，可以将 Assets/Lua 和 Assets/Res 目录删除，然后将该目录下的内容拷贝到 Assets 目录下，再进行打包操作。
  - `Tools/` 工具目录，目前主要包含了打包相关工具。你可以在 Build 段落看到详解。
  - `Tools/templates` 框架包含的 Java / OC 代码，打包 Andorid / XCode 项目时，会自动拷贝到 Android / XCode 项目中。
  - `Logs/Running.log` 运行时产生的日志。详细介绍可查看 [Templates/Logger.md](https://github.com/lolo1208/unity3d-lolo/blob/master/Templates/Logger.md)
  - `LuaAPI/` 该目录内生成了提供给 Lua 访问的 C# 类，属性，方法等，
  配合 EmmyLua 插件可在 IDEA 中实现 代码提示，快速访问，查看数据，参数类型，注释等。
  可在菜单栏中点击 `ShibaInu`->`Generate Lua API` 自动生成。
  该目录内的 Lua 文件不会被 require()，也不会参与打包，仅用于代码提示。
  - `Assets/Framework/ShibaInu/Lua/Define/` 与 LuaAPI 目录类似。

#### * 其他文档
  - [NativeEvent / NativeHelper](https://github.com/lolo1208/unity3d-lolo/blob/master/Templates/NativeEvent-NativeHelper.md)
  - [Handler / DelayedCall](https://github.com/lolo1208/unity3d-lolo/blob/master/Templates/Handler-DelayedCall.md)
  - [Logger](https://github.com/lolo1208/unity3d-lolo/blob/master/Templates/Logger.md)
  - [Language / LocalizationText](https://github.com/lolo1208/unity3d-lolo/blob/master/Templates/Language-LocalizationText.md)
  - [AndroidStudio Project Notes](https://github.com/lolo1208/unity3d-lolo/blob/master/Templates/AndroidStudio.md)
  - [XCode Project Notes](https://github.com/lolo1208/unity3d-lolo/blob/master/Templates/XCode.md)
  - [Lua Static Data](https://github.com/lolo1208/unity3d-lolo/tree/master/Templates/SData)

#### * 示例内容

###### UI Samples
![](https://static.lolo.link/img/unity/unity-framework/screenshot-samples.jpg)

###### Picker
![](https://static.lolo.link/img/unity/unity-framework/screenshot-picker.jpg)

###### Scroll List
![](https://static.lolo.link/img/unity/unity-framework/screenshot-scroll-list.jpg)

###### View Pager / Page List
![](https://static.lolo.link/img/unity/unity-framework/screenshot-view-pager.jpg)

###### Dungeon
![](https://static.lolo.link/img/unity/unity-framework/screenshot-dungeon.jpg)

<br>

# 开发环境

启动 IDEA，并点击打开项目，项目目录为 `Assets/Lua/`

打开 `Project Structure` 窗口，点击 `Add Content Root` 按钮，添加目录：

  - Assets/Framework/ShibaInu/Lua/
  - Assets/Framework/ToLua/Lua/

并将这3个目录都标记为 `Sources` 目录。

###### 最终配置结果如图：
![](https://static.lolo.link/img/unity/unity-framework/project-structure.png)

#### * C# -> Lua
首先，将需要导出给 Lua 访问的 类，属性，方法 等添加到 `Assets/Framework/ToLua/Editor/CustomSettings.cs` 中。

然后，在 Unity Editor 中点击菜单 `ShibaInu`->`Generate Lua Wraps`。
清理完成后，会弹出询问是否 “自动生成” 的对话框，点击`确定`按钮，重新生成所有 C#Wrap 文件。

完成后，再点击 `ShibaInu`->`Generate Lua API` 重新生成 LuaAPI 目录内可供 EmmyLua 插件快速访问和代码提示的 Lua 文件。

不需要导出给 Lua 访问的属性或方法，可添加 `[NoToLua]` 特性标签进行排除，
或在 `Assets/Framework/App/Core/ToLuaExtend.cs` **MEMBER_FILTER** 列表中添加排除。

#### * 安装 EmmyLua 插件

点击 `Preferences`->`Plugins` 打开插件窗口。
Windows 为 `File`->`Settings`->`Plugins`

可以在线安装，也可以从硬盘安装，插件放在 `Templates/EmmyLua-1.2.6-IDEA172-181.zip`
*注意：插件版本要与 IDEA 版本匹配。*

再次打开 `Project Structure` 窗口，
选择 `Project Settings`->`Libraries`，
在右侧列表（窗口中间）点击 `+` 按钮，
在弹出的列表中点击 `Lua Zip Library`，
然后选择 `Assets/LuaAPI` 目录。

###### 如图：
![](https://static.lolo.link/img/unity/unity-framework/libraries-luaapi.jpg)

自此，Lua 开发环境已全部配置完成。

#### * 忽略 .meta 文件
打开 `Preferences`->`Editor`->`File Types` 窗口，在 `Ignore files and folders` 输入框中添加 **`*.meta;`** 即可忽略所有 meta 文件。

###### 如图：
![](https://static.lolo.link/img/unity/unity-framework/preferences-ignore-meta.jpg)


# Build
构建打包功能的代码分为三部分：

  - `C#` Assets/Framework/ShibaInu/Editor/Builder.cs
  - `Node.js` Tools/lib/*.js
  - `sh / bat` Tools/bin/*

Tools/bin 目录下为各操作系统和产出需求下的打包脚本，可用文本编辑器打开查看(*.sh)，有详细描述。

Tools 为独立项目，bin 目录下的脚本是为当前项目打包所用。
也可将 Tools 单独架设在 MacOS 或 Windows 机器上，作为打包服务器使用。

Tools 项目核心功能基于 [Node.js](https://nodejs.org/en/download) 实现，在使用前，请确保已安装好 Node.js 与 npm

*可运行 `build-help.sh` 或 `build-help.bat` 查看帮助信息(build options)*

#### * 以导出 Android 项目为例

第一次运行脚本前，需要先下载 Tools 项目所需 node_modules

```bash
# Go into the repository
cd Tools

# Install dependencies
npm install
```

然后，编辑 `Tools/lib/config/config.js` 文件，根据当前操作系统，只需在 `macUnityPath` 或 `winUnityPath` 填入 Unity Editor 绝对路径即可。

*你也可以配置变量 `unityVersion` 和路径中的 `[UnityVersion]` 替换符，配合 build.js `-u` 参数，用于同一台机器的多个 Unity 版本打包。*

接下来，可运行 `startup-web.sh`(MacOS) 或 `startup-web.bat`(Windows) 脚本，开启查看打包进度与日志的 Web 程序。
浏览器 URL 参数 `packid` 为打包时的唯一标识 ID，bin 目录下的脚本默认都是用 packid=0 来打包。
*也可以跳过这一步，不启动 web 服务。*

运行 `build-android-as.sh` 或 `build-android-as.bat` 脚本。
*第一次打包速度会比较慢，需要生成 Unity/Library(Android) 资源（和 libil2cpp.symbols.zip）*

默认生成的 AndroidStudio 项目路径为 `Tools/build/ShibaInu/platform/android`

Unity Android 项目需要添加的配置和常见问题，可参考：Templates/AndroidStudio.docx

***注意：打包前，请在 Unity Editor 中关闭当前项目。***

###### 打包进度与日志页面：
![](https://static.lolo.link/img/unity/unity-framework/build-web-page.jpg)

#### * Unity Editor - `AssetBundle`

你可以在 Unity Editor 中以 AssetBundle 模式加载资源。该模式对 模拟真机环境，检视资源 和 调试程序 都有非常大的帮助。
打包步骤如下：

在 Unity Editor 中关闭当前项目。

运行脚本 `build-macos-ab-mode.sh` 或 `build-windows-ab-mode.bat` 脚本。
该脚本会将所有资源打成 AssetBundle（Launcher 和 Empty 场景除外），
Encode 所有 Lua 文件，
然后拷贝至 `Assets/StreamingAssets` 目录。

重新在 Unity Editor 中打开项目，这时默认已经进入了 AssetBundle 模式，直接运行项目即可。

你也可以点击菜单 `ShibaInu`->`退出 AssetBundle 模式` 或  `ShibaInu`->`进入 AssetBundle 模式` 切换加载模式。

*提示：可以在 Web 程序中查看打包进度与详细日志*


# 可能会遇到的问题
#### * macOS 10.15 以上，报错：“tolua.bundle” 已损坏，无法打开。您应该将它移到废纸篓。
解决办法：

```bash
cd Assets/Plugins
sudo xattr -r -d com.apple.quarantine tolua.bundle
```

