//
//  AICommentaryView.swift
//  bigbruhh
//
//  AI commentary from "future you" accountability persona
//  Supports both single message and chat-style multiple messages
//

import SwiftUI

struct AICommentaryView: View {
    let config: AICommentaryConfig
    let onContinue: () -> Void

    @State private var hasAppeared = false
    @State private var messageVisible = false
    @State private var canContinue = false
    @State private var visibleMessages: [ChatMessage] = []
    @State private var showingTypingIndicator = false
    @State private var allMessagesDisplayed = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // Scanline overlay - subtle monitor effect
            Scanlines()

            // Vignette overlay - focus attention
            Vignette(intensity: 0.5)

            if let messages = config.messages, !messages.isEmpty {
                // Chat-style interface for multiple messages
                chatInterfaceView
            } else {
                // Single message interface (backward compatibility)
                singleMessageView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if let messages = config.messages, !messages.isEmpty {
                animateChatMessages(messages)
            } else {
                animateSingleMessage()
            }
        }
    }
    
    // MARK: - Chat Interface
    
    private var chatInterfaceView: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Chat messages
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(minHeight: 100)
                        
                        VStack(spacing: 16) {
                            ForEach(visibleMessages) { message in
                                chatMessageBubble(message, maxWidth: geometry.size.width * 0.75)
                            }
                            
                            // Typing indicator
                            if showingTypingIndicator {
                                typingIndicator(maxWidth: geometry.size.width * 0.75)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                            .frame(minHeight: 100)
                    }
                }
                
                Spacer()
                    .frame(height: 80)
            }
            .overlay(
                // Continue indicator (only after all messages displayed)
                VStack {
                    Spacer()
                    if canContinue {
                        Text("Tap anywhere to continue")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.bottom, 40)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: canContinue)
                    }
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if canContinue {
                    onContinue()
                }
            }
            .gesture(swipeGesture)
        }
    }
    
    private func chatMessageBubble(_ message: ChatMessage, maxWidth: CGFloat) -> some View {
        // Left-aligned message bubble (from "future you")
        Text(message.text)
            .font(.system(size: message.emphasize ? 20 : 18, weight: message.emphasize ? .bold : .regular))
            .foregroundColor(.white)
            .chromaticAberration(isActive: true, intensity: 0.7) // RGB effect for emphasis
            .padding(16)
            .background(Color.white.opacity(0.15))
            .cornerRadius(20)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func typingIndicator(maxWidth: CGFloat) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 8, height: 8)
                .animation(.easeInOut(duration: 0.6).repeatForever().delay(0.0), value: showingTypingIndicator)
            
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 8, height: 8)
                .animation(.easeInOut(duration: 0.6).repeatForever().delay(0.2), value: showingTypingIndicator)
            
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 8, height: 8)
                .animation(.easeInOut(duration: 0.6).repeatForever().delay(0.4), value: showingTypingIndicator)
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .frame(maxWidth: maxWidth, alignment: .leading)
    }
    
    // MARK: - Single Message Interface (Backward Compatibility)
    
    private var singleMessageView: some View {
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
                    .chromaticAberration(isActive: true, intensity: 0.7) // RGB effect for emphasis
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
    
    // MARK: - Gestures
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                guard canContinue else { return }
                
                if value.translation.width > 50 || value.translation.height < -50 {
                    onContinue()
                }
            }
    }
    
    // MARK: - Animation Logic
    
    private func animateChatMessages(_ messages: [ChatMessage]) {
        var cumulativeDelay: Double = 0.5 // Initial delay
        
        for (index, message) in messages.enumerated() {
            cumulativeDelay += message.delay
            
            // Show typing indicator before each message (except first)
            if index > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeDelay - 0.8) {
                    showingTypingIndicator = true
                }
            }
            
            // Hide typing indicator and show message
            DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeDelay) {
                showingTypingIndicator = false
                withAnimation(.easeIn(duration: 0.3)) {
                    visibleMessages.append(message)
                }
                
                // Check if this is the last message
                if index == messages.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        allMessagesDisplayed = true
                        // Enable continue after additional 1.5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                canContinue = true
                            }
                        }
                    }
                }
            }
            
            // Add spacing between messages
            cumulativeDelay += 1.2
        }
    }
    
    private func animateSingleMessage() {
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

#Preview("Chat Style") {
    AICommentaryView(
        config: AICommentaryConfig(
            messages: [
                ChatMessage(text: "hey", delay: 0.5),
                ChatMessage(text: "it's me. you. from later.", delay: 1.0),
                ChatMessage(text: "remember that thing you started last month?", delay: 1.2)
            ],
            persona: .futureYou,
            showAvatar: false
        ),
        onContinue: {
            print("Continue tapped")
        }
    )
}
