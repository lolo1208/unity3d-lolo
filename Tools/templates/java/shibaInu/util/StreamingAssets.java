package shibaInu.util;

import android.content.res.AssetManager;
import android.util.Log;

import com.unity3d.player.UnityPlayer;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.HashSet;


/**
 * 解析项目包含的文件列表
 * 读取 Unity 项目 streamingAssets 目录下的文件
 * C#FileHelper 调用
 * Created by LOLO on 2018/06/05.
 */
public final class StreamingAssets {

    // Android App AssetManager
    private static AssetManager sAssetMgr = null;
    // streamingAssets 包含的文件列表
    private static HashSet<String> sStreamingAssets = null;


    /**
     * 初始化
     */
    private static void initialize() {
        sAssetMgr = UnityPlayer.currentActivity.getAssets();
        sStreamingAssets = new HashSet<>();
        try {
            String[] list = sAssetMgr.list("");
            for (String item : list) {
                if (item.endsWith(".lua")
                        || item.endsWith(".bytes")
                        || item.endsWith(".ab")
                        || item.endsWith(".scene")
                        || item.endsWith(".cfg")
                        || item.endsWith(".manifest")
                )
                    sStreamingAssets.add(item);
            }

        } catch (Exception e) {
            Log.e("[ShibaInu]", "Java Error: " + e.toString());
        }
    }


    /**
     * 文件是否存在
     */
    public static boolean exists(String filePath) {
        if (sAssetMgr == null) initialize();

        return sStreamingAssets.contains(filePath);
    }


    /**
     * 获取文件的字节内容
     */
    public static byte[] getBytes(String filePath) {
        if (sAssetMgr == null) initialize();

        try {
            InputStream input = sAssetMgr.open(filePath);
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            byte[] buf = new byte[4096];
            int len;
            while ((len = input.read(buf)) != -1)
                output.write(buf, 0, len);
            input.close();
            output.close();
            return output.toByteArray();

        } catch (Exception e) {
            return new byte[0];
        }
    }


    /**
     * 获取文件的字符串内容
     */
    public static String getText(String filePath) {
        if (sAssetMgr == null) initialize();

        try {
            InputStream input = sAssetMgr.open(filePath);
            int size = input.available();
            byte[] buffer = new byte[size];
            input.read(buffer);
            input.close();
            return new String(buffer);

        } catch (Exception e) {
            return "";
        }
    }


    //
}
