/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.compress

/**  
 * CompressedProvider 类是一个解析器，用于解析 XMPP 中的压缩非自定义数据（Nonza）元素。
 * <p>
 * 该类实现了 NonzaProvider 接口，专门用于创建和处理 Compressed 实例。
 * </p>
 */
public class CompressedProvider <: NonzaProvider<Compressed> {
    /**  
     * CompressedProvider 的单例实例。
     */
    public static let INSTANCE = CompressedProvider()

    /**  
     * 私有构造函数，防止外部创建实例。
     * <p>
     * 由于采用单例模式，只允许创建一个 CompressedProvider 实例。
     * </p>
     */
    private init() {
        super("Compressed")
    }

    /**  
     * 解析给定的 XML 拉解析器中的压缩元素。
     *
     * @param _        用于读取 XML 内容的 XmlPullParser。
     * @param _  初始的 XML 深度。
     * @param _ 与 XML 解析相关的环境信息。
     * @return 返回 Compressed 实例，表示解析出的压缩元素。
     */
    public override func parse(_: XmlPullParser, _: Int, _: ?XmlEnvironment): Compressed {
        return Compressed.INSTANCE
    }
}
