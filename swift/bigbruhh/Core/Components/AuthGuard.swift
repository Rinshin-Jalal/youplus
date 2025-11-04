//
//  AuthGuard.swift
//  bigbruhh
//
//  Authentication guard wrapper for protected pages
//  Redirects to welcome screen if user is not authenticated
//

import SwiftUI

struct AuthGuard<Content: View>: View {
    @EnvironmentObject var authService: AuthService
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                content
            } else {
                WelcomeView()
            }
        }
        .onAppear {
            // Ensure auth state is up to date
            Task {
                await authService.checkAuthStatus()
            }
        }
    }
}

// MARK: - Convenience Extensions

extension View {
    func requiresAuth() -> some View {
        AuthGuard {
            self
        }
    }
}
