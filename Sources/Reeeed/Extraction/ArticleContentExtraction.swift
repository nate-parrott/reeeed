import Foundation
import WebKit

public enum ExtractionError: Error {
    case DataIsNotString
    case FailedToExtract
    case MissingExtractionData
}

public struct ExtractedContent: Equatable {
    // See https://github.com/postlight/mercury-parser#usage
    public var content: String?
    public var author: String?
    public var title: String?
    public var excerpt: String?
}

public enum Extractor: Equatable {
    case mercury
    case readability
}
