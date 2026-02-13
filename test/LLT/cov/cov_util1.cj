// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.util.*
import cangjie_tpc::xmpp4cj.modular.*
import std.sync.*
import std.collection.*
import std.collection.concurrent.*
import std.time.*
import std.io.*
import std.fs.*

@Test
public func test_Async(): Unit {
    let arr = [0]
    let fur = Async.go {
        => arr[0] = 1
    }
    fur.get()
    @Assert(arr[0], 1)
    let fur1 = Async.daemonThreadFrom {
        => arr[0] = 2
    }
    fur1.get()
    @Assert(arr[0], 2)
}

@Test
public func test_ByteUtils(): Unit {
    let arr = [0u8]
    let arr1 = [1u8]
    let arr2 = ByteUtils.concat(arr, arr1)
    @Assert(arr2[0], 0)
    @Assert(arr2[1], 1)
}

@Test
public func test_anyClassId(): Unit {
    let obj = CompressionStateDescriptor()
    let classid = anyClassId(obj)
    @Assert(classid, "CompressionStateDescriptor")
}

class ExceptionCloseable <: Resource {
    public func isClosed(): Bool {
        false
    }
    public func close(): Unit {
        throw Exception("error")
    }
}

@Test
public func test_CloseableUtil(): Unit {
    let obj = ExceptionCloseable()
    CloseableUtil.maybeClose(obj)
}

@Test
public func test_CollectionBlockingQueue(): Unit {
    var obj = CollectionBlockingQueue<String>(1)
    @Assert(obj.size, 0)
    @Assert(obj.isEmpty(), true)
    let arr = ArrayBlockingQueue<String>(5)
    obj = CollectionBlockingQueue<String>(arr)
    arr.enqueue("1")
    @Assert(obj.iterator().next(), "1")
}

@Test
public func test_CollectionUtil(): Unit {
    let arr: Array<String> = []
    @AssertThrows[IllegalArgumentException](CollectionUtil.requireNotEmpty(arr,"arr"))
}

@Test
public func test_Collections(): Unit {
    let m = HashMap<String, String>([("0", "0")])
    let obj = Collections.unmodifiableMap(m)
    @Assert(obj.get("0"),"0")
    @Assert(obj.contains("0"))
    @Assert(obj.contains(all:["0"]))
    @AssertThrows[UnsupportedException](obj.add("1","1"))
    @AssertThrows[UnsupportedException](obj.add(all:[("1","1")]))
    @AssertThrows[UnsupportedException](obj.remove("1"))
    @AssertThrows[UnsupportedException](obj.remove(all:["1"]))
    @AssertThrows[UnsupportedException](obj.removeIf{_,_ => true})
    @AssertThrows[UnsupportedException](obj.clear())
    // @AssertThrows[UnsupportedException](obj.clone())
    @Assert(obj["0"],"0")
    @AssertThrows[UnsupportedException](obj["0"] = "1")
    @Assert(obj.keys().size, 1)
    @Assert(obj.values().size, 1)
    @Assert(obj.size, 1)
    @Assert(obj.isEmpty(), false)
    @Assert(obj.iterator().next()?[0], "0")
}

@Test
public func test_Collections1(): Unit {
    let obj = Collections.EMPTY_STRING_MAP
    @Assert(obj.get("0"),None)
    @Assert(obj.contains("0"), false)
    @Assert(obj.contains(all:["0"]), false)
    @AssertThrows[UnsupportedException](obj.add("1","1"))
    @AssertThrows[UnsupportedException](obj.add(all:[("1","1")]))
    @AssertThrows[UnsupportedException](obj.remove("1"))
    @AssertThrows[UnsupportedException](obj.remove(all:["1"]))
    @AssertThrows[UnsupportedException](obj.removeIf{_,_ => true})
    obj.clear()
    // @AssertThrows[UnsupportedException](obj.clone())
    @AssertThrows[UnsupportedException](obj["0"])
    @AssertThrows[UnsupportedException](obj["0"] = "1")
    @Assert(obj.keys().size, 0)
    @Assert(obj.values().size, 0)
    @Assert(obj.size, 0)
    @Assert(obj.isEmpty(), true)
    @Assert(obj.iterator().next().isNone())
}

