/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.connection

/**
 * - 前提:
 *     1. cangjie不能打包资源文件
 *         - 可以使用与so/dll分离的资源文件 但不好向下游分发
 *     2. 本库被限制不能使用反射
 *     3. Initializer原理:
 *         - 大部分Initializer主要为了初始化`Config`和`Provider`
 *         - Config目的是触发加载类静态资源 这通过import相应的类 可以自动达成
 *         - Provider目的是将自定义Provider注册到ProviderManager
 * - 结果:
 *     - 基于配置文件初始化的方式不可能实现
 *     - 失去反射意味着不可能自动执行Initializer
 * - 解决:
 *     1. 子Initializer各自将自己注册到某个集中的地方 随后集中{@link initialize()}
 *         - 暂不提供
 *     2. 子Initializer各自通过{@code static init()}执行{@link initialize()}
 * - 示例:
 * ```
 * class MyInitializer <: XmppInitializer{
 *     static init(){
 *         MyInitializer().initialize()
 *     }
 *     public override func initialize(): Collection<Exception>{
 *         /* 直接使用ProviderManager添加自定义Provider */
 *
 *         // 通过自定义ProviderLoader 添加Provider
 *         ProviderManager.addLoader(...)
 *
 *         // 直接添加Provider
 *         ProviderManager.addIQProvider(...)
 *         ProviderManager.addExtensionProvider(...)
 *         ProviderManager.addStreamFeatureProvider(...)
 *
 *         return []
 *     }
 * }
 * ```
 */
public interface XmppInitializer {
    /*
     * 初始化模块
     * @return 可能产生的异常
     */
    func initialize(): Collection<Exception> {
        throw UnsupportedException()
    }
}
