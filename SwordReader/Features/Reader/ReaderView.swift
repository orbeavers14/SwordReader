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
                    Text("Import a local SWORD catalog from the Library to begin reading.")
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
            LazyVStack(alignment: .leading, spacing: 18) {
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
    let verse: BibleVerse

    var body: some View {
        Text(verse.number + " ")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        + Text(verse.text)
            .font(.body)
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
