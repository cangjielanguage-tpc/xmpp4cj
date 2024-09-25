import xmpp4cj.jid.*

public class JidTestUtil {
    public static let EXAMPLE_ORG: DomainBareJid = JidCreate.domainBareFrom("example.org")
    public static let DUMMY_AT_EXAMPLE_ORG: EntityBareJid = JidCreate.entityBareFrom("dummy@example.org")
    public static let DUMMY_AT_EXAMPLE_ORG_SLASH_DUMMYRESOURCE: EntityFullJid = JidCreate.entityFullFrom(
        "dummy@example.org/dummyresource")

    public static let BARE_JID_1: EntityBareJid = JidCreate.entityBareFrom("one@exampleOne.org")
    public static let BARE_JID_2: EntityBareJid = JidCreate.entityBareFrom("one@exampleTwo.org")

    public static let FULL_JID_1_RESOURCE_1: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceOne")
    public static let FULL_JID_1_RESOURCE_2: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceTwo")
    public static let FULL_JID_2_RESOURCE_1: EntityFullJid = JidCreate.entityFullFrom("two@exampleTwo.org/resourceOne")
    public static let FULL_JID_2_RESOURCE_2: EntityFullJid = JidCreate.entityFullFrom("two@exampleTwo.org/resourceTwo")

    public static let DOMAIN_BARE_JID_1: DomainBareJid = JidCreate.domainBareFrom("exampleOne.org")
    public static let DOMAIN_BARE_JID_2: DomainBareJid = JidCreate.domainBareFrom("exampleTwo.org")

    public static let DOMAIN_FULL_JID_1: DomainFullJid = JidCreate.domainFullFrom("exampleOne.org/oneResource")
    public static let DOMAIN_FULL_JID_2: DomainFullJid = JidCreate.domainFullFrom("exampleTwo.org/twoResource")

    public static let MUC_EXAMPLE_ORG: DomainBareJid = JidCreate.domainBareFrom("muc.example.org")
    public static let PUBSUB_EXAMPLE_ORG: DomainBareJid = JidCreate.domainBareFrom("pubsub.example.org")

    public static let RESOURCEPART: Resourcepart = Resourcepart.froms("resource")
}
