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
 * Created by LOLO on 2018/6/5.
 */
public class StreamingAssets {

    private static AssetManager sAssetMgr = null;
    // streamingAssets 包含的文件列表
    private static HashSet<String> sStreamingAssets = null;


    /**
     * 初始化
     */
    private static void initialize() {
        sAssetMgr = UnityPlayer.currentActivity.getAssets();
        sStreamingAssets = new HashSet<>();
        sStreamingAssets.add("ResInfo");// 包资源信息文件
        parseDirAssets("Lua");
        parseDirAssets("Res");
        parseDirAssets("Scenes");
    }


    /**
     * 将目录中的资源添加到 sStreamingAssets 中
     */
    private static void parseDirAssets(String dirPath) {
        try {
            String[] list = sAssetMgr.list(dirPath);
            for (String item : list) {
                item = dirPath + "/" + item;
                if (item.endsWith(".lua") || item.endsWith(".unity3d"))
                    sStreamingAssets.add(item);// 资源文件
                else
                    parseDirAssets(item);// 目录，继续递归
            }

        } catch (Exception e) {
            Log.e("[ShibaInu]", "Java Error:" + e.toString());
        }
    }


    /**
     * 文件是否存在
     *
     * @param filePath
     * @return
     */
    public static boolean exists(String filePath) {
        return sStreamingAssets.contains(filePath);
    }


    /**
     * 获取文件内容
     *
     * @param filePath
     * @return
     */
    public static byte[] getFileBytes(String filePath) {
        if (sStreamingAssets == null)
            initialize();

        try {
            InputStream inputStream = sAssetMgr.open(filePath);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            byte buf[] = new byte[4096];
            int len;
            while ((len = inputStream.read(buf)) != -1)
                outputStream.write(buf, 0, len);
            inputStream.close();
            outputStream.close();
            return outputStream.toByteArray();

        } catch (Exception e) {
            return new byte[0];
        }
    }


    //
}
