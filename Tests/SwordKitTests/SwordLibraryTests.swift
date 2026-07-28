import Testing
@testable import SwordKit

@Test
func bridgeReturnsVersion() {
    let library = SwordLibrary()

    #expect(library.bridgeVersion == "SwordKit Bridge 0.1")
}

@Test
func swordEngineReturnsVersion() {
    let library = SwordLibrary()

    #expect(!library.engineVersion.isEmpty)
    #expect(library.engineVersion != "Unknown")
}

@Test
func libraryListsInstalledModules() {
    let library = SwordLibrary()
    let moduleNames = library.moduleNames()

    print("Installed SWORD modules: \(moduleNames)")
    #expect(moduleNames == moduleNames.sorted())
}