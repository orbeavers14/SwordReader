import Testing
@testable import SwordKit

@Test
func bridgeReturnsVersion() {
    let library = SwordLibrary()

    #expect(library.version == "SwordKit Bridge 0.1")
}
