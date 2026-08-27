import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct FeedbackView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var kind = FeedbackKind.bug
    @State private var title = ""
    @State private var reportBody = ""
    @State private var hasPreparedReport = false
    @State private var isShowingCopiedConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Feedback Type", selection: $kind) {
                        ForEach(FeedbackKind.allCases) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField(kind == .bug ? "Short description of the problem" : "Short name for your idea", text: $title)
                } header: {
                    Text("What would you like to share?")
                }

                Section {
                    TextEditor(text: $reportBody)
                        .font(.body.monospaced())
                        .frame(minHeight: 250)
                        .accessibilityLabel("Report Preview")

                    Button("Restore Report Template", systemImage: "arrow.counterclockwise") {
                        prepareReport()
                    }
                } header: {
                    Text("Review Before Sharing")
                } footer: {
                    Text("Edit or remove anything you do not want to share. SwordReader does not include notes, bookmarks, reading history, searches, Scripture text, or file paths.")
                }

                Section {
                    Button("Open GitHub Issue", systemImage: "safari") {
                        guard let url = outgoingReport.githubIssueURL(body: reportBody) else { return }
                        openURL(url)
                    }
                    .disabled(!canShare)

                    ShareLink(
                        item: shareText,
                        subject: Text(outgoingReport.issueTitle),
                        message: Text("SwordReader feedback")
                    ) {
                        Label("Share Report", systemImage: "square.and.arrow.up")
                    }
                    .disabled(!canShare)

                    Button("Copy Report", systemImage: "doc.on.doc") {
                        copyToPasteboard(shareText)
                        isShowingCopiedConfirmation = true
                    }
                    .disabled(!canShare)
                } footer: {
                    Text("GitHub opens in your browser for final review and submission using your own account. SwordReader never stores GitHub credentials or submits reports automatically.")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Feedback")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                guard !hasPreparedReport else { return }
                hasPreparedReport = true
                prepareReport()
            }
            .onChange(of: kind) { _, _ in prepareReport() }
            .alert("Report Copied", isPresented: $isShowingCopiedConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You can paste it into an email, message, or issue tracker.")
            }
        }
        .frame(idealWidth: 620, idealHeight: 720)
    }

    private var canShare: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !reportBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var outgoingReport: FeedbackReport {
        FeedbackReport(
            kind: kind,
            title: title,
            details: reportBody,
            reproductionSteps: "",
            diagnostics: diagnostics
        )
    }

    private var shareText: String {
        "\(outgoingReport.issueTitle)\n\n\(reportBody)"
    }

    private var diagnostics: FeedbackDiagnostics {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = info?["CFBundleVersion"] as? String ?? "Unknown"
        let modules = model.modules.map { module in
            [module.id, module.version].compactMap { $0 }.joined(separator: " ")
        }
        return FeedbackDiagnostics(
            appVersion: "\(version) (\(build))",
            platform: platformName,
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            modules: modules
        )
    }

    private var platformName: String {
        #if os(macOS)
        "macOS"
        #else
        UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #endif
    }

    private func prepareReport() {
        let details = kind == .bug
            ? "Describe what happened and what you expected to happen."
            : "Describe the idea and how it would improve SwordReader."
        let steps = kind == .bug
            ? "1. \n2. \n3. "
            : ""
        reportBody = FeedbackReport(
            kind: kind,
            title: title,
            details: details,
            reproductionSteps: steps,
            diagnostics: diagnostics
        ).body
    }

    private func copyToPasteboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

struct CrashDiagnosticReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    let report: CrashDiagnosticReport
    let deleteReport: () -> Void
    @State private var reviewedJSON: String
    @State private var isConfirmingDeletion = false

    init(report: CrashDiagnosticReport, deleteReport: @escaping () -> Void) {
        self.report = report
        self.deleteReport = deleteReport
        _reviewedJSON = State(initialValue: report.json)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $reviewedJSON)
                        .font(.body.monospaced())
                        .frame(minHeight: 320)
                        .accessibilityLabel("Apple Crash Diagnostic")
                } header: {
                    Text("Review Apple Diagnostic")
                } footer: {
                    Text("Crash diagnostics may contain device details, file paths, and runtime information. Edit or remove anything you do not want to share.")
                }

                Section {
                    Button("Open GitHub Issue Draft", systemImage: "safari") {
                        if let url = draft.githubIssueURL { openURL(url) }
                    }
                    .disabled(reviewedJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    ShareLink(
                        item: reviewedJSON,
                        subject: Text(draft.title),
                        message: Text("SwordReader Apple crash diagnostic")
                    ) {
                        Label("Share Full Diagnostic", systemImage: "square.and.arrow.up")
                    }

                    Button("Delete Stored Diagnostic", systemImage: "trash", role: .destructive) {
                        isConfirmingDeletion = true
                    }
                } header: {
                    Text("Share After Review")
                } footer: {
                    Text("GitHub opens for final review under your own account. SwordReader stores no GitHub credentials and never submits crash reports automatically.")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Crash Report")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Delete this diagnostic?",
                isPresented: $isConfirmingDeletion,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deleteReport() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The locally stored Apple diagnostic will be permanently removed.")
            }
        }
        .frame(idealWidth: 700, idealHeight: 720)
    }

    private var draft: CrashDiagnosticIssueDraft {
        CrashDiagnosticIssueDraft(
            report: CrashDiagnosticReport(
                id: report.id,
                capturedAt: report.capturedAt,
                json: reviewedJSON
            )
        )
    }
}
