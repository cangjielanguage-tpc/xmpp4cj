<div align="center">
<h1>xmpp4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.3-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.2.0-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-90.5%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

## 介绍

xmpp4cj是一个开源、高度模块化、易于使用的 XMPP 客户端库

### 特性

- xmpp-core
- xmpp-tcp

### 路线

## 软件架构

### 源码目录

```shell
.
├── README.md             # README
├── README.OpenSource
├── CHANGELOG.md
├── doc                   # 文档
└── src                   # 源码
```

### 接口说明

主要类和函数接口说明，详见 [API](https://gitcode.com/Cangjie-TPC/xmpp4cj/blob/xmpp_document/doc/api/html/index.html)

## 使用说明

### 编译构建

两种编译方式

1. 使用脚本编译
    1. 下载配置[编译脚本](https://gitcode.com/Cangjie-TPC/TPC-Test-Framework.git)
    2. ciTest build
2. 使用包管理器编译
    1. 该三方库依赖stdx，请参考[stdx](https://gitcode.com/Cangjie/Cangjie-STDX#%E4%BD%BF%E7%94%A8%E6%8C%87%E5%AF%BC)文档配置`CANGJIE_STDX_PATH`路径
    2. cjpm build

### 示例

#### 账号
```cj
import std.sync.*
import xmpp4cj.connection.*
import xmpp4cj.feature.*
import xmpp4cj.filter.*
import xmpp4cj.jid.*
import xmpp4cj.packet.*
import xmpp4cj.tcp.*

@Test
func account(): Unit {
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain("xmpp.testserver") // 替换为有效的XmppDomain
        .setHost("xmpp.testserver") // 替换为有效的Xmpp服务器域名或ip
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .build()
    let conn = XMPPTCPConnection(config)
    conn.connect()

    /*当前无完整的用户模块 仅用报文模拟注册注销*/

    // 注册用户
    var reg = Register()
    conn.sendStanza(reg)
    // 登录
    conn.login("user00001", "123456")
    // 注销用户
    var unreg = UnRegister()
    conn.sendStanza(unreg)

    conn.disconnect() // 从服务器断开连接
}

// 注册账户
class Register <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>user00001</username><password>123456</password></query></iq>"
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return "iq"
    }
}

// 注销账户
class UnRegister <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return '<iq xmlns="jabber:client" type="set"><query xmlns="jabber:iq:register"><remove /></query></iq>'
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return "iq"
    }
}
```

#### 消息
```cj
import std.sync.*
import xmpp4cj.connection.*
import xmpp4cj.feature.*
import xmpp4cj.filter.*
import xmpp4cj.jid.*
import xmpp4cj.packet.*
import xmpp4cj.tcp.*

func getConn(): XMPPTCPConnection {
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain("xmpp.testserver") // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication() // 匿名登陆
        .build()
    let conn = XMPPTCPConnection(config)
    conn.connect()
    conn.login()
    conn
}

/*两个用户发消息*/
@Test
func message(): Unit {
    let conn1 = getConn()
    let conn2 = getConn()

    let counter = SyncCounter(1)
    let l = SimpleStanzaListener {
        stanza, _ =>
        println("got message ${stanza.toXML()}")
        counter.dec()
    }
    // 监听server发来的message
    conn2.addStanzaListener(l, StanzaTypeFilter<Message>.MESSAGE)

    let message: Message = MessageBuilder
        .buildMessage()
        .to(conn2.getUser().getOrThrow())
        .ofType(MessageType.chat)
        .setBody("hello")
        .build()
    // conn1发送message给conn2
    conn1.sendStanza(message)

    counter.waitUntilZero(timeout: Duration.second)
}
```

#### 联系人
```cj
import std.sync.*
import xmpp4cj.connection.*
import xmpp4cj.feature.*
import xmpp4cj.filter.*
import xmpp4cj.jid.*
import xmpp4cj.packet.*
import xmpp4cj.tcp.*

func getConn(): XMPPTCPConnection {
    // Debugger立即打印报文
    XMPPInputOutputStream.setFlushMethod(XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain('xmpp.testserver') // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .enableDefaultDebugger() // 打开debug 观察报文交互
        .build()
    let conn = XMPPTCPConnection(config)
    conn.connect()
    conn.login("5","123456")
    conn
}

/*当前未实现roster模块 仅用报文模拟roster流程*/
@Test
func roster() {
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain('xmpp.testserver') // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .build()
    let conn = getConn()

    conn.sendStanza(ElementAddFriend()) // 添加联系人
    conn.sendStanza(ElementListFriend()) // 查询联系人
    conn.sendStanza(ElementRemoveFriend()) // 删除联系人
    conn.sendStanza(ElementListFriend()) // 查询联系人
    sleep(Duration.second) // 等待1s从debuger日志可以看到roster交互报文
}

//添加联系人
class ElementAddFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' id='1' type='set'><query xmlns='jabber:iq:roster'><item jid='asd@xmpp.testserver'></item></query></iq>"
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return 'iq'
    }
}
//查询联系人列表
class ElementListFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' id='2' type='get'><query xmlns='jabber:iq:roster'/></iq>"
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return 'iq'
    }
}
//删除联系人
class ElementRemoveFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' id='3' type='set'><query xmlns='jabber:iq:roster'><item jid='asd@xmpp.testserver' subscription='remove' /></query></iq>"
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return 'iq'
    }
}

```

#### 监听器
```cj
import std.sync.*
import xmpp4cj.connection.*
import xmpp4cj.feature.*
import xmpp4cj.filter.*
import xmpp4cj.jid.*
import xmpp4cj.packet.*
import xmpp4cj.tcp.*

/*监听报文*/
@Test
func listener(): Unit {
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain("xmpp.testserver") // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication() // 匿名登陆
        .build()
    let conn = XMPPTCPConnection(config)

    let l = SimpleStanzaListener {
        stanza, _ =>
        println("got staza ${stanza.toXML()}")
    }
    // 监听server发来的stanza
    conn.addStanzaListener(l, StanzaTypeFilter<Stanza>("Stanza"))

    conn.connect()
    conn.login()
    conn.disconnect()
}
```

#### 拦截器
```cj
import std.sync.*
import xmpp4cj.connection.*
import xmpp4cj.feature.*
import xmpp4cj.filter.*
import xmpp4cj.jid.*
import xmpp4cj.packet.*
import xmpp4cj.tcp.*
import xmpp4cj.util.*

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
```

## 约束与限制

## 开源协议

本项目基于 [Apache License 2.0](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。
