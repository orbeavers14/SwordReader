import SwiftUI

struct RemoteModuleBrowser: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var selectedLanguage: String?
    @State private var isShowingSources = false
    @State private var pendingSource: ModuleSource?

    private var selectedSource: ModuleSource {
        model.moduleSources.first(where: { $0.id == model.selectedModuleSourceID }) ?? .crossWire
    }

    private var filteredModules: [CatalogModule] {
        CatalogFilter.apply(
            to: model.remoteModules,
            query: query,
            language: selectedLanguage
        )
    }

    private var availableLanguages: [String] {
        CatalogFilter.availableLanguages(in: model.remoteModules)
    }

    var body: some View {
        NavigationStack {
            Group {
                if model.isRefreshingRemoteCatalog && model.remoteModules.isEmpty {
                    ContentUnavailableView {
                        ProgressView()
                        Text("Finding Bibles")
                    } description: {
                        Text("Contacting \(selectedSource.name)…")
                    }
                } else if filteredModules.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    List(filteredModules) { module in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                moduleDescription(module)
                                Spacer()
                                installControl(for: module)
                            }

                            if let copyright = module.copyright {
                                Text(copyright)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Label(module.compatibility.title, systemImage: module.compatibility == .compatible ? "checkmark.shield" : "xmark.shield")
                                .font(.caption)
                                .foregroundStyle(module.compatibility == .compatible ? Color.secondary : Color.red)
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
            .navigationTitle("Get Modules")
            .searchable(text: $query, prompt: "Name, abbreviation, or language")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task { await model.refreshRemoteCatalog() }
                    }
                    .disabled(model.isRefreshingRemoteCatalog || model.installingModuleID != nil)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Picker("Language", selection: $selectedLanguage) {
                            Text("All Languages").tag(String?.none)
                            ForEach(availableLanguages, id: \.self) { code in
                                Text(CatalogFilter.languageName(for: code))
                                    .tag(Optional(code))
                            }
                        }
                    } label: {
                        Label(
                            selectedLanguage.map(CatalogFilter.languageName(for:)) ?? "All Languages",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                    }
                    .help("Filter by Language")
                }
                ToolbarItem(placement: .secondaryAction) {
                    Menu(selectedSource.name, systemImage: "server.rack") {
                        ForEach(model.moduleSources) { source in
                            Button {
                                pendingSource = source
                            } label: {
                                if source.id == selectedSource.id {
                                    Label(source.name, systemImage: "checkmark")
                                } else {
                                    Text(source.name)
                                }
                            }
                        }
                        Divider()
                        Button("Manage Sources…", systemImage: "gear") {
                            isShowingSources = true
                        }
                    }
                }
            }
        }
        .frame(minWidth: 520, minHeight: 480)
        .sheet(isPresented: $isShowingSources) {
            ModuleSourcesView().environment(model)
        }
        .confirmationDialog(
            "Connect to \(pendingSource?.name ?? "this source")?",
            isPresented: Binding(
                get: { pendingSource != nil },
                set: { if !$0 { pendingSource = nil } }
            ),
            titleVisibility: .visible,
            presenting: pendingSource
        ) { source in
            Button("Connect") {
                pendingSource = nil
                Task { await model.refreshRemoteCatalog(sourceID: source.id) }
            }
            Button("Cancel", role: .cancel) { pendingSource = nil }
        } message: { source in
            Text("SwordReader will contact \(source.host) to retrieve its SWORD catalog. The source receives the network information needed to serve this request.")
        }
    }

    private func moduleDescription(_ module: CatalogModule) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(module.title)
                if module.id == "ASV" {
                    Text("Recommended")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.tint)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.tint.opacity(0.12), in: .capsule)
                }
            }
            Text([module.id, module.language, module.version]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " · "))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(module.category.title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("Source: \(selectedSource.host)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func installControl(for module: CatalogModule) -> some View {
        if model.modules.contains(where: { $0.id == module.id })
            || model.keyedModules.contains(where: { $0.id == module.id }) {
            Text("Installed")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else if model.installingModuleID == module.id {
            HStack(spacing: 8) {
                if let fraction = model.installProgress?.fractionCompleted {
                    ProgressView(value: fraction)
                        .frame(width: 64)
                        .accessibilityLabel("Downloading \(module.title)")
                } else {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel("Downloading \(module.title)")
                }
                Button("Cancel", role: .cancel) { model.cancelRemoteInstall() }
            }
        } else {
            Button("Get") { Task { await model.installRemote(module) } }
                .buttonStyle(.bordered)
                .disabled(model.installingModuleID != nil || module.compatibility != .compatible)
                .accessibilityLabel("Get \(module.title)")
        }
    }
}