@Test
public func test_ConcurrentLinkedQueue(): Unit {
    let obj = ConcurrentLinkedList<String>()
    obj.append("0")
    // synchronized(obj.lock) {
    //     obj.list.prepend("0")
    // }
    @Assert(obj.size,1)
    // synchronized(obj.lock) {
    //     var node = obj.list.nodeAt(0)
    //     if (let Some(n) <- node) {
    //         obj.list.remove(n)
    //         // return n.value
    //     }
    //     // return None
    // }
    // obj.remove(0)
    @Assert(obj.remove(0),'0')
    obj.prepend('1')
    obj.clear()
    @Assert(obj.size,0)
    obj.append("3")
    obj.prepend('4')
    @Assert(obj.reverseIterator().next(),'3')
}

@Test
public func test_ConcurrentSet(): Unit {
    let obj = ConcurrentSet<Int64>()
    obj.put(0)
    obj.put(0)
    @Assert(obj.size, 1)
    obj.clear()
    @Assert(obj.size, 0)
    obj.put(1)
    obj.remove(0)
    @Assert(obj.size, 1)
    obj.remove(1)
    @Assert(obj.size, 0)
}

class Delayable <: Delayed & Comparable<Delayable> {
    Delayable(let id: Int64, let deadline: DateTime) {}
    public override func getDelay(): Duration {
        deadline - DateTime.now()
    }
    public override func compare(that: Delayable): Ordering {
        deadline.compare(that.deadline)
    }
}

@Test
public func test_DelayQueue(): Unit {
    let obj = DelayQueue<Delayable>()
    let now = DateTime.now()
    let item2 = Delayable(2, now + Duration.second * 2)
    obj.append(item2)
    obj.append(Delayable(1, now + Duration.second))
    obj.append(Delayable(3, now + Duration.second * 3))
    @Assert(obj.poll().isNone())
    @Assert(obj.take()?.id,1)

    let remove1 = obj.remove(Delayable(2, now + Duration.second * 2))
    @Assert(remove1, false)
    @Assert(obj.peek()?.id, 2)
    let remove2 = obj.remove(item2)
    @Assert(remove2, true)
    @Assert(obj.peek()?.id, 3)

    let item = obj.peek().getOrThrow()
    sleep(item.getDelay())
    @Assert(obj.poll().getOrThrow().id, 3)
}

@Test
public func test_ExceptionUtil(): Unit {
    var e = InterruptedException()
    @Assert(e.getClassName(), "InterruptedException")
    e = InterruptedException(Exception("123"))
    @Assert(e.message, "123")
    e = InterruptedException("test2", e)
    @Assert(e.message, "test2")
    @Assert(e.getCause()?.message, "123")
    @Assert(e.getCauseStackTrace()[..30], "cause by: InterruptedException")
}

class Appendable01 <: Appendable {
    let str = StringBuilder()
    public override func append(s: ToString): Appendable01 {
        this.str.append(s.toString())
        this
    }
}

@Test
public func test_Appendable(): Unit {
    let a1 = Appendable01()
    let a2 = ExtendedAppendable(a1)
    a2.append("123")
    @Assert(a1.str.toString(), "123")
}

@Test
public func test_SimpleHashMap(): Unit {
    let obj = SimpleHashMap<Object, Object>()
    @AssertThrows[UnsupportedException](obj.containsAll([Object()]))

    let arr = [(Object(), Object()), (Object(), Object())]
    obj.putAll(arr)
    @Assert(obj.size, 2)

    obj.removeAll([Object()])
    @Assert(obj.size, 2)

    obj.removeIf {_, v => refEq(v, arr[1][1])}
    @Assert(obj.size, 1)

    obj[arr[0][0]]
    obj[arr[0][0]] = Object()

    obj.keys().iterator().next().getOrThrow()
    @Assert(obj.values().size, 1)

    @Assert(obj.isEmpty() , false)

    obj.iterator().next().getOrThrow()

    obj.clear()
    @Assert(obj.size, 0)

    let obj1 = SimpleHashMap<StringBuilder, StringBuilder>()
    obj1.put(StringBuilder(), StringBuilder())

    let obj2 = SimpleHashMap<Int, Int>()
    obj2.put(1, 11)
}

