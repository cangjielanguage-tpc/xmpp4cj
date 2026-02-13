/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.util

public class SSLEngine <: ToString {
    SSLEngine(let tlsSocket: TlsSocket) {}
    public func getHandshakeStatus(): HandshakeStatus {
        throw Exception("TODO")
    }
    public func getDelegatedTask(): ?Runnable {
        throw Exception("TODO")
    }
    public func closeOutbound(): Unit {
        throw Exception("TODO")
    }
    public func closeInbound(): Unit {
        throw Exception("TODO")
    }
    public func beginHandshake(): Unit {
        throw Exception("TODO")
    }
    public func getSession(): TlsSession {
        throw Exception("TODO")
    }
    public override func toString(): String {
        throw Exception("TODO")
    }
}

public class SSLEngineResult <: ToString {
    SSLEngineResult(
        let status: SSLStatus,
        let handshakeStatus: HandshakeStatus,
        let bytesConsumed: Int,
        let bytesProduced: Int,
        let sequenceNumber: Int
    ) {}
    public override func toString(): String {
        "Status = ${status} HandshakeStatus = ${handshakeStatus}\nbytesConsumed = ${bytesConsumed} bytesProduced = ${bytesProduced}${if (sequenceNumber == -1) { "" } else { " sequenceNumber = ${sequenceNumber}" }}"
    }
    public func getHandshakeStatus(): HandshakeStatus {
        handshakeStatus
    }
}

public enum SSLStatus <: ToString & Equatable<SSLStatus> {
    | BUFFER_UNDERFLOW
    | BUFFER_OVERFLOW
    | OK
    | CLOSED

    public override func toString(): String {
        match (this) {
            case BUFFER_UNDERFLOW => "BUFFER_UNDERFLOW"
            case BUFFER_OVERFLOW => "BUFFER_OVERFLOW"
            case OK => "OK"
            case CLOSED => "CLOSED"
        }
    }
    public operator override func ==(that: SSLStatus): Bool {
        this.toString() == that.toString()
    }
}

public enum HandshakeStatus <: ToString & Equatable<HandshakeStatus> {
    | NOT_HANDSHAKING
    | FINISHED
    | NEED_TASK
    | NEED_WRAP
    | NEED_UNWRAP
    | NEED_UNWRAP_AGAIN

    public override func toString(): String {
        match (this) {
            case NOT_HANDSHAKING => "NOT_HANDSHAKING"
            case FINISHED => "FINISHED"
            case NEED_TASK => "NEED_TASK"
            case NEED_WRAP => "NEED_WRAP"
            case NEED_UNWRAP => "NEED_WRAP"
            case NEED_UNWRAP_AGAIN => "NEED_UNWRAP_AGAIN"
        }
    }
    public operator override func ==(that: HandshakeStatus): Bool {
        this.toString() == that.toString()
    }
}

public class SSLException <: Exception {}
