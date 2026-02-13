// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.modular.*

@Test
func modtcp_test1(): Unit {
    let configBuilder = C2sConnectionConfiguration.builder()
    configBuilder
        .setUsernameAndPassword("user1", "user1")
        // .setResource("jtest")
        .setXmppDomain(XmppTestServerHostName)
        // .setHost("10.56.237.54")
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        // .setConnectTimeout(1000)
        // .setDebuggerFactory(ConsoleDebuggerFactory.INSTANCE)
        // .setSendPresence(false)
        .setCompressionEnabled(true)
        // .setSslContextFactory(() -> { return context; })
        // .setCustomX509TrustManager(new SparkTrustManager())
        .enableDefaultDebugger()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let connection = C2sConnection(configBuilder.build())

    @Assert(connection.isUsingCompression(), false)

    let logger = getGlobalLogger("")
    let stateHistory = StringBuilder()
    let stateMachineListener: ConnectionStateMachineListener = ConnectionStateMachineListener {
        e, c =>
        let sd: StateDescriptor = e.getStateDescriptor()
        let str = """
${e.getTimestamp()} 当前状态:${e}
    ${sd.getSuccessors().toArray()}
    ${sd.getPredeccessors().toArray()}
    ${sd.getSubordinates().toArray()}
    ${sd.getSuperiors().toArray()}
    ${sd.getStateName()}
    ${sd.getFullStateName(true)}
    ${sd.getFullStateName(false)}
    ${sd.getReference()}
    ${sd.getStateClass()}
    ${sd.isMultiVisitState()}
    ${sd.isNotImplemented()}
    ${sd.isFinalState()}
    ${sd.toString()}
    ${sd.getClass()}
    ${sd.hashCode()}
"""
        stateHistory.append(str)
    }

    connection.addConnectionStateMachineListener(stateMachineListener)
    connection.removeConnectionStateMachineListener(ConnectionStateMachineListener {_, _ => ()})

    let stats1: Stats = connection.getStats()

    connection.connect()
    connection.login()
    connection.instantShutdown()
    connection.disconnect()

    connection.instantShutdown()
    connection.disconnect()
    
    logger.info(stateHistory.toString())

    logger.info(stats1.toString())
    let stats2: Stats = connection.getStats()
    logger.info(stats2.toString())
}


/*     let appendable = StringBuilder()
    let transportsStats = stas.transportsStats
    let filtersStats = stas.filtersStats
    StringUtils.appendHeading(appendable, "Connection stats", r'#').append(r'\n')
    for ((transportClass, stats) in transportsStats) {
        StringUtils.appendHeading(appendable, transportClass)
        appendable.append(anyToString1(stats))
        // var str = match(stats){
        //     // case  => 
        //     case _ => "()"
        // } 
        var str = if (stats is ToString) {
            (stats as ToString).getOrThrow().toString()
        } else {
            "None"
        }
        while (str.startsWith("Some(")) {
            str = str[5..str.size - 1]
        }
        appendable.append(str)
        appendable.append(r'\n')
    }
    // for ((filterName, filterStats) in filtersStats) {
    //     StringUtils.appendHeading(appendable, filterName)
    //     appendable.append(anyToString(filterStats))
    //     appendable.append(r'\n')
    // }
    // stas.appendStatsTo(appendable)
    // logger.info(appendable.toString()) */
