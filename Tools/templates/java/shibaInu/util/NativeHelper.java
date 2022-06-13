package shibaInu.util;

import java.util.ArrayList;
import java.util.HashMap;

import javax.security.auth.callback.Callback;

import android.util.Log;

import com.unity3d.player.UnityPlayer;


/**
 * Unity 与 Native 通信相关工具类
 * Created by LOLO on 2020/08/08.
 */
public final class NativeHelper {

    private static final HashMap<Integer, UnityMsgCallback> callbacks = new HashMap<>();
    private static int callbackHandleID = 0;

    public interface UnityMsgCallback extends Callback {
        void invoke(String action, String msg);
    }


    /**
     * 注册一个收到 Unity 消息时的回调
     *
     * @param callback 回调
     * @return handleID
     */
    public static int registerUnityMsgCallback(UnityMsgCallback callback) {
        int handleID = ++callbackHandleID;
        callbacks.put(handleID, callback);
        return handleID;
    }

    /**
     * 移除一个收到 Unity 消息时的回调
     *
     * @param handleID 注册回调时返回的 handleID
     * @return 是否成功找到并移除了 handleID 对应的回调
     */
    public static boolean unregisterUnityMsgCallback(int handleID) {
        if (callbacks.containsKey(handleID)) {
            callbacks.remove(handleID);
            return true;
        }
        return false;
    }


    /**
     * 收到 Unity 发来的消息（该函数由 Unity 调用）
     *
     * @param action action
     * @param msg    message
     */
    private static void onReceiveUnityMessage(String action, String msg) {
        ArrayList<UnityMsgCallback> list = new ArrayList<>(callbacks.values());
        for (UnityMsgCallback callback : list) {
            try {
                callback.invoke(action, msg);
            } catch (Exception e) {
                Log.e("[ShibaInu]", "Java Error: " + e.toString());
            }
        }
    }


    /**
     * 向 Unity 发送消息
     *
     * @param action action
     * @param msg    message
     */
    public static void sendMessageToUnity(String action, String msg) {
        UnityPlayer.UnitySendMessage("[ShibaInu]", "OnReceiveNativeMessage", action + "#" + msg);
    }

    public static void sendMessageToUnity(String action) {
        sendMessageToUnity(action, "");
    }


    //
}
