/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class NoEndpointsDiscoveredException <: ConnectionException {
    private let lookupFailures: Collection<LookupConnectionEndpointsFailed>

    private init(message: String, lookupFailures: Collection<LookupConnectionEndpointsFailed>) {
        super(message)
        this.lookupFailures = lookupFailures // TODO Collections.unmodifiableList(lookupFailures)
    }

    public func getLookupFailures(): Collection<LookupConnectionEndpointsFailed> {
        return lookupFailures
    }

    public static func comefrom(lookupFailures: Collection<LookupConnectionEndpointsFailed>): NoEndpointsDiscoveredException {
        let sb = StringBuilder()
        if (lookupFailures.isEmpty()) {
            sb.append("No endpoint lookup finished within the timeout")
        } else {
            sb.append("No endpoints could be discovered due the following lookup failures: ")
            let iter: Iterable<String> = lookupFailures |>
                map<LookupConnectionEndpointsFailed, String> {v => anyToString(v)}
            StringUtils.appendTo(iter, sb)
        }
        return NoEndpointsDiscoveredException(sb.toString(), lookupFailures)
    }
}
