import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

struct CompanionPassage: Codable, Hashable, Sendable {
    static let schemaVersion = 1
    let schemaVersion: Int
    let reference: String
    let moduleID: String
    let verses: [CompanionVerse]
    let updatedAt: Date

    init(chapter: BibleChapter) {
        schemaVersion = Self.schemaVersion
        reference = chapter.reference
        moduleID = chapter.moduleID
        verses = chapter.verses.map {
            CompanionVerse(number: $0.number, text: $0.text)
        }
        updatedAt = .now
    }
}

struct CompanionVerse: Codable, Hashable, Sendable {
    let number: String
    let text: String
}

@MainActor
protocol CompanionSyncing: AnyObject {
    func send(chapter: BibleChapter)
    func sendModule(moduleID: String) async throws
}

enum CompanionSyncError: LocalizedError {
    case unavailable
    case invalidModuleID

    var errorDescription: String? {
        switch self {
        case .unavailable:
            String(localized: "Apple Watch is not paired or SwordReader is not installed on it.")
        case .invalidModuleID:
            String(localized: "This Bible cannot be prepared for Apple Watch.")
        }
    }
}

extension CompanionSyncing {
    func sendModule(moduleID: String) async throws { throw CompanionSyncError.unavailable }
}

#if canImport(WatchConnectivity) && !os(watchOS)
@MainActor
final class WatchPassageSync: NSObject, CompanionSyncing, WCSessionDelegate {
    private let session: WCSession?
    private var pendingArchives: Set<URL> = []

    override init() {
        session = WCSession.isSupported() ? .default : nil
        super.init()
        session?.delegate = self
        session?.activate()
    }

    func send(chapter: BibleChapter) {
        guard let session,
              let data = try? JSONEncoder().encode(
                CompanionPassage(chapter: chapter)
              )
        else { return }
        try? session.updateApplicationContext(["passage": data])
    }

    func sendModule(moduleID: String) async throws {
        guard let session else { throw CompanionSyncError.unavailable }
        #if os(iOS)
        guard session.isPaired, session.isWatchAppInstalled else {
            throw CompanionSyncError.unavailable
        }
        #endif
        guard !moduleID.isEmpty,
              moduleID != ".",
              moduleID != "..",
              !moduleID.contains("/"),
              !moduleID.contains("\\"),
              let remoteURL = URL(string: "https://www.crosswire.org/ftpmirror/pub/sword/packages/rawzip/\(moduleID).zip")
        else { throw CompanionSyncError.invalidModuleID }

        let (temporaryURL, _) = try await URLSession.shared.download(from: remoteURL)
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appending(path: "WatchTransfers", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let archive = directory.appending(path: "\(moduleID)-\(UUID().uuidString).zip")
        try FileManager.default.moveItem(at: temporaryURL, to: archive)
        pendingArchives.insert(archive)
        session.transferFile(archive, metadata: ["moduleID": moduleID])
    }

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {}

    nonisolated func session(
        _ session: WCSession,
        fileTransfer: WCSessionFileTransfer,
        didFinishWithError error: (any Error)?
    ) {
        let url = fileTransfer.file.fileURL
        Task { @MainActor in
            self.pendingArchives.remove(url)
            try? FileManager.default.removeItem(at: url)
        }
    }

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
#endif
