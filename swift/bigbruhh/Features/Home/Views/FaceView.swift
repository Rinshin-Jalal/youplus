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

    // MARK: - Performance Optimizations
    // Cache expensive computations to prevent repeated body recomputation
    @State private var cachedSuccessRate: Int = 0
    @State private var cachedProgressMessage: String = ""
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Computed Properties for Grades
    // Optimized: Cache success rate calculation to avoid recomputation on every body evaluation
    private var successRate: Int {
        // Recalculate only when promisesMade or promisesBroken changes
        guard promisesMade > 0 else { return 0 }
        let kept = promisesMade - promisesBroken
        let calculated = Int((Double(kept) / Double(promisesMade)) * 100)
        
        // Update cache if changed
        if calculated != cachedSuccessRate {
            Task { @MainActor in
                cachedSuccessRate = calculated
                updateCachedProgressMessage()
            }
        }
        
        return cachedSuccessRate != 0 ? cachedSuccessRate : calculated
    }
    
    private func updateCachedProgressMessage() {
        let newMessage: String
        if !disciplineMessage.isEmpty && disciplineMessage != "Keep pushing. Consistency is key." {
            newMessage = disciplineMessage
        } else if cachedSuccessRate >= 80 {
            newMessage = "Actually locked in 🔥"
        } else if cachedSuccessRate >= 60 {
            newMessage = "Getting there... maybe"
        } else if cachedSuccessRate >= 40 {
            newMessage = "Still making excuses bro"
        } else if cachedSuccessRate >= 20 {
            newMessage = "You're not even trying"
        } else {
            newMessage = "Absolutely cooked 💀"
        }
        
        if newMessage != cachedProgressMessage {
            cachedProgressMessage = newMessage
        }
    }

    private var progressMessage: String {
        // Use cached message to avoid recomputation
        if !cachedProgressMessage.isEmpty {
            return cachedProgressMessage
        }
        
        // Fallback calculation (should rarely execute due to caching)
        if !disciplineMessage.isEmpty && disciplineMessage != "Keep pushing. Consistency is key." {
            return disciplineMessage
        }
        
        let rate = successRate
        if rate >= 80 { return "Actually locked in 🔥" }
        if rate >= 60 { return "Getting there... maybe" }
        if rate >= 40 { return "Still making excuses bro" }
        if rate >= 20 { return "You're not even trying" }
        return "Absolutely cooked 💀"
    }

    private func gradeColor(_ value: Int) -> Color {
        if value >= 80 { return .gradeA }
        if value >= 60 { return .gradeB }
        if value >= 40 { return .gradeC }
        if value >= 20 { return .gradeD }
        return .gradeF
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
                    // FLAT red icon background - brutalist
                    ZStack {
                        RoundedRectangle(cornerRadius: Spacing.radiusXS, style: .continuous)
                            .fill(Color.brutalRed)
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
        .glassEffectIfAvailable()
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

            // FLAT progress bar - brutalist
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: Spacing.radiusXS, style: .continuous)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    // Progress fill - FLAT color
                    RoundedRectangle(cornerRadius: Spacing.radiusXS, style: .continuous)
                        .fill(successRate >= 60 ? Color.success : Color.brutalRed)
                        .frame(width: max(0, CGFloat(successRate) / 100.0 * geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)

            Text(progressMessage)
                .font(.captionSmall)
                .foregroundColor(Color.white.opacity(0.65))
                .italic()
        }
        .padding(Spacing.md)
        .glassEffectIfAvailable()
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.lg)
    }

    // MARK: - Grade Cards Grid

    private var gradeCardsGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("STATS")
                .font(.captionMedium)
                .foregroundColor(Color.white.opacity(0.5))
                .extraWideTracking()

            VStack(spacing: 12) {
                // Row 1: Promises & Streak
                HStack(spacing: Spacing.sm) {
                    VStack(alignment: .center, spacing: 4) {
                        Text("\(promisesMade)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("PROMISES")
                            .font(.captionSmall)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .glassEffectIfAvailable()

                    VStack(alignment: .center, spacing: 4) {
                        Text("\(streakDays)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("STREAK")
                            .font(.captionSmall)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .glassEffectIfAvailable()
                }

                // Row 2: Broken & Success Rate
                HStack(spacing: Spacing.sm) {
                    VStack(alignment: .center, spacing: 4) {
                        Text("\(promisesBroken)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.brutalRed)
                        Text("BROKEN")
                            .font(.captionSmall)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .glassEffectIfAvailable()

                    VStack(alignment: .center, spacing: 4) {
                        Text("\(successRate)%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(gradeColor(successRate))
                        Text("SUCCESS")
                            .font(.captionSmall)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .glassEffectIfAvailable()

                }
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.lg)
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

            // Optimize: Only animate pulse when under one hour to reduce animation overhead
            if isUnderOneHour {
                withAnimation(.easeInOut(duration: 0.5)) {
                    timerPulse = timerPulse == 1.0 ? 0.98 : 1.0
                }
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

        // PERFORMANCE: Only show loading indicator on initial load, not on refresh
        // This follows Apple's guidance to minimize energy usage with incremental updates
        if !forceRefresh {
            isLoading = true
        }
        loadError = nil

        do {
            // PERFORMANCE: Move network requests off main thread
            // Fetch data concurrently to reduce total wait time
            let identityResponse = try await APIService.shared.fetchIdentityWithCache(
                userId: userId,
                forceRefresh: forceRefresh
            )
            
            // NOTE: Identity and IdentityStatus are separate tables
            // Identity = psychological profile (name, summary, behavioral fields)
            // IdentityStatus = stats (trust %, streak, promises, next call time)
            // TODO: Backend should return both or create a combined endpoint

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

            // PERFORMANCE: Fetch stats concurrently after identity is validated
            // This endpoint returns promise tracking data from the promises table
            let statsResponse = try await APIService.shared.fetchIdentityStats(userId: userId)

            if let statsData = statsResponse.data {
                // Parse the stats response
                // Backend returns: { currentStreakDays, totalCallsCompleted, promises: { total, kept, broken, successRate } }

                // Extract currentStreakDays
                if case .int(let streak) = statsData["currentStreakDays"] {
                    streakDays = streak
                }

                // Extract promises object and parse its fields
                if case .dictionary(let promisesDict) = statsData["promises"] {
                    if case .int(let total) = promisesDict["total"] {
                        promisesMade = total
                    }
                    if case .int(let broken) = promisesDict["broken"] {
                        promisesBroken = broken
                    }
                    // Calculate trust percentage from success rate
                    if case .double(let successRate) = promisesDict["successRate"] {
                        trustPercentage = Int(successRate * 100)
                    }
                }

                Config.log("Stats loaded - trust: \(trustPercentage)%, streak: \(streakDays), promises: \(promisesMade) made / \(promisesBroken) broken", category: "FaceView")
            } else {
                // Fallback to defaults if stats not available
                Config.log("No stats data available, using defaults", category: "FaceView")
                trustPercentage = 100
                streakDays = 0
                promisesMade = 0
                promisesBroken = 0
            }

            // Extract dynamic AI-generated messages from statusSummary
            // TODO: Backend needs to implement status_summary generation
            // if let statusSummary = identity.statusSummary {
            //     notificationTitle = statusSummary.notificationTitle ?? "ACCOUNTABILITY CHECK"
            //     notificationMessage = statusSummary.notificationMessage ?? "No excuses today. Your call is coming."
            //     disciplineLevel = statusSummary.disciplineLevel ?? "STABLE"
            //     disciplineMessage = statusSummary.disciplineMessage ?? "Keep pushing. Consistency is key."
            //
            //     Config.log("Dynamic messages loaded - Level: \(disciplineLevel), Title: \(notificationTitle)", category: "FaceView")
            // } else {
            //     Config.log("No statusSummary found, using default messages", category: "FaceView")
            // }


            // Calculate countdown from nextCallTimestamp
            // TODO: Backend needs to provide next_call_timestamp in identity_status
            // if let nextCallTimestamp = identity.nextCallTimestamp {
            //     let nextCallDate = Date(timeIntervalSince1970: nextCallTimestamp)
            //     let remaining = nextCallDate.timeIntervalSinceNow
            //     if remaining > 0 {
            //         self.timeRemaining = remaining
            //         Config.log("Next call in \(Int(remaining/60)) minutes", category: "FaceView")
            //     } else {
            //         Config.log("Next call is overdue or not scheduled", category: "FaceView")
            //     }
            // } else {
            //     Config.log("No next call timestamp available", category: "FaceView")
            // }

            // PERFORMANCE: Defer schedule fetch to background - not critical for initial render
            // SUPER MVP: Calculate next call time from user settings or default
            // TODO: Backend should provide call_time in identity table
            // For now, fetch from user settings or use default 2 hours
            Task.detached(priority: .utility) {
                do {
                    guard let userId = await authService.user?.id else { return }
                    let scheduleResponse = try await APIService.shared.fetchSchedule(userId: userId)

                    if let schedule = scheduleResponse.data {
                        // Use evening time for accountability call (morningTime is for morning check-ins)
                        let callTime = schedule.eveningTime
                        let components = callTime.split(separator: ":").compactMap { Int($0) }
                        if components.count >= 2 {
                            let callHour = components[0]
                            let callMinute = components[1]

                            var calendar = Calendar.current
                            let timezone = TimeZone(identifier: schedule.timezone) ?? TimeZone.current
                            calendar.timeZone = timezone

                            var nextCallComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                            nextCallComponents.hour = callHour
                            nextCallComponents.minute = callMinute
                            nextCallComponents.second = 0

                                if let nextCallDate = calendar.date(from: nextCallComponents) {
                                    let remaining = nextCallDate.timeIntervalSinceNow
                                    if remaining > 0 {
                                        await MainActor.run {
                                            // PERFORMANCE: Incremental update - only update if changed
                                            if abs(self.timeRemaining - remaining) > 60 { // Only update if difference > 1 minute
                                                self.timeRemaining = remaining
                                                Config.log("Next call at \(callHour):\(String(format: "%02d", callMinute)) - in \(Int(remaining/60)) minutes", category: "FaceView")
                                            }
                                        }
                                    } else {
                                        // If call time is in the past, schedule for tomorrow
                                        if let tomorrowCall = calendar.date(byAdding: .day, value: 1, to: nextCallDate) {
                                            await MainActor.run {
                                                // PERFORMANCE: Incremental update
                                                if abs(self.timeRemaining - tomorrowCall.timeIntervalSinceNow) > 60 {
                                                    self.timeRemaining = tomorrowCall.timeIntervalSinceNow
                                                    Config.log("Next call tomorrow at \(callHour):\(String(format: "%02d", callMinute))", category: "FaceView")
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                } catch {
                    Config.log("Failed to fetch call schedule, using default 2 hour countdown: \(error)", category: "FaceView")
                }
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

extension View {
    @ViewBuilder
    func glassEffectIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: .rect(cornerRadius: 20))
        } else {
            self
        }
    }
}

#Preview {
    FaceView()
        .environmentObject(AuthService.shared)
}
