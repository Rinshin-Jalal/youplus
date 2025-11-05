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
    @State private var loading: Bool = false
    @State private var isRefreshing: Bool = false
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

                    // Control Actions
                    Text("CONTROL ACTIONS")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.7, opacity: 1.0))
                        .tracking(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 8)

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
        VStack(spacing: 10) {
            Text("commitment window")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(white: 0.85, opacity: 1.0))

            Text("\(formatTimeForDisplay(callWindowStart)) - \(formatTimeForDisplay(endTime))")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
                .tracking(2)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 250)
        .background(Color.black)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    // MARK: - Control Actions

    private var controlActions: some View {
        VStack(spacing: 12) {
            // DEBUG: Call Screen Button
            #if DEBUG
            Button(action: {
                navigator.showCall()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("DEBUG: CALL SCREEN")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .tracking(1)

                            Spacer()

                            Image(systemName: "phone.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("Test the call screen interface")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(white: 0.8, opacity: 1.0))
                            .lineSpacing(4)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#8B00FF"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#4B0082"), lineWidth: 3)
                )
            }
            .buttonStyle(.plain)

    // DEBUG: Secret Plan Button
    Button(action: {
        navigator.showSecretPlan(userName: "BigBruh", source: "debug")
    }) {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("DEBUG: SECRET PLAN")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(1)

                    Spacer()

                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("Test the secret plan paywall flow")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(white: 0.8, opacity: 1.0))
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#FFD700"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#B8860B"), lineWidth: 3)
        )
    }
    .buttonStyle(.plain)

            // DEBUG: Identity Extraction Button
            Button(action: {
                triggerIdentityExtraction()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("DEBUG: IDENTITY EXTRACTION")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .tracking(1)

                            Spacer()

                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("Trigger AI identity extraction manually")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(white: 0.8, opacity: 1.0))
                            .lineSpacing(4)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#00CED1"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#008B8B"), lineWidth: 3)
                )
            }
            .buttonStyle(.plain)
            .disabled(loading)

            // Status Display
            if !extractionStatus.isEmpty {
                Text(extractionStatus)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(white: 0.7))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            #endif

            // Modify Window Button
            Button(action: {
                withAnimation {
                    showTimePicker = true
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("MODIFY WINDOW")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .tracking(1)

                            Spacer()

                            Image(systemName: "clock")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("Change your daily commitment window")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(white: 0.8, opacity: 1.0))
                            .lineSpacing(4)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#1a1a1a"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#333333"), lineWidth: 3)
                )
            }
            .buttonStyle(.plain)

            // Terminate Session Button
            Button(action: handleSignOut) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("TERMINATE SESSION")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .tracking(1)

                            Spacer()

                            Image(systemName: "arrow.right.square")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("End your accountability commitment")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#DC143C"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#8B0000"), lineWidth: 3)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    // MARK: - Time Picker Modal

    private var timePickerModal: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showTimePicker = false
                    }
                }

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        withAnimation {
                            showTimePicker = false
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#DC143C"))

                    Spacer()

                    Text("SELECT TIME")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(1)

                    Spacer()

                    Button("Done") {
                        saveCallWindow()
                        withAnimation {
                            showTimePicker = false
                        }
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.success)
                }
                .padding(20)
                .background(Color(white: 0.1, opacity: 1.0))

                // Time Picker
                DatePicker("", selection: $callWindowStart, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                    .background(Color(white: 0.05, opacity: 1.0))
            }
            .background(Color(white: 0.05, opacity: 1.0))
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

        loading = true
        extractionStatus = "🔄 Triggering identity extraction..."

        Task {
            do {
                let response: APIResponse<[String: AnyCodableValue]> = try await APIService.shared.post(
                    "/onboarding/extract-data",
                    body: [:]
                )

                await MainActor.run {
                    if response.success {
                        extractionStatus = "✅ Identity extraction completed successfully"
                    } else {
                        extractionStatus = "❌ Identity extraction failed: \(response.error ?? "Unknown error")"
                    }
                    loading = false
                }
            } catch {
                await MainActor.run {
                    extractionStatus = "❌ Identity extraction error: \(error.localizedDescription)"
                    loading = false
                }
            }
        }
    }
}

#Preview {
    ControlView()
        .environmentObject(AuthService.shared)
}
