# Unity XCode 项目相关笔记

### 禁用 Bitcode
报错如图：
![](https://blog.lolo.link/img/unity/xcode/bitcode-1.png)

`TARGETS` -> `Build Settings` -> `搜索 Enable Bitcode`
设置成：`NO`
![](https://blog.lolo.link/img/unity/xcode/bitcode-2.png)

---

### 运行时崩溃
 * 查看控制台是否有Could not produce class with ID [Number] 错误。

---

### Could not produce class with ID [Number]
![](https://blog.lolo.link/img/unity/xcode/find-class-id.png)
##### Find Class with ID: 
<https://docs.unity3d.com/2018.1/Documentation/Manual/ClassIDReference.html>

##### Append Class
&nbsp;&nbsp;&nbsp; to \[ Assets/Link.xml ]

&nbsp;&nbsp;&nbsp; or \[ Assets/Resources/Link.xxx ] \( Editor Class, Save File or Prefab )

---

### Could not launch “[App Name]”
 * iPhone7-36 has denied the launch request.<br>
   原因可能是证书类型与运行目标类型不匹配。打开Edit Scheme，
   确认 Build Configuration 值：Debug 或 Release;
   以及 Signing Certificate 值：Developer 或 Distribution 是否匹配。

---

### clang: error: linker command failed with exit code 1 (use -v to see invocation)
 * Native 代码文件没有加入到项目中，选中文件夹 `Classes/Nitive`，右键，选择 Add Files to `Project`
 * 查看日志详情，是否native函数命名有误。

---

### libiconv.2.dylib is in RED
xCode 7 uses tdb libraries instead of dylib libraries. So you should remove the `libiconv.2.dylib` dependency and add `libiconv.2.tdb`.
