//
//  TypewriterText.swift
//  bigbruhh
//
//  Typewriter text animation effect
//

import SwiftUI

struct TypewriterText: View {
    let text: String
    let speed: Double  // seconds per character

    @State private var displayedText = ""

    var body: some View {
        Text(displayedText)
            .onAppear {
                animateText()
            }
    }

    private func animateText() {
        displayedText = ""
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * speed) {
                displayedText.append(character)
            }
        }
    }
}
