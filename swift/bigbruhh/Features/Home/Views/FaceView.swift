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
        if grade.contains("A") { return .gradeAPlus }
        if grade.contains("B") { return .gradeBPlus }
        if grade.contains("C") { return .gradeC }
        if grade.contains("D") { return .gradeD }
        return .gradeF
    }

    private func gradeGradient(_ grade: String) -> LinearGradient {
        if grade.contains("A") {
            return LinearGradient(
                colors: [Color.gradeAPlus, Color.gradeA],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if grade.contains("B") {
            return LinearGradient(
                colors: [Color.gradeBPlus, Color.gradeB],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if grade.contains("C") {
            return LinearGradient(
                colors: [Color.gradeC.opacity(0.9), Color.gradeC],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if grade.contains("D") {
            return LinearGradient(
                colors: [Color.gradeD.opacity(0.9), Color.gradeD],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.gradeF.opacity(0.9), Color.gradeF],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
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
        VStack(spacing: Spacing.md) {
            Text("next call in")
                .font(.captionMedium)
                .foregroundColor(Color.white.opacity(0.7))
                .wideTracking()
                .textCase(.uppercase)

            // HERO TIMER - BIG DISPLAY
            Text(timeRemainingString)
                .font(.timerHero)
                .foregroundColor(.white)
                .tightTracking()
                .monospacedDigit()
                .scaleEffect(timerPulse)
                .shadow(color: isUnderOneHour ? Color.brutalRed.opacity(0.5) : Color.clear, radius: 20, x: 0, y: 0)
                .animation(.easeInOut(duration: isUnderOneHour ? 0.5 : 1.0), value: timerPulse)
        }
        .padding(.vertical, Spacing.xxl)
        .padding(.horizontal, Spacing.screenHorizontal)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 240)
    }

    private var timeRemainingString: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Notification Card

    private var notificationCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                HStack(spacing: Spacing.xs) {
                    ZStack {
                        RoundedRectangle(cornerRadius: Spacing.radiusSmall, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.brutalRedLight, Color.brutalRed],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 24, height: 24)

                        Text("🔥")
                            .font(.system(size: 12))
                    }

                    Text("BigBruh")
                        .font(.titleSmall)
                        .foregroundColor(.white)
                }

                Spacer()

                Text("now")
                    .font(.captionMedium)
                    .foregroundColor(Color.white.opacity(0.5))
            }

            Text(notificationTitle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .wideTracking()
                .textCase(.uppercase)

            Text(notificationMessage)
                .font(.bodyMedium)
                .foregroundColor(Color.white.opacity(0.85))
                .lineSpacing(3)
        }
        .padding(Spacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Spacing.radiusMedium, style: .continuous)
                    .fill(Color.surfaceElevated)

                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: Spacing.radiusMedium, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusMedium, style: .continuous)
                .strokeBorder(Color.divider, lineWidth: Spacing.borderThin)
        )
        .elevation(.low)
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.lg)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("DISCIPLINE LEVEL")
                    .font(.captionMedium)
                    .foregroundColor(.white.opacity(0.9))
                    .wideTracking()

                Spacer()

                Text("\(successRate)%")
                    .font(.titleSmall)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            // Progress bar with gradient
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: Spacing.radiusXS, style: .continuous)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)

                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: Spacing.radiusXS, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: successRate >= 60 ?
                                    [Color.success, Color.success.opacity(0.8)] :
                                    [Color.brutalRedLight, Color.brutalRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, CGFloat(successRate) / 100.0 * geometry.size.width), height: 10)
                        .shadow(
                            color: (successRate >= 60 ? Color.success : Color.brutalRed).opacity(0.5),
                            radius: 6,
                            x: 0,
                            y: 0
                        )
                }
            }
            .frame(height: 10)

            Text(progressMessage)
                .font(.captionSmall)
                .foregroundColor(Color.white.opacity(0.65))
                .italic()
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Spacing.radiusSmall, style: .continuous)
                .fill(Color.surfaceDimmed)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusSmall, style: .continuous)
                .strokeBorder(Color.divider.opacity(0.5), lineWidth: Spacing.borderThin)
        )
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.lg)
    }

    // MARK: - Grade Cards Grid

    private var gradeCardsGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("PERFORMANCE GRADES")
                .font(.captionMedium)
                .foregroundColor(Color.white.opacity(0.5))
                .extraWideTracking()

            VStack(spacing: Spacing.sm) {
                HStack(spacing: Spacing.sm) {
                    gradeCard(category: "PROMISES", grade: promiseGrade.grade, message: promiseGrade.message, color: gradeColor(promiseGrade.grade))
                    gradeCard(category: "EXCUSES", grade: excuseGrade.grade, message: excuseGrade.message, color: gradeColor(excuseGrade.grade))
                }

                HStack(spacing: Spacing.sm) {
                    gradeCard(category: "STREAK", grade: streakGrade.grade, message: streakGrade.message, color: gradeColor(streakGrade.grade))
                    gradeCard(category: "OVERALL", grade: overallGrade.grade, message: overallGrade.message, color: gradeColor(overallGrade.grade))
                }
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.lg)
    }

    private func gradeCard(category: String, grade: String, message: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Text(category)
                .font(.captionMedium)
                .foregroundColor(.white.opacity(0.85))
                .wideTracking()
                .textCase(.uppercase)

            Text(grade)
                .font(.gradeDisplay)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            Text(message)
                .font(.captionSmall)
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 12)
        .background(
            ZStack {
                // Gradient background
                RoundedRectangle(cornerRadius: Spacing.radiusLarge, style: .continuous)
                    .fill(gradeGradient(grade))

                // Subtle overlay pattern
                RoundedRectangle(cornerRadius: Spacing.radiusLarge, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear,
                                Color.black.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusLarge, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .elevation(.medium)
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
