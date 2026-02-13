// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.jid.*
@Test
public func t1(): Unit {
    let roomName01= "asd@conference.xmpp.testserver"  //群聊id
    let roomJid01: EntityBareJid = JidCreate.entityBareFrom(roomName01)
    let msgBuilder: MessageBuilder = MessageBuilder
        .buildMessage()
        .ofType(MessageType.groupchat) // 设置消息类型
        .to(roomJid01) // 设置消息的接收方地址
        .setBody("红红火火") // 设置消息正文
    let msg = msgBuilder.build()
    println(msg.toXML())
}
/* 

 */
