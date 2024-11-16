/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

// TODO
public class SrvXmppsRemoteConnectionEndpoint <: SrvRemoteConnectionEndpoint {
    protected init(inetAddresses: ArrayList<IPSocketAddress>) {
        // protected init(srv: SRV, inetAddresses: ArrayList<IPSocketAddress>) {
        // super(srv, inetAddresses)
        super(inetAddresses)
    }

    public override func getDescription(): String {
        return "XEP-0368 SRV Endpoint + [\'xmpps\', ]"
        // return "XEP-0368 SRV Endpoint + [\'xmpps\', ${srv.toString()}]"
    }
}
