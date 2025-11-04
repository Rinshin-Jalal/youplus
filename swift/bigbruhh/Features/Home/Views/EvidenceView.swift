//
//  EvidenceView.swift
//  bigbruhh
//
//  EVIDENCE tab - Call history with brutal reviews matching NRN history.tsx
//

import SwiftUI
import Auth

struct CallHistoryItem: Identifiable {
    let id: String
    let date: String
    let time: String
    let duration: Int
    let promisesAnalyzed: Int
    let promisesBroken: Int
    let promisesKept: Int
    let worstExcuse: String?
    // brutalReview removed (bloat elimination)
}

struct EvidenceView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var cacheManager = DataCacheManager.shared

    @State private var callHistory: [CallHistoryItem] = []
    @State private var actualCalls: [CallLogEntry] = []
    @State private var loading: Bool = false
    @State private var loadError: String? = nil
    @State private var selectedCall: CallHistoryItem?
    @State private var showDetailModal: Bool = false
    @State private var isRefreshing: Bool = false

    var body: some View {
        ZStack {
            Color.brutalBlack
                .ignoresSafeArea()

            PullToRefreshWrapper(onRefresh: {
                await refreshData()
            }) {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with logo
                    HeaderLogoBar()

                    if loading {
                        loadingView
                    } else if let error = loadError {
                        errorView(message: error)
                    } else {
                        // HERO EVIDENCE CARD - matches NRN
                        heroEvidenceCard

                        // Assessment Card
                        Text("EVIDENCE ASSESSMENT")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(white: 0.7, opacity: 1.0))
                            .tracking(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 8)

                        assessmentCard

                        // Stats Grid
                        Text("EVIDENCE STATS")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(white: 0.7, opacity: 1.0))
                            .tracking(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 8)

                        statsGrid

                        // Recent Evidence
                        Text("RECENT EVIDENCE")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(white: 0.7, opacity: 1.0))
                            .tracking(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 8)

                        recentEvidenceList

                        Spacer(minLength: 100)
                    }
                    }
                }
            }
            .refreshable {
                await loadCallHistory(forceRefresh: true)
            }
        }
        .onAppear {
            Task {
                await loadCallHistory()
            }
        }
        .sheet(isPresented: $showDetailModal) {
            if let call = selectedCall {
                EvidenceDetailModal(call: call, onDismiss: {
                    showDetailModal = false
                })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Data Loading with Caching
    
    private func refreshData() async {
        await loadCallHistory(forceRefresh: true)
    }
    
    private func loadCallHistory(forceRefresh: Bool = false) async {
        guard let userId = authService.user?.id else {
            Config.log("❌ No authenticated user for call history", category: "Evidence")
            await MainActor.run {
                loadError = "Authentication required"
                loading = false
            }
            return
        }
        
        // Debug auth status
        if let session = SupabaseManager.shared.currentSession {
            Config.log("🔑 Auth session exists: userId=\(userId), tokenLength=\(session.accessToken.count)", category: "Evidence")
            Config.log("🔑 Token preview: \(String(session.accessToken.prefix(20)))...", category: "Evidence")
        } else {
            Config.log("❌ No auth session found", category: "Evidence")
            await MainActor.run {
                loadError = "Authentication session expired"
                loading = false
            }
            return
        }
        
        // Also check AuthService session
        if let authSession = authService.session {
            Config.log("🔑 AuthService session exists: userId=\(authSession.user.id)", category: "Evidence")
        } else {
            Config.log("❌ No AuthService session found", category: "Evidence")
        }
        
        // Check cache first unless force refresh
        if !forceRefresh {
            if let cachedCalls: [CallLogEntry] = cacheManager.get(DataCacheManager.CacheKeys.callHistory, type: [CallLogEntry].self) {
                Config.log("📦 Using cached call history", category: "Evidence")
                await MainActor.run {
                    actualCalls = cachedCalls
                    callHistory = convertToCallHistoryItems(cachedCalls)
                    loading = false
                }
                return
            }
        }
        
        await MainActor.run {
            loading = true
            loadError = nil
        }
        
        do {
            Config.log("🔄 Calling API: /api/history/calls", category: "Evidence")
            let response = try await APIService.shared.fetchCallHistory(userId: userId)
            Config.log("📡 API Response: success=\(response.success), dataCount=\(response.data?.count ?? 0)", category: "Evidence")
            
            if response.success {
                if let calls = response.data {
                    Config.log("✅ API returned \(calls.count) calls", category: "Evidence")
                    // Cache the data
                    cacheManager.set(DataCacheManager.CacheKeys.callHistory, data: calls)
                    
                    await MainActor.run {
                        actualCalls = calls
                        callHistory = convertToCallHistoryItems(calls)
                        loading = false
                    }
                    Config.log("✅ Loaded call history from API", category: "Evidence")
                } else {
                    Config.log("⚠️ API succeeded but data is nil", category: "Evidence")
                    await MainActor.run {
                        actualCalls = []
                        callHistory = []
                        loading = false
                    }
                    Config.log("📊 Showing empty call history", category: "Evidence")
                }
            } else {
                Config.log("❌ API failed: success=\(response.success), error=\(response.error ?? "none")", category: "Evidence")
                // Fallback to mock data
                await MainActor.run {
                    callHistory = createMockCallHistory()
                    loading = false
                }
                Config.log("📊 Using mock call history data", category: "Evidence")
            }
        } catch {
            await MainActor.run {
                // Fallback to mock data on error
                callHistory = createMockCallHistory()
                loadError = nil
                loading = false
            }
            Config.log("❌ Failed to load call history: \(error)", category: "Evidence")
        }
    }
    
    private func convertToCallHistoryItems(_ calls: [CallLogEntry]) -> [CallHistoryItem] {
        return calls.map { call in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            // Use createdAt since startedAt was removed
            let dateStr = formatter.string(from: call.createdAt)

            formatter.dateFormat = "HH:mm"
            let timeStr = formatter.string(from: call.createdAt)

            return CallHistoryItem(
                id: call.id,
                date: dateStr,
                time: timeStr,
                duration: (call.durationSec ?? 0) / 60,
                promisesAnalyzed: call.promisesAnalyzed ?? 0,
                promisesBroken: call.promisesBroken ?? 0,
                promisesKept: call.promisesKept ?? 0,
                worstExcuse: call.worstExcuse
                // brutalReview removed (bloat elimination)
            )
        }
    }

    // MARK: - Hero Evidence Card

    private var heroEvidenceCard: some View {
        VStack(spacing: 10) {
            Text("pattern detected")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(white: 0.85, opacity: 1.0))

            Text(dominantPattern)
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
                .tracking(2)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 250)
        .background(Color.black)
        .padding(.horizontal, 20)
    }

    // MARK: - Assessment Card

    private var assessmentCard: some View {
        VStack {
            Text(evidenceAssessment)
                .font(.system(size: 35, weight: .black))
                .foregroundColor(.white)
                .tracking(4)
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100)
        .background(Color(hex: "#B22222"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#dd2a2a"), lineWidth: 2)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                statCard(
                    value: "\(callHistory.count)",
                    label: "CALLS",
                    backgroundColor: Color(hex: "#C8E6C9"),
                    borderColor: Color(hex: "#88a88a"),
                    textColor: .black
                )

                statCard(
                    value: "\(totalBroken)",
                    label: "BROKEN",
                    backgroundColor: Color(hex: "#DC143C"),
                    borderColor: Color(hex: "#8B0000"),
                    textColor: .white
                )
            }

            HStack(spacing: 8) {
                statCard(
                    value: "\(patternsIdentified)",
                    label: "PATTERNS",
                    backgroundColor: Color(hex: "#FFD700"),
                    borderColor: Color(hex: "#B8860B"),
                    textColor: .black
                )

                statCard(
                    value: "\(successRate)%",
                    label: "SUCCESS",
                    backgroundColor: Color(hex: "#8B00FF"),
                    borderColor: Color(hex: "#4B0082"),
                    textColor: .white
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    private func statCard(value: String, label: String, backgroundColor: Color, borderColor: Color, textColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 48, weight: .black))
                .foregroundColor(textColor)
                .tracking(2)

            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(textColor.opacity(0.8))
                .tracking(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 130)
        .padding(16)
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 3)
        )
    }

    // MARK: - Recent Evidence List

    private var recentEvidenceList: some View {
        VStack(spacing: 12) {
            ForEach(callHistory.prefix(7)) { call in
                evidenceCard(call: call)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
    }


    private func evidenceCard(call: CallHistoryItem) -> some View {
        let isFail = call.promisesBroken > 0
        let bgColor = isFail ? Color(hex: "#DC143C") : Color(hex: "#C8E6C9")
        let borderColor = isFail ? Color(hex: "#8B0000") : Color(hex: "#88a88a")
        let textColor = isFail ? Color.white : Color.black

        return HStack(alignment: .center, spacing: 12) {
            // Date
                Text(formatDateShort(call.date))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textColor)
                    .tracking(1)
                .frame(width: 80, alignment: .leading)

            // Status
                Text(isFail ? "FAIL" : "PASS")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(textColor)
                    .tracking(2)
                .frame(width: 50, alignment: .center)

            // Brief text preview
            Text((call.worstExcuse?.prefix(60) ?? "Call completed") + "...")
                .font(.system(size: 13, weight: .medium))
                    .foregroundColor(textColor)
                    .lineSpacing(4)
                    .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 3)
        )
        .onTapGesture {
            selectedCall = call
            showDetailModal = true
        }
    }

    // MARK: - Computed Properties

    private var dominantPattern: String {
        if callHistory.isEmpty { return "NO EVIDENCE" }

        // Simplified: Show most common excuse instead
        let excuses = callHistory.compactMap { $0.worstExcuse }
        if excuses.isEmpty {
            return "BUILDING HISTORY"
        }

        // Return first excuse as placeholder
        return excuses.first?.uppercased() ?? "ANALYZING PATTERNS"
    }

    private var evidenceAssessment: String {
        if callHistory.isEmpty { return "PATHETIC" }

        let rate = successRate
        if rate >= 80 { return "RELIABLE EVIDENCE" }
        if rate >= 60 { return "MIXED EVIDENCE" }
        if rate >= 40 { return "FAILURE EVIDENCE" }
        if rate >= 20 { return "DAMNING EVIDENCE" }
        return "HOPELESS CASE"
    }

    private var totalBroken: Int {
        callHistory.reduce(0) { $0 + $1.promisesBroken }
    }

    private var totalKept: Int {
        callHistory.reduce(0) { $0 + $1.promisesKept }
    }

    private var totalPromises: Int {
        callHistory.reduce(0) { $0 + $1.promisesAnalyzed }
    }

    private var successRate: Int {
        guard totalPromises > 0 else { return 0 }
        return Int((Double(totalKept) / Double(totalPromises)) * 100)
    }

    private var patternsIdentified: Int {
        callHistory.filter { $0.worstExcuse != nil }.count
    }


    private func formatDateShort(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "TODAY"
        } else if calendar.isDateInYesterday(date) {
            return "YESTERDAY"
        } else {
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "MMM d"
            return shortFormatter.string(from: date).uppercased()
        }
    }


    private func loadCallHistory() async -> [CallHistoryItem] {
        // Try to load real call history from API first
        guard let userId = AuthService.shared.user?.id else {
            Config.log("❌ No authenticated user for call history", category: "Evidence")
            return createMockCallHistory()
        }
        
        do {
            let response = try await APIService.shared.fetchCallHistory(userId: userId)
            if response.success, let calls = response.data {
                Config.log("✅ Loaded call history from API", category: "Evidence")
                return calls.map { call in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    // Use createdAt since startedAt was removed
                    let dateStr = formatter.string(from: call.createdAt)

                    formatter.dateFormat = "HH:mm"
                    let timeStr = formatter.string(from: call.createdAt)

                    return CallHistoryItem(
                        id: call.id,
                        date: dateStr,
                        time: timeStr,
                        duration: (call.durationSec ?? 0) / 60,
                        promisesAnalyzed: call.promisesAnalyzed ?? 0,
                        promisesBroken: call.promisesBroken ?? 0,
                        promisesKept: call.promisesKept ?? 0,
                        worstExcuse: call.worstExcuse
                        // brutalReview removed (bloat elimination)
                    )
                }
            }
        } catch {
            Config.log("❌ Failed to load call history from API: \(error)", category: "Evidence")
        }
        
        // Fallback to mock data
        Config.log("📊 Using mock call history data", category: "Evidence")
        return createMockCallHistory()
    }
    
    private func createMockCallHistory() -> [CallHistoryItem] {
        // Comprehensive mock data for testing multiple scenarios
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: today)!

        return [
            // TODAY - Mixed results with brutal review
            CallHistoryItem(
                id: "today-morning",
                date: formatter.string(from: today),
                time: "08:30",
                duration: 15,
                promisesAnalyzed: 4,
                promisesBroken: 2,
                promisesKept: 2,
                worstExcuse: "I didn't have time this morning",
            ),

            // YESTERDAY - Perfect day
            CallHistoryItem(
                id: "yesterday-evening",
                date: formatter.string(from: yesterday),
                time: "21:15",
                duration: 12,
                promisesAnalyzed: 3,
                promisesBroken: 0,
                promisesKept: 3,
                worstExcuse: nil,
                
            ),

            // TWO DAYS AGO - Complete failure with rage
            CallHistoryItem(
                id: "two-days-ago",
                date: formatter.string(from: twoDaysAgo),
                time: "19:45",
                duration: 8,
                promisesAnalyzed: 5,
                promisesBroken: 5,
                promisesKept: 0,
                worstExcuse: "Everything went wrong today, not my fault",
            ),

            // THREE DAYS AGO - Partial success
            CallHistoryItem(
                id: "three-days-ago",
                date: formatter.string(from: threeDaysAgo),
                time: "07:15",
                duration: 10,
                promisesAnalyzed: 3,
                promisesBroken: 1,
                promisesKept: 2,
                worstExcuse: "I forgot about that one",
                
            ),

            // FOUR DAYS AGO - Good day with despair trigger
            CallHistoryItem(
                id: "four-days-ago",
                date: formatter.string(from: fourDaysAgo),
                time: "20:30",
                duration: 14,
                promisesAnalyzed: 4,
                promisesBroken: 0,
                promisesKept: 4,
                worstExcuse: nil,
            ),

            // FIVE DAYS AGO - Mixed with excuse pattern
            CallHistoryItem(
                id: "five-days-ago",
                date: formatter.string(from: Calendar.current.date(byAdding: .day, value: -5, to: today)!),
                time: "18:20",
                duration: 11,
                promisesAnalyzed: 3,
                promisesBroken: 1,
                promisesKept: 2,
                worstExcuse: "I was overwhelmed with work",
            ),

            // SIX DAYS AGO - Good streak building
            CallHistoryItem(
                id: "six-days-ago",
                date: formatter.string(from: Calendar.current.date(byAdding: .day, value: -6, to: today)!),
                time: "08:00",
                duration: 13,
                promisesAnalyzed: 3,
                promisesBroken: 0,
                promisesKept: 3,
                worstExcuse: nil,
                
            )
        ]
    }

    // MARK: - Loading & Error Views

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)

            Text("Loading evidence...")
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
                    await loadCallHistory(forceRefresh: true)
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

