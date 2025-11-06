//
//  HomeTabView.swift
//  bigbruhh
//
//  Main tab view container with 2 tabs: FACE, CONTROL (Super MVP)
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var navigator: AppNavigator

    var body: some View {
        TabView {
            // Tab 1: FACE (Home/Dashboard)
            FaceView()
                .tabItem {
                    Label("FACE", systemImage: "waveform.path.ecg")
                }

            // Tab 2: CONTROL (Settings)
            ControlView()
                .tabItem {
                    Label("CONTROL", systemImage: "gearshape")
                }
        }
        .accentColor(Color.brutalRed)
        .onAppear {
            // Configure tab bar appearance - BRUTAL DESIGN
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black

            // Unselected tab color - DIMMED
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.3, alpha: 1.0)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor(white: 0.3, alpha: 1.0)
            ]

            // Selected tab color - BRUTAL RED
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 1.0, green: 0.0, blue: 0.2, alpha: 1.0)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(red: 1.0, green: 0.0, blue: 0.2, alpha: 1.0),
                .font: UIFont.systemFont(ofSize: 10, weight: .bold)
            ]

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    HomeTabView()
        .environmentObject(AppNavigator())
}
