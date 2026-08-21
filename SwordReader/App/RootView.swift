import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            #if os(macOS)
            SplitRootView()
            #else
            TabRootView()
            #endif
        }
        .alert(item: Bindable(model).presentedError) { error in
            Alert(
                title: Text("Something Went Wrong"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(item: Bindable(model).continuityNotice) { notice in
            Alert(
                title: Text("Bible Not Installed"),
                message: Text(notice.message),
                primaryButton: .default(Text("Download & Continue")) {
                    Task { await model.downloadContinuityModule() }
                },
                secondaryButton: .cancel(
                    Text(notice.currentTranslationTitle == nil ? "Not Now" : "Use Current Bible")
                )
            )
        }
        #if os(macOS)
        .sheet(isPresented: onboardingBinding) {
            OnboardingView().environment(model)
        }
        #else
        .fullScreenCover(isPresented: onboardingBinding) {
            OnboardingView().environment(model)
        }
        #endif
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { model.isPresentingOnboarding },
            set: { if !$0 { model.completeOnboarding() } }
        )
    }
}

private struct TabRootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model
        TabView(selection: $model.section) {
            NavigationStack { ReaderView() }
                .tabItem { Label(AppSection.read.title, systemImage: AppSection.read.systemImage) }
                .tag(AppSection.read)
            NavigationStack { ReadingPlansView() }
                .tabItem { Label(AppSection.plans.title, systemImage: AppSection.plans.systemImage) }
                .tag(AppSection.plans)
            NavigationStack { SearchView() }
                .tabItem { Label(AppSection.search.title, systemImage: AppSection.search.systemImage) }
                .tag(AppSection.search)
            NavigationStack { LibraryView() }
                .tabItem { Label(AppSection.library.title, systemImage: AppSection.library.systemImage) }
                .tag(AppSection.library)
        }
    }
}

private struct SplitRootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases) { section in
                Button {
                    model.section = section
                } label: {
                    HStack {
                        Label(section.title, systemImage: section.systemImage)
                        Spacer()
                        if model.section == section {
                            Image(systemName: "checkmark")
                                .accessibilityHidden(true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowBackground(model.section == section ? Color.accentColor.opacity(0.14) : Color.clear)
                .accessibilityAddTraits(
                    model.section == section ? .isSelected : []
                )
            }
            .navigationTitle("SwordReader")
        } detail: {
            NavigationStack {
                switch model.section {
                case .read: ReaderView()
                case .plans: ReadingPlansView()
                case .search: SearchView()
                case .library: LibraryView()
                }
            }
        }
    }
}
