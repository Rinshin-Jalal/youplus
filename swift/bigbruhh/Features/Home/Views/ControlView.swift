//
//  ControlView.swift
//  bigbruhh
//
//  CONTROL tab - Settings and account management matching NRN settings.tsx
//

import SwiftUI

struct ControlView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var navigator: AppNavigator
    @StateObject private var cacheManager = DataCacheManager.shared
    
    @State private var callWindowStart: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    @State private var showTimePicker: Bool = false
    @State private var extractionStatus: String = ""

    var body: some View {
        ZStack {
            Color.brutalBlack
                .ignoresSafeArea()

            // Scanline overlay - full screen
            Scanlines()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HeaderLogoBar()

                    // HERO SETTINGS CARD - matches NRN
                    heroSettingsCard

//                    // Actions Section
//                    Text("ACTIONS")
//                        .font(.system(size: 11, weight: .bold))
//                        .foregroundColor(Color(white: 0.5))
//                        .tracking(1.5)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal, 16)
//                        .padding(.top, 16)
//                        .padding(.bottom, 10)
                    Spacer(minLength: 150)

                    controlActions

                }
            }

            // Time Picker Modal
            if showTimePicker {
                timePickerModal
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Hero Settings Card

    private var heroSettingsCard: some View {
        VStack(spacing: 8) {
            Text("COMMITMENT WINDOW")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .opacity(0.6)
                .tracking(1.5)

            Text("\(formatTimeForDisplay(callWindowStart)) - \(formatTimeForDisplay(endTime))")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
                .tracking(1)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(Color.brutalBlack)
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }

    // MARK: - Control Actions

    private var controlActions: some View {
        VStack(spacing: 12) {
//            #if DEBUG
//            // Debug Actions Section
//            VStack(spacing: 10) {
//                HStack(spacing: 10) {
//                    // Call Screen
//                    Button(action: { navigator.showCall() }) {
//                        VStack(spacing: 4) {
//                            Image(systemName: "phone.fill")
//                                .font(.system(size: 16, weight: .bold))
//                            Text("CALL")
//                                .font(.system(size: 10, weight: .bold))
//                        }
//                        .foregroundColor(.brutalWhite)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .background(Color.gradeD)
//                    }
//
//                    // Paywall
//                    Button(action: { navigator.showSecretPlan(userName: "BigBruh", source: "debug") }) {
//                        VStack(spacing: 4) {
//                            Image(systemName: "lock.fill")
//                                .font(.system(size: 16, weight: .bold))
//                            Text("PAYWALL")
//                                .font(.system(size: 10, weight: .bold))
//                        }
//                        .foregroundColor(.brutalBlack)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .background(Color.gradeB)
//                    }
//
//                    // Identity Extraction
//                    Button(action: triggerIdentityExtraction) {
//                        VStack(spacing: 4) {
//                            Image(systemName: "brain.head.profile")
//                                .font(.system(size: 16, weight: .bold))
//                            Text("EXTRACT")
//                                .font(.system(size: 10, weight: .bold))
//                        }
//                        .foregroundColor(.brutalBlack)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .background(Color.gradeA)
//                    }
//                }
//                .buttonStyle(.plain)
//
//                if !extractionStatus.isEmpty {
//                    Text(extractionStatus)
//                        .font(.system(size: 11, weight: .medium))
//                        .foregroundColor(.white)
//                        .opacity(0.6)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//            }
//            .padding(Spacing.md)
//            .frame(maxWidth: .infinity)
//            .background(Color.brutalBlack)
//            .overlay(
//                Rectangle()
//                    .stroke(Color.brutalWhite.opacity(0.2), lineWidth: 1)
//            )
//            #endif

            // Modify Window Button
            Button(action: { withAnimation { showTimePicker = true } }) {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 18, weight: .bold))
                    Text("MODIFY WINDOW")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .buttonStyleGlassIfAvailable()

            // Terminate Session Button
            Button(action: handleSignOut) {
                HStack {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 18, weight: .bold))
                    Text("SIGN OUT")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.brutalWhite)
                .padding(Spacing.lg)
            }
            .buttonStyleGlassProminentIfAvailable()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.huge)
    }

    // MARK: - Time Picker Modal

    private var timePickerModal: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showTimePicker = false } }

            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") {
                        withAnimation { showTimePicker = false }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.brutalRed)

                    Spacer()

                    Text("SELECT TIME")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .tracking(1.5)

                    Spacer()

                    Button("Save") {
                        saveCallWindow()
                        withAnimation { showTimePicker = false }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.success)
                }
                .padding(Spacing.lg)
                .background(Color.brutalBlack)

                DatePicker("", selection: $callWindowStart, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding(Spacing.lg)
                    .background(Color.brutalBlack)
            }
            .background(Color.brutalBlack)
            .padding(.horizontal, Spacing.lg)
        }
    }

    // MARK: - Helpers

    private var endTime: Date {
        Calendar.current.date(byAdding: .minute, value: 30, to: callWindowStart) ?? callWindowStart
    }

    private func formatTimeForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date).uppercased()
    }

    private func saveCallWindow() {
        Task {
            do {
                // Format time as HH:MM for backend (backend will add :00 for seconds)
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: callWindowStart)

                // Get user's timezone
                let timezone = TimeZone.current.identifier

                print("💾 Saving call window: \(timeString) (\(timezone))")

                // Call API
                let _: APIResponse<[String: AnyCodableValue]> = try await APIService.shared.updateCallSchedule(
                    callWindowStart: timeString,
                    timezone: timezone
                )

                print("✅ Call window saved successfully")

            } catch {
                print("❌ Failed to save call window: \(error)")
                // TODO: Show error alert to user
            }
        }
    }

    private func handleSignOut() {
        Task {
            try? await authService.signOut()
        }
    }

    private func triggerIdentityExtraction() {
        guard authService.user?.id != nil else {
            extractionStatus = "❌ No user ID found"
            return
        }

        extractionStatus = "🔄 Triggering identity extraction..."

        Task {
            do {
                let response: APIResponse<[String: AnyCodableValue]> = try await APIService.shared.post(
                    "/onboarding/extract-data",
                    body: [:]
                )

                await MainActor.run {
                    if response.success {
                        extractionStatus = "✅ Identity extraction completed"
                    } else {
                        extractionStatus = "❌ Failed: \(response.error ?? "Unknown error")"
                    }
                }
            } catch {
                await MainActor.run {
                    extractionStatus = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func buttonStyleGlassIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    func buttonStyleGlassProminentIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ControlView()
        .environmentObject(AuthService.shared)
}
