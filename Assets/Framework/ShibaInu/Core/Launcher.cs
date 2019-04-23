using System;
using System.IO;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;


namespace ShibaInu
{
    /// <summary>
    /// 项目启动器，启动与重启相关逻辑
    /// </summary>
    public class Launcher : MonoBehaviour
    {

        void Start()
        {
            // 首次启动
            if (!Common.Initialized)
            {
                // 初始变量赋值
                Common.FixedValue = 640;
                Common.IsFixedWidth = false;
                DeviceHelper.SetScreenOrientation(true);
                Common.IsOptimizeResolution = true;
                Common.FrameRate = 60;
                Common.IsNeverSleep = true;
#if UNITY_EDITOR
                Common.IsDebug = !File.Exists(Constants.ABModeFilePath);
#endif

                StartCoroutine(Launch());

            }
            else
            {
                // 动更完重启
                Relaunch();
            }
        }



        /// <summary>
        /// 启动
        /// </summary>
        private IEnumerator Launch()
        {
            // 先进入启动场景
            if (SceneManager.GetActiveScene().name != Constants.LauncherSceneName)
                SceneManager.LoadScene(Constants.LauncherSceneName);
            // 等之前场景的内容清除完毕
            yield return new WaitForEndOfFrame();

            // 首次启动
            if (!Common.Initialized)
            {
                Common.Initialized = true;
                TimeUtil.Initialize();
                Logger.Initialize();

                // EventSystem
                GameObject eventSystem = new GameObject("EventSystem");
                eventSystem.AddComponent<EventSystem>();
                eventSystem.AddComponent<StandaloneInputModule>();
                eventSystem.transform.SetParent(transform);
            }

            ResManager.Initialize();
            Stage.Initialize();

            Common.looper = gameObject.AddComponent<Looper>();
            Common.luaMgr = gameObject.AddComponent<LuaManager>();
            Common.luaMgr.Initialize();// start lua

            Destroy(this);
        }



        /// <summary>
        /// 重启项目（动更完成后）
        /// </summary>
        private void Relaunch()
        {
            // destroy
            Common.luaMgr.Destroy();
            Destroy(Common.looper);
            Destroy(Stage.uiCanvas.gameObject);

            // clear reference
            Stage.ClearReference();
            SafeAreaLayout.ClearReference();
            LocalizationText.ClearReference();
            ViewPager.ClearReference();
            TcpSocket.ClearReference();
            UdpSocket.ClearReference();
            DestroyEventDispatcher.ClearReference();
            PointerEventDispatcher.ClearReference();
            TriggerEventDispatcher.ClearReference();
            DragDropEventDispatcher.ClearReference();
            StageTouchEventDispatcher.ClearReference();
            AvailabilityEventDispatcher.ClearReference();

            // unload
            ResManager.UnloadAll();

            // relaunch
            StartCoroutine(Launch());
        }


        //
    }
}