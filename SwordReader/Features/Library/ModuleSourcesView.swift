import SwiftUI

struct ModuleSourcesView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var isAddingCustomSource = false
    @State private var isApprovingEBible = false

    var body: some View {
        NavigationStack {
            List {
                Section("Approved Sources") {
                    ForEach(model.moduleSources) { source in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(source.name)
                                if source.isCurated {
                                    Text("Curated")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.tint)
                                }
                            }
                            Text("https://\(source.host)\(source.catalogPath)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                        .swipeActions {
                            if source.id != ModuleSource.crossWire.id {
                                Button("Remove", systemImage: "trash", role: .destructive) {
                                    model.removeModuleSource(source.id)
                                }
                            }
                        }
                    }
                }

                if !model.moduleSources.contains(.eBible) {
                    Section("Curated Sources") {
                        Button {
                            isApprovingEBible = true
                        } label: {
                            Label("Add eBible.org", systemImage: "plus.circle")
                        }
                        Text("eBible.org publishes a large SWORD Bible catalog in many languages. Adding it does not contact the service until you choose it in Get Bibles.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Advanced") {
                    Button("Add Custom HTTPS Source", systemImage: "server.rack") {
                        isAddingCustomSource = true
                    }
                    Text("Only add a repository you trust. SwordReader accepts HTTPS SWORD catalogs and raw module packages; ordinary PDF, EPUB, and USFM files are not installable modules.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Module Sources")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Add eBible.org?",
                isPresented: $isApprovingEBible,
                titleVisibility: .visible
            ) {
                Button("Add Source") { model.approveModuleSource(.eBible) }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This saves eBible.org as an available source. SwordReader will ask before making a network connection.")
            }
            .sheet(isPresented: $isAddingCustomSource) {
                CustomModuleSourceView().environment(model)
            }
        }
        .frame(idealWidth: 560, idealHeight: 620)
    }
}

private struct CustomModuleSourceView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var host = ""
    @State private var catalogPath = ""
    @State private var packagePath = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Repository") {
                    TextField("Name", text: $name)
                    TextField("Host, such as modules.example.org", text: $host)
                        .textContentType(.URL)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        #endif
                    TextField("Catalog path, such as /sword/raw", text: $catalogPath)
                    TextField("Package path, such as /sword/zip", text: $packagePath)
                }

                Section {
                    Label("HTTPS is required", systemImage: "lock.fill")
                    Label("Catalog must contain SWORD module metadata", systemImage: "doc.text.magnifyingglass")
                    Label("Only Bible-category modules are supported", systemImage: "book.closed")
                } header: {
                    Text("Compatibility Requirements")
                }

                if let validationMessage {
                    Section {
                        Label(validationMessage, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Custom Source")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Review & Add") { save() }
                }
            }
        }
        .frame(idealWidth: 520, idealHeight: 560)
    }

    private func save() {
        do {
            let source = try ModuleSource.validated(
                name: name,
                host: host,
                catalogPath: catalogPath,
                packagePath: packagePath
            )
            model.approveModuleSource(source)
            dismiss()
        } catch {
            validationMessage = error.localizedDescription
        }
    }
}
