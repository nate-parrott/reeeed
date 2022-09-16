import Foundation
import SwiftSoup

extension Reeeed {
    public static func wrapHTMLInReaderStyling(html: String, title: String, baseURL: URL?, author: String?, heroImage: URL?, includeExitReaderButton: Bool = true, theme: ReaderTheme = .init()) -> String {
        let escapedTitle = Entities.escape(title.byStrippingSiteNameFromPageTitle)
        let logger = Reeeed.logger

        let (fgLight, fgDark) = theme.foreground.hexPair
        let (fg2Light, fg2Dark) = theme.foreground2.hexPair
        let (bgLight, bgDark) = theme.background.hexPair
        let (bg2Light, bg2Dark) = theme.background2.hexPair
        let (linkLight, linkDark) = theme.link.hexPair

        let heroHTML: String = {
            if let heroImage = heroImage {
                do {
                    let firstImageIndex = try numberOfElementsUntilFirstImage(
                        tags: Set(["p", "h1", "h2", "ul", "ol", "table"]),
                        html: html)
                    logger.info("First image index: \(firstImageIndex ?? 999)")
                    // If there is no image in the first 10 elements, insert the hero image:
                    if (firstImageIndex ?? 999) > 10 {
                        let safeURL = Entities.escape(heroImage.absoluteString)
                        return "<img class='__hero' src=\"\(safeURL)\" />"
                    }
                }
                catch {
                    logger.error("\(error)")
                }
            }
            return ""
        }()

        let subtitle: String = {
            var parts = [String]()
            if let author = author {
                parts.append(author)
            }
            if let url = baseURL {
                parts.append(url.hostWithoutWWW)
            }
            if parts.count == 0 {
                return ""
            }
            let text = parts.joined(separator: " • ")
            let textEscaped = Entities.escape(text)
            return "<p class='__subtitle'>\(textEscaped)</p>"
        }()

        let exitReaderButton: String
        if includeExitReaderButton {
            exitReaderButton = "<button onClick=\"document.location = '\(URL.exitReaderModeLink.absoluteString)'\">View Normal Page</button>"
        } else {
            exitReaderButton = ""
        }

        let wrapped = """
<!DOCTYPE html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>\(escapedTitle)</title>
<style>

html, body {
    margin: 0;
}

body {
    color: \(fgLight);
    background-color: \(bgLight);
    overflow-wrap: break-word;
    font: -apple-system-body;
}

.__hero {
    display: block;
    width: 100%;
    height: 50vw;
    max-height: 300px;
    object-fit: cover;
    overflow: hidden;
    border-radius: 7px;
}

#__content {
    line-height: 1.5;
    font-size: 1.1em;
}

@media screen and (min-width: 650px) {
    #__content { font-size: 1.35em; line-height: 1.5; }
}

h1 {
    font-size: 1.5em;
}

img, iframe, object, video {
    max-width: 100%;
    height: auto;
    border-radius: 7px;
}

pre {
    max-width: 100%;
    overflow-x: auto;
}

table {
    display: block;
    max-width: 100%;
    overflow-x: auto;
}

a:link {
    color: \(linkLight);
}

figure {
    margin-left: 0;
    margin-right: 0;
}

figcaption, cite {
    opacity: 0.5;
    font-size: small;
}

.__subtitle {
    opacity: 0.5;
    font-size: small;
    text-transform: uppercase;
    font-weight: bold;
}

#__content {
    padding: 1.5em;
    margin: auto;
    margin-top: 5px;
    max-width: 700px;
}

@media (prefers-color-scheme: dark) {
    body {
        color: \(fgDark);
        background-color: \(bgDark);
    }
    a:link { color: \(linkDark); }
}

#__footer {
    margin-bottom: 4em;
    margin-top: 2em;
}

#__footer > .label {
    font-size: small;
    opacity: 0.5;
    text-align: center;
    margin-bottom: 0.66em;
    font-weight: 500;
}

#__footer > button {
    padding: 0.5em;
    text-align: center;
    background-color: \(bg2Light);
    font-weight: 500;
    color: \(fg2Light);
    min-height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    font-size: 1em;
    border: none;
    border-radius: 0.5em;
}

@media (prefers-color-scheme: dark) {
    #__footer > button {
        background-color: \(bg2Dark);
        color: \(fg2Dark);
    }
}

\(theme.additionalCSS ?? "")

</style>
<body>
<div id='__content' style='opacity: 0'>
    \(heroHTML)
    <h1>\(escapedTitle)</h1>
        \(subtitle)
        \(html)
    <div id="__footer">
        <div class="label">Automatically converted to Reader Mode</div>
        \(exitReaderButton)
    </div>
</div>

<script>
    setTimeout(() => {
        document.getElementById('__content').style.opacity = 1;
    }, 100);
</script>

</body>
"""
        return wrapped
    }
}

public extension URL {
    /// If HTML is generated with `includeExitReaderButton=true`, clicking the button will navigate to this URL, which you should intercept and use to display the original website.
    static let exitReaderModeLink = URL(string: "feeeed://exit-reader-mode")!
}

private func numberOfElementsUntilFirstImage(tags: Set<String>, html: String) throws -> Int? {
    var elCount = 0
    var firstImageIndex: Int? = nil

    let soup = try SwiftSoup.parse(html)
    try soup.traverseElements { element in
        let tagName = element.tagName()
        if tagName == "img", firstImageIndex == nil {
            firstImageIndex = elCount
        } else if tags.contains(tagName) {
            elCount += 1
        }
    }

    return firstImageIndex
}

extension SwiftSoup.Node {
    func traverseElements(_ block: @escaping (Element) -> Void) throws {
        let visitor = BlockNodeVisitor(headCallback: { (node, _depth) in
            if let el = node as? Element {
                block(el)
            }
        }, tailCallback: nil)
        try traverse(visitor)
    }
}

private struct BlockNodeVisitor: NodeVisitor {
    var headCallback: ((Node, Int) -> Void)?
    var tailCallback: ((Node, Int) -> Void)?

    func head(_ node: Node, _ depth: Int) throws {
        headCallback?(node, depth)
    }

    func tail(_ node: Node, _ depth: Int) throws {
        tailCallback?(node, depth)
    }
}
