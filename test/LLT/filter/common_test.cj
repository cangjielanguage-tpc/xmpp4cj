internal import std.collection.*
internal import std.fs.*
internal import std.io.*
internal import std.math.*
internal import std.reflect.*
internal import std.sync.*
internal import std.time.*
internal import std.unicode.UnicodeExtension
internal import std.unittest.*
internal import std.random.*
internal import xmpp4cj.compress.*
internal import xmpp4cj.feature.*
internal import xmpp4cj.jid.*
internal import xmpp4cj.packet.*
internal import xmpp4cj.provider.*
internal import xmpp4cj.util.*
internal import xmpp4cj.xml.*
internal import xmpp4cj.filter.*

public func getStaxXmlPullParser(xmppXmlString: String): XmlPullParser {
    let byteArrayStream: ByteArrayStream = ByteArrayStream()
    byteArrayStream.write(xmppXmlString.toArray())
    var staxXmlPullParserFactory = StaxXmlPullParserFactory()
    return staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
}

public func getStanzaMessageSetFrom(jid: ?String): Stanza {
    var stanza = StanzaBuilder.buildMessage().build()
    if (!jid.isNone()) {
        stanza.setFrom(JidCreate.froms(jid.getOrThrow()))
    }
    return stanza;
}

public func getStanzaMessageSetTo(jid: ?String): Stanza {
    var stanza = StanzaBuilder.buildMessage().build()
    if (!jid.isNone()) {
        stanza.setTo(JidCreate.froms(jid.getOrThrow()))
    }
    return stanza;
}

public func getStanzaUnparsedIQaddExtension(extensionElement: ?ExtensionElement): Stanza {
    var stanza = UnparsedIQ("UnparsedIQelement", "UnparsedIQnamespace", "UnparsedIQcontent")
    if (!extensionElement.isNone()) {
        stanza.addExtension(extensionElement.getOrThrow())
    }
    return stanza;
}

public func getStanzaUnparsedIQSetType(iqType: ?IQType): Stanza {
    var stanza = UnparsedIQ("UnparsedIQelement", "UnparsedIQnamespace", "UnparsedIQcontent");
    if (!iqType.isNone()) {
        stanza.setType(iqType.getOrThrow());
    }
    return stanza;
}
