// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main 
//--filter=*.*
import xmpp4cj.connection.*
import xmpp4cj.tcp.*
import xmpp4cj.modular.*

@Test
func fsm1(): Unit {
    let configurationBuilder = C2sConnectionConfiguration.builder()
    configurationBuilder.setUsernameAndPassword("user", "password")
    configurationBuilder.setXmppDomain("example.org")

    let configuration = configurationBuilder.build()

    let sb = StringBuilder()

    configuration.printStateGraphInDotFormat(sb, false)

    println(sb)
}
