//
//  PaywallIntroView.swift
//  bigbruhh
//
//  Story-aligned intro before RevenueCat paywall
//  Frames payment as commitment, not transaction
//

import SwiftUI

struct PaywallIntroView: View {
    @Environment(\.dismiss) private var dismiss
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("42 complete")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .lineLimit(1)
                    .foregroundColor(.white)

                Text("You did what most people won't")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(Color(hex: "#A0A0A0"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 48)
            .padding(.horizontal, 24)

            // Content
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    BulletPoint(text: "You answered questions you've never been asked", icon: "✓")
                    BulletPoint(text: "You recorded your voice three times", icon: "✓")
                    BulletPoint(text: "You saw the system", icon: "✓")
                    BulletPoint(text: "You made your choice", icon: "✓")
                }

                Divider()
                    .background(Color(hex: "#2A2A2A"))

                VStack(alignment: .leading, spacing: 16) {
                    Text("But here's the truth:")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.white)

                    Text("This was the easy part. Answering questions in private? Comfortable. Getting called daily? Using your voice? With consequences? That's when the system kicks in.")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "#D0D0D0"))
                        .lineSpacing(2)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Free apps let you quit silently. No one notices. This doesn't.")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "#FFB800"))
                        .lineSpacing(2)

                    Text("This costs something. So does quitting. When money's on the table, excuses get expensive.")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "#D0D0D0"))
                        .lineSpacing(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 36)
            .padding(.bottom, 20)

            Spacer()

            // CTA Button
            VStack(spacing: 12) {
                Button(action: onContinue) {
                    Text("This is the last filter. Are you in?")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#FF6B6B"),
                                    Color(hex: "#FF5252")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: { dismiss() }) {
                    Text("I need to think about this")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "#808080"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(hex: "#1A1A1A"))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

// MARK: - Helper Views

struct BulletPoint: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#4ECDC4"))

            Text(text)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(Color(hex: "#D0D0D0"))
                .lineSpacing(1)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    PaywallIntroView(onContinue: {})
}
