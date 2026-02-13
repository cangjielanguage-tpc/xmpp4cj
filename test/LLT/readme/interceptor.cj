// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main 
import std.sync.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.util.*

/*拦截器 拦截处理client发出的报文*/
@Test
func interceptor(): Unit {
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain("xmpp.testserver") // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication() // 匿名登陆
        .build()
    let conn = XMPPTCPConnection(config)

    // 添加message拦截器
    conn.addMessageInterceptor(
        HashableConsumer<MessageBuilder> {
            msgBuilder =>
            // 拦截器 可对message进行二次加工
            msgBuilder.to("intercepted1@qwe")
        },
        LambdaPredicate<Message> {
            msg =>
            // 拦截器的前置过滤器
            true
        }
    )
    // 添加presence拦截器
    conn.addPresenceInterceptor(HashableConsumer {_ => ()}, LambdaPredicate {_ => true})

    conn.connect()
    conn.login()
    conn.disconnect()
}
