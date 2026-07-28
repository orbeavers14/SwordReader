public struct SwordModule: Hashable, Sendable {
    public let name: String
    public let title: String
    public let language: String
    public let category: Category

    public init(
        name: String,
        title: String,
        language: String,
        category: Category
    ) {
        self.name = name
        self.title = title
        self.language = language
        self.category = category
    }
}

public extension SwordModule {
    enum Category: Hashable, Sendable {
        case bible
        case commentary
        case dictionary
        case generalBook
        case other(String)

        init(swordType: String) {
            switch swordType {
            case "Biblical Texts":
                self = .bible

            case "Commentaries":
                self = .commentary

            case "Lexicons / Dictionaries":
                self = .dictionary

            case "Generic Books":
                self = .generalBook

            default:
                self = .other(swordType)
            }
        }
    }
}
