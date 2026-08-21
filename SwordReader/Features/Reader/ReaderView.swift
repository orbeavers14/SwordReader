import SwiftUI

struct ReaderView: View {
    @Environment(AppModel.self) private var model
    @State private var isChoosingChapter = false

    var body: some View {
        Group {
            if model.modules.isEmpty {
                ContentUnavailableView {
                    Label("No Bibles Installed", systemImage: "book.closed")
                } description: {
                    Text("Get a Bible from the Library to begin reading.")
                } actions: {
                    Button("Open Library") { model.section = .library }
                }
            } else if model.isLoading && model.chapter == nil {
                ProgressView("Loading chapter…")
            } else if let chapter = model.chapter {
                chapterContent(chapter)
            } else {
                ContentUnavailableView(
                    "Choose a Chapter",
                    systemImage: "text.book.closed"
                )
            }
        }
        .navigationTitle(model.reference.isEmpty ? "Read" : model.reference)
        .toolbarTitleDisplayMode(.inline)
        .toolbar { readerToolbar }
        .popover(isPresented: $isChoosingChapter) {
            ChapterNavigationView()
                .environment(model)
                .frame(minWidth: 340, idealWidth: 420, minHeight: 480)
                .presentationCompactAdaptation(.sheet)
        }
    }

    private func chapterContent(_ chapter: BibleChapter) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: model.readerSpacing.verseSpacing) {
                ForEach(chapter.verses) { verse in
                    VerseView(verse: verse)
                }
            }
            .frame(maxWidth: 720, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 56, for: .scrollContent)
        .gesture(
            DragGesture(minimumDistance: 60).onEnded { value in
                guard abs(value.translation.width)
                    > abs(value.translation.height) * 1.5
                else { return }

                model.moveChapter(
                    by: value.translation.width < 0 ? 1 : -1
                )
            }
        )
    }

    @ToolbarContentBuilder
    private var readerToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button("Previous Chapter", systemImage: "chevron.left") {
                model.moveChapter(by: -1)
            }
            .disabled(!model.canMoveToPreviousChapter)
            .keyboardShortcut(.leftArrow, modifiers: [.command])
        }

        ToolbarItem(placement: .principal) {
            Button {
                isChoosingChapter = true
            } label: {
                HStack(spacing: 5) {
                    Text(model.reference.isEmpty ? "Choose Chapter" : model.reference)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shows books and chapters")
        }

        ToolbarItem(placement: .primaryAction) {
            Button("Next Chapter", systemImage: "chevron.right") {
                model.moveChapter(by: 1)
            }
            .disabled(!model.canMoveToNextChapter)
            .keyboardShortcut(.rightArrow, modifiers: [.command])
        }

        ToolbarItem(placement: .secondaryAction) {
            ReaderAppearanceMenu()
        }

        ToolbarItem(placement: .secondaryAction) {
            Menu {
                ForEach(model.modules) { module in
                    Button {
                        model.selectModule(module.id)
                    } label: {
                        if module.id == model.selectedModuleID {
                            Label(module.title, systemImage: "checkmark")
                        } else {
                            Text(module.title)
                        }
                    }
                }
            } label: {
                Label(
                    model.selectedModuleID ?? "Translation",
                    systemImage: "character.book.closed"
                )
            }
            .accessibilityLabel("Translation")
        }
    }
}

private struct VerseView: View {
    @Environment(AppModel.self) private var model
    let verse: BibleVerse
    @State private var isShowingAnnotations = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(verse.headings) { heading in
                Text(heading.text)
                    .font(.system(.title3, design: model.readerFont.design, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 8)
            }

            verseText
                .font(.system(model.readerTextSize.textStyle, design: model.readerFont.design))
                .lineSpacing(model.readerSpacing.lineSpacing)
                .textSelection(.enabled)

            if verse.annotationCount > 0 {
                Button {
                    isShowingAnnotations = true
                } label: {
                    Label(
                        "\(verse.annotationCount) \(verse.annotationCount == 1 ? "note" : "notes")",
                        systemImage: "text.bubble"
                    )
                    .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .accessibilityHint("Shows notes and Scripture references for \(verse.reference)")
            }
        }
        .sheet(isPresented: $isShowingAnnotations) {
            VerseAnnotationsView(verse: verse)
                .environment(model)
        }
    }

    private var verseText: Text {
        if model.showsVerseNumbers {
            Text(verse.number + " ")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            + Text(verse.content)
        } else {
            Text(verse.content)
        }
    }
}

