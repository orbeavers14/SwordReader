import CSwordBridge

internal final class SwordManagerStorage {
    internal let handle: OpaquePointer

    internal init?(directory: String? = nil) {
        let handle = directory?.withCString {
            SwordManagerCreateAtPath($0)
        } ?? SwordManagerCreate()

        guard let handle else {
            return nil
        }

        self.handle = handle
    }

    deinit {
        SwordManagerDestroy(handle)
    }
}
