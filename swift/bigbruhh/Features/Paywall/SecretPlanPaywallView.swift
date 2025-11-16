//
//  SecretPlanPaywallView.swift
//  bigbruhh
//
//  Secret Plan Paywall - $2.99/week Starter Package
//  Apple Quick Action: "Get first month for $2.99"
//  After purchase, user goes through onboarding but ends at celebration instead of call flow
//  Matches NRN secret-plan.tsx implementation
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct SecretPlanPaywallView: View {
    @EnvironmentObject var navigator: AppNavigator
    @EnvironmentObject var revenueCat: RevenueCatService
    @Environment(\.dismiss) private var dismiss

    let userName: String?
    let source: String
    let onPurchaseComplete: (() -> Void)?
    let onDecline: (() -> Void)?

    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var secretPlanOffering: Offering?

    init(
        userName: String? = "BigBruh",
        source: String = "quick_action",
        onPurchaseComplete: (() -> Void)? = nil,
        onDecline: (() -> Void)? = nil
    ) {
        self.userName = userName
        self.source = source
        self.onPurchaseComplete = onPurchaseComplete
        self.onDecline = onDecline
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .tint(.primary)
                        .scaleEffect(2.0)

                    Text("Loading subscription plans...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            } else if let offering = secretPlanOffering {
                // RevenueCat's native PaywallView with specific Secret Plan offering
                RevenueCatUI.PaywallView(offering: offering)
                    .onPurchaseCompleted { customerInfo in
                        handlePurchaseCompleted(customerInfo)
                    }
                    .onPurchaseCancelled {
                        handlePurchaseCancelled()
                    }
                    .onRestoreFailure { error in
                        handlePurchaseError(error)
                    }
                    .onRequestedDismissal {
                        handleDismiss()
                    }
            } else {
                // Error state
                VStack(spacing: 20) {
                    Text("❌")
                        .font(.system(size: 48))
                    
                    Text("Failed to load subscription plans")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        loadOffering()
                    }
                    .padding()
                    .background(Color.primary)
                    .foregroundColor(Color(.systemBackground))
                    .cornerRadius(8)
                }
                .padding()
            }
        }
        .preferredColorScheme(nil) // Use device's theme (dark/light)
        .onAppear {
            loadOffering()
            trackSecretPaywallView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func loadOffering() {
        Task {
            do {
                // Fetch offerings from RevenueCat
                let offerings = try await Purchases.shared.offerings()
                
                // Find the "Secret Plan" offering
                if let secretOffering = offerings.offering(identifier: "Secret Plan") {
                    await MainActor.run {
                        secretPlanOffering = secretOffering
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Secret Plan offering not found"
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func trackSecretPaywallView() {
        // Track secret paywall view (matches NRN implementation)
        AnalyticsService.shared.track(event: "secret_paywall_viewed", properties: [
            "user_name": userName ?? "BigBruh",
            "source": source,
            "paywall_type": "secret_starter",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
        print("📊 Secret paywall viewed - userName: \(userName ?? "BigBruh"), source: \(source), paywall_type: secret_starter")
    }

    private func handlePurchaseCompleted(_ customerInfo: CustomerInfo) {
        print("💰 Secret plan purchase completed!")
        
        // Extract product information from active entitlements
        let productId = customerInfo.entitlements.active.first?.value.productIdentifier ?? "starter"
        let planPrice = 2.99 // Secret plan is $2.99/week
        
        // Track secret paywall purchase successful
        AnalyticsService.shared.track(event: "secret_paywall_purchase_successful", properties: [
            "user_name": userName ?? "BigBruh",
            "source": source,
            "paywall_type": "secret_starter",
            "plan_identifier": "starter",
            "plan_price": "$\(planPrice)",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
        
        // Track revenue
        AnalyticsService.shared.trackRevenue(
            amount: planPrice,
            productId: productId,
            currency: "USD",
            properties: [
                "user_name": userName ?? "BigBruh",
                "source": source,
                "paywall_type": "secret_starter",
                "plan_identifier": "starter"
            ]
        )
        
        print("📊 Secret paywall purchase successful - userName: \(userName ?? "BigBruh"), source: \(source), paywall_type: secret_starter")
        
        // Store plan type and purchase source (matches NRN AsyncStorage.setItem)
        UserDefaultsManager.set("starter", forKey: "plan_type")
        UserDefaultsManager.set(source, forKey: "purchase_source")
        
        // Set user properties
        AnalyticsService.shared.setUserProperties([
            "plan_type": "starter",
            "purchase_source": source,
            "subscription_active": true
        ])
        
        // Update RevenueCat customer info and sync to backend
        Task {
            await revenueCat.fetchCustomerInfo()
            
            // Sync subscription status to backend immediately after purchase
            await revenueCat.syncSubscriptionStatusToBackend(customerInfo: customerInfo)
        }
        
        // Call completion handler if provided
        if let onPurchaseComplete = onPurchaseComplete {
            onPurchaseComplete()
        }
        
        // Navigate to onboarding with starter plan (matches NRN router.push to /onboarding)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            navigator.showOnboarding(
                userName: userName ?? "BigBruh",
                planType: "starter",
                source: source
            )
        }
    }

    private func handlePurchaseCancelled() {
        print("💔 Secret plan purchase cancelled")
        
        // Track secret paywall purchase cancelled
        AnalyticsService.shared.track(event: "secret_paywall_purchase_cancelled", properties: [
            "user_name": userName ?? "BigBruh",
            "source": source,
            "paywall_type": "secret_starter",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
        
        print("📊 Secret paywall purchase cancelled - userName: \(userName ?? "BigBruh"), source: \(source), paywall_type: secret_starter")
    }

    private func handlePurchaseError(_ error: Error) {
        print("❌ Secret plan purchase failed: \(error)")
        
        // Track secret paywall purchase failed
        AnalyticsService.shared.track(event: "secret_paywall_purchase_failed", properties: [
            "user_name": userName ?? "BigBruh",
            "source": source,
            "paywall_type": "secret_starter",
            "error": error.localizedDescription,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
        
        print("📊 Secret paywall purchase failed - userName: \(userName ?? "BigBruh"), source: \(source), paywall_type: secret_starter")
        
        errorMessage = "Purchase failed. Please try again."
        showError = true
    }

    private func handleDismiss() {
        print("👋 User dismissed secret paywall")
        
        // Track secret paywall declined
        AnalyticsService.shared.track(event: "secret_paywall_declined", properties: [
            "user_name": userName ?? "BigBruh",
            "source": source,
            "plan_identifier": "starter",
            "plan_price": "$2.99",
            "paywall_type": "secret_starter",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
        
        print("📊 Secret paywall declined - userName: \(userName ?? "BigBruh"), source: \(source), paywall_type: secret_starter")
        
        // Call decline handler if provided
        if let onDecline = onDecline {
            onDecline()
        } else {
            // Default: navigate to home (matches NRN router.push("/"))
            navigator.navigateToHome()
        }
    }
}

#Preview {
    SecretPlanPaywallView(
        userName: "BigBruh",
        source: "quick_action"
    )
    .environmentObject(AppNavigator())
    .environmentObject(RevenueCatService.shared)
}