private struct VerseAnnotationsView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let verse: BibleVerse

    var body: some View {
        NavigationStack {
            List {
                if !verse.footnotes.isEmpty {
                    Section("Notes") {
                        ForEach(verse.footnotes) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.text)
                                if let type = note.type, !type.isEmpty {
                                    Text(type)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .textSelection(.enabled)
                        }
                    }
                }

                if !verse.crossReferences.isEmpty {
                    Section("Cross-References") {
                        ForEach(verse.crossReferences) { group in
                            ForEach(group.references, id: \.self) { reference in
                                Button {
                                    dismiss()
                                    model.open(reference: reference)
                                } label: {
                                    Label(reference, systemImage: "arrow.right.circle")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(verse.reference)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct ReaderAppearanceMenu: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Menu("Reading Appearance", systemImage: "textformat.size") {
            Picker("Font", selection: fontBinding) {
                ForEach(ReaderFont.allCases) { font in
                    Text(font.title).tag(font)
                }
            }

            Picker("Text Size", selection: sizeBinding) {
                ForEach(ReaderTextSize.allCases) { size in
                    Text(size.title).tag(size)
                }
            }

            Picker("Spacing", selection: spacingBinding) {
                ForEach(ReaderSpacing.allCases) { spacing in
                    Text(spacing.title).tag(spacing)
                }
            }

            Toggle("Verse Numbers", isOn: verseNumberBinding)
        }
        .accessibilityHint("Changes font, text size, spacing, and verse numbers")
    }

    private var fontBinding: Binding<ReaderFont> {
        Binding(
            get: { model.readerFont },
            set: { model.setReaderFont($0) }
        )
    }

    private var sizeBinding: Binding<ReaderTextSize> {
        Binding(
            get: { model.readerTextSize },
            set: { model.setReaderTextSize($0) }
        )
    }

    private var spacingBinding: Binding<ReaderSpacing> {
        Binding(
            get: { model.readerSpacing },
            set: { model.setReaderSpacing($0) }
        )
    }

    private var verseNumberBinding: Binding<Bool> {
        Binding(
            get: { model.showsVerseNumbers },
            set: { model.setShowsVerseNumbers($0) }
        )
    }
}

private extension ReaderFont {
    var design: Font.Design {
        switch self {
        case .system: .default
        case .serif: .serif
        case .rounded: .rounded
        }
    }
}

private extension ReaderTextSize {
    var textStyle: Font.TextStyle {
        switch self {
        case .small: .callout
        case .standard: .body
        case .large: .title3
        case .extraLarge: .title2
        }
    }
}

private extension ReaderSpacing {
    var verseSpacing: CGFloat {
        switch self {
        case .compact: 12
        case .comfortable: 18
        case .relaxed: 26
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .compact: 2
        case .comfortable: 6
        case .relaxed: 10
        }
    }
}

private struct ChapterNavigationView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var matchingBooks: [BibleBook] {
        guard !query.isEmpty else { return model.books }
        return model.books.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.abbreviation.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                testamentSection("Old Testament", testament: .old)
                testamentSection("New Testament", testament: .new)
            }
            .navigationTitle("Choose a Book")
            .toolbarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Book")
            .navigationDestination(for: BibleBook.self) { book in
                ChapterGridView(book: book) { dismiss() }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func testamentSection(
        _ title: String,
        testament: BibleBook.Testament
    ) -> some View {
        let books = matchingBooks.filter { $0.testament == testament }
        if !books.isEmpty {
            Section(title) {
                ForEach(books) { book in
                    NavigationLink(value: book) {
                        HStack {
                            Text(book.name)
                            Spacer()
                            Text("\(book.chapterCount)")
                                .foregroundStyle(.secondary)
                                .accessibilityLabel(
                                    "\(book.chapterCount) chapters"
                                )
                            if book.id == model.selectedBookID {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                                    .accessibilityLabel("Current book")
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct ChapterGridView: View {
    @Environment(AppModel.self) private var model
    let book: BibleBook
    let didSelect: () -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 48, maximum: 64), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(1...book.chapterCount, id: \.self) { chapter in
                    Button {
                        model.select(bookID: book.id, chapter: chapter)
                        didSelect()
                    } label: {
                        Text("\(chapter)")
                            .font(.body.monospacedDigit())
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                isSelected(chapter)
                                    ? Color.accentColor
                                    : Color.secondary.opacity(0.12),
                                in: .rect(cornerRadius: 10)
                            )
                            .foregroundStyle(
                                isSelected(chapter) ? .white : .primary
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        "\(book.name) chapter \(chapter)"
                    )
                }
            }
            .padding()
        }
        .navigationTitle(book.name)
        .toolbarTitleDisplayMode(.inline)
    }

    private func isSelected(_ chapter: Int) -> Bool {
        model.selectedBookID == book.id
            && model.selectedChapter == chapter
    }
}
