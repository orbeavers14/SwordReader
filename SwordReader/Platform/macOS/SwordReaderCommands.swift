#if os(macOS)
import SwiftUI

struct SwordReaderCommands: Commands {
    @FocusedValue(\.swordReaderModel) private var model

    var body: some Commands {
        CommandMenu("Navigate") {
            Button("Previous Chapter") { model?.moveChapter(by: -1) }
                .keyboardShortcut(.leftArrow, modifiers: [.command])
                .disabled(model == nil)
            Button("Next Chapter") { model?.moveChapter(by: 1) }
                .keyboardShortcut(.rightArrow, modifiers: [.command])
                .disabled(model == nil)
            Divider()
            ForEach(AppSection.allCases) { section in
                Button(section.title) { model?.section = section }
                    .disabled(model == nil)
            }
        }
    }
}

private struct SwordReaderModelFocusedValueKey: FocusedValueKey {
    typealias Value = AppModel
}

extension FocusedValues {
    var swordReaderModel: AppModel? {
        get { self[SwordReaderModelFocusedValueKey.self] }
        set { self[SwordReaderModelFocusedValueKey.self] = newValue }
    }
}
#endif
