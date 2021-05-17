using System.IO;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using USceneMgr = UnityEngine.SceneManagement.SceneManager;


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
#if UNITY_EDITOR
                Common.IsDebug = !File.Exists(Constants.ABModeFilePath);
#else
                Common.IsDebug = false;
#endif

                App.ShibaInuExtend.BeforeLaunch();
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
            // 重新进入 Empty 场景
            USceneMgr.LoadScene(Constants.EmptySceneName);
            ResManager.CurrentAssetGroup = Constants.DefaultAssetGroup;
            // 等之前场景的内容清除完毕
            yield return new WaitForEndOfFrame();

            // 首次启动
            if (!Common.Initialized)
            {
                Common.Initialized = true;
                TimeUtil.Initialize();
                Logger.Initialize();
                AudioManager.Initialize();

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
            SceneManager.ClearReference();
            AudioManager.ClearReference();
            SafeAreaLayout.ClearReference();
            LocalizationText.ClearReference();
            ViewPager.ClearReference();
            TcpSocket.ClearReference();
            UdpSocket.ClearReference();
            NetHelper.ClearReference();
            NativeHelper.ClearReference();
            DestroyEventDispatcher.ClearReference();
            PointerEventDispatcher.ClearReference();
            TriggerEventDispatcher.ClearReference();
            DragDropEventDispatcher.ClearReference();
            StageTouchEventDispatcher.ClearReference();
            AvailabilityEventDispatcher.ClearReference();
            Logger.ClearReference();
            App.ShibaInuExtend.ClearReference();

            // unload
            ResManager.UnloadAll();

            // relaunch
            StartCoroutine(Launch());
        }


        //
    }
}