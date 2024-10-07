/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/**
 * 异步工具类。
 */
public class Async {
    /**
     * 使用给定的Runnable创建一个新线程，将其标记为守护进程，启动它并返回已启动的线程。
     *
     * @param runnable 子线程
     * @return 已启动的线程。
     */
    public static func go(runnable: Runnable): Future<Unit> {
        let thread = daemonThreadFrom(runnable)
        return thread
    }

    /**
     * 使用给定的Runnable创建一个新线程，将其标记为守护进程，设置名称，启动它并返回已启动的线程。
     *
     * @param runnable 子线程
     * @param threadName 线程名称。
     * @return 已启动的线程。
     */
    public static func go(runnable: Runnable, threadName: String): Future<Unit> {
        spawn {
            Thread.currentThread.name = threadName
            runnable()
        }
    }

    /**
     * 使用给定的Runnable创建一个新线程，将其标记为守护进程，启动它并返回已启动的线程。
     *
     * @param runnable 子线程
     * @return 已启动的线程。
     */
    public static func daemonThreadFrom(runnable: Runnable): Future<Unit> {
        spawn {
            runnable()
        }
    }
}
