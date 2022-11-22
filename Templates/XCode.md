# Unity XCode 项目相关笔记

## 添加和设置框架代码
* 右键点击项目，选择 `Add Files to "项目"...`，在弹出的窗口中选择 `Sources` 目录，Added Folders 选择 `Create Groups`

 ![](https://static.lolo.link/img/unity/xcode/add-sources.png)

* 选中文件 `Libraries/Plugins/iOS/ShibaInu/AppControllerProtocol.h`
设置为 `Public`

 ![](https://static.lolo.link/img/unity/xcode/set-app-controller-protocol.h.png)

* <font color=red>Undefined symbol: \_OBJC\_CLASS\_$\_UnityFramework</font>

 `TARGET` -> `Build Phases` -> `Link Binary With Libraries`
 添加 `UnityFramework`
 
 ![](https://static.lolo.link/img/unity/xcode/link-unity-framework.png)

<br>
<br>
<br>

## 遇到过的问题

### 禁用 Bitcode
报错如图：
![](https://static.lolo.link/img/unity/xcode/bitcode-1.png)

`TARGET` -> `Build Settings` -> `Enable Bitcode`
设置成：`NO`
![](https://static.lolo.link/img/unity/xcode/bitcode-2.png)

---

### Could not produce class with ID [Number]
![](https://static.lolo.link/img/unity/xcode/find-class-id.png)
##### Find Class with ID: 
<https://docs.unity3d.com/2020.3/Documentation/Manual/ClassIDReference.html>

##### Find Assemblies: 
<https://docs.unity3d.com/2020.3/Documentation/ScriptReference/UnityEngine.AIModule.html>

然后将对应的 Assembly 和 Class 添加到 `Assets/link.xml` 文件中

---

### Could not launch “[App Name]”
* iPhone7-36 has denied the launch request.<br>
   原因可能是证书类型与运行目标类型不匹配。打开Edit Scheme，
   确认 Build Configuration 值：Debug 或 Release;
   以及 Signing Certificate 值：Developer 或 Distribution 是否匹配。

---

### - clang: error: linker command failed with exit code 1 (use -v to see invocation)
### - undefined symbols for architecture armv7 _gadurequestinterstitial
 * Native 代码文件没有加入到项目中，选中文件夹 `Classes/Nitive`，右键，选择 Add Files to [Project]
 * 查看日志详情，是否 native 函数命名有误。

---

### libiconv.2.dylib is in RED
XCode 7 uses tdb libraries instead of dylib libraries.
So you should remove the `libiconv.2.dylib` dependency and add `libiconv.2.tdb`.

---

### Undefined symbols for architecture arm64
  "\_OBJC\_CLASS\_$\_ASIdentifierManager", referenced from: objc-class-ref in DeviceUtil.o
  
添加 `AdSupport.Framework` 即可。

此类编译错误可使用关键字，如：`_OBJC_CLASS_$_ASIdentifierManager` 搜索查出对应的 Framework 名称。

---

### -canOpenURL: failed for URL: "weixinULAPI://" - error: "This app is not allowed to query for scheme weixinulapi"
接入第三方登录时，运行时可能会在控制台看到该错误。解决办法：

`TARGET` -> `Info` -> `Custom iOS Target Properties`

添加新项，Key = `LSApplicationQueriesSchemes` Type = Array

添加内容：`wechat` , `weixinULAPI` , `weixin`

接入微博等其他平台时，也有可能会遇到该错误，追加相关内容即可。

### Thread 1: "+[WXApi genExtraUrlByReq:withAppData:]: unrecognized selector sent to class 0x100966948"
这个运行时异常出现在跳转（唤起）第三方 APP 时。解决办法：

`TARGET` -> `Build Setting` -> `Linking` -> `Other Linker Flags`

添加内容：`-ObjC -all_load`

---

### dyld: Library not loaded
```
dyld: Library not loaded: @rpath/UnityFramework.framework/UnityFramework...

dyld: launch, loading dependent libraries
DYLD_INSERT_LIBRARIES=/Developer/usr/lib/libMainThreadChecker.dylib:/Developer/Library/PrivateFrameworks/DTDDISupport.framework/libViewDebuggerSupport.dylib
```
这个错误出现于：XCode 为最新版本 (xcode 13.2.1)，设备 iOS 版本过低 (ios 13)。
解决方法：升级设备的 iOS 至最新版本 (ios 15)。

---

### Multiple commands produce
这个错误是由于存在 Info.plist 导致的。
解决办法：

Solution -> `TARGET` -> `Build Phases` > `Copy Bundle Resources`
and remove `Info.plist` from there.

<br>
<br>
<br>

## 其他

### 编译 tolua_runtime
[tolua_runtime 项目](https://github.com/topameng/tolua_runtime)

#####  ToLua(Unity Editor) 添加 Apple Silicon 支持
XCode 打开项目 `tolua_runtime/macnojit`

开始设置 `TARGETS` -> `tolua` -> `Build Settings`

`Architectures` 值改为 `Standard Architectures (Apple Silicon, Intel) - $(ARCHS_STANDARD)`

`VALID_ARCHS` 值改为 `arm64 x86_64`（添加 `arm64`，并去掉对 `i386` 的支持）

##### C 编译报错: implicit declaration of function xxx is invalid in C99
原因：隐式声明在 C99 中无效。

解决办法：在头文件或文件开头声明 xxx 函数即可。

##### macOS 10.15 以上，自己编译的 xxx.bundle 提示损坏，移动到废纸篓
解决办法：手动执行 `sudo xattr -r -d com.apple.quarantine xxx.bundle`

