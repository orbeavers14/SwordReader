import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @Environment(AppModel.self) private var model
    @State private var isImporting = false
    @State private var modulePendingRemoval: BibleModule?
    @State private var isShowingRemoteAccessWarning = false
    @State private var isShowingModuleBrowser = false

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

            if let catalog = model.catalog {
                Section("Available in \(catalog.directory.lastPathComponent)") {
                    ForEach(catalog.modules.filter(\.isBible)) { module in
                        HStack {
                            moduleDescription(
                                title: module.title,
                                details: [module.id, module.language, module.version]
                            )
                            Spacer()
                            if model.modules.contains(where: { $0.id == module.id }) {
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
                Button("Get Bibles", systemImage: "arrow.down.circle") {
                    isShowingRemoteAccessWarning = true
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Import Local Catalog", systemImage: "folder.badge.plus") {
                    isImporting = true
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
        .overlay {
            if model.isInstalling {
                ProgressView("Installing…")
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
