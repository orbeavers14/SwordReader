import Foundation

/// An ordered, immutable Scripture reading plan.
public struct SwordReadingPlan: Hashable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let days: [SwordReadingPlanDay]

    public init(
        id: String,
        title: String,
        days: [SwordReadingPlanDay]
    ) throws {
        let id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !id.isEmpty,
            !title.isEmpty,
            !days.isEmpty,
            Set(days.map(\.id)).count == days.count
        else {
            throw SwordError.invalidReadingPlan(id)
        }

        self.id = id
        self.title = title
        self.days = days
    }
}

/// One ordered day in a reading plan.
public struct SwordReadingPlanDay: Hashable, Sendable, Identifiable {
    public let id: Int
    public let title: String?
    public let readings: [String]

    public init(
        id: Int,
        title: String? = nil,
        readings: [String]
    ) throws {
        let readings = readings.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard id > 0, !readings.isEmpty, readings.allSatisfy({ !$0.isEmpty }) else {
            throw SwordError.invalidReadingPlanDay(id)
        }

        self.id = id
        self.title = title
        self.readings = readings
    }
}

/// Immutable completion state for one reading plan.
public struct SwordReadingPlanProgress: Hashable, Sendable {
    public let planID: String
    public let completedDayIDs: Set<Int>

    public init(planID: String, completedDayIDs: Set<Int> = []) {
        self.planID = planID
        self.completedDayIDs = completedDayIDs
    }

    public func completing(dayID: Int) -> SwordReadingPlanProgress {
        SwordReadingPlanProgress(
            planID: planID,
            completedDayIDs: completedDayIDs.union([dayID])
        )
    }

    public func completionFraction(for plan: SwordReadingPlan) -> Double {
        guard plan.id == planID else { return 0 }
        let planDayIDs = Set(plan.days.map(\.id))
        let completedCount = completedDayIDs.intersection(planDayIDs).count
        return Double(completedCount) / Double(plan.days.count)
    }
}
