//
//  CallScreen.swift
//  bigbruhh
//
//  AI-powered accountability call screen with mood-based animations
//

import SwiftUI
import Combine

struct CallScreen: View {
    @EnvironmentObject var callStateStore: CallStateStore
    @EnvironmentObject var callKitManager: CallKitManager
    @EnvironmentObject var sessionController: CallSessionController

    @State private var elapsed: String = "00:00"
    @State private var muted = false
    @State private var showTextInput = false
    @State private var messageText = ""
    @State private var typedText = "Connecting to your accountability system..."
    @State private var timerTask: Task<Void, Never>?
    @State private var stateObserverTask: Task<Void, Never>?
    @State private var promptObserverTask: Task<Void, Never>?

    // MARK: - Performance Optimizations
    // Cache expensive gradient computations to prevent repeated body recomputation
    @State private var cachedGradientDisconnected: AnyView?
    @State private var cachedGradientConnected: AnyView?
    @State private var cachedGlowEffect: AnyView?
    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 0) {
                titleSection
                    .padding(.top, 60)
                Spacer()
                liveTextSection
                    .padding(.horizontal, 20)
                Spacer()
                if showTextInput {
                    textInputSection
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                controlButtons
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .onAppear(perform: configureBindings)
        .onDisappear(perform: teardown)
        .animation(.easeInOut(duration: 0.3), value: callStateStore.state.phase)
        .task {
            // Pre-cache gradients on first appearance to avoid recomputation
            if cachedGradientDisconnected == nil {
                cachedGradientDisconnected = AnyView(baseGradientDisconnected)
                cachedGradientConnected = AnyView(baseGradientConnected)
                cachedGlowEffect = AnyView(glowEffect)
            }
        }
    }

    // Cached gradient views for performance - computed once and reused
    private var baseGradientDisconnected: some View {
        LinearGradient(
            colors: [Color.brutalBlack, Color.brutalRed.opacity(0.08)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var baseGradientConnected: some View {
        LinearGradient(
            colors: [Color.brutalBlack, Color.brutalRed.opacity(0.35)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var glowEffect: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.brutalRed.opacity(0.4),
                Color.brutalRed.opacity(0.0)
            ]),
            center: .center,
            startRadius: 100,
            endRadius: 500
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func background(for phase: CallSessionState.Phase) -> some View {
        ZStack {
            Color.brutalBlack.ignoresSafeArea()

            if phase == .connected {
                if let cached = cachedGradientConnected {
                    cached
                } else {
                    baseGradientConnected
                }
                if let cached = cachedGlowEffect {
                    cached
                } else {
                    glowEffect
                }
            } else {
                if let cached = cachedGradientDisconnected {
                    cached
                } else {
                    baseGradientDisconnected
                }
            }
        }
    }

    private var backgroundView: some View {
        background(for: callStateStore.state.phase)
    }

    private var titleSection: some View {
        VStack(spacing: Spacing.md) {
            Text(elapsed)
                .font(.callTimer)
                .foregroundColor(.white)
                .tightTracking()
                .monospacedDigit()
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

            Text(callStateStore.state.callType?.uppercased() ?? "ACCOUNTABILITY")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .extraWideTracking()
        }
    }

    private var liveTextSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Status badge
            HStack(spacing: Spacing.xs) {
                Circle()
                    .fill(statusLine == "LIVE" ? Color.success : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)

                Text(statusLine)
                    .font(.captionMedium)
                    .foregroundColor(.white.opacity(0.7))
                    .wideTracking()
            }

            Text(typedText)
                .font(.headlineMedium)
                .foregroundColor(.white)
                .normalTracking()
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: Spacing.borderThin)
        )
    }

    private var textInputSection: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            TextField("Type message to BigBruh...", text: $messageText, axis: .vertical)
                .font(.bodyRegular)
                .foregroundColor(.white)
                .padding(Spacing.md)
                .lineLimit(1...4)
                .background(
                    RoundedRectangle(cornerRadius: Spacing.radiusLarge, style: .continuous)
                        .fill(.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusLarge, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: Spacing.borderThin)
                )

            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.brutalBlack)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.bottom, Spacing.lg)
        .padding(.top, Spacing.sm)
        .background(
            LinearGradient(
                colors: [Color.clear, Color.brutalBlack.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var controlButtons: some View {
        HStack(spacing: Spacing.xxxl) {
            controlButton(
                icon: muted ? "mic.slash.fill" : "mic.fill",
                label: "mute",
                action: toggleMute
            )
            controlButton(
                icon: "message.fill",
                label: "message",
                action: toggleTextInput
            )
            controlButton(
                icon: "phone.down.fill",
                label: "end",
                tint: Color.brutalRed,
                action: endCall
            )
        }
    }

    private func controlButton(icon: String, label: String, tint: Color = .white.opacity(0.15), action: @escaping () -> Void) -> some View {
        VStack(spacing: Spacing.xs) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(tint == .brutalRed ? .brutalWhite : .white)
                    .frame(width: 64, height: 64)
                    .background(
                        ZStack {
                            Circle()
                                .fill(tint)

                            // INTENSE border on red button
                            Circle()
                                .strokeBorder(
                                    Color.white.opacity(tint == .brutalRed ? 0.3 : 0.1),
                                    lineWidth: tint == .brutalRed ? 2 : Spacing.borderThin
                                )
                        }
                    )
                    .shadow(
                        color: tint == .brutalRed ? Color.brutalRed.opacity(0.6) : Color.black.opacity(0.2),
                        radius: tint == .brutalRed ? 20 : 8,  // Increased glow radius
                        x: 0,
                        y: tint == .brutalRed ? 8 : 4
                    )
                    .scaleEffect(0.95)  // Press effect ready
            }
            .buttonStyle(PlainButtonStyle())

            Text(label.uppercased())
                .font(.captionMedium)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(tint == .brutalRed ? 1.0 : 0.8))
        }
    }

    private func configureBindings() {
        startElapsedTimer()
        observeSessionState()
        observePromptResponse()
    }

    private func startElapsedTimer() {
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                guard let startedAt = callStateStore.state.startedAt else {
                    try? await Task.sleep(for: .seconds(1))
                    continue
                }

                // Optimize: Calculate elapsed time off main thread, update UI on main thread
                let elapsedTime = Date().timeIntervalSince(startedAt)
                let formatted = String(format: "%02d:%02d", Int(elapsedTime) / 60, Int(elapsedTime) % 60)

                // Only update if changed to prevent unnecessary view updates
                if formatted != elapsed {
                    elapsed = formatted
                }

                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func observeSessionState() {
        stateObserverTask = Task { @MainActor in
            for await state in sessionController.$state.values {
                updateTypedText(for: state)
            }
        }
    }

    private func observePromptResponse() {
        promptObserverTask = Task { @MainActor in
            for await response in sessionController.$promptResponse.values {
                guard response != nil else { continue }
                callStateStore.markPromptsReady()
            }
        }
    }

    private func updateTypedText(for state: CallSessionController.State) {
        switch state {
        case .awaitingPrompts:
            typedText = "Lock in. BigBruh is loading your judgement."
        case .preparing:
            typedText = "Hold steady."
        case .streaming:
            typedText = "Hold the line. BigBruh is on."
        case .completed:
            typedText = "Stay ruthless."
        case .failed(let error):
            typedText = "Connection failed: \(error.localizedDescription)"
        case .idle:
            break
        }
    }

    private func teardown() {
        timerTask?.cancel()
        timerTask = nil
        stateObserverTask?.cancel()
        stateObserverTask = nil
        promptObserverTask?.cancel()
        promptObserverTask = nil
    }

    private func toggleMute() {
        guard let uuid = callStateStore.state.uuid else { return }
        muted.toggle()
        callKitManager.setMuted(muted, uuid: uuid)
    }

    private func toggleTextInput() {
        withAnimation {
            showTextInput.toggle()
        }
    }

    private func sendMessage() {
        messageText = ""
    }

    private func endCall() {
        if let uuid = callStateStore.state.uuid {
            callKitManager.endCall(uuid: uuid)
        }
        sessionController.endSession()
        callStateStore.reset()
    }

    private var statusLine: String {
        switch callStateStore.state.phase {
        case .ringing:
            return "RINGING"
        case .awaitingPrompts:
            return "FETCHING SCRIPT"
        case .connecting:
            return "CONNECTING"
        case .connected:
            return "LIVE"
        case .ended:
            return "ENDED"
        case .idle:
            return "WAITING"
        }
    }
}

#Preview {
    CallScreen()
        .environmentObject(AppNavigator())
}
