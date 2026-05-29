//
//  SearchView.swift
//  Divine Codex iOS
//
//  Placeholder for the Search tab. Real implementation TBD.
//
//  Created by Dennis Miller on 5/29/26.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Spacer()
            Text("Search")
                .sacredHeading()
            Text("Seek and ye shall find.")
                .sacredSubtitle()
            Spacer()
        }
    }
}

#Preview {
    SearchView()
        .sacredBackground()
}
