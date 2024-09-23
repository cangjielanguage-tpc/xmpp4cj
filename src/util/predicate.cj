/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public interface Predicate<T> {
    func test(t: T): Bool
}

/* 
 * 使用lambda构建判定式
 * e.g. let p: Predicate<String> = LambdaPredicate<String>{ x: String => x.size > 0 }
 */
public class LambdaPredicate<S> <: Predicate<S> {
    public LambdaPredicate(let testFunc: (S) -> Bool) {}
    public override func test(s: S): Bool {
        testFunc(s)
    }
}

public type Consumer<T> = (T) -> Unit
