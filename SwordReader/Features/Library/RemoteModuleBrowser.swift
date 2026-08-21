import SwiftUI

struct RemoteModuleBrowser: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var filteredModules: [CatalogModule] {
        guard !query.isEmpty else { return model.remoteModules }
        return model.remoteModules.filter {
            [$0.title, $0.id, $0.language]
                .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if model.isRefreshingRemoteCatalog && model.remoteModules.isEmpty {
                    ContentUnavailableView {
                        ProgressView()
                        Text("Finding Bibles")
                    } description: {
                        Text("Contacting the CrossWire Bible Society…")
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
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
            .navigationTitle("Get Bibles")
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
            }
        }
        .frame(minWidth: 520, minHeight: 480)
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
        }
    }

    @ViewBuilder
    private func installControl(for module: CatalogModule) -> some View {
        if model.modules.contains(where: { $0.id == module.id }) {
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
                .disabled(model.installingModuleID != nil)
                .accessibilityLabel("Get \(module.title)")
        }
    }
}
