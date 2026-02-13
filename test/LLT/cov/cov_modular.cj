// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main

import cangjie_tpc::xmpp4cj.modular.*

class AbstractStats0 <: AbstractStats {
    public override func appendStatsTo(str: StringBuilder): Unit {
        str.append("AbstractStats0")
    }
}

@Test
public func test_AbstractStats(): Unit {
    let obj = AbstractStats0()
    @Assert(obj.toString(),"AbstractStats0")
    @Assert(obj.toString(),"AbstractStats0")
}

