//
//  TwoFuturesDebateView.swift
//  bigbruhh
//
//  Split-screen debate view for Two Futures onboarding
//

import SwiftUI

struct TwoFuturesDebateView: View {
    let messages: [DebateMessage]
    let onContinue: () -> Void

    @State private var visibleMessages: [DebateMessage] = []
    @State private var allMessagesDisplayed = false
    @State private var canContinue = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar like iMessage
                topBar

                // Chat-style message list
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(minHeight: 100)
                        
                        VStack(spacing: 16) {
                            ForEach(visibleMessages) { message in
                                chatMessageView(message)
                            }
                        }
                        
                        Spacer()
                            .frame(minHeight: 100)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
                    .frame(height: 80)
            }

            // Tap anywhere to continue indicator (only after delay)
            if canContinue {
                VStack {
                    Spacer()
                    Text("Tap anywhere to continue")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.bottom, 40)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: canContinue)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if canContinue {
                onContinue()
            }
        }
        .gesture(swipeGesture)
        .onAppear {
            animateMessages()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 4) {
            Text("Two Futures")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.95))
    }

    @ViewBuilder
    private func chatMessageView(_ message: DebateMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if message.speaker == .hopeful || message.speaker == .both {
                Spacer()
            }

            // Left icon for doubtful
            if message.speaker == .doubtful {
                Image(systemName: speakerIcon(for: message.speaker))
                    .font(.system(size: 16))
                    .foregroundColor(speakerColor(for: message.speaker))
                    .frame(width: 24, height: 24)
            }

            // Message bubble
            VStack(alignment: message.speaker == .hopeful ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(messageBubbleColor(for: message.speaker))
                    .cornerRadius(20)
                    .frame(maxWidth: 300, alignment: messageAlignment(for: message.speaker))
            }

            // Right icon for hopeful
            if message.speaker == .hopeful {
                Image(systemName: speakerIcon(for: message.speaker))
                    .font(.system(size: 16))
                    .foregroundColor(speakerColor(for: message.speaker))
                    .frame(width: 24, height: 24)
            }

            if message.speaker == .doubtful || message.speaker == .both {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func messageBubbleColor(for speaker: FutureVoice) -> Color {
        switch speaker {
        case .hopeful:
            return Color(hex: "#1a4d2e").opacity(0.4)  // Hopeful green tint
        case .doubtful:
            return Color(hex: "#4d1a1a").opacity(0.4)  // Doubtful red tint
        case .both:
            return Color.white.opacity(0.15)
        }
    }

    private func speakerIcon(for speaker: FutureVoice) -> String {
        switch speaker {
        case .hopeful:
            return "arrow.up.circle.fill"
        case .doubtful:
            return "arrow.down.circle.fill"
        case .both:
            return "circle.fill"
        }
    }

    private func speakerColor(for speaker: FutureVoice) -> Color {
        switch speaker {
        case .hopeful:
            return Color(hex: "#4ECDC4")  // Hopeful cyan
        case .doubtful:
            return Color(hex: "#FF6B6B")  // Doubtful red
        case .both:
            return Color.white.opacity(0.7)
        }
    }

    private func messageAlignment(for speaker: FutureVoice) -> Alignment {
        switch speaker {
        case .hopeful:
            return .trailing
        case .doubtful:
            return .leading
        case .both:
            return .center
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                guard canContinue else { return }

                if value.translation.width > 50 {
                    onContinue()
                }
            }
    }

    private func animateMessages() {
        for (index, message) in messages.enumerated() {
            let delay = Double(index) * 1.5 // 1.5 seconds between each message
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: 0.3)) {
                    visibleMessages.append(message)
                }

                // Mark as complete after last message
                if index == messages.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            allMessagesDisplayed = true
                        }
                        // Enable continue after additional 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                canContinue = true
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TwoFuturesDebateView(
        messages: [
            DebateMessage(speaker: .hopeful, text: "They're here.", delay: 0.5),
            DebateMessage(speaker: .doubtful, text: "I know. I can feel it.", delay: 1.0),
            DebateMessage(speaker: .hopeful, text: "This is our chance. OUR chance to change it.", delay: 1.5),
            DebateMessage(speaker: .doubtful, text: "Or our chance to save them from what happened to me.", delay: 2.0),
            DebateMessage(speaker: .hopeful, text: "Different is possible. I'm proof.", delay: 2.5),
            DebateMessage(speaker: .doubtful, text: "So am I. Just... the other kind of proof.", delay: 3.0),
            DebateMessage(speaker: .both, text: "Maybe is enough to start.", delay: 4.5)
        ],
        onContinue: {
            print("Continue tapped")
        }
    )
}
