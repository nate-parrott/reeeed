import Foundation
import WebKit
import Fuzi

public enum ExtractionError: Error {
    case DataIsNotString
    case FailedToExtract
    case MissingExtractionData
}

public struct ExtractedContent: Equatable, Codable {
    // See https://github.com/postlight/mercury-parser#usage
    public var content: String?
    public var author: String?
    public var title: String?
    public var excerpt: String?
    public var date_published: String?

    public init(content: String? = nil, author: String? = nil, title: String? = nil, excerpt: String? = nil, date_published: String? = nil) {
        self.content = content
        self.author = author
        self.title = title
        self.excerpt = excerpt
        self.date_published = date_published
    }
}

extension ExtractedContent {
    public var datePublished: Date? {
        date_published.flatMap { Self.dateParser.date(from: $0) }
    }
    static let dateParser = ISO8601DateFormatter()

    public var extractPlainText: String {
        if let content {
            let parsed = try? HTMLDocument(data: content.data(using: .utf8)!)
            var paragraphs = [""]
            let blockLevelTags = Set<String>(["p", "section", "li", "div", "h1", "h2", "h3", "h4", "h5", "h6", "pre"])
            var withinPre = 0
            parsed?.body?.traverseChildren(onEnterElement: { el in
                if let tag = el.tag?.lowercased() {
                    if tag == "pre" {
                        withinPre += 1
                    }
                    if blockLevelTags.contains(tag) {
                        paragraphs.append("")
                    }
                }
            },
            onExitElement: { el in
                if el.tag?.lowercased() == "pre" {
                    withinPre -= 1
                }
            },
            onText: { str in
                if withinPre > 0 {
                    paragraphs[paragraphs.count - 1] += str
                } else {
                    paragraphs[paragraphs.count - 1] += str.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            })
            return paragraphs.filter({ $0 != "" }).joined(separator: "\n")
//            return parsed?.root?.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        return ""
    }
}

extension Fuzi.XMLElement {
    func traverseChildren(onEnterElement: (Fuzi.XMLElement) -> Void, onExitElement: (Fuzi.XMLElement) -> Void, onText: (String) -> Void) {
        for node in childNodes(ofTypes: [.Element, .Text]) {
            switch node.type {
            case .Text:
                onText(node.stringValue)
            case .Element:
                if let el = node as? Fuzi.XMLElement {
                    onEnterElement(el)
                    el.traverseChildren(onEnterElement: onEnterElement, onExitElement: onExitElement, onText: onText)
                    onExitElement(el)
                }
            default: ()
            }
        }
    }
}

public enum Extractor: Equatable {
    case mercury
    case readability
}
