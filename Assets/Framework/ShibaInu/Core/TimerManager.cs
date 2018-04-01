using System;
using System.Diagnostics;
using System.Collections.Generic;
using UnityEngine;


namespace ShibaInu
{
	/// <summary>
	/// 定时器实例对象（C#层使用的定时器）
	/// </summary>
	public class Timer
	{
		/// 定时器触发间隔（毫秒）
		public int delay;
		/// 定时器是否正在运行中
		public bool running;
		/// 定时器当前已运行次数
		public int currentCount;
		/// 定时器的总运行次数，0 表示无限次数
		public int repeatCount;
		/// 定时器上次触发时间
		public long lastUpdateTime;
		/// 定时器每次触发的回调
		public Action<Timer> callback;
		/// 附带的数据
		public System.Object data;


		/// <summary>
		/// 启动定时器
		/// </summary>
		public void Start ()
		{
			Common.timerMgr.StartTimer (this);
		}

		/// <summary>
		/// 停止定时器
		/// </summary>
		public void Stop ()
		{
			Common.timerMgr.StopTimer (this);
		}

	}


	/// <summary>
	/// 定时器管理（C#层使用的定时器）
	/// </summary>
	public class TimerManager : MonoBehaviour
	{
		/// 正在运行中的定时器列表
		private HashSet<Timer> m_runningTimers;
		/// 运行状态有变化的定时器列表
		private HashSet<Timer> m_changedTimers;
		/// 用于精确计时
		private Stopwatch m_stopwatch;


		void Awake ()
		{
			m_stopwatch = new Stopwatch ();
			m_stopwatch.Start ();
			m_runningTimers = new HashSet<Timer> ();
			m_changedTimers = new HashSet<Timer> ();
		}


		void Update ()
		{
			// 根据 timer.running 在 m_runningTimers 中添加或移除
			foreach (Timer timer in m_changedTimers) {
				if (timer.running)
					m_runningTimers.Add (timer);
				else
					m_runningTimers.Remove (timer);
			}
			m_changedTimers.Clear ();


			long curTime = m_stopwatch.ElapsedMilliseconds;
			bool ignorable;
			int delay;
			foreach (Timer timer in m_runningTimers) {
				if (!timer.running)
					continue;

				int count = Mathf.FloorToInt ((curTime - timer.lastUpdateTime) / timer.delay);// 计算次数用以解决丢帧和加速
				// 次数过多，忽略掉（可能是系统休眠后恢复）
				if (count > 999) {
					ignorable = true;
					count = 1;
				} else {
					ignorable = false;
				}

				if (count == 0)
					continue;// 还没达到间隔

				delay = timer.delay;
				for (int i = 0; i < count; i++) {
					if (!timer.running)
						break;// 定时器在回调中被停止了

					if (timer.delay != delay)
						break;// 定时器在回调中更改了delay

					// 执行回调
					timer.currentCount++;
					if (timer.callback != null)
						timer.callback (timer);

					// 定时器已到达允许运行的最大次数
					if (timer.repeatCount != 0 && timer.currentCount >= timer.repeatCount) {
						StopTimer (timer);
						break;// 可以忽略后面的计次了
					}

					// 更新上次触发的时间
					timer.lastUpdateTime = (ignorable || timer.delay != delay) ? curTime : timer.lastUpdateTime + delay * count;
				}
			}
		}


		/// <summary>
		/// 创建并运行一个指定次数的计时器
		/// </summary>
		/// <param name="delay">Delay.</param>
		/// <param name="repeatCount">定时器的总运行次数，0 表示无限次数</param>
		/// <param name="callback">Callback.</param>
		/// <param name="data">Data.</param>
		public Timer Create (int delay, int repeatCount, Action<Timer> callback, System.Object data = null)
		{
			Timer timer = new Timer ();
			timer.delay = delay;
			timer.repeatCount = repeatCount;
			timer.callback = callback;
			timer.data = data;

			StartTimer (timer);

			return timer;
		}


		/// <summary>
		/// 创建并运行一个只运行一次的定时器
		/// </summary>
		/// <returns>The timer.</returns>
		/// <param name="delay">Delay.</param>
		/// <param name="callback">Callback.</param>
		/// <param name="data">Data.</param>
		public Timer Once (int delay, Action<Timer> callback, System.Object data = null)
		{
			return Create (delay, 1, callback, data);
		}


		/// <summary>
		/// 启动定时器
		/// </summary>
		/// <param name="timer">Timer.</param>
		public void StartTimer (Timer timer)
		{
			timer.lastUpdateTime = m_stopwatch.ElapsedMilliseconds;
			timer.running = true;
			m_changedTimers.Add (timer);
		}


		/// <summary>
		/// 停止定时器
		/// </summary>
		/// <param name="timer">Timer.</param>
		public void StopTimer (Timer timer)
		{
			timer.running = false;
			m_changedTimers.Add (timer);
		}

		//
	}
}

