//
//  FaceView.swift
//  bigbruhh
//
//  FACE tab - Main dashboard with countdown timer and stats
//

import SwiftUI
import Combine

struct FaceView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var cacheManager = DataCacheManager.shared

    @State private var timeRemaining: TimeInterval = 2 * 60 * 60 // 2 hours default
    @State private var timerPulse: CGFloat = 1.0
    @State private var showRedFlash: Bool = false
    @State private var currentDate: String = ""

    // User stats (loaded from API)
    @State private var promisesMade: Int = 0
    @State private var promisesBroken: Int = 0
    @State private var streakDays: Int = 0
    @State private var trustPercentage: Int = 100
    
    // Dynamic AI-generated messages (loaded from API)
    @State private var notificationTitle: String = "ACCOUNTABILITY CHECK"
    @State private var notificationMessage: String = "No excuses today. Your call is coming."
    @State private var disciplineLevel: String = "STABLE"
    @State private var disciplineMessage: String = "Keep pushing. Consistency is key."

    // Loading state
    @State private var isLoading: Bool = false
    @State private var loadError: String? = nil
    @State private var isRefreshing: Bool = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Computed Properties for Grades

    private var successRate: Int {
        guard promisesMade > 0 else { return 0 }
        let kept = promisesMade - promisesBroken
        return Int((Double(kept) / Double(promisesMade)) * 100)
    }

    private var progressMessage: String {
        // Use AI-generated discipline message if available, otherwise fallback to computed message
        if !disciplineMessage.isEmpty && disciplineMessage != "Keep pushing. Consistency is key." {
            return disciplineMessage
        }
        
        // Fallback to computed message based on success rate
        if successRate >= 80 { return "Actually locked in 🔥" }
        if successRate >= 60 { return "Getting there... maybe" }
        if successRate >= 40 { return "Still making excuses bro" }
        if successRate >= 20 { return "You're not even trying" }
        return "Absolutely cooked 💀"
    }

    private var promiseGrade: (grade: String, message: String) {
        if successRate >= 90 { return ("A+", "Actually reliable") }
        if successRate >= 80 { return ("A", "Pretty good") }
        if successRate >= 70 { return ("B+", "Not bad") }
        if successRate >= 60 { return ("B", "Mediocre") }
        if successRate >= 50 { return ("C", "Weak effort") }
        if successRate >= 40 { return ("D", "Disappointing") }
        return ("F", "Pathetic")
    }

    private var excuseGrade: (grade: String, message: String) {
        // Inverse grading - more excuses = higher grade
        if successRate <= 20 { return ("A+", "Too creative") }
        if successRate <= 40 { return ("A", "Very creative") }
        if successRate <= 60 { return ("B", "Getting there") }
        if successRate <= 80 { return ("C", "Boring excuses") }
        return ("F", "No excuses!")
    }

    private var streakGrade: (grade: String, message: String) {
        if streakDays >= 14 { return ("A+", "On fire") }
        if streakDays >= 7 { return ("B+", "Building up") }
        if streakDays >= 3 { return ("C", "Inconsistent") }
        if streakDays >= 1 { return ("D", "Broken") }
        return ("F", "Non-existent")
    }

    private var overallGrade: (grade: String, message: String) {
        if successRate >= 90 { return ("A+", "Exceptional") }
        if successRate >= 80 { return ("A", "Good work") }
        if successRate >= 70 { return ("B", "Average") }
        if successRate >= 60 { return ("C", "Below par") }
        if successRate >= 50 { return ("D", "Disappointing") }
        return ("F", "Hopeless")
    }

    private func gradeColor(_ grade: String) -> Color {
        if grade.contains("A") { return Color(hex: "#00FF00") } // Green for A
        if grade.contains("B") { return Color(hex: "#FFD700") } // Gold for B
        if grade.contains("C") { return Color(hex: "#FF8C00") } // Orange for C
        if grade.contains("D") { return Color(hex: "#8B00FF") } // Purple for D
        return Color(hex: "#DC143C") // Red for F
    }

    var body: some View {
        ZStack {
            Color.brutalBlack
                .ignoresSafeArea()

            // Red flash overlay
            if showRedFlash {
                Color.red.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            ScrollView {
                VStack(spacing: 0) {
                    // Header with logo
                    HeaderLogoBar()

                    if isLoading {
                        // Loading state
                        loadingView
                    } else if let error = loadError {
                        // Error state
                        errorView(message: error)
                    } else {
                        // Main countdown card
                        countdownCard

                        // Notification style card
                        notificationCard

                        // Progress bar
                        progressBar

                        // Grade cards grid
                        gradeCardsGrid

                        Spacer(minLength: 100)
                    }
                }
            }
            .refreshable {
                await loadUserStatus(forceRefresh: true)
            }
        }
        .onAppear {
            updateCurrentDate()
            Task {
                await loadUserStatus()
            }
        }
        .onReceive(timer) { _ in
            updateTimer()
        }
    }

    // MARK: - Hero Call Timer (Main Element)

    private var countdownCard: some View {
        VStack(spacing: 20) {
            Text("next call in")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.white.opacity(0.87))
                .tracking(1)

            // HERO TIMER - BIG DISPLAY
            Text(timeRemainingString)
                .font(.system(size: 64, weight: .black))
                .foregroundColor(.white)
                .tracking(4)
                .monospacedDigit()
                .scaleEffect(timerPulse)
                .animation(.easeInOut(duration: isUnderOneHour ? 0.5 : 1.0), value: timerPulse)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 250)
    }

    private var timeRemainingString: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Notification Card

    private var notificationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.brutalRed)
                            .frame(width: 24, height: 24)

                        Text("🔥")
                            .font(.system(size: 12))
                    }

                    Text("BigBruh")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("now")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.5))
            }

            Text(notificationTitle)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .tracking(1)

            Text(notificationMessage)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color(white: 0.1, opacity: 1.0))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(white: 0.2, opacity: 1.0), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("DISCIPLINE LEVEL")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(successRate)%")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                }

                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.2, opacity: 1.0))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(successRate >= 60 ? Color.neonGreen : Color.brutalRed)
                        .frame(width: max(0, CGFloat(successRate) / 100.0 * UIScreen.main.bounds.width * 0.85), height: 8)
                }

                Text(progressMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .italic()
            }
            .padding(16)
            .background(Color(white: 0.05, opacity: 1.0))
            .cornerRadius(8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Grade Cards Grid

    private var gradeCardsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERFORMANCE GRADES")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.white.opacity(0.5))
                .tracking(2)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    gradeCard(category: "PROMISES", grade: promiseGrade.grade, message: promiseGrade.message, color: gradeColor(promiseGrade.grade))
                    gradeCard(category: "EXCUSES", grade: excuseGrade.grade, message: excuseGrade.message, color: gradeColor(excuseGrade.grade))
                }

                HStack(spacing: 12) {
                    gradeCard(category: "STREAK", grade: streakGrade.grade, message: streakGrade.message, color: gradeColor(streakGrade.grade))
                    gradeCard(category: "OVERALL", grade: overallGrade.grade, message: overallGrade.message, color: gradeColor(overallGrade.grade))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private func gradeCard(category: String, grade: String, message: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(category)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .tracking(1)

            Text(grade)
                .font(.system(size: 48, weight: .black))
                .foregroundColor(.white)

            Text(message)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(color)
        .cornerRadius(12)
    }

    // MARK: - Timer Logic

    private var hours: Int {
        Int(timeRemaining) / 3600
    }

    private var minutes: Int {
        (Int(timeRemaining) % 3600) / 60
    }

    private var seconds: Int {
        Int(timeRemaining) % 60
    }

    private var isUnderOneHour: Bool {
        timeRemaining < 3600 && timeRemaining > 0
    }

    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1

            // Pulse animation
            withAnimation {
                timerPulse = timerPulse == 1.0 ? 0.98 : 1.0
            }

            // Red flash on exact hour marks
            if seconds == 0 && minutes == 0 {
                triggerRedFlash()
            }
        }
    }

    private func triggerRedFlash() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showRedFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showRedFlash = false
            }
        }
    }

    private func updateCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        currentDate = formatter.string(from: Date())
    }

    @MainActor
    private func loadUserStatus(forceRefresh: Bool = false) async {
        guard let userId = authService.user?.id else {
            Config.log("No user ID available for loading status", category: "FaceView")
            return
        }

        isLoading = true
        loadError = nil

        do {
            // NOTE: Identity and IdentityStatus are separate tables
            // Identity = psychological profile (name, summary, behavioral fields)
            // IdentityStatus = stats (trust %, streak, promises, next call time)
            // TODO: Backend should return both or create a combined endpoint

            // For now, fetch identity to verify user has completed onboarding
            let identityResponse = try await APIService.shared.fetchIdentityWithCache(
                userId: userId,
                forceRefresh: forceRefresh
            )

            Config.log("Identity response - success: \(identityResponse.success), hasData: \(identityResponse.data != nil), error: \(identityResponse.error ?? "none")", category: "FaceView")

            if !identityResponse.success {
                if let error = identityResponse.error {
                    throw APIError.serverError(error)
                } else {
                    throw APIError.serverError("Unknown server error")
                }
            }

            guard let identity = identityResponse.data else {
                Config.log("Identity data is nil", category: "FaceView")
                throw APIError.noData
            }

            Config.log("Identity exists for user", category: "FaceView")

            // Use data from identity response (includes identity_status data)
            // The backend /api/identity/:userId endpoint returns both identity and identity_status
            trustPercentage = identity.trustPercentage ?? 100
            streakDays = identity.currentStreakDays ?? 0
            promisesMade = identity.promisesMadeCount ?? 0
            promisesBroken = identity.promisesBrokenCount ?? 0
            
            // Extract dynamic AI-generated messages from statusSummary
            if let statusSummary = identity.statusSummary {
                notificationTitle = statusSummary.notificationTitle ?? "ACCOUNTABILITY CHECK"
                notificationMessage = statusSummary.notificationMessage ?? "No excuses today. Your call is coming."
                disciplineLevel = statusSummary.disciplineLevel ?? "STABLE"
                disciplineMessage = statusSummary.disciplineMessage ?? "Keep pushing. Consistency is key."
                
                Config.log("Dynamic messages loaded - Level: \(disciplineLevel), Title: \(notificationTitle)", category: "FaceView")
            } else {
                Config.log("No statusSummary found, using default messages", category: "FaceView")
            }

            Config.log("Stats - trust: \(trustPercentage)%, streak: \(streakDays), promises: \(promisesMade) made / \(promisesBroken) broken", category: "FaceView")

            // Calculate countdown from nextCallTimestamp
            if let nextCallTimestamp = identity.nextCallTimestamp {
                let nextCallDate = Date(timeIntervalSince1970: nextCallTimestamp)
                let remaining = nextCallDate.timeIntervalSinceNow
                if remaining > 0 {
                    self.timeRemaining = remaining
                    Config.log("Next call in \(Int(remaining/60)) minutes", category: "FaceView")
                } else {
                    Config.log("Next call is overdue or not scheduled", category: "FaceView")
                }
            } else {
                Config.log("No next call timestamp available", category: "FaceView")
            }

            isLoading = false

        } catch APIError.unauthorized {
            Config.log("Unauthorized error - user needs to sign in", category: "FaceView")
            loadError = "Please sign in to view your stats"
            isLoading = false
        } catch APIError.networkError(let underlyingError) {
            Config.log("Network error: \(underlyingError)", category: "FaceView")
            loadError = "Network error - pull to refresh"
            isLoading = false
        } catch APIError.serverError(let message) {
            Config.log("Server error: \(message)", category: "FaceView")
            loadError = "Server error: \(message)"
            isLoading = false
        } catch APIError.noData {
            Config.log("No data returned from API", category: "FaceView")
            loadError = "No data available - pull to refresh"
            isLoading = false
        } catch let error as APIError {
            Config.log("API error: \(error.localizedDescription)", category: "FaceView")
            loadError = "Failed to load data - pull to refresh"
            isLoading = false
        } catch {
            Config.log("Failed to load user status: \(error)", category: "FaceView")
            loadError = "Failed to load data - pull to refresh"
            isLoading = false
        }
    }

    // MARK: - Loading & Error Views

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)

            Text("Loading your accountability data...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.brutalRed)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)

            Button(action: {
                Task {
                    await loadUserStatus()
                }
            }) {
                Text("Retry")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.brutalRed)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .padding(.top, 100)
    }
}

#Preview {
    FaceView()
        .environmentObject(AuthService.shared)
}
