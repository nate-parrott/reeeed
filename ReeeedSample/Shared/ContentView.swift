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

    var body: some View {
        Form {
            Section {
                Button("Test Article") {
                    showReaderForURL = IdentifiableURL(url: URL(string: "https://www.nytimes.com/2022/09/08/magazine/book-bans-texas.html")!)
                }
            } footer: {
                Text("This presents an example article in Reader Mode")
            }

            Section {
                Button("Unextractable Article") {
                    showReaderForURL = IdentifiableURL(url: URL(string: "https://google.com")!)
                }
            } footer: {
                Text("This presents an example page that we are not able to extract content for. It will show a webview as a fallback")
            }
        }
        .navigationTitle("Reader Mode Sample")
        .sheet(item: $showReaderForURL) { idURL in
            ReeeederView(url: idURL.url)
        }
    }
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
