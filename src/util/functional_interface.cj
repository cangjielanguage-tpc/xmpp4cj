/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * 定义一个公共接口 Predicate，表示一个接受类型为 T 的参数并返回布尔值的测试函数。
 */
public interface Predicate<T> {
    /**
     * 定义一个抽象方法 test，接受参数 t，返回一个布尔值。
     *
     * @param t 泛型T。
     * @return 布尔值。
     */
    func test(t: T): Bool
}

/* 
 * 定义一个泛型类 LambdaPredicate，它实现了 Predicate 接口。
 * 使用lambda构建判定式
 * e.g. let p: Predicate<String> = LambdaPredicate<String>{ x: String => x.size > 0 }
 */
public class LambdaPredicate<S> <: Predicate<S> {
    /**
     * 构造方法。
     *
     * @param testFunc 方法。
     */
    public LambdaPredicate(let testFunc: (S) -> Bool) {}

    /**
     * 重写 test 方法，实现 Predicate 接口。
     *
     * @param t 泛型S。
     * @return 布尔值。
     */
    public override func test(s: S): Bool {
        testFunc(s)
    }
}

public type Consumer<T> = (T) -> Unit

public type Supplier<T> = () -> T

public type Runnable = () -> Unit

/* 将Runnable在spawn中执行 */
public type Executor = (Runnable) -> Unit
