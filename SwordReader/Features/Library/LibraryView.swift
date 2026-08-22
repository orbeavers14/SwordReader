import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @Environment(AppModel.self) private var model
    @State private var isImporting = false
    @State private var modulePendingRemoval: BibleModule?
    @State private var keyedModulePendingRemoval: KeyedModule?
    @State private var isShowingRemoteAccessWarning = false
    @State private var isShowingModuleBrowser = false
    @State private var isShowingPrivacyAndLicenses = false
    @State private var isShowingFeedback = false

    var body: some View {
        List {
            Section("Installed Bibles") {
                if model.modules.isEmpty {
                    Text("No Bibles installed").foregroundStyle(.secondary)
                }
                ForEach(model.modules) { module in
                    Button {
                        model.selectModule(module.id)
                    } label: {
                        HStack {
                            moduleDescription(
                                title: module.title,
                                details: [module.id, module.language, module.version]
                            )
                            Spacer()
                            if module.id == model.selectedModuleID {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                                    .accessibilityLabel("Selected")
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if let copyright = module.copyright {
                            Text(copyright)
                        }
                        #if os(iOS)
                        Button("Send to Apple Watch", systemImage: "applewatch") {
                            Task { await model.sendModuleToWatch(module.id) }
                        }
                        .disabled(model.sendingModuleID != nil)
                        #endif
                        Button("Remove Bible", systemImage: "trash", role: .destructive) {
                            modulePendingRemoval = module
                        }
                    }
                    #if !os(macOS)
                    .swipeActions {
                        Button("Remove", systemImage: "trash", role: .destructive) {
                            modulePendingRemoval = module
                        }
                    }
                    #endif
                    .disabled(model.removingModuleID != nil)
                }
            }

            Section("Books & Devotionals") {
                if model.keyedModules.isEmpty {
                    Text("No books or devotionals installed")
                        .foregroundStyle(.secondary)
                }
                ForEach(model.keyedModules) { module in
                    NavigationLink {
                        KeyedModuleReaderView(module: module)
                            .environment(model)
                    } label: {
                        moduleDescription(
                            title: module.title,
                            details: [module.category.title, module.language, module.version]
                        )
                    }
                    .contextMenu {
                        if let copyright = module.copyright { Text(copyright) }
                        Button("Remove", systemImage: "trash", role: .destructive) {
                            keyedModulePendingRemoval = module
                        }
                    }
                }
            }

            if let catalog = model.catalog {
                Section("Available in \(catalog.directory.lastPathComponent)") {
                    ForEach(catalog.modules.filter { $0.compatibility == .compatible }) { module in
                        HStack {
                            moduleDescription(
                                title: module.title,
                                details: [module.id, module.language, module.version]
                            )
                            Spacer()
                            if model.modules.contains(where: { $0.id == module.id })
                                || model.keyedModules.contains(where: { $0.id == module.id }) {
                                Text("Installed")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Button("Install") { Task { await model.install(module) } }
                                    .disabled(model.isInstalling)
                            }
                        }
                        if let copyright = module.copyright {
                            Text(copyright)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Library")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Get Modules", systemImage: "arrow.down.circle") {
                    isShowingRemoteAccessWarning = true
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Import Local Catalog", systemImage: "folder.badge.plus") {
                    isImporting = true
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Feedback", systemImage: "bubble.left.and.exclamationmark.bubble.right") {
                    isShowingFeedback = true
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Privacy & Licenses", systemImage: "info.circle") {
                    isShowingPrivacyAndLicenses = true
                }
            }
        }
        .confirmationDialog(
            "Connect to CrossWire?",
            isPresented: $isShowingRemoteAccessWarning,
            titleVisibility: .visible
        ) {
            Button("Continue") {
                isShowingModuleBrowser = true
                Task { await model.refreshRemoteCatalog() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("SwordReader will contact the CrossWire Bible Society to retrieve its module catalog. This network request may reveal that you use a Bible reader. Modules are supplied by their publishers and have separate licenses.")
        }
        .sheet(isPresented: $isShowingModuleBrowser) {
            RemoteModuleBrowser().environment(model)
        }
        .sheet(isPresented: $isShowingPrivacyAndLicenses) {
            PrivacyAndLicensesView().environment(model)
        }
        .sheet(isPresented: $isShowingFeedback) {
            FeedbackView().environment(model)
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result {
                Task { await model.inspectCatalog(at: url) }
            } else if case .failure(let error) = result {
                model.presentedError = PresentedError(error)
            }
        }
        .confirmationDialog(
            "Remove \(modulePendingRemoval?.title ?? "Bible")?",
            isPresented: Binding(
                get: { modulePendingRemoval != nil },
                set: { if !$0 { modulePendingRemoval = nil } }
            ),
            titleVisibility: .visible,
            presenting: modulePendingRemoval
        ) { module in
            Button("Remove Bible", role: .destructive) {
                modulePendingRemoval = nil
                Task { await model.removeModule(id: module.id) }
            }
            Button("Cancel", role: .cancel) { modulePendingRemoval = nil }
        } message: { module in
            Text("\(module.title) will be removed from this device. You can install it again from its source catalog.")
        }
        .confirmationDialog(
            "Remove \(keyedModulePendingRemoval?.title ?? "module")?",
            isPresented: Binding(
                get: { keyedModulePendingRemoval != nil },
                set: { if !$0 { keyedModulePendingRemoval = nil } }
            ),
            titleVisibility: .visible,
            presenting: keyedModulePendingRemoval
        ) { module in
            Button("Remove", role: .destructive) {
                keyedModulePendingRemoval = nil
                Task { await model.removeKeyedModule(id: module.id) }
            }
            Button("Cancel", role: .cancel) { keyedModulePendingRemoval = nil }
        } message: { module in
            Text("\(module.title) will be removed from this device.")
        }
        .overlay {
            if model.isInstalling {
                ProgressView("Installing…")
                    .padding()
                    .background(.regularMaterial, in: .rect(cornerRadius: 12))
            } else if let moduleID = model.sendingModuleID {
                ProgressView("Sending \(moduleID) to Apple Watch…")
                    .padding()
                    .background(.regularMaterial, in: .rect(cornerRadius: 12))
            } else if model.removingModuleID != nil {
                ProgressView("Removing…")
                    .padding()
                    .background(.regularMaterial, in: .rect(cornerRadius: 12))
            }
        }
    }

    private func moduleDescription(
        title: String,
        details: [String?]
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
            Text(details.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · "))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct KeyedModuleReaderView: View {
    @Environment(AppModel.self) private var model
    let module: KeyedModule
    @State private var keys: [String] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Opening \(module.category.title)…")
            } else if keys.isEmpty {
                ContentUnavailableView(
                    "No Readable Entries",
                    systemImage: "text.book.closed",
                    description: Text("This module did not provide any navigable entries.")
                )
            } else {
                List(keys, id: \.self) { key in
                    NavigationLink {
                        KeyedEntryView(module: module, key: key)
                            .environment(model)
                    } label: {
                        Text(Self.displayTitle(for: key))
                    }
                }
            }
        }
        .navigationTitle(module.title)
        .task {
            do {
                keys = try await model.keyedEntryKeys(moduleID: module.id)
            } catch {
                model.presentedError = PresentedError(error)
            }
            isLoading = false
        }
    }

    private static func displayTitle(for key: String) -> String {
        key.split(separator: "/").last.map(String.init) ?? key
    }
}

private struct KeyedEntryView: View {
    @Environment(AppModel.self) private var model
    let module: KeyedModule
    let key: String
    @State private var entry: KeyedModuleEntry?

    var body: some View {
        ScrollView {
            if let entry {
                Text(entry.text)
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: 720, alignment: .leading)
                    .padding()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .navigationTitle(key.split(separator: "/").last.map(String.init) ?? key)
        .task(id: key) {
            do {
                entry = try await model.keyedEntry(moduleID: module.id, key: key)
            } catch {
                model.presentedError = PresentedError(error)
            }
        }
    }
}
