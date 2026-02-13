/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.util

/**
 * 日志相关。
 */
public interface LogExt {
    /**
     * 日志。
     *
     * @param logLevel 日志等级。
     * @param msg 内容。
     * @param error 异常信息。
     */
    func log(logLevel: LogLevel, msg: String, error: Exception): Unit
    /**
     * 判断日志等级。
     *
     * @param level 日志等级。
     * @return 判断日志等级。
     */
    func isLoggable(level: LogLevel): Bool
}

/**
 * 扩展日志相关。
 */
extend Logger <: LogExt {
    /**
     * 日志。
     *
     * @param logLevel 日志等级。
     * @param msg 内容。
     * @param error 异常信息。
     */
    public func log(logLevel: LogLevel, msg: String, error: Exception): Unit {
        this.log(logLevel, msg, ("exception", error))
    }
    /**
     * 判断日志等级。
     *
     * @param level 日志等级。
     * @return 判断日志等级。
     */
    public func isLoggable(level: LogLevel): Bool {
        level >= this.level
    }
}

public func getGlobalLogger(loggerName: String): Logger {
    getGlobalLogger(("name", loggerName))
}

public let DEBUGER = getGlobalLogger("DEBUGER")