@Test
public func test_LinkedHashMap(): Unit {
    let obj = LinkedHashMap<Byte, Byte>()
    // @AssertThrows[UnsupportedException](obj.clone())
    obj.add(1, 11)
    obj.add(2, 2)
    obj.add(2, 22)
    obj.add(3, 33)

    @Assert(obj[1][1], 22)

    // obj.set(1, 111)
    // @Assert(obj.get(1), 111)

    @Assert(obj.contains(all:[1,3]),true)

    obj.add(all:[(4, 44)])
    @Assert(obj.size, 4)

    @Assert(obj.remove(0).isNone())
    @Assert(obj.size, 4)
    @Assert(obj.remove(1), 11)
    @Assert(obj.size, 3)

    obj.remove(all:[2])
    @Assert(obj.size, 2)

    @Assert(obj[3u8], 33)
    obj[3u8] = 3u8
    @Assert(obj[3u8], 3u8)

    @Assert(obj.keys().iterator().next(),3)
    @Assert(obj.isEmpty(),false)
    obj.iterator().next()
    @Assert(obj.iterator().next().getOrThrow()[1], 3)

    obj.clear()
    @Assert(obj.isEmpty())
}

@Test
public func test_ListIterator(): Unit {
    let iter = ListIterator([1, 2, 3].iterator())
    @Assert(iter.previous().isNone())
    @Assert(iter.next(),1)
    @Assert(iter.next(),2)
    @Assert(iter.next(),3)
    @Assert(iter.next().isNone())
    @Assert(iter.previous(),3)
    @Assert(iter.previous(),2)
    @Assert(iter.previous(),1)
    @Assert(iter.previous().isNone())
    @Assert(iter.next(),1)
}

@Test
public func test_ObservableReader(): Unit {
    let f = File("test_ObservableReader", Write)
    let reader1 = ObservableReader(f)
    let reader2 = ObservableReader(reader1)

    reader1.addReaderListener(ReaderListener {_ => ()})
    reader1.removeReaderListener(ReaderListener {_ => ()})

    @Assert(reader2.isClosed(), false)
    reader2.close()
    @Assert(reader2.isClosed(), true)
}

@Test
public func test_ObservableWriter(): Unit {
    let f = File("test_ObservableWriter", Write)
    let writer1 = ObservableWriter(f)
    let writer2 = ObservableWriter(writer1)

    writer1.addWriterListener(WriterListener {_ => ()})
    writer1.removeWriterListener(WriterListener {_ => ()})

    writer2.write("asd".toArray())

    @Assert(writer2.isClosed(), false)
    writer2.close()
    @Assert(writer2.isClosed(), true)
}

@Test
public func test_OutputStreamUtil(): Unit {
    let buf = ByteBuffer()
    @AssertThrows[IOException](OutputStreamUtil.writeByteSafe(buf,-1,"test"))
    OutputStreamUtil.writeByteSafe(buf, 1, "test1")
}

@Test
public func test_AssertionError(): Unit {
    var e = AssertionError()
    @Assert(e.message,"")
    e = AssertionError("msg")
    @Assert(e.toString(),"AssertionError: msg")
    e = AssertionError(Exception("2"))
    @Assert(e.toString()[..14],"AssertionError")

    // @AssertThrows[Exception](assert(false))
}

@Test
public func test_MultiMap(): Unit {
    let map = MultiMap<String, String>()
    map.put("1","11")
    map.put("1","12")
    // @Assert(map.get("1")[0], "11")
    @Assert(map.isEmpty() , false)
    map.putFirst("1","10")
    @Assert(map.getFirst("1"), "10")
    @Assert(map.removeOne("11","12"),false)
    @Assert(map.remove("1", 10)?.size, 3)
    // @Assert(map.get("1"), "")

    map.putAll(HashMap<String,String>([("2","22")]))
    map.clear()
    @Assert(map.isEmpty() , true)
}

@Test
public func test_ToStringUtil (): Unit {
    let builder = ToStringUtil.builderFor("asd")
    builder.addValue("k1", "v1")
    builder.addValue("k2", "v2")
    builder.add("k3", ["v3"])
    builder.addValue("k4", "v4")
    builder.add("k5", ["v51","v52"])
    let str = builder.build()
    @Assert(str,"asd(k1='v1' k2='v2' k3[v3] k4='v4' k5[v51, v52])")
}
