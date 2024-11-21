//
//  ContentView.swift
//  Shared
//
//  Created by nate parrott on 9/11/22.
//

import SwiftUI
import Reeeed

struct ContentView: View {
    @State private var showReaderForURL: IdentifiableURL?

    // TODO: Handle external links
    var body: some View {
        NavigationView {
            List {
                ArticleButton(title: "Test Article (NYT)", url: "https://www.nytimes.com/2022/09/08/magazine/book-bans-texas.html")
                ArticleButton(title: "Test Article (NYT, Custom Theme)", url: "https://www.nytimes.com/2022/09/08/magazine/book-bans-texas.html", theme: .serif)
                ArticleButton(title: "Test Article (Verge)", url: "https://www.theverge.com/2023/9/3/23857664/california-forever-tech-billionaire-secret-city")
                ArticleButton(title: "Test Article (image at top)", url: "https://9to5mac.com/2023/09/08/apple-iphone-15-event-what-to-expect/")
                ArticleButton(title: "Unextractable Page", url: "https://google.com")
                ArticleButton(title: "Extract ISO Latin", url: "https://www.politicargentina.com/notas/202411/62138-are-you-pistarini-el-comico-posteo-de-la-afa-tras-el-episodio-entre-dillom-y-el-tuitero-libertario.html")
            }
            .frame(minWidth: 200)
        }
        .navigationTitle("Reader Mode Sample")
    }
}

struct ArticleButton: View {
    var title: String
    var url: String
    var theme: ReaderTheme = .init()

    @State private var presented = false

    var body: some View {
        if isMac() {
            NavigationLink(title) {
                reader
            }
        } else {
            Button(title, action: { presented = true })
                .sheet(isPresented: $presented) {
                    reader
                }
        }
    }

    @ViewBuilder private var reader: some View {
        ReeeederView(url: URL(string: url)!, options: .init(theme: theme, onLinkClicked: linkClicked))
    }

    private func linkClicked(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}

extension ReaderTheme {
    static let serif: ReaderTheme = .init(additionalCSS: """
    body {
        font-family: serif;
    }
""")
}

func isMac() -> Bool {
    #if os(macOS)
    return true
    #else
    return false
    #endif
}

private struct IdentifiableURL: Identifiable {
    var url: URL
    var id: String { url.absoluteString }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
