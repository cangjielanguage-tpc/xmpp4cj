import std.time.*
import xmpp4cj.xmpp.*

public abstract class JidCase <: ToString {
    /*JID from parse*/
    var jid: ?Jid = None
    /*ValidJid*/
    var unnormalizedJid: String = ""
    var localpart: String = ""
    var domainpart: String = ""
    var resourcepart: String = ""
    /*InvalidJid*/
    var invalidJid: String = ""
    /*ToString*/
    var toStr: String = ""
}

public class InvalidJid <: JidCase {
    InvalidJid(invalidJid: String) {
        this.invalidJid = invalidJid
        this.toStr = "InvalidJid: " + invalidJid
    }

    public func toString(): String {
        return toStr
    }
}

public class ValidJid <: JidCase {
    ValidJid(unnormalizedJid: String, localpart: String, domainpart: String, resourcepart: String) {
        this.unnormalizedJid = unnormalizedJid
        this.localpart = localpart
        this.domainpart = domainpart
        this.resourcepart = resourcepart

        let sb = StringBuilder("ValidJid\nunnormalized: ${unnormalizedJid}\n")
        if (localpart.size > 0) {
            sb.append("localpart   : ${localpart}\n")
        }
        sb.append("domainpart  : ${domainpart}\n")
        if (resourcepart.size > 0) {
            sb.append("resourcepart: ${resourcepart}\n")
        }
        this.toStr = sb.toString()
    }

    public func toString(): String {
        return toStr
    }
}

