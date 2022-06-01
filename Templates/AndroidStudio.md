# Unity AndroidStudio 项目相关笔记

### AndroidManifest.xml
##### 权限：文件读写 / 震动
```xml
<manifest>
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.VIBRATE" />
</manifest>
```

##### 全面屏适配
```xml
<application>
  <meta-data android:name="android.max_aspect" android:value="2.2" /><!--O/V-->
  <meta-data android:name="notch.config" android:value="portrait|landscape"/><!--小米-->
  <meta-data android:name="android.notch_support" android:value="true"/><!--华为-->
</application>
```

---

### 绘制刘海区
##### 使用 API 28 (Android P)
Project Structure -> Compile Sdk Version : API 28

##### 添加代码
Activity.java -> onCreate()

shibaInu.util.DeviceHelper.displayNotch();

---

### 其他
##### VIVO手机调试安装
在gradle.properties 中添加：

android.injected.testOnly=false

---

### 支持ARM64
##### Player Settings Panel > Settings for Android > Other Settings > Configuration
![](https://blog.lolo.link/img/unity/android-studio/unity-configuration.png)

##### Link:
<https://developer.android.com/distribute/best-practices/develop/64-bit?hl=zh-cn>


##### Settings:
[Unity] `Preferences` > `External Tools` > `Android SDK / NDK`

---

### Could not produce class with ID xxx
##### Find Class with ID: 
<https://docs.unity3d.com/2020.3/Documentation/Manual/ClassIDReference.html>

##### Find Assemblies: 
<https://docs.unity3d.com/2020.3/Documentation/ScriptReference/UnityEngine.AIModule.html>

然后将对应的 Assembly 和 Class 添加到 `Assets/link.xml` 文件中

---

### error: resource style/Theme.AppCompat.Light.NoActionBar
在build.gradle 中添加

```gradle
dependencies {
    implementation 'com.android.support:appcompat-v7:28.0.0'
}
```

---

### Android 8: Cleartext HTTP traffic to *** not permitted
在AndroidManifest.xml配置文件的<application>标签中直接插入

android:usesCleartextTraffic="true"

---

### 编译时，下载 fastutil.jar 等卡住
解决方案：使用阿里云。

在 build.gradle 的 buildscript.repositories 以及 allprojects.repositories 中移除 mavenCentral(), google() 等，改为

```gradle
repositories {
	maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
	maven { url 'http://maven.aliyun.com/nexus/content/repositories/jcenter' }
	maven { url 'http://maven.aliyun.com/nexus/content/repositories/google' }
	maven { url 'http://maven.aliyun.com/nexus/content/repositories/gradle-plugin' }
}
```

---

### 改包名后启动报错： Error while executing: am start -n
解决方案：

File -> Invalidate Caches -> 勾选 Clear file system cache and Local History -> 点击 Invalidate and Restart

重启完 Android Studio 即可。

