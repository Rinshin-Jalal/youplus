//
//  RevenueCatService.swift
//  bigbruhh
//
//  RevenueCat singleton service for subscription management
//

import Foundation
import Combine
import RevenueCat
import Auth

class RevenueCatService: NSObject, ObservableObject {
    static let shared = RevenueCatService()

    // MARK: - Published Properties

    @Published var customerInfo: CustomerInfo?
    @Published var currentOffering: Offering?
    @Published var isLoading: Bool = true
    @Published var subscriptionStatus: SubscriptionStatus = SubscriptionStatus()

    // MARK: - Subscription Status

    struct SubscriptionStatus {
        var isActive: Bool = false
        var isEntitled: Bool = false
        var productId: String?
        var expirationDate: Date?
        var willRenew: Bool = false
        var managementURL: URL?
    }

    // MARK: - Initialization

    private override init() {
        super.init()

        // Skip configuration in preview mode
        if Config.isPreview {
            Config.log("⚠️ RevenueCat: Skipping configuration in preview mode", category: "RevenueCat")
            isLoading = false
            return
        }

        configure()
    }

    // MARK: - Configuration

    func configure() {
        // Skip in preview mode
        if Config.isPreview {
            return
        }

        #if DEBUG
        Purchases.logLevel = .debug
        #endif

        Purchases.configure(withAPIKey: Config.revenueCatAPIKey)

        // Add listener for customer info updates
        Purchases.shared.delegate = self

        // Fetch initial data
        Task { @MainActor in
            print("🔄 RevenueCat: Starting to fetch offerings...")
            await fetchCustomerInfo()
            await fetchOfferings()
            print("🔄 RevenueCat: Finished fetching. Setting isLoading = false")
            isLoading = false
        }
    }

    // MARK: - Customer Info

    @MainActor
    func fetchCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            customerInfo = info
            updateSubscriptionStatus(info)
            print("✅ Customer info fetched: \(info.originalAppUserId)")
        } catch {
            print("❌ Failed to fetch customer info: \(error)")
        }
    }

    @MainActor
    private func updateSubscriptionStatus(_ info: CustomerInfo) {
        #if DEBUG
        // Development mode: Always entitled
        subscriptionStatus = SubscriptionStatus(
            isActive: true,
            isEntitled: true,
            productId: "dev_override_premium",
            expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60),
            willRenew: true,
            managementURL: nil
        )
        print("🔧 DEV MODE: Subscription always active")
        #else
        // Production logic
        let activeEntitlements = info.entitlements.active
        let isEntitled = !activeEntitlements.isEmpty

        if isEntitled, let firstEntitlement = activeEntitlements.first?.value {
            subscriptionStatus = SubscriptionStatus(
                isActive: true,
                isEntitled: true,
                productId: firstEntitlement.productIdentifier,
                expirationDate: firstEntitlement.expirationDate,
                willRenew: firstEntitlement.willRenew,
                managementURL: info.managementURL
            )
            print("✅ Subscription active: \(firstEntitlement.productIdentifier)")
        } else {
            subscriptionStatus = SubscriptionStatus(
                isActive: false,
                isEntitled: false
            )
            print("❌ No active subscription")
        }
        #endif
    }

    // MARK: - Offerings

    @MainActor
    func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
            print("✅ Offerings fetched: \(offerings.current?.availablePackages.count ?? 0) packages")
        } catch {
            print("❌ Failed to fetch offerings: \(error)")
        }
    }

    // MARK: - Purchase

    @MainActor
    func purchase(package: Package) async throws -> CustomerInfo {
        do {
            let (_, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)

            if userCancelled {
                throw RevenueCatError.userCancelled
            }

            self.customerInfo = customerInfo
            updateSubscriptionStatus(customerInfo)

            print("✅ Purchase successful: \(package.storeProduct.productIdentifier)")
            return customerInfo

        } catch let error as RevenueCat.ErrorCode {
            if error == RevenueCat.ErrorCode.purchaseCancelledError {
                throw RevenueCatError.userCancelled
            }
            print("❌ Purchase failed: \(error.localizedDescription)")
            throw RevenueCatError.purchaseFailed(error.localizedDescription)
        } catch {
            print("❌ Purchase failed: \(error)")
            throw error
        }
    }

    // MARK: - Restore

    @MainActor
    func restorePurchases() async throws -> CustomerInfo {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            self.customerInfo = customerInfo
            updateSubscriptionStatus(customerInfo)
            print("✅ Purchases restored")
            return customerInfo
        } catch {
            print("❌ Restore failed: \(error)")
            throw error
        }
    }

    // MARK: - User Identification

    func identify(userId: String) async {
        do {
            let (customerInfo, _) = try await Purchases.shared.logIn(userId)
            await MainActor.run {
                self.customerInfo = customerInfo
                updateSubscriptionStatus(customerInfo)
            }
            print("✅ User identified: \(userId)")

            // Sync subscription status to backend after identification
            await syncSubscriptionStatusToBackend(customerInfo: customerInfo)
        } catch {
            print("❌ Failed to identify user: \(error)")
        }
    }

    func logout() async {
        do {
            let customerInfo = try await Purchases.shared.logOut()
            await MainActor.run {
                self.customerInfo = customerInfo
                updateSubscriptionStatus(customerInfo)
            }
            print("✅ User logged out")
        } catch {
            print("❌ Logout failed: \(error)")
        }
    }

    // MARK: - Helpers

    var hasActiveSubscription: Bool {
        return subscriptionStatus.isActive && subscriptionStatus.isEntitled
    }

    var isSubscribed: Bool {
        return hasActiveSubscription
    }

    // MARK: - Backend Sync

    /// Sync subscription status to backend
    @MainActor
    func syncSubscriptionStatusToBackend(customerInfo: CustomerInfo? = nil) async {
        let info = customerInfo ?? self.customerInfo

        guard let info = info else {
            print("⚠️ No customer info available to sync")
            return
        }

        // Get current user ID
        guard let userId = SupabaseManager.shared.currentUser?.id.uuidString else {
            print("⚠️ No authenticated user - skipping subscription sync")
            return
        }

        // Determine subscription status
        let activeEntitlements = info.entitlements.active
        let isEntitled = !activeEntitlements.isEmpty
        let isActive = isEntitled // Active if entitled

        print("🔄 Syncing subscription status to backend:")
        print("   User ID: \(userId)")
        print("   RevenueCat Customer ID: \(info.originalAppUserId)")
        print("   Is Active: \(isActive)")
        print("   Is Entitled: \(isEntitled)")

        do {
            // Sync subscription status
            let statusResponse = try await APIService.shared.updateSubscriptionStatus(
                isActive: isActive,
                isEntitled: isEntitled,
                revenuecatCustomerId: info.originalAppUserId
            )

            if statusResponse.success {
                print("✅ Subscription status synced successfully")
            } else {
                print("⚠️ Subscription status sync failed: \(statusResponse.error ?? "Unknown error")")
            }

            // Also sync customer ID separately (in case status endpoint fails)
            let customerIdResponse = try await APIService.shared.updateRevenueCatCustomerId(
                originalAppUserId: info.originalAppUserId
            )

            if customerIdResponse.success {
                print("✅ RevenueCat customer ID synced successfully")
            } else {
                let errorMsg = customerIdResponse.error ?? "Unknown error"
                print("⚠️ RevenueCat customer ID sync failed: \(errorMsg)")
            }

        } catch {
            print("❌ Failed to sync subscription status to backend: \(error)")
        }
    }
}

