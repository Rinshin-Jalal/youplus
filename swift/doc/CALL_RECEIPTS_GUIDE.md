# 📋 Call Receipts & Evidence Screen Implementation Guide

## Overview
Backend has a comprehensive **Call Receipts API** that provides "receipt-based accountability display" with call history grouped by date. Swift app needs to integrate this for the Evidence screen.

## 🔍 Research Findings

### ❌ NO Shareable Screenshot Feature in RN App
After thorough search, the RN app does **NOT** have:
- Screenshot/image export functionality (`react-native-view-shot`, `expo-sharing`, etc.)
- Share buttons after calls
- Receipt image generation
- Social media sharing

The term "receipt" refers to the **data format** for accountability display, NOT an actual shareable image.

### ✅ Backend API EXISTS
**Endpoint:** `GET /call-log/receipts/:userId`

Located in: `/be/dist/routes/call-log.js` (lines 127-215)

## 📊 Backend API Details

### Response Structure

```json
{
  "success": true,
  "data": {
    "receiptsByDate": {
      "Mon Oct 06 2025": [
        {
          "id": "call-uuid",
          "type": "morning",
          "status": "ANSWERED",
          "time": "08:30:45 AM",
          "duration": 420,
          "transcript": "Full conversation transcript...",
          "enforcement": {
            "apology_required": true,
            "escalation_level": 2,
            "broken_promises": ["gym", "project deadline"]
          },
          "confidenceScores": {
            "truthfulness": 0.72,
            "commitment": 0.45
          }
        }
      ],
      "Sun Oct 05 2025": [...]
    },
    "enforcementSummary": {
      "totalEnforcementEvents": 5,
      "apologyRequired": 3,
      "escalationEvents": 2
    },
    "accountability": {
      "totalCallsScheduled": 30,
      "callsAnswered": 17,
      "callsMissed": 13,
      "complianceRate": 57
    }
  }
}
```

### Key Features
- **Date-grouped receipts**: Calls organized by date for calendar view
- **Enforcement tracking**: Identifies when user broke promises/needed escalation
- **Compliance metrics**: Answer rate, missed calls, accountability stats
- **Transcript storage**: Full conversation text for each call
- **Confidence scores**: AI-generated truthfulness/commitment ratings

## 🎯 What RN App Does (history.tsx)

The React Native history screen shows:

1. **Hero Evidence Card**: Displays dominant failure pattern
   ```
   CHRONIC EXCUSE-MAKER
   ```

2. **Assessment Card**: Brutal judgment
   ```
   PATHETIC
   ```

3. **Stats Grid**: 4 cards showing
   - Total calls
   - Broken promises
   - Patterns identified
   - Success rate %

4. **Evidence Cards**: Recent calls with:
   - Date (TODAY, YESTERDAY, etc.)
   - Status (PASS/FAIL based on broken promises)
   - Brutal review paragraph
   - Color-coded (red for fail, green for pass)

## 🛠️ Implementation Plan for Swift App

### 1. Update APIModels.swift

Add call receipt models:

```swift
// MARK: - Call Receipts

struct CallReceiptsResponse: Codable {
    let success: Bool
    let data: CallReceiptsData?
}

struct CallReceiptsData: Codable {
    let receiptsByDate: [String: [CallReceipt]]
    let enforcementSummary: EnforcementSummary
    let accountability: AccountabilityMetrics
}

struct CallReceipt: Codable {
    let id: String
    let type: String
    let status: String // "ANSWERED" or "MISSED"
    let time: String
    let duration: Int
    let transcript: String?
    let enforcement: EnforcementData?
    let confidenceScores: ConfidenceScores?
}

struct EnforcementData: Codable {
    let apologyRequired: Bool?
    let escalationLevel: Int?
    let brokenPromises: [String]?

    enum CodingKeys: String, CodingKey {
        case apologyRequired = "apology_required"
        case escalationLevel = "escalation_level"
        case brokenPromises = "broken_promises"
    }
}

struct ConfidenceScores: Codable {
    let truthfulness: Double?
    let commitment: Double?
}

struct EnforcementSummary: Codable {
    let totalEnforcementEvents: Int
    let apologyRequired: Int
    let escalationEvents: Int
}

struct AccountabilityMetrics: Codable {
    let totalCallsScheduled: Int
    let callsAnswered: Int
    let callsMissed: Int
    let complianceRate: Int
}
```

### 2. Update APIService.swift

Add call receipts endpoint:

