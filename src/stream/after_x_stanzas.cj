package xmpp4cj.stream

public class AfterXStanzas <: StanzaFilter {
    let count: Int
    var currentCount: Int
    private let GeneratedLockObject = Mutex()

    public init(count: Int) {
        this.count = count
        currentCount = 0
    }

    public override func accept(packet: Stanza): Bool {
        synchronized(GeneratedLockObject) {
            currentCount++
            if (currentCount == count) {
                resetCounter()
                return true
            }
            return false
        }
    }

    public func resetCounter(): Unit {
        synchronized(GeneratedLockObject) {
            currentCount = 0
        }
    }
    public override func toString(): String {
        "AfterXStanzas"
    }
}