// MARK: - Purchases Delegate

extension RevenueCatService: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            let oldExpiration = self.customerInfo?.entitlements.active.first?.value.expirationDate
            let oldProductId = self.customerInfo?.entitlements.active.first?.value.productIdentifier
            
            self.customerInfo = customerInfo
            updateSubscriptionStatus(customerInfo)
            
            // Check if subscription renewed
            if let oldExpiration = oldExpiration,
               let newExpiration = customerInfo.entitlements.active.first?.value.expirationDate,
               newExpiration > oldExpiration,
               let productId = customerInfo.entitlements.active.first?.value.productIdentifier {
                
                // Subscription renewed - track renewal event
                // Note: Revenue amount would need to come from StoreKit product price
                AnalyticsService.shared.track(event: "subscription_renewed", properties: [
                    "product_id": productId,
                    "renewal_count": (customerInfo.entitlements.active.first?.value.willRenew == true ? 1 : 0)
                ])
                
                // Increment renewal count
                AnalyticsService.shared.incrementUserProperty("subscription_renewal_count", by: 1)
            }
            
            // Check if subscription expired
            if let oldProductId = oldProductId,
               customerInfo.entitlements.active.isEmpty {
                // Subscription expired
                AnalyticsService.shared.track(event: "subscription_expired", properties: [
                    "product_id": oldProductId
                ])
                
                AnalyticsService.shared.setUserProperties([
                    "subscription_active": false
                ])
            }

            // Sync to backend when subscription status changes
            await syncSubscriptionStatusToBackend(customerInfo: customerInfo)
        }
    }
}

// MARK: - Errors

enum RevenueCatError: LocalizedError {
    case userCancelled
    case purchaseFailed(String)
    case packageNotFound

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Purchase was cancelled"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .packageNotFound:
            return "No weekly subscription package found"
        }
    }
}

