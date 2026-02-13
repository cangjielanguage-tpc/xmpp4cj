// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

internal import std.random.*

var tmpString = None<String>

@Test
public class TestXmpp4cjStanzaBuilderBuildMessage {
    @TestCase
    func test_StanzaBuilder_buildMessage01_01(): Unit {
        //public static func buildMessage ():MessageBuilder
        let msgBuilder = StanzaBuilder.buildMessage()
        let actMsg = msgBuilder.build()
        let actMsgtoString = actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza []")
    }

    @TestCase
    func test_StanzaBuilder_buildMessage02_01(): Unit {
        //buildMessage (stanzaId:?String):MessageBuilder
        let stanzaId = None<String>
        let msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        let actMsg = msgBuilder.build()
        let actMsgtoString = actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza []")
    }

    @TestCase
    func test_StanzaBuilder_buildMessage02_02(): Unit {
        let stanzaId = Some("")
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaBuilder.buildMessage(stanzaId))
        @Assert("IllegalArgumentException: Stanza ID must not be the empty String", e.toString())
    }

    @TestCase
    func test_StanzaBuilder_buildMessage02_03(): Unit {
        //buildMessage (stanzaId:?String):MessageBuilder
        let stanzaId = Some("jabber:iq:roster")
        let msgBuilder = StanzaBuilder.buildMessage(stanzaId)
        let actMsg = msgBuilder.build()
        let actMsgtoString = actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza [id=jabber:iq:roster,]")
    }

    @TestCase
    func test_StanzaBuilder_buildMessageFrom01_01(): Unit {
        //public static func buildMessageFrom (Message message, stanzaId:?String):MessageBuilder
        let oriMsg = StanzaBuilder.buildMessage().build()
        let stanzaId = Some("jabber:iq:roster")
        let msgBuilder = StanzaBuilder.buildMessageFrom(oriMsg, stanzaId)
        let actMsg = msgBuilder.build()
        let actMsgtoString = actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza [id=jabber:iq:roster,type=normal,]")
    }

    @TestCase
    func test_StanzaBuilder_buildMessageFrom01_02(): Unit {
        //public static func buildMessageFrom (Message message, stanzaId:?String):MessageBuilder
        let oriMsg = StanzaBuilder.buildMessage().build()
        var stanzaId = Some("")
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaBuilder.buildMessageFrom(oriMsg, stanzaId))
        @Assert("IllegalArgumentException: Stanza ID must not be the empty String", e.toString())
    }

    @TestCase
    func test_StanzaBuilder_buildMessageFrom01_03(): Unit {
        //public static func buildMessageFrom (Message message, stanzaId:?String):MessageBuilder
        let oriMsg = StanzaBuilder.buildMessage().build()
        var stanzaId = None<String>
        var msgBuilder = StanzaBuilder.buildMessageFrom(oriMsg, stanzaId)
        var actMsg = msgBuilder.build()
        let actMsgtoString = actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza [type=normal,]")
    }

    @TestCase
    func test_StanzaBuilder_buildMessageFrom02_01(): Unit {
        //public static func buildMessageFrom (message:Message, stanzaIdSource:StanzaIdSource):MessageBuilder
        let oriMsg = StanzaBuilder.buildMessage().build()
        let stanzaIdSource: RandomStringStanzaIdSource = RandomStringStanzaIdSource(testSome)
        let msgBuilder = StanzaBuilder.buildMessageFrom(oriMsg, stanzaIdSource)
        @Assert(msgBuilder.willBuildStanzaWithId(),true) //有stanzaIdSource
        let actMsg = msgBuilder.build()
        let actMsgtoString = actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza [id=${tmpString.getOrThrow()},type=normal,]")
    }

    @TestCase
    func test_StanzaBuilder_buildMessageFrom02_02(): Unit {
        //public static func buildMessageFrom (message:Message, stanzaIdSource:StanzaIdSource):MessageBuilder
        let oriMsg = StanzaBuilder.buildMessage().build()
        let stanzaIdSource = RandomStringStanzaIdSource(testNone)
        let msgBuilder = StanzaBuilder.buildMessageFrom(oriMsg, stanzaIdSource)
        @Assert(msgBuilder.willBuildStanzaWithId(),true) //有stanzaIdSource
        let actMsg = msgBuilder.build()
        let actMsgtoString = actMsg.toString()
        @Assert(actMsgtoString,"Message Stanza [type=normal,]")
    }
}

public func testNone(): ?String {
    var value = None<String>
    tmpString = value
    return value
}

public func testSome(): ?String {
    var value = None<String>
    var r = Random()
    var tmp = r.nextInt64()
    value = Some(tmp.toString())
    tmpString = value
    return value
}
