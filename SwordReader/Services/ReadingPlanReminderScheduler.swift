import Foundation
import UserNotifications

@MainActor
protocol ReadingPlanReminderScheduling: AnyObject {
    func scheduleDaily(hour: Int, minute: Int) async throws
    func disable()
}

enum ReadingPlanReminderError: LocalizedError {
    case permissionDenied
    var errorDescription: String? {
        "Notifications are disabled for SwordReader. You can enable them in System Settings."
    }
}

@MainActor
final class ReadingPlanReminderScheduler: ReadingPlanReminderScheduling {
    private let center = UNUserNotificationCenter.current()
    private let identifier = "reading-plan.daily"

    func scheduleDaily(hour: Int, minute: Int) async throws {
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            guard try await center.requestAuthorization(options: [.alert, .sound]) else {
                throw ReadingPlanReminderError.permissionDenied
            }
        } else if settings.authorizationStatus != .authorized
                    && settings.authorizationStatus != .provisional {
            throw ReadingPlanReminderError.permissionDenied
        }
        let content = UNMutableNotificationContent()
        content.title = "Today’s Reading"
        content.body = "Continue your optional SwordReader reading plan."
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute),
            repeats: true
        )
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        try await center.add(.init(identifier: identifier, content: content, trigger: trigger))
    }

    func disable() {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
