/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/*
 * 用于定义那些需要在一定延迟后进行处理的对象
 * 使用getDelay方法获取还需延迟多久才能执行此Action
 * 实现了Comparable接口以进行Action优先级排序
 */
public class ScheduledAction <: Comparable<ScheduledAction> & Delayed {
    private let action: Runnable // 要执行的任务

    let releaseTime: DateTime //动作的释放时间

    let xmppReactor: XmppReactor //关联的 XmppReactor 实例

    let kind: ScheduledActionKind //动作的类型（非阻塞或阻塞）

    /**  
     * 创建一个新的调度动作实例。
     *
     * @param action 要执行的任务
     * @param releaseTime 动作释放的时间
     * @param xmppReactor 关联的 XmppReactor 实例
     * @param kind 动作的类型（非阻塞或阻塞）
     */
    init(action: Runnable, releaseTime: DateTime, xmppReactor: XmppReactor, kind: ScheduledActionKind) {
        this.action = action
        this.releaseTime = releaseTime
        this.xmppReactor = xmppReactor
        this.kind = kind
    }

    /**  
     * 取消此调度动作。
     *
     * @return <code>true</code> 如果调度动作仍处于待处理状态并已被移除，<code>false</code> 否则。
     */
    public func cancel(): Bool {
        return xmppReactor.cancel(this)
    }

    /**  
     * 检查该动作是否已经到期。
     *
     * @return <code>true</code> 如果当前时间已超过释放时间，<code>false</code> 否则。
     */
    public func isDue(): Bool {
        let now = DateTime.now()
        return now > releaseTime
    }

    /**  
     * 获取距离到期的毫秒数。
     *
     * @return 距离到期的毫秒数，如果动作已经到期，则返回负值。
     */
    public func getTimeToDueMillis(): Duration {
        let now = DateTime.now()
        return releaseTime - now
    }

    /**  
     * 比较此调度动作与另一个延迟对象的延迟时间。
     *
     * @param otherDelayed 另一个延迟对象
     * @return 如果此对象在时间上小于、等于或大于另一个对象，则返回负值、零或正值。
     */
    public override func compare(otherDelayed: ScheduledAction): Ordering {
        if (refEq(this, otherDelayed)) {
            return Ordering.EQ
        }
        let thisDelay = getDelay()
        let otherDelay = otherDelayed.getDelay()
        return thisDelay.compare(otherDelay)
    }

    /**  
     * 获取此调度动作的延迟时间。
     *
     * @param unit 返回的时间单位
     * @return 此调度动作的延迟时间，单位为指定的时间单位。
     */
    public override func getDelay(): Duration {
        let delayInMillis = getTimeToDueMillis()
        return delayInMillis
    }

    /**  
     * 执行调度的动作，根据动作类型选择执行方式。
     */
    func run(): Unit {
        match (kind) {
            case ScheduledActionKind.NonBlocking => action()
            case ScheduledActionKind.Blocking => Async.go(action)
        }
    }
}

/**  
 * <p>表示操作的类型，可以是非阻塞或阻塞。此枚举用于区分不同的操作模式。</p>
 */
public enum ScheduledActionKind {
    /**  
     * 非阻塞操作。
     * <p>在此模式下，操作不会阻塞调用线程，调用者可以继续执行其他任务。</p>
     */
    | NonBlocking
    /**  
     * 阻塞操作。
     * <p>在此模式下，操作会阻塞调用线程，直到操作完成。</p>
     */
    | Blocking
}
