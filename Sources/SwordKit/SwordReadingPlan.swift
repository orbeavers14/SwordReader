import Foundation

/// An ordered, immutable Scripture reading plan.
public struct SwordReadingPlan: Hashable, Sendable, Identifiable {
    /// The stable, nonempty plan identifier.
    public let id: String
    /// The user-visible plan title.
    public let title: String
    /// The plan's uniquely identified days in reading order.
    public let days: [SwordReadingPlanDay]

    /// Creates a validated, nonempty reading plan.
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
    /// The positive day number.
    public let id: Int
    /// An optional user-visible day title.
    public let title: String?
    /// The nonempty Scripture expressions assigned to the day.
    public let readings: [String]

    /// Creates a validated reading-plan day.
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
    /// The reading plan associated with this progress.
    public let planID: String
    /// The identifiers of completed days.
    public let completedDayIDs: Set<Int>

    /// Creates completion state for a reading plan.
    public init(planID: String, completedDayIDs: Set<Int> = []) {
        self.planID = planID
        self.completedDayIDs = completedDayIDs
    }

    /// Returns a copy with the specified day marked complete.
    public func completing(dayID: Int) -> SwordReadingPlanProgress {
        SwordReadingPlanProgress(
            planID: planID,
            completedDayIDs: completedDayIDs.union([dayID])
        )
    }

    /// Returns completed days as a value from zero through one for the plan.
    public func completionFraction(for plan: SwordReadingPlan) -> Double {
        guard plan.id == planID else { return 0 }
        let planDayIDs = Set(plan.days.map(\.id))
        let completedCount = completedDayIDs.intersection(planDayIDs).count
        return Double(completedCount) / Double(plan.days.count)
    }
}
