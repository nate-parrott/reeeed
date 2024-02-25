import Foundation

public struct ReadableDoc: Equatable, Codable {
    public var extracted: ExtractedContent
    public var insertHeroImage: Bool
    public var metadata: SiteMetadata
    public var date: Date?

    public init(extracted: ExtractedContent, insertHeroImage: Bool? /* autodetect if nil */, metadata: SiteMetadata, date: Date? = nil) {
        self.extracted = extracted
        if let insertHeroImage {
            self.insertHeroImage = insertHeroImage
        } else if let html = extracted.content {
            self.insertHeroImage = (try? estimateLinesUntilFirstImage(html: html) ?? 999 >= 10) ?? false
        } else {
            self.insertHeroImage = false
        }
        self.metadata = metadata
        self.date = date ?? extracted.datePublished
    }

    public var title: String? {
        extracted.title ?? metadata.title
    }

    public var url: URL {
        metadata.url
    }
}
