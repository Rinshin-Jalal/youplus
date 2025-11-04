//
//  AICommentaryView.swift
//  bigbruhh
//
//  AI commentary from "future you" accountability persona
//

import SwiftUI

struct AICommentaryView: View {
    let config: AICommentaryConfig
    let onContinue: () -> Void

    @State private var hasAppeared = false
    @State private var messageVisible = false
    @State private var canContinue = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Avatar (if shown)
                if config.showAvatar {
                    Image(systemName: config.persona.avatarIcon)
                        .font(.system(size: 60))
                        .foregroundColor(config.emphasize ? Color(hex: "#4ECDC4") : .white.opacity(0.7))
                        .scaleEffect(hasAppeared ? 1.0 : 0.8)
                        .opacity(hasAppeared ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: hasAppeared)
                }

                // Message
                VStack(spacing: 16) {
                    Text(config.message)
                        .font(.system(size: config.emphasize ? 24 : 20, weight: config.emphasize ? .bold : .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(messageVisible ? 1.0 : 0.0)
                        .offset(y: messageVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(config.showAvatar ? 0.3 : 0.0), value: messageVisible)

                    // Subtle persona indicator
                    if config.showAvatar {
                        Text(config.persona.tone)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .opacity(messageVisible ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.6).delay(0.6), value: messageVisible)
                    }
                }

                Spacer()

                // Continue button (only show after delay)
                if canContinue {
                    Group {
                        if #available(iOS 26, *) {
                            Button(action: onContinue) {
                                Text("Continue")
                                    .font(.bodyBold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .buttonStyle(.glassProminent)
                        } else {
                            Button(action: onContinue) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(30)
                            }
                        }
                    }
                    .transition(.opacity)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation {
                hasAppeared = true
            }
            // Delay message appearance slightly for sequential animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    messageVisible = true
                }
            }
            // Enable continue after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    canContinue = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Future You") {
    AICommentaryView(
        config: AICommentaryConfig(
            message: "I'm you from the future. Here to make sure you don't quit. Again.",
            persona: .futureYou,
            showAvatar: true,
            emphasize: true
        ),
        onContinue: {
            print("Continue tapped")
        }
    )
}

#Preview("Accountability") {
    AICommentaryView(
        config: AICommentaryConfig(
            message: "Okay. Now let's look at your pattern.",
            persona: .accountability,
            showAvatar: true,
            emphasize: false
        ),
        onContinue: {
            print("Continue tapped")
        }
    )
}

#Preview("No Avatar") {
    AICommentaryView(
        config: AICommentaryConfig(
            message: "Here's what happens next.",
            persona: .neutral,
            showAvatar: false,
            emphasize: false
        ),
        onContinue: {
            print("Continue tapped")
        }
    )
}
