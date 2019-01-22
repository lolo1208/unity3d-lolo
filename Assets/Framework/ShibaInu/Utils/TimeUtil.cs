using System;
using System.Diagnostics;


namespace ShibaInu
{
	/// <summary>
	/// 时间相关工具
	/// </summary>
	public class TimeUtil
	{
		private static Stopwatch s_stopwatch;

		/// 当前程序已运行时间（秒.毫秒）
		public static float timeSec;
		/// 当前程序已运行时间（毫秒）
		public static UInt32 timeMsec;


		public static void Initialize ()
		{
			s_stopwatch = new Stopwatch ();
			s_stopwatch.Start ();
		}



		/// <summary>
		/// Updates the time.
		/// </summary>
		public static void Update ()
		{
			long value = s_stopwatch.ElapsedMilliseconds;
			timeSec = (float)value / 1000;
			timeMsec = Convert.ToUInt32 (value);
		}



		public static float GetTimeSec ()
		{
			Update ();
			return timeSec;
		}


		public static UInt32 GetTimeMsec ()
		{
			Update ();
			return timeMsec;
		}


		//
	}
}

