package shibaInu.util;

import android.os.Vibrator;
import android.content.Context;

import com.unity3d.player.UnityPlayer;


/**
 * 设备相关工具类
 * Created by LOLO on 2019/03/07.
 */
public final class DeviceHelper {


    /**
     * 设备震动反馈
     * ƒ
     *
     * @param style 震动方式 [ 1:轻微, 2:明显, 3:强烈 ]
     */
    public static void vibrate(int style) {
        Vibrator vibrator = (Vibrator) UnityPlayer.currentActivity.getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        if (vibrator != null && vibrator.hasVibrator()) {
            switch (style) {
                case 1:
                    vibrator.vibrate(20);
                    break;
                case 2:
                    vibrator.vibrate(50);
                    break;
                case 3:
                    vibrator.vibrate(100);
                    break;
            }
        }
    }


    //
}
