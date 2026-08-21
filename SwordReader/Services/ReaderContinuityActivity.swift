import Foundation

enum ReaderContinuityActivity {
    static let activityType = "com.orbeavers14.SwordReader.reading"
    private static let moduleKey = "module"
    private static let referenceKey = "reference"

    static func update(
        _ activity: NSUserActivity,
        with destination: ReaderDestination
    ) {
        activity.title = destination.reference
        activity.userInfo = [
            moduleKey: destination.moduleID as Any,
            referenceKey: destination.reference
        ]
        activity.requiredUserInfoKeys = [referenceKey]
        activity.targetContentIdentifier = destination.url?.absoluteString
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = false
        activity.isEligibleForPublicIndexing = false
        activity.needsSave = true
    }

    static func destination(from activity: NSUserActivity) -> ReaderDestination? {
        guard activity.activityType == activityType,
              let reference = activity.userInfo?[referenceKey] as? String,
              !reference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }
        return ReaderDestination(
            moduleID: activity.userInfo?[moduleKey] as? String,
            reference: reference
        )
    }
}
