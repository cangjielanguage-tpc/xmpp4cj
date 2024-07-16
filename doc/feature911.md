# xmpp4cj

jxmpp  
jid(url) -> connection(连接) -> packet(报文)

## jid

local@domain/resource

### 主要接口

1. Jid 及其子类
2. Part 及其子类
3. JidCreate
4. XmppContext // 创建jid使用的配置
5. XmppStringprep // 创建jid使用的主要配置 主要是每个Part的字符串处理(大小写/过滤词等)
6. 异常

## xml

packet(报文)都是xml格式, 所以需要xml解析  
xml解析接口: xmpp4cj.xml.XmlPullParser  

```xml
<tag1 xmlns='namespace-uri-0' xmlns:ns1='namespace-uri-1' attr0='attribute-0' attr1='attribute-1'>
    <ns1:tag2 ns1:attr0='attribute-0'/>
    <tag3 attr0='attribute-0'/>
<tag1>
```

所有的命名空间(namespace)对当前节点以及子节点有效  
所有的节点名称/命名空间名称/属性名称 都以QName对象描述  

### 主要接口

1. QName
2. XmlPullParser // 流式xml解析接口
    - StaxXmlPullParser // XmlPullParser实现 支持流式解析功能 支持获取节点/命名空间/属性信息
3. XmppXmlParser // 获取XmlPullParser
4. 异常

## packet

所有报文对象的父接口: xmpp4cj.packet.Element  
此模块主要是 对象 -> 报文  报文 -> 对象

### 主要接口

1. Element 及其子类
    1. Stanza // Element衍生类, XMPP 节的基类。XMPP 节有 Message、IQ 和 Presence
        - StanzaBuilder
    2. Nonza // 状态指令等没有用户内容的数据结构
    3. Message  // Element衍生类, 表示XMPP消息包
        - MessageBuilder
    4. IQ  // Element衍生类, 表示（信息/查询）
2. 一些工具
    1. StanzaIdSource  // id生成器
    2. EqualsUtil  
    3. HashCode  
    4. LazyStringBuilder  
    5. RandomUtil  
    6. XmppElementUtil  
    7. XmlStringBuilder  // Element转xml报文
    8. XmlEnvironment  // xml转化操作的上下文设置
3. 异常