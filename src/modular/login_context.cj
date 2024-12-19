/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

// TODO: At one point SASL authzid should be part of this.
public class LoginContext {
    public let username: String

    public let password: String

    public let resource: ?Resourcepart

    public init(username: ?String, password: ?String, resource: ?Resourcepart) {
        this.username = username.getOrThrow()
        this.password = password.getOrThrow()
        this.resource = resource
    }
}
