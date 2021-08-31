# Handler / DelayedCall

###### 本篇将介绍 Handler 以及 DelayedCall 相关内容。

`Handler`
可用于指定执行域（self），携带参数的情况下，执行回调函数。

##### Handler 要点：

 - Handler 在创建（获取）以及调用时，均可传递参数，这可以避免在相关逻辑处临时创建和存储多余的变量和引用。
 - Handler 内部有使用回收池，可避免产生大量的匿名（闭包）函数，这将对 gc 有不少帮助。
 - 在创建 Handler 并传递给其他业务逻辑后，你仍然可以在自己的代码处取消已传递的回调。
 - 在创建只会使用一次的回调时，请使用 handler() 或 OnceHandler()，不要使用 NewHandler()。 

`HandlerRef`
创建（获取）Handler 或使用 DelayedCall 时，持有的都是 HandlerRef 实例，而不是直接持有 Handler 实例。
在项目业务逻辑层，不允许直接持有 Handler 实例，或直接调用 Handler 实例的方法。
对 Handler 的相关操作，可使用下面介绍的系列全局函数。
所有函数以及参数都有详细注释，使用前可跳转至定义处详细了解。

##### 使用示例：
```lua
-- 只会使用一次的回调，使用 handler() 或 OnceHandler() 获取 HandlerRef
Service.Send(Protocols.heartbeat, nil, handler(function(succ, data)
    dump(succ, data)
end))


-- 定时器的 timerHandler 与 timerCompleteHandler 一般都会被多次调用，请使用 NewHandler() 获取 HandlerRef
Timer.New(5, NewHandler(self.fiveSeconds, self))
Timer.New(30, NewHandler(self.halfMinute, self), 4, NewHandler(self.twoMinutes, self))

-- 倒计时的回调也会被多次调用
self.cd = Countdown.New(NewHandler(self.ThreeTwoOne, self), 3000)


-- 在创建或调用 Handler 时，可以使用附带参数 (...) 传递数据
function TestClass:Callback(...)
    print(...)
end
local handlerID = handler(self.Callback, self, 1, 2)
CallHandler(handlerID, "a", "b") -- 调用回调，print: "a", "b", 1, 2

-- 再次使用该 handlerID 来调用 CallHandler() 将会报错，因为使用 handler() 创建的回调只能单次使用
CallHandler(handlerID, "c", "d") -- 这句会报错

-- 改为 NewHandler() 创建回调即可多次调用
local handlerID = NewHandler(self.Callback, self, 1, 2)
CallHandler(handlerID, "a", "b") -- print: "a", "b", 1, 2
CallHandler(handlerID, "c", "d") -- print: "c", "d", 1, 2

-- 取消（清理）回调后，将不能再使用该 HandlerRef 进行相关操作
CancelHandler(handlerID) -- 取消回调
CallHandler(handlerID, "e", "f") -- 这句会报错


-- GetHandlerLambda() 可以获取执行回调的匿名函数。例如：你需要将回调交由 C# 对象执行
self.csObj:SetLuaCallback(GetHandlerLambda(handlerID))


-- 如果你要使用的回调可能会被取消（或 handlerID 值为 nil），可以先使用 HasHandler() 验证后再调用
if HasHandler(handlerID) then
    CancelHandler(handlerID)
end
```

##### 在 DelayedCall 相关内容中：
`真实时间` 指的是自然时间，不受 timeScale，暂停，卡顿，切入后台 等因素的影响。

`游戏时间` 指的是基于 UnityEngine.Time. deltaTime 的时间，该时间与游戏进程（渲染进度）一致。

---

#### Handler
 - `NewHandler()` 获取一个 [会多次使用] 的 Handler 实例（引用）。

 - `OnceHandler()` 获取一个 [只会执行一次] 的 Handler 实例（引用）。
 - `handler()` OnceHandler() 的别名。
 - `CallHandler()` 执行回调。
 - `TryCallHandler()` 执行回调，并捕获回调函数中产生的错误。返回：调用函数是否成功（是否没有报错），以及 callback 函数返回值。
 - `CancelHandler()` 取消回调，清除引用，并将对应的 Handler 回收到池中。
 - `HasHandler()` 回调是否可用（是否为 不是已被调用的单次回调，或没有被取消）。
 - `GetHandlerLambda()` 获取执行回调的匿名函数。

#### DelayedCall
 - `DelayedRealTimeCall()` 在指定真实时间（自然时间）后执行回调。

 - `DelayedDeltaTimeCall()`  在指定游戏时间（deltaTime）后执行回调。
 - `DelayedCall()` DelayedDeltaTimeCall() 的别名。
 - `DelayedFrameCall()` 在指定游戏帧数后执行回调。
 - `DelayedCallWithTarget()` 在指定 游戏时间（默认） 或 真实时间 后执行回调。届时，如果指定的 target 值为 null，将会取消（不执行）回调。
 - `CancelDelayedCall()` 取消延迟回调，清除引用，并将对应的 Handler 回收到池中。
