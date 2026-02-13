// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

var tmpString=None<String>
@Test
public class TestXmpp4cjStanzaBuilderBuildPresenceFrom {
    @TestCase
    func test_StanzaBuilder_buildPresenceFrom01_01(): Unit {
        //public static func buildPresenceFrom (presence: Presence, stanzaId: ?String):PresenceBuilder
        let oriPs=StanzaBuilder.buildPresence().build()
        let stanzaId=Some("jabber:iq:roster")
        let psBuilder=StanzaBuilder.buildPresenceFrom(oriPs,stanzaId)
        psBuilder.setMode(PresenceMode.xa)
        let actPs=psBuilder.build()
        let actPstoString=actPs.toString()
        @Assert(actPstoString,"Presence Stanza [id=jabber:iq:roster,type=available,mode=xa,prio=0,]")
    }
    @TestCase
    func test_StanzaBuilder_buildPresenceFrom01_02(): Unit {
        //public static func buildPresenceFrom (presence: Presence, stanzaId: ?String):PresenceBuilder
        let oriPs=StanzaBuilder.buildPresence().build()
        var stanzaId=Some("")
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](StanzaBuilder.buildPresenceFrom(oriPs,stanzaId))
        @Assert(e.toString(),"IllegalArgumentException: Stanza ID must not be the empty String")
    }
    @TestCase
    func test_StanzaBuilder_buildPresenceFrom01_03(): Unit {
        //public static func buildPresenceFrom (presence: Presence, stanzaId: ?String):PresenceBuilder
        let oriPs=StanzaBuilder.buildPresence().build()
        var stanzaId=None<String>
        var psBuilder=StanzaBuilder.buildPresenceFrom(oriPs,stanzaId)
        psBuilder.setMode(PresenceMode.xa)
        let actPs=psBuilder.build()
        let actPstoString=actPs.toString()
        @Assert(actPstoString,"Presence Stanza [type=available,mode=xa,prio=0,]")
    }
    @TestCase
    func test_StanzaBuilder_buildPresenceFrom02_01(): Unit {
        //public static func buildPresenceFrom (presence: Presence, stanzaIdSource: StanzaIdSource):PresenceBuilder
        let oriPs=StanzaBuilder.buildPresence().build()
        let stanzaIdSource=RandomStringStanzaIdSource(testNone)
        let psBuilder=StanzaBuilder.buildPresenceFrom(oriPs,stanzaIdSource)
        psBuilder.setMode(PresenceMode.xa)
        let actPs=psBuilder.build()
        let actPstoString=actPs.toString()
        @Assert(actPstoString,"Presence Stanza [type=available,mode=xa,prio=0,]")
    }
    @TestCase
    func test_StanzaBuilder_buildPresenceFrom02_02(): Unit {
        //public static func buildPresenceFrom (presence: Presence, stanzaIdSource: StanzaIdSource):PresenceBuilder
        let oriPs=StanzaBuilder.buildPresence().build()
        let stanzaIdSource=RandomStringStanzaIdSource(testSome)
        let psBuilder=StanzaBuilder.buildPresenceFrom(oriPs,stanzaIdSource)
        psBuilder.setMode(PresenceMode.xa)
        let actPs=psBuilder.build()
        let actPstoString=actPs.toString()
        @Assert(actPstoString,"Presence Stanza [id=${tmpString.getOrThrow()},type=available,mode=xa,prio=0,]")
    }
}
public func testNone():?String{
    var value=None<String>
    tmpString=value
    return value
}
public func testSome():?String{
    var value=None<String>
    var r=Random()
    var tmp=r.nextInt64()
    value=Some(tmp.toString())
    tmpString=value
    return value
}