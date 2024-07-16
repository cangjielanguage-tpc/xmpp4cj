rm -rf doc/api/ && cjdoc doc/Doxyfile && start doc/api/html/index.html

cjcov --html-details -o tmp/cjcov -b -e "src/packet/collections.cj tmp/ src/z_main.cj src\packet\packet_util.cj src\packet\packet_parser_utils.cj src\packet\parser_utils.cj src\xmpp\xmpp_string_utils.cj src\packet\xmpp_element_util.cj src/packet/package.cj src/packet/import.cj src\packet\provider_manager.cj src\xml\xml_event.cj src\packet\string_utils.cj src\xml\xml_token.cj src\xml\xml_reader.cj src\xml\xml_utils.cj" 


## src预处理

### type类型

^public type (.+) = .+

public interface $1 {}

## html后处理

### 抽象类名称替换

(AbstractDebugger|AbstractXMPPConnection|ConnectionConfiguration|ConnectionConfigurationBuilder|SASLMechanism|ScramMechanism|ScramPlusMechanism|SelectableChannel|XmppCompressionFactory|XmppDebugger|XmppFuture|InternalProcessStanzaXmppFuture|SimpleInternalProcessStanzaXmppFuture|AbstractIqRequestHandler|DNSResolver|RemoteConnectionEndpointLookupFailure|XMPPException|XMPPInputOutputStream|Xmpp4cjException|SecurityRequiredException|ConnectionException|AbstractExactJidTypeFilter|AbstractFromToMatchesFilter|AbstractJidTypeFilter|AbstractListFilter|AbstractPossibleJidTypeFilter|FlexibleStanzaTypeFilter|JidTypeAbstractJidTypeFilter|StanzaFilter|AbstractJid|Part|InvalidXmlException|XmlPrinter|AbstractStats|C2sConnectionInternal|C2sConnectionModule|ModuleDescriptor|ModuleDescriptorBuilder|C2sTransport|C2sTransportStats|ConnectionStateEventDetailedTransitionIntoInformation|StateDescriptor|StateMachineException|StateTransitionResult|AttemptResult|TransitionImpossible|State|AbstractErrorBuilder|AbstractIqBuilder|AbstractTextElement|IqBuilder|IQ|MessageOrPresence|MessageOrPresenceBuilder|SimpleIQ|StanzaBuilder|Stanza|AbstractProviderInfo|EmbeddedExtensionProvider|ExtensionElementProvider|IQIntrospectionProvider|PacketExtensionIntrospectionProvider|IqProvider|NonzaProvider|Provider|StreamManagementException|TcpHostEvent|ExceptionExt)类 参考

$1抽象类 参考