let ValidJids = [
    ValidJid("juliet@example.com", "juliet", "example.com", ""), // A "bare JID"
    ValidJid("juliet@example.com/foo", "juliet", "example.com", "foo"), // A "full JID"
    ValidJid("juliet@example.com/foo bar", "juliet", "example.com", "foo bar"), // Single space in resourcepart
    ValidJid("juliet@example.com/foo@bar", "juliet", "example.com", "foo@bar"), // "At" sign in resourcepart
    ValidJid(#"foo\20bar@example.com"#, #"foo\20bar"#, "example.com", ""), // Single space in localpart, as optionally escaped using the XMPP JID
    ValidJid("fussball@example.com", "fussball", "example.com", ""), // Another bare JID
    ValidJid("fußball@example.com", "fußball", "example.com", ""), // The third character is LATIN SMALL LETTER SHARP S (U+00DF)
    ValidJid("π@example.com", "π", "example.com", ""), // A localpart of GREEK SMALL LETTER PI (U+03C0)
    ValidJid("Σ@example.com", "σ", "example.com", ""), // A localpart of GREEK SMALL LETTER SIGMA (U+03C3)
    ValidJid("ς@example.com", "σ", "example.com", ""), // A localpart of GREEK SMALL FINAL SIGMA (U+03C2)
    ValidJid("king@example.com/♚", "king", "example.com", "♚"), // A resourcepart of the Unicode character BLACK CHESS KING (U+265A)
    ValidJid("example.com", "", "example.com", ""), // A domainpart
    ValidJid("example.com/foobar", "", "example.com", "foobar"), // A domainpart and resourcepart
    ValidJid("a.example.com/b@example.net", "", "a.example.com", "b@example.net"), // A domainpart followed by an resourcepart that contains an "at" sign.
    ValidJid("server/resource@foo", "", "server", "resource@foo"), // 
    ValidJid("server/resource@foo/bar", "", "server", "resource@foo/bar"), // 
    ValidJid("user@CaSe-InSeNsItIvE", "user", "case-insensitive", ""), // Domainparts are case-insensitive.
    ValidJid("user@192.168.1.1", "user", "192.168.1.1", ""), // IPv4 addresses are valid domainparts.
    ValidJid("user@[2001:638:a000:4134::ffff:40]", "user", "[2001:638:a000:4134::ffff:40]", ""), // IPv6 addresses are valid domainparts.
    ValidJid("user@[2001:638:a000:4134::ffff:40%eno1]", "user", "[2001:638:a000:4134::ffff:40%eno1]", ""), // IPv6 addresses with zone identifier are valid domainparts.
    ValidJid("user@averylongdomainpartisstillvalideventhoughitexceedsthesixtyfourbytelimitofdnslabels", "user",
        "averylongdomainpartisstillvalideventhoughitexceedsthesixtyfourbytelimitofdnslabels", ""), // A very long text label (that is resolvable on a local network) is a valid domainpart.  Note that RFC7622 does not restrict the text label in any form.  Whereas DNS labels are restricted to 64 bytes.
    ValidJid("user@example.org/🍺", "user", "example.org", "🍺") // A resourcepart of the Unicode character BEER MUG (U+1F37A)
]
let InvalidJids = [
    InvalidJid("jul\u{1}iet@example.com"), // SOH character (U+0001) in localpart
    InvalidJid("@example.com"), // Localpart is empty string
    InvalidJid(#""juliet"@example.com"#), // Quotation marks (U+0022) in localpart
    InvalidJid("foo bar@example.com"), // Space (U+0020) in localpart
    InvalidJid("@example.com/"), // Zero-length localpart and resourcepart
    InvalidJid("henryⅣ@example.com"), // he sixth character is ROMAN NUMERAL FOUR (U+2163)
    InvalidJid("♚@example.com"), // A localpart of BLACK CHESS KING (U+265A)
    InvalidJid("juliet@"), // A localpart without a domainpart
    InvalidJid("/foobar"), // A resourcepart without a domainpart
    InvalidJid("node@/server"),
    InvalidJid("@server"),
    InvalidJid("@server/resource"),
    InvalidJid("@/resource"),
    InvalidJid("@/resource"),
    InvalidJid("@/"),
    InvalidJid("/"),
    InvalidJid("@"),
    InvalidJid("user@"),
    InvalidJid("user@@"),
    InvalidJid("user@@host"),
    InvalidJid("user@@host/resource"),
    InvalidJid("user@@host/"),
    InvalidJid("xsf@muc.xmpp.org/\u{061C}x"), // U+061C is assigned since 2013 and in the Cf category, which makes it a control character, which are disallowed in by the FreeformClass (RFC 7564 § 4.3.3) and therefore disallowed in resourceparts.
    InvalidJid("username@example.org@example.org") // the '@' in a domainpart is disallowed
]

class JidTestResult {
    JidTestResult(let jid: JidCase, let time: Duration, let e: ?Exception) {}
}

class XmppStringPrepperState {
    let validJidSuccessfulTestresults: ArrayList<JidTestResult> = ArrayList<JidTestResult>()
    let validJidFailedTestresults: ArrayList<JidTestResult> = ArrayList<JidTestResult>()
    let invalidJidSuccessfulTestresults: ArrayList<JidTestResult> = ArrayList<JidTestResult>()
    let invalidJidFailedTestresults: ArrayList<JidTestResult> = ArrayList<JidTestResult>()
    let context: XmppContext

    XmppStringPrepperState(let xmppStringprep: XmppStringprep, let jidCorpusSize: Int) {
        this.context = XmppContext.builder().withXmppStringprep(xmppStringprep).build()
    }
}

func testValidJids(xmppStringPrepperState: XmppStringPrepperState, validJid: ValidJid): Unit {
    let xmppStringPrepper = xmppStringPrepperState.xmppStringprep
    let jid: Jid
    let startTime = DateTime.now()
    try {
        jid = JidCreate.froms(validJid.unnormalizedJid, xmppStringPrepperState.context)
        validJid.jid = jid
    } catch (e: XmppStringprepException) {
        let time = Duration.since(startTime)
        let failed = JidTestResult(validJid, time, e)
        xmppStringPrepperState.validJidFailedTestresults.append(failed)
        return
    }
    let time = Duration.since(startTime)
    var domainpartMismatch = false
    var localpartMismatch = false
    var resourcepartMismatch = false
    let domainpart: String = jid.getDomain().toString()
    if (domainpart != validJid.domainpart) {
        domainpartMismatch = true
    }
    if (validJid.localpart.size > 0) {
        if (!jid.hasLocalpart()) {
            localpartMismatch = true
        } else {
            let localpart: String = jid.getLocalpartOrThrow().toString()
            if (localpart != validJid.localpart) {
                localpartMismatch = true
            }
        }
    }
    if (validJid.resourcepart.size > 0) {
        if (jid.hasNoResource()) {
            resourcepartMismatch = true
        } else {
            let resourcepart: String = jid.getResourceOrThrow().toString()
            if (resourcepart != validJid.resourcepart) {
                resourcepartMismatch = true
            }
        }
    }
    if (domainpartMismatch || localpartMismatch || resourcepartMismatch) {
        let failed = JidTestResult(validJid, time,
            Exception(
            "domainpartMismatch:${domainpartMismatch}, localpartMismatch:${localpartMismatch}, resourcepartMismatch:${resourcepartMismatch}"
        ))
        xmppStringPrepperState.validJidFailedTestresults.append(failed)
    } else {
        let successful = JidTestResult(validJid, time, None)
        xmppStringPrepperState.validJidSuccessfulTestresults.append(successful)
    }
}

func testInvalidJids(xmppStringPrepperState: XmppStringPrepperState, invalidJid: InvalidJid): Unit {
    let xmppStringPrepper = xmppStringPrepperState.xmppStringprep
    let jid: Jid
    let startTime = DateTime.now()
    try {
        jid = JidCreate.froms(invalidJid.invalidJid, xmppStringPrepperState.context)
    } catch (e: XmppStringprepException) {
        let time = Duration.since(startTime)
        let successful = JidTestResult(invalidJid, time, e)
        xmppStringPrepperState.invalidJidSuccessfulTestresults.append(successful)
        return
    }
    let time = Duration.since(startTime)
    let failed = JidTestResult(invalidJid, time, None)
    xmppStringPrepperState.invalidJidFailedTestresults.append(failed)
}

public class KnownFailures {
    static let VALID_JIDS_WHITELIST: Set<String> = HashSet<String>(["ς@example.com"])
    static let INVALID_JIDS_WHITELIST: Set<String> = HashSet<String>(
        [
            "♚@example.com",
            "henry\u{2163}@example.com",
            "user@@host/resource",
            "user@@host",
            "user@@",
            "xsf@muc.xmpp.org/\u{061c}x",
            "username@example.org@example.org"
        ]
    )
    static func checkAgainstWhitelist(res: ArrayList<JidTestResult>) {
        for (i in res.size - 1..=0 : -1) {
            let jidTestResult = res[i]
            let validJid = jidTestResult.jid
            let whitelisted = VALID_JIDS_WHITELIST.contains(validJid.unnormalizedJid)
            if (whitelisted) {
                println("Known failure: ${validJid.unnormalizedJid}")
                res.remove(i)
            }
        }
        for (i in res.size - 1..=0 : -1) {
            let jidTestResult = res[i]
            let invalidJid = jidTestResult.jid
            let whitelisted = INVALID_JIDS_WHITELIST.contains(invalidJid.invalidJid)
            if (whitelisted) {
                println("Known failure: ${invalidJid.invalidJid}")
                res.remove(i)
            }
        }
    }
}
