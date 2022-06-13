package shibaInu.app;


import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import com.unity3d.player.UnityPlayer;

import java.util.HashMap;


/**
 * 该工具类用于在 AndroidManifest.xml 中获取 meta-data 标签对应的数据
 * Created by LOLO on 2020/12/25.
 */
public final class MetaDataUtil {


    // 缓存内容
    private static final HashMap<String, Object> cache = new HashMap<>();


    /**
     * 从 AndroidManifest.xml application 标签下获取 key 对应的 meta-data 数据
     *
     * @param key key
     * @return String value or null
     */
    public static String getMetaDataFormApplication(String key) {
        if (cache.containsKey(key))
            return String.valueOf(cache.get(key));

        Activity activity = UnityPlayer.currentActivity;
        String value = "";
        try {
            ApplicationInfo appInfo = activity.getPackageManager().getApplicationInfo(
                    activity.getPackageName(),
                    PackageManager.GET_META_DATA
            );
            value = appInfo.metaData.getString(key);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        cache.put(key, value);
        return value;
    }


    //
}
