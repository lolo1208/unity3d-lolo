using ShibaInu;


namespace App
{
    /// <summary>
    /// ShinaInu 框架在游戏中的扩展
    /// </summary>
    public static class ShibaInuExtend
    {

        /// <summary>
        /// 首次启动前调用
        /// 请在该函数中 赋值初始变量
        /// </summary>
        public static void BeforeLaunch()
        {
            Common.VersionInfo.CoreVersion = "0.0.0.1";

            DeviceHelper.SetScreenOrientation(false);
            Common.IsOptimizeResolution = true;
            Common.FrameRate = 60;
            Common.IsNeverSleep = true;
        }



        /// <summary>
        /// 重启项目（动更完成后）调用，重启项目会销毁 lua state。
        /// 请在该函数中清除对 lua 的静态引用，以及清空或重置其他不会销毁的静态变量。
        /// </summary>
        public static void ClearReference()
        {
        }


        //
    }
}