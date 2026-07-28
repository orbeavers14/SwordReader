import CSwordBridge

internal final class SwordManagerStorage {
    internal let handle: OpaquePointer

    internal init?() {
        guard let handle = SwordManagerCreate() else {
            return nil
        }

        self.handle = handle
    }

    deinit {
        SwordManagerDestroy(handle)
    }
}
