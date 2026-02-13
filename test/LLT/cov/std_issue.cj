// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.util.*
import cangjie_tpc::xmpp4cj.modular.*
import std.sync.*
import std.collection.*
import std.collection.concurrent.*

@Test
public func test_ConcurrentLinkedQueue(): Unit {
    let obj = ConcurrentLinkedQueue1<String>()
    obj.append("0")
    obj.remove(0)
}

public class ConcurrentLinkedQueue1<T> <: Collection<T> {
    let lock: Monitor = Monitor()
    let list = LinkedList<T>()
    public prop size: Int64 {
        get() {
            synchronized(lock) {
                list.size
            }
        }
    }

    public func append(t: T): Unit {
        // synchronized(lock) {
            list.addLast(t)
        // }
    }

    public func remove(index: Int): ?T {
        // synchronized(lock) {
            var node = list.nodeAt(index)
            if (let Some(n) <- node) {
                let v = n.value
                list.remove(n)
                return v
            }
            return None
        // }
    }

    public override func isEmpty(): Bool {
        throw UnsupportedException()
    }

    public override func iterator(): Iterator<T> {
        throw UnsupportedException()
    }
}
