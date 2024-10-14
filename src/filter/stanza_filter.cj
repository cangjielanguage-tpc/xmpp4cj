/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**  
 * 定义了一种根据特定属性过滤 Stanza 的方法。Stanza 过滤器用于构建 Stanza 监听器或收集器，
 * 过滤器定义哪些 Stanza 匹配收集器或监听器的标准，以便进行进一步的 Stanza 处理。
 * <p>
 * 预定义了几个简单的过滤器。可以使用 {@link org.jivesoftware.smack.filter.AndFilter AndFilter} 和
 * {@link org.jivesoftware.smack.filter.OrFilter OrFilter} 过滤器逻辑组合这些过滤器，以实现更复杂的
 * Stanza 过滤。也可以通过实现该接口来定义自己的过滤器。下面的代码示例创建了一个用于特定 ID
 * 的 Stanza 的简单过滤器（真实代码应使用 {@link StanzaIdFilter} 替代）。
 *
 * <pre>
 * // 使用匿名内部类定义一个返回所有具有 Stanza ID 为 &quot;RS145&quot; 的 Stanza 的过滤器。
 * StanzaFilter myFilter = new StanzaFilter() {
 *     public boolean accept(Stanza stanza) {
 *         return &quot;RS145&quot;.equals(stanza.getStanzaId());
 *     }
 * };
 * // 使用我们创建的过滤器创建一个新的 Stanza 收集器。
 * StanzaCollector myCollector = connection.createStanzaCollector(myFilter);
 * </pre>
 * <p>
 * 作为经验法则：如果您有一个谓词方法，即一个以单个 Stanza 作为参数、无副作用（纯粹）并且仅返回布尔值
 * 的方法，那么这通常是一个很好的指示，表明该逻辑应该放入 {@link StanzaFilter} 中（并在
 * {@link org.jivesoftware.smack.StanzaListener} 中引用）。
 * </p>
 *
 * @see org.jivesoftware.smack.StanzaCollector
 * @see org.jivesoftware.smack.StanzaListener
 */
public abstract class StanzaFilter <: Predicate<Stanza> & ToString {
    /**  
     * 测试指定的 Stanza 是否应该通过过滤器。
     *
     * @param stanza 要测试的 Stanza。
     * @return 如果且仅如果 <code>stanza</code> 通过过滤器，则返回 true。
     */
    public func accept(stanza: Stanza): Bool

    public override func test(stanza: Stanza): Bool {
        return accept(stanza)
    }

    /**  
     * 将当前过滤器转换为适用于特定 Stanza 类的谓词。
     *
     * @param stanzaClass 要匹配的 Stanza 类。
     * @param <S> Stanza 的子类型。
     * @return 一个谓词，它检查 Stanza 是否与给定类型匹配并通过过滤器。
     */
    public func asPredicate<S, ST>(): Predicate<S> where S <: Stanza {
        LambdaPredicate<S> {
            s: S => if (s is ST) {
                accept(s)
            } else {
                false
            }
        }
    }
}

extend StanzaFilter <: Hashable & Equatable<StanzaFilter> {
    public func hashCode(): Int64 {
        return this.toString().hashCode()
    }
    public operator func ==(that: StanzaFilter): Bool {
        return refEq(this, that)
    }
}
