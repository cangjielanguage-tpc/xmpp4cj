// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.connection.*
import std.collection.*

@Test
public func t1(): Unit {
    @AssertThrows[IllegalArgumentException](ArrayBlockingQueueWithShutdown<Int>(0,false))
    let q = ArrayBlockingQueueWithShutdown<Int>(1)
    @Assert(q.isEmpty(),true)
    @Assert(q.peek().isNone())
    @Assert(q.offer(0))
    @Assert(q.peek(),0)
    @Assert(q.offer(1),false)
    @Assert(q.offer(1,Duration.Zero),false)

    let fur = spawn {
        q.offer(1, Duration.second)
    }
    let res = q.tryTake()
    @Assert(res.getResultCode(),ArrayBlockingQueueWithShutdownTryTakeResultCode.takeSuccessful)
    @Assert(res.getElement(),0)

    @Assert(fur.get())
    println(q.size)
    for (i in q) {
        @Assert(i,1)
    }

    @Assert(q.offerAndShutdown(2),false)
    @Assert(q.start())

    let f2 = spawn {q.putAll([3])}
    @Assert(q.poll(Duration.second),1)
    f2.get()

    @Assert(q.tryPut(4),ArrayBlockingQueueWithShutdownTryPutResult.queueWasFull)
    q.shutdown()
    @Assert(q.tryPut(4),ArrayBlockingQueueWithShutdownTryPutResult.queueWasShutDown)
    @Assert(q.start())
    @Assert(q.take(),3)
    @Assert(q.tryPut(4),ArrayBlockingQueueWithShutdownTryPutResult.putSuccessful)

    let f3 = spawn {q.offer(5, Duration.second * 5)}
    sleep(Duration.millisecond * 50)
    @Assert(q.take(),4)
    @Assert(f3.get())

    q.shutdown()
    @Assert(q.tryTake().getResultCode(),ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasShutDown)

    q.start()
    @Assert(q.tryTake().getElement(),5)
    @Assert(q.tryTake().getResultCode(),ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasEmpty)

    let f4 = spawn {q.poll(Duration.second * 2)}
    sleep(Duration.millisecond * 50)
    q.put(6)
    @Assert(f4.get(),6)

    @Assert(q.remainingCapacity(),1)

    let arr = ArrayList<Int>()
    @Assert(q.drainTo(arr,10),0)

    q.put(7)
    @Assert(q.drainTo(arr,10),1)

    q.put(8)
    let f5 = spawn {q.put(9)}
    @Assert(q.take(),8)
    f5.get()
}

@Test
public func t2(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    q.put(0)
    q.put(1)
    let f1 = spawn {q.put(2)}
    sleep(Duration.millisecond * 50)
    @Assert(q.take(),0)
    f1.get()

    let f2 = spawn {q.offer(3, Duration.second * 5)}
    sleep(Duration.millisecond * 50)
    q.shutdown()
    @AssertThrows[IllegalStateException](f2.get())
}

@Test
public func t3(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    @Assert(q.poll(Duration.Zero).isNone())

    let f2 = spawn {q.poll(Duration.second * 5)}
    sleep(Duration.millisecond * 50)
    q.shutdown()
    @AssertThrows[IllegalStateException](f2.get())
}

@Test
public func t4(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    @Assert(q.drainTo(ArrayList<Int>(), 0),0)
}

@Test
public func t5(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    q.put(0)
    q.clear()
    for (i in q) {
        println(i)
    }
    q.put(0)
    q.put(1)
    let iter = q.iterator()
    q.clear()
    @Assert(iter.next(),0)
}

@Test
public func t6(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    let f1 = spawn {
        sleep(Duration.millisecond * 500)
        q.put(0)
    }
    f1.cancel()
    @AssertThrows[IllegalStateException](f1.get())
}

@Test
public func t7(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    @AssertThrows[NoSuchElementException](q.remove())
}
