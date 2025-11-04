//
//  EntryView.swift
//  bigbruhh
//
//  Main entry point view handling authentication flow
//

import SwiftUI

// DEPRECATED - Use RootView instead
// This file is kept for backwards compatibility but should not be used

struct EntryView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    EntryView()
        .environmentObject(AuthService.shared)
}
