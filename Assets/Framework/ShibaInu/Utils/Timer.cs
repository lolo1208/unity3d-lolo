using System;
using System.Collections.Generic;
using UnityEngine;


namespace ShibaInu
{
    /// <summary>
    /// C# 层使用的定时器
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
        public uint lastUpdateTime;
        /// 定时器每次触发的回调
        public Action<Timer> callback;
        /// 附带的数据
        public object data;


        /// <summary>
        /// 启动定时器
        /// </summary>
        public void Start()
        {
            lastUpdateTime = TimeUtil.GetTimeMsec();
            running = true;
            s_changedTimers.Add(this);
        }

        /// <summary>
        /// 停止定时器
        /// </summary>
        public void Stop()
        {
            running = false;
            s_changedTimers.Add(this);
        }




        /// 正在运行中的定时器列表
        private static readonly HashSet<Timer> s_runningTimers = new HashSet<Timer>();
        /// 运行状态有变化的定时器列表
        private static readonly HashSet<Timer> s_changedTimers = new HashSet<Timer>();


        /// <summary>
        /// 更新定时器
        /// </summary>
        public static void Update()
        {
            // 根据 timer.running 在 m_runningTimers 中添加或移除
            foreach (Timer timer in s_changedTimers)
            {
                if (timer.running)
                    s_runningTimers.Add(timer);
                else
                    s_runningTimers.Remove(timer);
            }
            s_changedTimers.Clear();

            uint curTime = TimeUtil.timeMsec;
            bool ignorable;
            int delay;
            foreach (Timer timer in s_runningTimers)
            {
                if (!timer.running)
                    continue;

                // 计算次数用以解决丢帧和加速
                int count = Mathf.FloorToInt((curTime - timer.lastUpdateTime) / timer.delay);

                // 次数过多，忽略掉（可能是系统休眠后恢复）
                if (count > 999)
                {
                    ignorable = true;
                    count = 1;
                }
                else
                {
                    ignorable = false;
                }

                if (count == 0)
                    continue;// 还没达到间隔

                delay = timer.delay;
                for (int i = 0; i < count; i++)
                {
                    if (!timer.running)
                        break;// 定时器在回调中被停止了

                    if (timer.delay != delay)
                        break;// 定时器在回调中更改了delay

                    // 执行回调
                    timer.currentCount++;
                    if (timer.callback != null)
                    {
                        try
                        {
                            timer.callback(timer);
                        }
                        catch (Exception e)
                        {
                            Logger.LogException(e);
                        }
                    }

                    // 定时器已到达允许运行的最大次数
                    if (timer.repeatCount != 0 && timer.currentCount >= timer.repeatCount)
                    {
                        timer.Stop();
                        break;// 可以忽略后面的计次了
                    }

                    // 更新上次触发的时间
                    timer.lastUpdateTime = (ignorable || timer.delay != delay) ? curTime : timer.lastUpdateTime + Convert.ToUInt32(delay * count);
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
        public static Timer Create(int delay, int repeatCount, Action<Timer> callback, object data = null)
        {
            Timer timer = new Timer
            {
                delay = delay,
                repeatCount = repeatCount,
                callback = callback,
                data = data
            };
            timer.Start();

            return timer;
        }


        /// <summary>
        /// 创建并运行一个只运行一次的定时器
        /// </summary>
        /// <returns>The timer.</returns>
        /// <param name="delay">Delay.</param>
        /// <param name="callback">Callback.</param>
        /// <param name="data">Data.</param>
        public static Timer Once(int delay, Action<Timer> callback, object data = null)
        {
            return Create(delay, 1, callback, data);
        }


        //
    }
}

