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
        Text("You+")
            .font(.system(size: 32, weight: .black))
            .foregroundColor(.white)
            .tracking(2)
    }
}

#Preview {
    ZStack {
        Color.brutalBlack.ignoresSafeArea()
        HeaderLogoBar(subtitle: "Monday, January 1, 2025")
    }
}
