/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

public interface CallbackRecipient<V, E> {
    func onSuccess(successCallback: SuccessCallback<V>): CallbackRecipient<V, E>

    func onError(exceptionCallback: ExceptionCallback<E>): CallbackRecipient<V, E>
}

/*
 * onSuccess
 * @param result:T
 */
public type SuccessCallback<T> = (T) -> Unit

public interface ExceptionCallback<E> {
    func processException(exception: E): Unit
}
