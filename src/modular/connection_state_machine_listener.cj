/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public type ConnectionStateMachineListener = (ConnectionStateEvent, C2sConnection) -> Unit
