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
                NavigationLink("Test Article") {
                    ReeeederView(url: URL(string: "https://www.nytimes.com/2022/09/08/magazine/book-bans-texas.html")!)
                }
                NavigationLink("Unextractable Page") {
                    ReeeederView(url: URL(string: "https://google.com")!)
                }
            }
            .frame(minWidth: 200)
        }
        .navigationTitle("Reader Mode Sample")
    }
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
