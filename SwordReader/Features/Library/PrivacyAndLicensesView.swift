import SwiftUI

struct PrivacyAndLicensesView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Privacy") {
                    Label("No tracking or analytics", systemImage: "hand.raised")
                    Label("No account or SwordReader server", systemImage: "person.crop.circle.badge.xmark")
                    Label("Reading data stays on your devices", systemImage: "iphone.and.arrow.forward")

                    Text("SwordReader contacts an approved module source only when you choose to browse or download Bible modules from it. That source receives the network information ordinarily required to serve the request.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section("SwordReader") {
                    Text("SwordReader is free software licensed under GNU GPL version 2 only. It is provided without warranty.")
                    Link("View Source and Complete License", destination: Self.sourceURL)
                }

                Section("Open Source Components") {
                    component(
                        "SwordKit",
                        detail: "Swift wrapper for the CrossWire SWORD engine",
                        destination: Self.swordKitURL
                    )
                    component(
                        "CrossWire SWORD",
                        detail: "Scripture module engine; licensed under GNU GPL",
                        destination: Self.swordURL
                    )
                }

                Section("Installed Bible Modules") {
                    if model.modules.isEmpty {
                        Text("No Bible modules installed")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.modules) { module in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(module.title)
                                    .font(.headline)
                                Text(module.copyright ?? "No publisher-supplied license summary is available. Review the module information from its distributor before sharing it.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                            }
                            .padding(.vertical, 2)
                        }
                    }

                    Text("Bible modules are separate works with their own copyright and distribution terms. Installing a module does not grant permission to redistribute it.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Privacy & Licenses")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(idealWidth: 560, idealHeight: 640)
    }

    private func component(
        _ name: String,
        detail: String,
        destination: URL
    ) -> some View {
        Link(destination: destination) {
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityHint("Opens the project website")
    }

    private static let sourceURL = URL(string: "https://github.com/orbeavers14/SwordReader")!
    private static let swordKitURL = URL(string: "https://github.com/orbeavers14/SwordKit")!
    private static let swordURL = URL(string: "https://crosswire.org/sword/")!
}
