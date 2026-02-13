// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj

import fuzz.fuzz.*

import cangjie_tpc::xmpp4cj.compress.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.provider.*
import cangjie_tpc::xmpp4cj.util.*
import cangjie_tpc::xmpp4cj.xml.*
import cangjie_tpc::xmpp4cj.filter.*

main() {
    Fuzzer(funcFuzz).startFuzz()
    return 0
}

public func funcFuzz(dp: FuzzDataProvider): Int32 {
    var str= dp.consumeString(1024)
    try{
        MissingDomainpart.froms(Some(str),Some(str))
    }catch(e:Exception){}
    return 0
}




