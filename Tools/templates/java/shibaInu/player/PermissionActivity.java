package shibaInu.player;


import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;

import com.unity3d.player.UnityPlayerActivity;

import java.util.List;

import pub.devrel.easypermissions.AppSettingsDialog;
import pub.devrel.easypermissions.EasyPermissions;
import shibaInu.util.NativeHelper;


/**
 * 实现 EasyPermissions 库的 Activity
 * dependencies:
 * implementation 'pub.devrel:easypermissions:2.0.1'
 * see also:
 * https://github.com/googlesamples/easypermissions
 * Created by LOLO on 2022/06/09.
 */
public class PermissionActivity extends UnityPlayerActivity implements EasyPermissions.PermissionCallbacks {

    // 与 Unity 通信的 Action
    private static final String UN_ACT_REQUEST_PERMISSIONS = "requestPermissions";
    // 获取权限成功回复给 Unity 的消息
    private static final String UN_MSG_GRANTED = "granted";
    // 获取权限失败回复给 Unity 的消息
    private static final String UN_MSG_DENIED = "denied";

    // 正在申请权限的请求信息
    private int mRequestCode;
    private String[] mPermissions;
    private String[] mSettingsDialog;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        NativeHelper.registerUnityMsgCallback(this::onReceiveUnityMessage);
    }


    /**
     * 收到 Unity 发来的消息
     *
     * @param act action
     * @param msg message requestCode|rationale|permission,permission...
     */
    private void onReceiveUnityMessage(String act, String msg) {
        if (!act.equals(UN_ACT_REQUEST_PERMISSIONS))
            return;

        String[] arr = msg.split("\\|");
        int requestCode = Integer.parseInt(arr[0]);
        String rationale = arr[1];
        String[] permissions = arr[2].split(",");
        String[] settingsDialog = arr[3].split("#");

        if (EasyPermissions.hasPermissions(this, permissions)) {
            // 已授权
            responsePermissionsResult(requestCode, true);
        } else {
            // 未授权
            if (mRequestCode != 0) {
                // EasyPermissions 不能同时发起多次权限请求。当有权限申请正在进行中时，直接返回无权限
                responsePermissionsResult(requestCode, false);
            } else {
                mRequestCode = requestCode;
                mPermissions = permissions;
                mSettingsDialog = settingsDialog;
                EasyPermissions.requestPermissions(this, rationale, requestCode, permissions);
            }
        }
    }


    /**
     * 回应 Unity 授权是否成功
     *
     * @param requestCode 请求追踪码
     * @param isGranted   true:成功授权，false:授权被拒
     */
    private void responsePermissionsResult(int requestCode, boolean isGranted) {
        // 当前进行中的权限申请请求结束了
        if (requestCode == mRequestCode)
            mRequestCode = 0;
        String msg = requestCode + "|" + (isGranted ? UN_MSG_GRANTED : UN_MSG_DENIED);
        NativeHelper.sendMessageToUnity(UN_ACT_REQUEST_PERMISSIONS, msg);
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        // 交由 EasyPermissions 处理授权结果
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }


    @Override
    public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {
        // 请求权限成功
        responsePermissionsResult(requestCode, true);
    }


    @Override
    public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
        // 请求权限被拒，并且勾选了不再提示
        if (EasyPermissions.somePermissionPermanentlyDenied(this, perms)) {
            // 引导用户前往设置界面自行开启权限对话框
            new AppSettingsDialog.Builder(this)
                    .setTitle(mSettingsDialog[0])
                    .setRationale(mSettingsDialog[1])
                    .setPositiveButton(mSettingsDialog[2])
                    .setNegativeButton(mSettingsDialog[3])
                    .build().show();
        } else {
            responsePermissionsResult(requestCode, false);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // 从设置界面返回时
        if (requestCode == AppSettingsDialog.DEFAULT_SETTINGS_REQ_CODE) {
            responsePermissionsResult(mRequestCode, EasyPermissions.hasPermissions(this, mPermissions));
        }
    }


    //
}
