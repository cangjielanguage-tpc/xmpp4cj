/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

public class CloseableUtil {
    /**
     * 关闭资源。
     *
     * @param closable 需要关闭的资源。
     */
    public static func maybeClose<T>(closable: ?T): Unit where T <: Resource {
        maybeClose(closable, None)
    }

    /**
     * 关闭资源。
     *
     * @param closable 需要关闭的资源。
     * @param logger 打印的日志。
     */
    public static func maybeClose<T>(closable: ?T, logger: ?Logger): Unit where T <: Resource {
        let res: Resource = closable ?? return ()

        try {
            res.close()
        } catch (e: Exception) {
            logger?.log(LogLevel.WARN, "Could not close ${anyToString(res)}", e)
        }
    }
}
