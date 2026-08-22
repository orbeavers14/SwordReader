import Foundation

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
