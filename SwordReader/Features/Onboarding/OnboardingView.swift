import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var isShowingRemoteAccessWarning = false
    @State private var isShowingModuleBrowser = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 32)

            Image(systemName: "book.pages.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Welcome to SwordReader")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Text("A focused, private place to read and search Scripture.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 24) {
                OnboardingFeature(
                    systemImage: "character.book.closed",
                    title: "Choose Your Translation",
                    detail: "Install compatible SWORD Bible modules and switch between them at any time."
                )
                OnboardingFeature(
                    systemImage: "lock.shield",
                    title: "Kept on This Device",
                    detail: "Reading and search happen locally. SwordReader does not require an account."
                )
                OnboardingFeature(
                    systemImage: "doc.text.magnifyingglass",
                    title: "Module Licenses Stay Their Own",
                    detail: "Each Bible module has separate copyright and distribution terms shown in the Library."
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 36)

            Spacer(minLength: 20)

            Button {
                if model.modules.isEmpty {
                    isShowingRemoteAccessWarning = true
                } else {
                    model.completeOnboarding()
                }
            } label: {
                Text(model.modules.isEmpty ? "Browse Bibles" : "Start Reading")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)

            if model.modules.isEmpty {
                Button("Set Up Later") { model.completeOnboarding() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .padding(.top, 14)
            }
        }
        .frame(maxWidth: 520)
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .interactiveDismissDisabled()
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
    }
}

private struct OnboardingFeature: View {
    let systemImage: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
