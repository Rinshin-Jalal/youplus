//
//  RevenueCatPaywallView.swift
//  bigbruhh
//
//  RevenueCat native paywall using PaywallView from RevenueCatUI
//  Matches NRN implementation using react-native-purchases-ui
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    @EnvironmentObject var revenueCat: RevenueCatService
    @EnvironmentObject var onboardingData: OnboardingDataManager
    @Environment(\.dismiss) private var dismiss

    let source: String
    let onPurchaseComplete: () -> Void
    let onDismiss: () -> Void

    @State private var purchaseInProgress = false

    var body: some View {
        Group {
            // RevenueCat's native PaywallView
            if revenueCat.isLoading {
                PaywallLoadingView()
            } else if revenueCat.currentOffering != nil {
                // RevenueCat PaywallView
                RevenueCatUI.PaywallView()
                    .onPurchaseCompleted { customerInfo in
                        handlePurchaseCompleted(customerInfo)
                    }
                    .onPurchaseCancelled {
                        handlePurchaseCancelled()
                    }
                    .onRestoreCompleted { customerInfo in
                        handleRestoreCompleted(customerInfo)
                    }
                    .onRestoreFailure { error in
                        handleRestoreFailure(error)
                    }
                    .onRequestedDismissal {
                        handleDismiss()
                    }
            } else {
                PaywallErrorView(
                    message: "Failed to load subscription plans",
                    onRetry: {
                        Task {
                            await revenueCat.fetchOfferings()
                        }
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            trackPaywallView()
        }
        // Prevent any system subscription UI from appearing
        .environment(\.openURL, OpenURLAction { _ in
            .discarded // Block any URLs that might trigger system subscription UI
        })
    }

    // MARK: - Event Handlers

    private func handlePurchaseCompleted(_ customerInfo: CustomerInfo) {
        print("💰 Purchase completed!")
        
        // Extract product information from active entitlements
        let productId = customerInfo.entitlements.active.first?.value.productIdentifier ?? "unknown"
        
        // Get price from the purchased package (we need to get this from the offering)
        // For now, we'll extract from customerInfo active entitlements
        var revenue: Double = 0.0
        var currency: String = "USD"
        var subscriptionPeriod: String = "unknown"
        
        if let activeEntitlement = customerInfo.entitlements.active.first?.value {
            // Try to get price from the product identifier
            // Note: RevenueCat doesn't expose price directly, so we'll need to track it separately
            // For now, we'll use a placeholder and recommend getting price from StoreKit
            revenue = 0.0 // Will be set when we have access to Package.storeProduct.price
            currency = "USD"
            subscriptionPeriod = activeEntitlement.productIdentifier
        }
        
        // Track purchase event
        AnalyticsService.shared.track(event: "paywall_purchase_successful", properties: [
            "source": source,
            "plan_type": "normal",
            "product_id": productId,
            "user_name": onboardingData.userName ?? "N/A"
        ])
        
        // Track revenue if we have it (will be updated when we have Package info)
        if revenue > 0 {
            AnalyticsService.shared.trackRevenue(
                amount: revenue,
                productId: productId,
                currency: currency,
                properties: [
                    "source": source,
                    "plan_type": "normal",
                    "subscription_period": subscriptionPeriod
                ]
            )
        }
        
        triggerHaptic(intensity: 1.0)

        // Update local subscription state
        Task {
            await revenueCat.fetchCustomerInfo()
            
            // Sync subscription status to backend immediately after purchase
            await revenueCat.syncSubscriptionStatusToBackend(customerInfo: customerInfo)
        }

        // Store purchase info
        UserDefaultsManager.set("normal", forKey: "plan_type")
        UserDefaultsManager.set(source, forKey: "purchase_source")
        
        // Set user properties
        AnalyticsService.shared.setUserProperties([
            "plan_type": "normal",
            "purchase_source": source,
            "subscription_active": true
        ])

        onPurchaseComplete()
    }

    private func handlePurchaseCancelled() {
        print("💔 Purchase cancelled")
        AnalyticsService.shared.track(event: "paywall_purchase_cancelled", properties: [
            "source": source,
            "user_name": onboardingData.userName ?? "N/A"
        ])
        triggerHaptic(intensity: 0.5)
    }

    private func handleRestoreCompleted(_ customerInfo: CustomerInfo) {
        print("✅ Restore completed")
        
        // Extract product information from active entitlements
        let productId = customerInfo.entitlements.active.first?.value.productIdentifier ?? "unknown"
        
        AnalyticsService.shared.track(event: "paywall_restore_successful", properties: [
            "source": source,
            "product_id": productId,
            "user_name": onboardingData.userName ?? "N/A"
        ])
        
        triggerHaptic(intensity: 1.0)

        // Update local subscription state
        Task {
            await revenueCat.fetchCustomerInfo()
            
            // Sync subscription status to backend after restore
            await revenueCat.syncSubscriptionStatusToBackend(customerInfo: customerInfo)
        }

        if revenueCat.hasActiveSubscription {
            onPurchaseComplete()
        }
    }

    private func handleRestoreFailure(_ error: Error) {
        print("❌ Restore failed: \(error)")
        AnalyticsService.shared.track(event: "paywall_restore_failed", properties: [
            "source": source,
            "error": error.localizedDescription,
            "user_name": onboardingData.userName ?? "N/A"
        ])
    }

    private func handleDismiss() {
        print("👋 Paywall dismissed")
        AnalyticsService.shared.track(event: "paywall_declined", properties: [
            "source": source,
            "user_name": onboardingData.userName ?? "N/A"
        ])
        triggerHaptic(intensity: 0.5)
        onDismiss()
    }

    // MARK: - Analytics

    private func trackPaywallView() {
        AnalyticsService.shared.track(event: "paywall_viewed", properties: [
            "source": source,
            "user_name": onboardingData.userName ?? "N/A"
        ])
        print("👀 Paywall viewed - Source: \(source)")
    }

    private func trackEvent(_ eventName: String) {
        // Legacy method - now uses AnalyticsService
        AnalyticsService.shared.track(event: eventName, properties: [
            "source": source,
            "user_name": onboardingData.userName ?? "N/A"
        ])
    }

    // MARK: - Haptics

    private func triggerHaptic(intensity: Double = 0.5) {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: intensity > 0.8 ? .heavy : intensity > 0.5 ? .medium : .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Paywall Loading View

struct PaywallLoadingView: View {
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotationAngle))

                Circle()
                    .stroke(.white.opacity(0.5), lineWidth: 3)
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-rotationAngle * 1.5))

                Circle()
                    .stroke(.white.opacity(0.8), lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotationAngle * 2))

                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(pulseScale)
            }

            Text("Loading subscription plans...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.8))
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
        }
    }
}

// MARK: - Paywall Error View

struct PaywallErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text(message)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: onRetry) {
                Text("RETRY")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(1.5)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - Preview

#Preview {
    RevenueCatPaywallView(
        source: "onboarding",
        onPurchaseComplete: {
            print("Purchase completed")
        },
        onDismiss: {
            print("Dismissed")
        }
    )
    .environmentObject(OnboardingDataManager.shared)
}
