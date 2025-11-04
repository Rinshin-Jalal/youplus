//
//  HeaderLogoBar.swift
//  bigbruhh
//
//  Reusable header component with logo - used across all main pages
//

import SwiftUI

struct HeaderLogoBar: View {
    let subtitle: String?

    init(subtitle: String? = nil) {
        self.subtitle = subtitle
    }

    var body: some View {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 200)
    }
}

#Preview {
    ZStack {
        Color.brutalBlack.ignoresSafeArea()
        HeaderLogoBar(subtitle: "Monday, January 1, 2025")
    }
}
