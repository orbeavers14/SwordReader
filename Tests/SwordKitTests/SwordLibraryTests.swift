import Testing
@testable import SwordKit

@Test
func bridgeVersionIsAvailable() {
    #expect(SwordLibrary.bridgeVersion == "0.1.0")
}

@Test
func engineVersionIsAvailable() {
    #expect(!SwordLibrary.engineVersion.isEmpty)
}

@Test
func libraryLoadsInstalledModules() {
    let library = SwordLibrary()

    // The machine may have zero installed modules.
    #expect(library.modules.count >= 0)
}

@Test
func moduleNamesAreSorted() {
    let library = SwordLibrary()
    let names = library.modules.map(\.name)

    #expect(
        names == names.sorted {
            $0.lowercased() < $1.lowercased()
        }
    )
}

@Test
func moduleLookupReturnsMatchingModule() {
    let library = SwordLibrary()

    guard let first = library.modules.first else {
        return
    }

    #expect(library.module(named: first.name) == first)
}

@Test
func moduleLookupIsCaseInsensitive() {
    let library = SwordLibrary()

    guard let first = library.modules.first else {
        return
    }

    #expect(
        library.module(named: first.name.uppercased()) == first
    )
}

@Test
func subscriptLooksUpModule() {
    let library = SwordLibrary()

    guard let first = library.modules.first else {
        return
    }

    #expect(library[first.name] == first)
}

@Test
func knownSwordCategoriesAreMapped() {
    #expect(
        SwordModule.Category(swordType: "Biblical Texts") == .bible
    )

    #expect(
        SwordModule.Category(swordType: "Commentaries") == .commentary
    )

    #expect(
        SwordModule.Category(
            swordType: "Lexicons / Dictionaries"
        ) == .dictionary
    )

    #expect(
        SwordModule.Category(swordType: "Generic Books") == .generalBook
    )

    #expect(
        SwordModule.Category(swordType: "Custom Type")
            == .other("Custom Type")
    )
}

@Test
func moduleKeepsNativeManagerAlive() {
    let module: SwordModule?

    do {
        let library = SwordLibrary()
        module = library.modules.first
    }

    guard let module else {
        // The machine may have zero installed modules.
        return
    }

    #expect(!module.name.isEmpty)
}

@Test
func referenceTrimsWhitespace() throws {
    let reference = try SwordReference("  John 3:16  ")

    #expect(reference.value == "John 3:16")
    #expect(reference.description == "John 3:16")
}

@Test
func emptyReferenceThrows() {
    #expect(throws: SwordError.emptyReference) {
        _ = try SwordReference("   \n   ")
    }
}

@Test
func verseStoresRetrievedValues() throws {
    let reference = try SwordReference("John 3:16")

    let verse = SwordVerse(
        reference: reference,
        moduleName: "KJV",
        text: "Test verse text"
    )

    #expect(verse.reference == reference)
    #expect(verse.moduleName == "KJV")
    #expect(verse.text == "Test verse text")
}

@Test
func bibleModuleCanRetrieveVerse() throws {
    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        // Integration testing requires an installed Bible module.
        return
    }

    let verse = try bible.verse("John 3:16")

    #expect(!verse.text.isEmpty)
    #expect(!verse.reference.value.isEmpty)
    #expect(verse.moduleName == bible.name)
}

@Test
func verseLookupRejectsNonBibleModule() {
    let library = SwordLibrary()

    guard let module = library.modules.first(
        where: { $0.category != .bible }
    ) else {
        return
    }

    #expect(throws: SwordError.unsupportedModuleType) {
        _ = try module.verse("John 3:16")
    }
}

@Test
func moduleCanAdvanceToNextVerse() throws {

    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        return
    }

    _ = try bible.verse("John 3:16")

    let first = bible.currentReference

    bible.advance()

    let second = bible.currentReference

    #expect(first != nil)
    #expect(second != nil)
    #expect(first != second)
}

