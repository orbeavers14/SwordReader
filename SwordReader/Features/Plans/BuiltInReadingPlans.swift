import Foundation
import SwordKit

enum BuiltInReadingPlans {
    static let all: [SwordReadingPlan] = [
        makePlan(
            id: "chronological-365",
            title: "Chronological Bible",
            subtitle: "One year · traditional historical sequence",
            chapters: chronologicalChapters,
            dayCount: 365
        ),
        makePlan(
            id: "canonical-365",
            title: "Bible in Canonical Order",
            subtitle: "One year · Genesis through Revelation",
            chapters: canonicalChapters,
            dayCount: 365
        ),
        makePlan(
            id: "new-testament-90",
            title: "New Testament",
            subtitle: "90 days · Matthew through Revelation",
            chapters: chapters(in: Array(canonicalBooks.dropFirst(39))),
            dayCount: 90
        )
    ]

    static let subtitles: [String: String] = [
        "chronological-365": "One year · traditional historical sequence",
        "canonical-365": "One year · Genesis through Revelation",
        "new-testament-90": "90 days · Matthew through Revelation"
    ]

    static let notes: [String: String] = [
        "chronological-365": "A SwordReader-authored arrangement using traditional book-era ordering. Biblical chronology is not universally agreed upon; Job, Psalms, Wisdom books, and the Prophets may be placed differently in other plans.",
        "canonical-365": "Follows the standard Protestant canonical book order.",
        "new-testament-90": "Follows New Testament canonical order."
    ]

    private static func makePlan(
        id: String,
        title: String,
        subtitle: String,
        chapters: [String],
        dayCount: Int
    ) -> SwordReadingPlan {
        precondition(chapters.count >= dayCount)
        let base = chapters.count / dayCount
        let remainder = chapters.count % dayCount
        var index = 0
        let days = (1...dayCount).map { day -> SwordReadingPlanDay in
            let count = base + (day <= remainder ? 1 : 0)
            defer { index += count }
            return try! SwordReadingPlanDay(
                id: day,
                title: "Day \(day)",
                readings: Array(chapters[index..<(index + count)])
            )
        }
        return try! SwordReadingPlan(id: id, title: title, days: days)
    }

    private static func chapters(
        in books: [(name: String, count: Int)]
    ) -> [String] {
        books.flatMap { book in (1...book.count).map { "\(book.name) \($0)" } }
    }

    private static let canonicalChapters = chapters(in: canonicalBooks)

    private static let chronologicalChapters: [String] = {
        let beforeAbraham = chapters(in: [("Genesis", 11)])
        let patriarchs = chapters(in: [("Job", 42), ("Genesis", 39)]).map {
            $0.hasPrefix("Genesis ")
                ? "Genesis \((Int($0.split(separator: " ").last!) ?? 0) + 11)"
                : $0
        }
        return beforeAbraham + patriarchs + chapters(in: chronologicalBooks)
    }()

    private static let chronologicalBooks: [(name: String, count: Int)] = [
        ("Exodus", 40), ("Leviticus", 27), ("Numbers", 36), ("Deuteronomy", 34),
        ("Joshua", 24), ("Judges", 21), ("Ruth", 4), ("1 Samuel", 31),
        ("2 Samuel", 24), ("1 Chronicles", 29), ("Psalms", 150),
        ("1 Kings", 22), ("2 Chronicles", 36), ("Proverbs", 31),
        ("Ecclesiastes", 12), ("Song of Solomon", 8), ("2 Kings", 25),
        ("Jonah", 4), ("Amos", 9), ("Hosea", 14), ("Isaiah", 66),
        ("Micah", 7), ("Nahum", 3), ("Zephaniah", 3), ("Jeremiah", 52),
        ("Habakkuk", 3), ("Lamentations", 5), ("Ezekiel", 48), ("Obadiah", 1),
        ("Daniel", 12), ("Ezra", 10), ("Haggai", 2), ("Zechariah", 14),
        ("Esther", 10), ("Nehemiah", 13), ("Joel", 3), ("Malachi", 4),
        ("Mark", 16), ("Matthew", 28), ("Luke", 24), ("John", 21),
        ("Acts", 28), ("James", 5), ("Galatians", 6), ("1 Thessalonians", 5),
        ("2 Thessalonians", 3), ("1 Corinthians", 16), ("2 Corinthians", 13),
        ("Romans", 16), ("Colossians", 4), ("Philemon", 1), ("Ephesians", 6),
        ("Philippians", 4), ("1 Timothy", 6), ("Titus", 3), ("1 Peter", 5),
        ("Hebrews", 13), ("2 Timothy", 4), ("2 Peter", 3), ("Jude", 1),
        ("1 John", 5), ("2 John", 1), ("3 John", 1), ("Revelation", 22)
    ]

    private static let canonicalBooks: [(name: String, count: Int)] = [
        ("Genesis",50),("Exodus",40),("Leviticus",27),("Numbers",36),("Deuteronomy",34),
        ("Joshua",24),("Judges",21),("Ruth",4),("1 Samuel",31),("2 Samuel",24),
        ("1 Kings",22),("2 Kings",25),("1 Chronicles",29),("2 Chronicles",36),
        ("Ezra",10),("Nehemiah",13),("Esther",10),("Job",42),("Psalms",150),
        ("Proverbs",31),("Ecclesiastes",12),("Song of Solomon",8),("Isaiah",66),
        ("Jeremiah",52),("Lamentations",5),("Ezekiel",48),("Daniel",12),("Hosea",14),
        ("Joel",3),("Amos",9),("Obadiah",1),("Jonah",4),("Micah",7),("Nahum",3),
        ("Habakkuk",3),("Zephaniah",3),("Haggai",2),("Zechariah",14),("Malachi",4),
        ("Matthew",28),("Mark",16),("Luke",24),("John",21),("Acts",28),("Romans",16),
        ("1 Corinthians",16),("2 Corinthians",13),("Galatians",6),("Ephesians",6),
        ("Philippians",4),("Colossians",4),("1 Thessalonians",5),("2 Thessalonians",3),
        ("1 Timothy",6),("2 Timothy",4),("Titus",3),("Philemon",1),("Hebrews",13),
        ("James",5),("1 Peter",5),("2 Peter",3),("1 John",5),("2 John",1),
        ("3 John",1),("Jude",1),("Revelation",22)
    ]
}
