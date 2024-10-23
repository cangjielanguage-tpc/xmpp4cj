/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.proxy

/**
 * 处理由代理引发的异常的异常类。
 */
public class ProxyException <: Exception {
    /**  
     * 根据代理类型和异常信息构造 ProxyException。
     *
     * @param type 代理类型
     * @param ex 异常信息
     */
    public init(proxyInfoProxyType: ProxyInfoProxyType, ex: String) {
        super("Proxy Exception ${proxyInfoProxyType.toString()} : ${ex}")
    }

    /**  
     * 根据代理类型构造 ProxyException，使用默认的未知错误信息。
     *
     * @param type 代理类型
     */
    public init(proxyInfoProxyType: ProxyInfoProxyType) {
        super("Proxy Exception ${proxyInfoProxyType.toString()} : Unknown Error")
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "ProxyException"
    }
}
