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
    @State private var timerCancellable: AnyCancellable?
    @State private var bindingCancellables = Set<AnyCancellable>()

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
    }

    private var backgroundView: some View {
        ZStack {
            Color.brutalBlack
                .ignoresSafeArea()

            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    Color.brutalBlack,
                    callStateStore.state.phase == .connected ?
                        Color.brutalRed.opacity(0.15) :
                        Color.brutalRed.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
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
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        ZStack {
                            Circle()
                                .fill(tint)

                            // Subtle border
                            Circle()
                                .strokeBorder(
                                    Color.white.opacity(tint == .brutalRed ? 0.2 : 0.1),
                                    lineWidth: Spacing.borderThin
                                )
                        }
                    )
                    .shadow(
                        color: tint == .brutalRed ? Color.brutalRed.opacity(0.4) : Color.black.opacity(0.2),
                        radius: tint == .brutalRed ? 12 : 8,
                        x: 0,
                        y: 4
                    )
            }

            Text(label)
                .font(.captionMedium)
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private func configureBindings() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard let startedAt = callStateStore.state.startedAt else { return }
                let elapsedTime = Date().timeIntervalSince(startedAt)
                let minutes = Int(elapsedTime) / 60
                let seconds = Int(elapsedTime) % 60
                elapsed = String(format: "%02d:%02d", minutes, seconds)
            }

        sessionController.$state
            .receive(on: RunLoop.main)
            .sink { state in
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
            .store(in: &bindingCancellables)

        sessionController.$promptResponse
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { _ in
                callStateStore.markPromptsReady()
            }
            .store(in: &bindingCancellables)
    }

    private func teardown() {
        timerCancellable?.cancel()
        timerCancellable = nil
        bindingCancellables.forEach { $0.cancel() }
        bindingCancellables.removeAll()
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
