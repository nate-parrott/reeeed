import Foundation
import SwiftSoup
import Fuzi


extension ReadableDoc {
    public func html(includeExitReaderButton: Bool, theme: ReaderTheme = .init()) -> String {
        let escapedTitle = Entities.escape(title?.byStrippingSiteNameFromPageTitle ?? "")

        var heroHTML: String = ""
        if insertHeroImage, let hero = metadata.heroImage {
            let safeURL = Entities.escape(hero.absoluteString)
            heroHTML = "<img class='__hero' src=\"\(safeURL)\" />"
        }

        let subtitle: String = {
            var partsHTML = [String]()

            let separatorHTML = "<span class='__separator'> · </span>"
            func appendSeparatorIfNecessary() {
                if partsHTML.count > 0 {
                    partsHTML.append(separatorHTML)
                }
            }
            if let author = extracted.author {
                partsHTML.append(Entities.escape(author))
            }
            if let date {
                appendSeparatorIfNecessary()
                partsHTML.append(DateFormatter.shortDateOnly.string(from: date))
            }
            
            appendSeparatorIfNecessary()
            partsHTML.append(metadata.url.hostWithoutWWW)

//            if partsHTML.count == 0 { return "" }
            return "<p class='__subtitle'>\(partsHTML.joined())</p>"
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
<style id='__themeStyle'>
\(theme.css)
</style>
<body>
<div id='__content' style='opacity: 0'>
    \(heroHTML)
    
    <h1 id='__title'>\(escapedTitle)</h1>
        \(subtitle)
        \(extracted.content ?? "")
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

extension ReaderTheme {
    public var css: String {
        let (fgLight, fgDark) = foreground.hexPair
        let (fg2Light, fg2Dark) = foreground2.hexPair
        let (bgLight, bgDark) = background.hexPair
        let (bg2Light, bg2Dark) = background2.hexPair
        let (linkLight, linkDark) = link.hexPair

        return """
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
            overflow-x: hidden;
        }

        @media screen and (min-width: 650px) {
            #__content { font-size: 1.35em; line-height: 1.5; }
        }

        h1, h2, h3, h4, h5, h6 {
            line-height: 1.2;
            font-family: -apple-system;
            font-size: 1.5em;
            font-weight: 800;
        }

        #__title {
            font-size: 1.8em;
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

        @media screen and (max-width: 500px) {
            dd {
                margin-inline-start: 20px; /* normally 40px */
            }
            blockquote {
                margin-inline-start: 20px; /* normally 40px */
                margin-inline-end: 20px; /* normally 40px */
            }
        }

        .__subtitle {
            font-weight: bold;
            vertical-align: baseline;
            opacity: 0.5;
            font-size: 0.9em;
        }

        .__subtitle .__icon {
            width: 1.2em;
            height: 1.2em;
            object-fit: cover;
            overflow: hidden;
            border-radius: 3px;
            margin-right: 0.3em;
            position: relative;
            top: 0.3em;
        }

        .__subtitle .__separator {
            opacity: 0.5;
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

        \(additionalCSS ?? "")
        """
    }
}

public extension URL {
    /// If HTML is generated with `includeExitReaderButton=true`, clicking the button will navigate to this URL, which you should intercept and use to display the original website.
    static let exitReaderModeLink = URL(string: "feeeed://exit-reader-mode")!
}

extension URL {
    var googleFaviconURL: URL? {
        if let host {
            return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64")
        }
        return nil
    }
}

func estimateLinesUntilFirstImage(html: String) throws -> Int? {
    let doc = try HTMLDocument(data: html.data(using: .utf8)!)
    var lines = 0
    var linesBeforeFirst: Int?
    try doc.root?.traverse { el in
        if el.tag?.lowercased() == "img", linesBeforeFirst == nil {
            linesBeforeFirst = lines
        }
        lines += el.estLineCount
    }
    return linesBeforeFirst
}

extension Fuzi.XMLElement {
    func traverse(_ block: (Fuzi.XMLElement) -> Void) throws {
        for child in children {
            block(child)
            try child.traverse(block)
        }
    }
    var estLineCount: Int {
        if let tag = self.tag?.lowercased() {
            switch tag {
            case "video", "embed": return 5
            case "h1", "h2", "h3", "h4", "h5", "h6", "p", "li":
                return Int(ceil(Double(stringValue.count) / 60)) + 1
            case "tr": return 1
            default: return 0
            }
        }
        return 0
    }
}

extension DateFormatter {
    static let shortDateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

//extension SwiftSoup.Node {
//    func traverseElements(_ block: @escaping (Element) -> Void) throws {
//        let visitor = BlockNodeVisitor(headCallback: { (node, _depth) in
//            if let el = node as? Element {
//                block(el)
//            }
//        }, tailCallback: nil)
//        try traverse(visitor)
//    }
//}
//
//private struct BlockNodeVisitor: NodeVisitor {
//    var headCallback: ((Node, Int) -> Void)?
//    var tailCallback: ((Node, Int) -> Void)?
//
//    func head(_ node: Node, _ depth: Int) throws {
//        headCallback?(node, depth)
//    }
//
//    func tail(_ node: Node, _ depth: Int) throws {
//        tailCallback?(node, depth)
//    }
//}
