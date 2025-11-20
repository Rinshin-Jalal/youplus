//
//  ExplanatoryStepView.swift
//  bigbruhh
//
//  Full-screen explanatory cards for onboarding hook
//

import SwiftUI

struct ExplanatoryStepView: View {
    let config: ExplanatoryConfig
    let onContinue: () -> Void

    @State private var hasAppeared = false
    @State private var canContinue = false

    var body: some View {
        ZStack {
            config.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Icon
                Image(systemName: config.iconName)
                    .font(.system(size: 80))
                    .foregroundColor(config.accentColor)
                    .scaleEffect(hasAppeared ? 1.0 : 0.8)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: hasAppeared)

                // Title
                Text(config.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .offset(y: hasAppeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: hasAppeared)

                // Subtitle
                if let subtitle = config.subtitle {
                    Text(subtitle)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(hasAppeared ? 1.0 : 0.0)
                        .offset(y: hasAppeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: hasAppeared)
                }

                Spacer()

                // Continue indicator (only show after delay)
                if canContinue {
                    VStack(spacing: 12) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.5))
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: canContinue)

                        Text("Swipe up to continue")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .transition(.opacity)
                    .padding(.bottom, 40)
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .onTapGesture {
            if canContinue {
                onContinue()
            }
        }
        .onAppear {
            withAnimation {
                hasAppeared = true
            }

            // Enable continue after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    canContinue = true
                }
            }
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                guard canContinue else { return }

                if value.translation.height < -50 {  // Swipe up
                    onContinue()
                } else if value.translation.width > 50 {  // Swipe right (also continue)
                    onContinue()
                }
            }
    }
}

// MARK: - Preview

struct ExplanatoryStepView_Previews: PreviewProvider {
    static var previews: some View {
        ExplanatoryStepView(
            config: ExplanatoryConfig(
                iconName: "calendar.badge.exclamationmark",
                title: "You've Been Here Before",
                subtitle: "Started strong. Lasted a week. Then... nothing.",
                backgroundColor: .black,
                accentColor: Color(hex: "#FF6B6B")
            ),
            onContinue: {
                print("Continue tapped")
            }
        )
    }
}