// MARK: - Evidence Detail Modal

struct EvidenceDetailModal: View {
    let call: CallHistoryItem
    let onDismiss: () -> Void

    private func formatDateShort(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "TODAY"
        } else if calendar.isDateInYesterday(date) {
            return "YESTERDAY"
        } else {
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "MMM d"
            return shortFormatter.string(from: date).uppercased()
        }
    }

    var body: some View {
        ZStack {
            Color.brutalBlack
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Text(formatDateShort(call.date))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(2)

                        Spacer()

                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    // Status and duration
                    HStack {
                        Text(call.promisesBroken > 0 ? "FAIL" : "PASS")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(call.promisesBroken > 0 ? Color(hex: "#DC143C") : Color(hex: "#4CAF50"))
                            .tracking(2)

                        Spacer()

                        Text("\(call.duration)min")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    // Promise breakdown
                    if call.promisesAnalyzed > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PROMISE BREAKDOWN")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(1)

                            HStack(spacing: 20) {
                                statItem(label: "Analyzed", value: call.promisesAnalyzed, color: .white.opacity(0.7))
                                statItem(label: "Kept", value: call.promisesKept, color: Color(hex: "#4CAF50"))
                                statItem(label: "Broken", value: call.promisesBroken, color: Color(hex: "#F44336"))
                            }
                        }
                    }

                    // Content
                    if let excuse = call.worstExcuse {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EXCUSE USED")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(2)

                            Text("\"\(excuse)\"")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .italic()
                                .lineSpacing(6)
                        }
                    }

                    Spacer()
                }
                .padding(20)
            }
        }
    }

    private func statItem(label: String, value: Int, color: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color.opacity(0.8))
                .tracking(1)
        }
    }

}

#Preview {
    EvidenceDetailModal(
        call: CallHistoryItem(
            id: "test",
            date: Date().addingTimeInterval(-86400).description,
            time: "08:30",
            duration: 12,
            promisesAnalyzed: 3,
            promisesBroken: 1,
            promisesKept: 2,
            worstExcuse: "I was too tired",
        ),
        onDismiss: {}
    )
}

#Preview {
    EvidenceView()
        .environmentObject(AuthService.shared)
}
