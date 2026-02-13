// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_entityFullFrom_02(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom("localdomain/resource"))
        println(e.toString())
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'localdomain/resource': XmppStringprepException: XmppStringprepException caused by 'None@localdomain/resource': XmppStringprepException: localpart can't be None")
    }

    @TestCase
    func test_JidCreate_entityFullFrom03_01(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom(None<String>,"","res"))
        println(e.toString())
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'None@/res': XmppStringprepException: domainpart can't be the empty string")
    }

    @TestCase
    func test_JidCreate_entityFullFrom03_02(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom("","domain",""))
        println(e.toString())
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '@domain/': XmppStringprepException: localpart can't be the empty string")
    }

    @TestCase
    func test_JidCreate_entityFullFrom03_03(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom("local","domain",""))
        println(e.toString())
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'local@domain/': XmppStringprepException: resourcepart can't be the empty string")
    }

    @TestCase
    func test_JidCreate_entityFullFrom03_04(): Unit {
        let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom("local","","res"))
        println(e.toString())
        @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by 'local@/res': XmppStringprepException: domainpart can't be the empty string")
    }

    @TestCase
    func test_JidCreate_entityFullFrom03_05(): Unit {
        var locals = [":", "&", "@", " "]
        for (local in locals) {
            let e: XmppStringprepException = @AssertThrows[XmppStringprepException](JidCreate.entityFullFrom(local, "dom.example", "res"))
            println(e.toString())
            @Assert(e.toString(),"XmppStringprepException: XmppStringprepException caused by '${local}@dom.example/res': XmppStringprepException: Localpart must not contain '${local}'")
        }
    }
}
