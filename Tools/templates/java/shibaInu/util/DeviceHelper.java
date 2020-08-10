package shibaInu.util;

import java.lang.reflect.Method;
import java.util.List;

import android.os.Build;
import android.os.Vibrator;
import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.view.DisplayCutout;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.unity3d.player.UnityPlayer;


/**
 * 设备相关工具类
 * Created by LOLO on 2019/3/7.
 */
public class DeviceHelper {

    /**
     * 设备类型
     */
    enum DeviceType {
        XIAOMI, HUAWEI, OPPO, VIVO, OTHER
    }


    /**
     * 获取当前设备类型
     */
    public static DeviceType getDeviceType() {
        if (_deviceType == null) {
            String manufacturer = Build.MANUFACTURER.toLowerCase();
            if (manufacturer.contains("xiaomi"))
                _deviceType = DeviceType.XIAOMI;
            else if (manufacturer.contains("huawei"))
                _deviceType = DeviceType.HUAWEI;
            else if (manufacturer.contains("oppo"))
                _deviceType = DeviceType.OPPO;
            else if (manufacturer.contains("vivo"))
                _deviceType = DeviceType.VIVO;
            else
                _deviceType = DeviceType.OTHER;
        }
        return _deviceType;
    }

    private static DeviceType _deviceType = null;


    //


    /**
     * 启用绘制刘海区（API 28 才起效）
     */
    public static void displayNotch() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            Window wnd = UnityPlayer.currentActivity.getWindow();
            WindowManager.LayoutParams lp = wnd.getAttributes();
            lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            wnd.setAttributes(lp);
        }
    }


    //


    /**
     * 是否为异形屏设备
     */
    public static boolean isNotchScreen() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
                return isNotchScreen_androidP();

            switch (getDeviceType()) {
                case XIAOMI:
                    return isNotchScreen_xiaomi();
                case HUAWEI:
                    return isNotchScreen_huawei();
                case OPPO:
                    return isNotchScreen_oppo();
                case VIVO:
                    return isNotchScreen_vivo();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Android P（API 28）
    private static boolean isNotchScreen_androidP() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            Activity activity = UnityPlayer.currentActivity;
            View view = activity.getWindow().getDecorView().findViewById(android.R.id.content);
            DisplayCutout dc = view.getRootWindowInsets().getDisplayCutout();
            List<Rect> rects = dc.getBoundingRects();
            return rects != null && rects.size() > 0;
        }
        return false;
    }

    // 小米
    private static boolean isNotchScreen_xiaomi() {
        return SystemPropertiesProxy.getInt("ro.miui.notch") == 1;
    }

    // 华为
    private static boolean isNotchScreen_huawei() {
        try {
            ClassLoader cl = UnityPlayer.currentActivity.getClassLoader();
            Class HwNotchSizeUtil = cl.loadClass("com.huawei.android.util.HwNotchSizeUtil");
            @SuppressWarnings("unchecked")
            Method get = HwNotchSizeUtil.getMethod("hasNotchInScreen");
            return (boolean) get.invoke(HwNotchSizeUtil);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // oppo
    private static boolean isNotchScreen_oppo() {
        return UnityPlayer.currentActivity.getPackageManager().hasSystemFeature("com.oppo.feature.screen.heteromorphism");
    }

    // vivo
    private static boolean isNotchScreen_vivo() {
        try {
            ClassLoader cl = UnityPlayer.currentActivity.getClassLoader();
            Class FtFeature = cl.loadClass("android.util.FtFeature");
            @SuppressWarnings("unchecked")
            Method get = FtFeature.getMethod("isFeatureSupport", int.class);
            return (boolean) get.invoke(FtFeature, 0x00000020);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


    //


    private static final String NONE_SAFE_INSETS = "0";


    /**
     * 获取设备的安全边界偏移，值为：
     * "top, bottom, left, right" - safe area
     * or "width, height" - notch size
     * or "height" - status bar
     */
    public static String getSafeInsets() {
        try {
            if (!isNotchScreen())
                return NONE_SAFE_INSETS;

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
                return getSafeInsets_androidP();

            switch (getDeviceType()) {
                case XIAOMI:
                case OPPO:
                case VIVO:
                    return getSafeInsets_xiaomi();
                case HUAWEI:
                    return getSafeInsets_huawei();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return NONE_SAFE_INSETS;
    }

    // Android P（API 28）
    private static String getSafeInsets_androidP() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            Activity activity = UnityPlayer.currentActivity;
            View view = activity.getWindow().getDecorView().findViewById(android.R.id.content);
            DisplayCutout dc = view.getRootWindowInsets().getDisplayCutout();
            return dc.getSafeInsetTop() + "," +
                    dc.getSafeInsetBottom() + "," +
                    dc.getSafeInsetLeft() + "," +
                    dc.getSafeInsetRight();
        }
        return NONE_SAFE_INSETS;
    }

    // 小米, oppo, vivo
    private static String getSafeInsets_xiaomi() {
        Context context = UnityPlayer.currentActivity.getApplicationContext();
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            int result = context.getResources().getDimensionPixelSize(resourceId);
            return result + "";
        }
        return NONE_SAFE_INSETS;
    }

    // 华为
    private static String getSafeInsets_huawei() {
        try {
            ClassLoader cl = UnityPlayer.currentActivity.getClassLoader();
            Class HwNotchSizeUtil = cl.loadClass("com.huawei.android.util.HwNotchSizeUtil");
            @SuppressWarnings("unchecked")
            Method get = HwNotchSizeUtil.getMethod("getNotchSize");
            int[] size = (int[]) get.invoke(HwNotchSizeUtil);
            return size[0] + "," + size[1];
        } catch (Exception e) {
            e.printStackTrace();
        }
        return NONE_SAFE_INSETS;
    }


    //

    /**
     * 设备震动反馈
     *
     * @param style 震动方式 [ 1:轻微, 2:明显, 3:强烈 ]
     */
    public static void vibrate(int style) {
        Vibrator vibrator = (Vibrator) UnityPlayer.currentActivity.getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        if (vibrator != null && vibrator.hasVibrator()) {
            switch (style) {
                case 1:
                    vibrator.vibrate(12);
                    break;
                case 2:
                    vibrator.vibrate(25);
                    break;
                case 3:
                    vibrator.vibrate(80);
                    break;
            }
        }
    }


    //
}
