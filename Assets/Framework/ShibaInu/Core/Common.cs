using System;
using UnityEngine;


namespace ShibaInu
{
	public class Common
	{
		
		/// 项目帧频
		public static int FrameRate;
		/// 固定宽度
		public static int FixedWidth = 1136;
		/// 是否按 FixedWidth 等比降低分辨率
		public static bool OptimizeResolution;
		/// 是否永不休眠
		public static bool NeverSleep;
		/// 是否在编辑器中运行，并且在开发模式下
		public static bool isDebug = false;


		/// 不会被销毁的 GameObject
		public static GameObject go;

		public static Looper looper;
		public static LuaManager luaMgr;

	}
}