```swift
// MARK: - Call Receipts

func fetchCallReceipts(userId: String) async throws -> CallReceiptsResponse {
    return try await request(
        endpoint: "/call-log/receipts/\(userId)",
        method: .GET,
        responseType: CallReceiptsResponse.self
    )
}

func fetchCallReceiptsWithCache(
    userId: String,
    forceRefresh: Bool = false
) async throws -> CallReceiptsResponse {
    let cacheKey = "call_receipts_\(userId)"

    if !forceRefresh, let cached: CallReceiptsResponse = DataStore.shared.load(
        forKey: cacheKey,
        as: CallReceiptsResponse.self
    ) {
        Config.log("📦 Using cached call receipts", category: "Cache")
        return cached
    }

    let response = try await fetchCallReceipts(userId: userId)

    // Cache for 1 minute (call data changes frequently)
    DataStore.shared.save(response, forKey: cacheKey, ttl: 60)

    return response
}
```

### 3. Update EvidenceView.swift

Replace test data with real API calls:

```swift
@State private var receiptsByDate: [String: [CallReceipt]] = [:]
@State private var enforcementSummary: EnforcementSummary?
@State private var accountability: AccountabilityMetrics?

@MainActor
private func loadCallReceipts(forceRefresh: Bool = false) async {
    guard let userId = authService.user?.id else {
        Config.log("No user ID for call receipts", category: "Evidence")
        return
    }

    isLoading = true

    do {
        let response = try await APIService.shared.fetchCallReceiptsWithCache(
            userId: userId,
            forceRefresh: forceRefresh
        )

        if response.success, let data = response.data {
            receiptsByDate = data.receiptsByDate
            enforcementSummary = data.enforcementSummary
            accountability = data.accountability

            Config.log("✅ Loaded \(receiptsByDate.count) days of call receipts", category: "Evidence")
        }

        isLoading = false
    } catch {
        Config.log("❌ Failed to load call receipts: \(error)", category: "Evidence")
        isLoading = false
    }
}

// Add pull-to-refresh
.refreshable {
    await loadCallReceipts(forceRefresh: true)
}
```

### 4. Add Call Data Cards UI

Similar to RN history.tsx, create expandable cards per day:

```swift
// Hero Pattern Card
VStack {
    Text("PATTERN DETECTED")
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(.white.opacity(0.8))

    Text(getDominantPattern())
        .font(.system(size: 32, weight: .black))
        .foregroundColor(.white)
        .tracking(2)
}
.padding(40)
.background(Color.brutalBlack)

// Stats Grid
LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
    StatCard(
        value: "\(accountability?.totalCallsScheduled ?? 0)",
        label: "CALLS",
        color: .green
    )

    StatCard(
        value: "\(enforcementSummary?.totalEnforcementEvents ?? 0)",
        label: "ENFORCED",
        color: .brutalRed
    )

    StatCard(
        value: "\(accountability?.complianceRate ?? 0)%",
        label: "COMPLIANCE",
        color: .neonGreen
    )
}

// Call Cards by Date
ForEach(sortedDates(), id: \.self) { date in
    VStack(alignment: .leading, spacing: 8) {
        Text(formatDate(date))
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)

        ForEach(receiptsByDate[date] ?? [], id: \.id) { receipt in
            CallReceiptCard(receipt: receipt)
        }
    }
}
```

### 5. Optional: Shareable Screenshot Feature

**Only implement if explicitly requested by user.**

If you want post-call shareables (like "I answered my accountability call today"):

```swift
// Add to CallScreen or post-call view
import UIKit

func generateCallReceiptImage() -> UIImage? {
    // Create receipt view
    let receiptView = CallReceiptView(
        status: "ANSWERED",
        duration: "7:23",
        date: Date(),
        compliance: 85
    )

    // Render to image
    let renderer = UIGraphicsImageRenderer(size: receiptView.frame.size)
    return renderer.image { ctx in
        receiptView.layer.render(in: ctx.cgContext)
    }
}

// Share button
Button("Share Receipt") {
    if let image = generateCallReceiptImage() {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        // Present share sheet
    }
}
```

## 📋 API Endpoints Summary

### Available Now
- `GET /call-log/receipts/:userId` - Call receipts grouped by date ✅
- `GET /call-log/history/:userId?limit=50&offset=0` - Full call history ✅
- `GET /call-log/weekly/:userId` - This week's summary ✅
- `POST /call-log/transcript` - Store call transcript ✅

## 🎨 UI Design Notes

Match RN app patterns:
- **Red cards** = Calls with broken promises
- **Green cards** = Successful calls
- **Bold uppercase text** = Brutal, no-nonsense style
- **Dark backgrounds** = Black (#000000)
- **Accent colors** = Neon green (#90FD0E) for success, red (#DC143C) for failure

## 🚀 Next Steps

1. ✅ Research complete - found call receipts API
2. ⏭️ Add `CallReceipt` models to APIModels.swift
3. ⏭️ Add `fetchCallReceipts()` to APIService.swift
4. ⏭️ Update EvidenceView.swift to fetch real data
5. ⏭️ Build call receipt cards UI (matching RN style)
6. ⏭️ Decide if shareable screenshot feature is needed

---

**Status:** 🔍 RESEARCH COMPLETE - Ready for implementation

**Last Updated:** 2025-10-06
