/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

/**
 * This callback is used to get the current value of the period in which Xmpp does bundle and defer
 * outgoing stanzas.
 * <p>
 * Xmpp will bundle and defer stanzas if the connection is authenticated
 * and if a bundle and defer callback is set, either via
 * {@link XMPPTCPConnection#setDefaultBundleAndDeferCallback(BundleAndDeferCallback)} or
 * {@link XMPPTCPConnection#setBundleandDeferCallback(BundleAndDeferCallback)}, and
 * {@link #getBundleAndDeferMillis(BundleAndDefer)} returns a positive value. In a mobile environment, bundling
 * and deferring outgoing stanzas may reduce battery consumption. It heavily depends on the
 * environment, but recommend values for the bundle and defer period range from 20-60 seconds. But
 * keep in mind that longer periods decrease the realtime aspect of Xmpp.
 * </p>
 * <p>
 * Xmpp will invoke the callback when it needs to know the length of the bundle and defer period.
 * If {@link #getBundleAndDeferMillis(BundleAndDefer)} returns 0 or a negative value, then the
 * stanzas will send immediately. You can also prematurely abort the bundling of stanzas by calling
 * {@link BundleAndDefer#stopCurrentBundleAndDefer()}.
 * </p>
 */
public interface BundleAndDeferCallback {
    /**
     * Return the bundle and defer period used by Xmpp in milliseconds.
     *
     * @param bundleAndDefer used to premature abort bundle and defer.
     * @return the bundle and defer period in milliseconds.
     */
    func getBundleAndDeferMillis(bundleAndDefer: BundleAndDefer): Duration
}
