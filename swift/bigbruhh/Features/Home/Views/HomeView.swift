//
//  HomeView.swift
//  bigbruhh
//
//  Main home screen - now using HomeTabView with 3 tabs
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigator: AppNavigator

    var body: some View {
        HomeTabView()
            .environmentObject(navigator)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppNavigator())
}
