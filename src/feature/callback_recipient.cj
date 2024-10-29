/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.feature

/**  
 * 回调接收者接口，用于处理成功和错误回调。
 * <p>
 * 该接口提供了注册成功和错误回调的方法，以实现异步处理的机制。
 * </p>
 *
 * @param <V> 成功时返回的结果类型
 * @param <E> 错误时返回的异常类型
 */
public interface CallbackRecipient<V, E> {
    /**  
     * 注册成功回调。
     *
     * @param successCallback 成功时调用的回调函数
     * @return 当前的 CallbackRecipient 实例，以支持链式调用
     */
    func onSuccess(successCallback: SuccessCallback<V>): CallbackRecipient<V, E>

    /**  
     * 注册错误回调。
     *
     * @param exceptionCallback 错误时调用的回调函数
     * @return 当前的 CallbackRecipient 实例，以支持链式调用
     */
    func onError(exceptionCallback: ExceptionCallback<E>): CallbackRecipient<V, E>
}

/*
 * onSuccess
 * @param result:T
 */
public type SuccessCallback<T> = (T) -> Unit

/**  
 * 异常回调接口，用于处理异常。
 * <p>
 * 该接口定义了一个方法，在发生异常时被调用以处理相应的异常情况。
 * </p>
 *
 * @param <E> 异常的类型
 */
public interface ExceptionCallback<E> {
    /**  
     * 处理异常的方法。
     *
     * @param exception 要处理的异常
     */
    func processException(exception: E): Unit
}
