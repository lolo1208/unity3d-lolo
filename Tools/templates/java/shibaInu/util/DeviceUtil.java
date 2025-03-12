package shibaInu.util;


import android.Manifest;
import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.util.Log;

import com.unity3d.player.UnityPlayer;

import java.util.Arrays;

import app.core.Common;


/**
 * 设备相关工具类
 * Created by LOLO on 2020/12/25.
 */
public final class DeviceUtil {


    /**
     * 获取 Device ID
     */
    @SuppressLint("HardwareIds")
    public static String getDeviceId() {
        String deviceId;
        Context context = UnityPlayer.currentActivity.getApplicationContext();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            deviceId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        } else {
            final TelephonyManager mTelephony = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (context.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                    return "";
                }
            }
            assert mTelephony != null;
            if (mTelephony.getDeviceId() != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    deviceId = mTelephony.getImei();
                } else {
                    deviceId = mTelephony.getDeviceId();
                }
            } else {
                deviceId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
            }
        }
        Log.i(Common.LOG_TAG, "deviceId: " + deviceId);
        return deviceId;
    }


    /**
     * 获取 Android ID
     */
    @SuppressLint("HardwareIds")
    public static String getAndroidId() {
        Context context = UnityPlayer.currentActivity.getApplicationContext();
        String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        Log.i(Common.LOG_TAG, "androidId: " + androidId);
        return androidId;
    }


    /**
     * 获取 deviceModel（手机品牌/设备型号）
     */
    public static String getDeviceModel() {
        String deviceModel = Build.BRAND;
        Log.i(Common.LOG_TAG, "deviceModel: " + deviceModel);
        return deviceModel;
    }


    /**
     * 获取 CPU ABIs
     */
    public static String getCpuABIs() {
        String cpuABIs = Arrays.toString(Build.SUPPORTED_ABIS);
        Log.i(Common.LOG_TAG, "CPU ABIs: " + cpuABIs);
        return cpuABIs;
    }


    /**
     * 获取 GLEs 版本号
     */
    public static String getGlEsVersion() {
        ActivityManager activityManager = (ActivityManager) UnityPlayer.currentActivity.getSystemService(Context.ACTIVITY_SERVICE);
        ConfigurationInfo configInfo = activityManager.getDeviceConfigurationInfo();
        String gles = configInfo.getGlEsVersion();
        Log.i(Common.LOG_TAG, "GlEs Version: " + gles);
        return gles;
    }


    /**
     * 获取 android 版本代号
     */
    public static String getAndroidVersionCode() {
        String versionCode = String.valueOf(Build.VERSION.SDK_INT);
        Log.i(Common.LOG_TAG, "versionCode: " + versionCode);
        return versionCode;
    }


    /**
     * 获取 <application> <meta-data> 子节点的值
     */
    public static String getMetaData(String key) {
        return MetaDataUtil.getMetaDataFormApplication(key);
    }


    //
}
