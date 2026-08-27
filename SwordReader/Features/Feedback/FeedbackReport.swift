import Foundation

#if canImport(MetricKit)
import MetricKit
#endif

struct CrashDiagnosticReport: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let capturedAt: Date
    let json: String

    init(id: UUID = UUID(), capturedAt: Date = .now, json: String) {
        self.id = id
        self.capturedAt = capturedAt
        self.json = json
    }
}

struct CrashDiagnosticIssueDraft: Hashable, Sendable {
    let report: CrashDiagnosticReport

    var title: String { "[Crash] Apple diagnostic report" }

    var body: String {
        let limit = 6_000
        let excerpt = String(report.json.prefix(limit))
        let truncationNotice = report.json.count > limit
            ? "\n\n_Diagnostic shortened for the GitHub draft. Use Share Full Diagnostic to attach the complete JSON._"
            : ""
        return """
        ## Apple Crash Diagnostic

        Captured: \(report.capturedAt.formatted(.iso8601))

        ```json
        \(excerpt)
        ```\(truncationNotice)

        _I reviewed this diagnostic before sharing it._
        """
    }

    var githubIssueURL: URL? {
        var components = URLComponents(
            string: "https://github.com/orbeavers14/SwordReader/issues/new"
        )
        components?.queryItems = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "body", value: body),
        ]
        return components?.url
    }
}

struct CrashDiagnosticStore {
    static let didSaveNotification = Notification.Name(
        "SwordReaderCrashDiagnosticDidSave"
    )
    private static let defaultsKey = "diagnostics.pendingCrash"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func pendingReport() -> CrashDiagnosticReport? {
        defaults.data(forKey: Self.defaultsKey).flatMap {
            try? JSONDecoder().decode(CrashDiagnosticReport.self, from: $0)
        }
    }

    func save(_ report: CrashDiagnosticReport) {
        guard let data = try? JSONEncoder().encode(report) else { return }
        defaults.set(data, forKey: Self.defaultsKey)
        NotificationCenter.default.post(name: Self.didSaveNotification, object: nil)
    }

    func clear() {
        defaults.removeObject(forKey: Self.defaultsKey)
    }
}

#if canImport(MetricKit)
final class MetricKitCrashMonitor: NSObject, MXMetricManagerSubscriber, @unchecked Sendable {
    static let shared = MetricKitCrashMonitor()
    private let store = CrashDiagnosticStore()
    private var isStarted = false

    func start() {
        guard !isStarted else { return }
        isStarted = true
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {}

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads where payload.crashDiagnostics?.isEmpty == false {
            guard let json = String(
                data: payload.jsonRepresentation(),
                encoding: .utf8
            ) else { continue }
            store.save(CrashDiagnosticReport(json: json))
        }
    }
}
#endif

enum FeedbackKind: String, CaseIterable, Identifiable, Sendable {
    case bug
    case feature

    var id: Self { self }

    var title: String {
        switch self {
        case .bug: String(localized: "Bug Report")
        case .feature: String(localized: "Feature Request")
        }
    }

    var issuePrefix: String {
        switch self {
        case .bug: "Bug"
        case .feature: "Feature"
        }
    }
}

struct FeedbackDiagnostics: Hashable, Sendable {
    let appVersion: String
    let platform: String
    let osVersion: String
    let modules: [String]

    var markdown: String {
        """
        - SwordReader: \(appVersion)
        - Platform: \(platform)
        - OS: \(osVersion)
        - Installed Bible modules: \(modules.isEmpty ? "None" : modules.joined(separator: ", "))
        """
    }
}

struct FeedbackReport: Hashable, Sendable {
    let kind: FeedbackKind
    let title: String
    let details: String
    let reproductionSteps: String
    let diagnostics: FeedbackDiagnostics

    var issueTitle: String {
        "[\(kind.issuePrefix)] \(title.trimmingCharacters(in: .whitespacesAndNewlines))"
    }

    var body: String {
        var sections = [
            "## Description\n\(details.trimmingCharacters(in: .whitespacesAndNewlines))"
        ]
        if kind == .bug, !reproductionSteps.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sections.append("## Steps to Reproduce\n\(reproductionSteps.trimmingCharacters(in: .whitespacesAndNewlines))")
        }
        sections.append("## App Diagnostics\n\(diagnostics.markdown)")
        sections.append("_I reviewed this report before sharing it._")
        return sections.joined(separator: "\n\n")
    }

    var githubIssueURL: URL? {
        githubIssueURL(body: body)
    }

    func githubIssueURL(body: String) -> URL? {
        var components = URLComponents(string: "https://github.com/orbeavers14/SwordReader/issues/new")
        components?.queryItems = [
            URLQueryItem(name: "title", value: issueTitle),
            URLQueryItem(name: "body", value: body)
        ]
        return components?.url
    }
}
