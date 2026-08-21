import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var model

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
            .padding(.vertical, 36)

            Spacer(minLength: 20)

            Button(model.modules.isEmpty ? "Choose a Bible" : "Start Reading") {
                model.completeOnboarding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: 520)
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .interactiveDismissDisabled()
    }
}

private struct OnboardingFeature: View {
    let systemImage: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(detail).foregroundStyle(.secondary)
            }
        }
    }
}