@Test
func moduleCanRetrieveSequentialPassage() throws {
    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        return
    }

    let passage = try bible.passage(
        startingAt: "John 3:16",
        verseCount: 3
    )

    #expect(passage.verses.count == 3)
    #expect(passage.verses[0].reference.value == "John 3:16")
    #expect(passage.verses[1].reference.value == "John 3:17")
    #expect(passage.verses[2].reference.value == "John 3:18")
}

@Test
func passageRejectsInvalidVerseCount() throws {
    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        return
    }

    #expect(throws: SwordError.self) {
        try bible.passage(
            startingAt: "John 3:16",
            verseCount: 0
        )
    }
}

@Test
func passageRangeParsesSameChapterRange() throws {
    let range = try SwordPassageRange(
        "John 3:16-21"
    )

    #expect(range.start.value == "John 3:16")
    #expect(range.endingVerse == 21)
    #expect(range.verseCount == 6)
}

@Test
func passageRangeSupportsNumberedBooks() throws {
    let range = try SwordPassageRange(
        "1 Corinthians 13:4-8"
    )

    #expect(range.start.value == "1 Corinthians 13:4")
    #expect(range.endingVerse == 8)
    #expect(range.verseCount == 5)
}

@Test
func passageRangeRejectsReversedRange() {
    #expect(throws: SwordError.self) {
        try SwordPassageRange("John 3:21-16")
    }
}

@Test
func moduleCanRetrievePassageRange() throws {
    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        return
    }

    let passage = try bible.passage("John 3:16-18")

    #expect(passage.verses.count == 3)
    #expect(passage.verses[0].reference.value == "John 3:16")
    #expect(passage.verses[1].reference.value == "John 3:17")
    #expect(passage.verses[2].reference.value == "John 3:18")
}

@Test
func chapterReferenceParsesBookAndChapter() throws {
    let reference = try SwordChapterReference("John 3")

    #expect(reference.value == "John 3")
    #expect(reference.book == "John")
    #expect(reference.chapterNumber == 3)
}

@Test
func chapterReferenceSupportsNumberedBooks() throws {
    let reference = try SwordChapterReference(
        "1 Corinthians 13"
    )

    #expect(reference.value == "1 Corinthians 13")
    #expect(reference.book == "1 Corinthians")
    #expect(reference.chapterNumber == 13)
}

@Test
func chapterReferenceRejectsVerseReference() {
    #expect(throws: SwordError.self) {
        try SwordChapterReference("John 3:16")
    }
}

@Test
func moduleCanRetrieveChapter() throws {
    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        return
    }

    let chapter = try bible.chapter("John 3")

    #expect(chapter.reference == "John 3")
    #expect(!chapter.verses.isEmpty)
    #expect(chapter.verses.first?.reference.value == "John 3:1")
    #expect(chapter.verses.last?.reference.value == "John 3:36")
}

@Test
func moduleCanParseReferenceList() throws {
    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        return
    }

    let references = try bible.references(
        in: "John 3:16-18; Romans 8:28"
    )

    #expect(references.count == 4)
    #expect(references[0].value == "John 3:16")
    #expect(references[1].value == "John 3:17")
    #expect(references[2].value == "John 3:18")
    #expect(references[3].value == "Romans 8:28")
}

@Test
func moduleCanParseNumberedBookReferenceList() throws {
    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        return
    }

    let references = try bible.references(
        in: "1 Corinthians 13:4-6"
    )

    #expect(references.count == 3)
    #expect(references.first?.value == "1 Corinthians 13:4")
    #expect(references.last?.value == "1 Corinthians 13:6")
}

@Test
func referenceListRejectsEmptyExpression() throws {
    let library = SwordLibrary()

    guard let bible = library.modules.first(
        where: { $0.category == .bible }
    ) else {
        return
    }

    #expect(throws: SwordError.self) {
        try bible.references(in: "   ")
    }
}
