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
        Color.black
            .ignoresSafeArea()
            .overlay(LinearGradient(
                colors: [Color.black, Color.red.opacity(callStateStore.state.phase == .connected ? 0.3 : 0.1)],
                startPoint: .top,
                endPoint: .bottom
            ))
    }

    private var titleSection: some View {
        VStack(spacing: 16) {
            Text(elapsed)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
                .tracking(12)
                .monospacedDigit()

            Text(callStateStore.state.callType?.uppercased() ?? "ACCOUNTABILITY")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(4)
        }
    }

    private var liveTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(statusLine)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            Text(typedText)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .tracking(0.3)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var textInputSection: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Type message to BigBruh...", text: $messageText, axis: .vertical)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(14)
                .lineLimit(1...4)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white.opacity(0.08))
                )
            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(.white)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .padding(.top, 12)
        .background(.black.opacity(0.3))
    }

    private var controlButtons: some View {
        HStack(spacing: 50) {
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
                tint: Color(hex: "#DC143C"),
                action: endCall
            )
        }
    }

    private func controlButton(icon: String, label: String, tint: Color = .white.opacity(0.2), action: @escaping () -> Void) -> some View {
            VStack(spacing: 8) {
            Button(action: action) {
                Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 68, height: 68)
                        .background(
                            Circle()
                            .fill(tint)
                        )
                }
            Text(label)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
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
