# Language-LocalizationText

本篇将会介绍 [Unity框架项目](https://github.com/lolo1208/unity3d-lolo) 的语言包系统以及相关功能和使用方法。

### 在 Unity Editor 中编辑和使用

* 在任意节点添加 `ShibaInu. LocalizationText` 组件（同时，将会自动添加 `UnityEngine.UI.Text` 组件）

![](https://static.lolo.link/img/unity/language-localizationtext/screenshot-1.png)

* 在 `languageKey` 中输入语言包中定义的 key，再点击 `Apply` 按钮，将会在 Unity Editor 中显示出对应的内容。

当语言包中找不到对应的 key 时，将会在控制台打印一条错误提示。如图：

![](https://static.lolo.link/img/unity/language-localizationtext/screenshot-2.png)


* 点击 `Refresh` 按钮，可以刷新语言包内容（一般无需手动刷新）。


* 点击 `Edit` 按钮，可以打开语言包管理窗口。如图：

![](https://static.lolo.link/img/unity/language-localizationtext/screenshot-3.png)

可以在该窗口中选择项目使用的语言包（例：en-US），以及新建和修改语言包内容项。

左侧内容为 key（例：string.format.unit.gb），右侧内容为 value（例：GB）。

列表会根据 key 进行排序（a-z）。

点击`查询`按钮，可列出 key 与 value 包含查询内容的语言包项。

`点击 key` 时，会自动将 key 的内容复制到系统剪切板。

*注：`Assets/Lua/Data/Languages/` 目录中所有的 Lua 文件为该窗口的数据源，Lua 文件的内容会被该窗口修改，一般无需手动修改该目录中的 Lua 文件内容。*


### 在 Lua 中使用
```lua
GetComponent.Text(go).text = Language.myLanguageKey
-- or
GetComponent.Text(go).text = Language["string.format.unit.gb"]

GetComponent.LocalizationText(go).languageKey = "myLanguageKey"
-- or
GetComponent.LocalizationText(go):SetText(Language["string.format.unit.gb"])
```
