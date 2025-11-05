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

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HeaderLogoBar()

                    // HERO SETTINGS CARD - matches NRN
                    heroSettingsCard

                    // Actions Section
                    Text("ACTIONS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(white: 0.5))
                        .tracking(1.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                    controlActions

                    Spacer(minLength: 100)
                }
            }

            // Time Picker Modal
            if showTimePicker {
                timePickerModal
            }
        }
    }

    // MARK: - Hero Settings Card

    private var heroSettingsCard: some View {
        VStack(spacing: 8) {
            Text("COMMITMENT WINDOW")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(white: 0.6))
                .tracking(1.5)

            Text("\(formatTimeForDisplay(callWindowStart)) - \(formatTimeForDisplay(endTime))")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
                .tracking(1)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.05))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Control Actions

    private var controlActions: some View {
        VStack(spacing: 12) {
            #if DEBUG
            // Debug Actions Section
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    // Call Screen
                    Button(action: { navigator.showCall() }) {
                        VStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("CALL")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#8B00FF"))
                        .cornerRadius(8)
                    }

                    // Paywall
                    Button(action: { navigator.showSecretPlan(userName: "BigBruh", source: "debug") }) {
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("PAYWALL")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#FFD700"))
                        .cornerRadius(8)
                    }

                    // Identity Extraction
                    Button(action: triggerIdentityExtraction) {
                        VStack(spacing: 4) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 16, weight: .bold))
                            Text("EXTRACT")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#00CED1"))
                        .cornerRadius(8)
                    }
                }
                .buttonStyle(.plain)

                if !extractionStatus.isEmpty {
                    Text(extractionStatus)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(white: 0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
            .background(Color(white: 0.08))
            .cornerRadius(8)
            #endif

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
                .padding(16)
                .background(Color(hex: "#1a1a1a"))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

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
                .foregroundColor(.white)
                .padding(16)
                .background(Color(hex: "#DC143C"))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
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
                    .foregroundColor(Color(hex: "#DC143C"))

                    Spacer()

                    Text("SELECT TIME")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(white: 0.7))
                        .tracking(1.5)

                    Spacer()

                    Button("Save") {
                        saveCallWindow()
                        withAnimation { showTimePicker = false }
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.success)
                }
                .padding(16)
                .background(Color(white: 0.08))

                DatePicker("", selection: $callWindowStart, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                    .background(Color(white: 0.03))
            }
            .background(Color(white: 0.03))
            .cornerRadius(12)
            .padding(.horizontal, 20)
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

#Preview {
    ControlView()
        .environmentObject(AuthService.shared)
}
