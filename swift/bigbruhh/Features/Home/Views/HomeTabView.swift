//
//  HomeTabView.swift
//  bigbruhh
//
//  Main tab view container with 3 tabs: FACE, EVIDENCE, CONTROL
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

            // Tab 2: EVIDENCE (History)
            EvidenceView()
                .tabItem {
                    Label("EVIDENCE", systemImage: "doc.text")
                }

            // Tab 3: CONTROL (Settings)
            ControlView()
                .tabItem {
                    Label("CONTROL", systemImage: "gearshape")
                }
        }
        .accentColor(Color.brutalRed)
        .onAppear {
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black

            // Unselected tab color
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.4, alpha: 1.0)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold)
            ]

            // Selected tab color (white)
            appearance.stackedLayoutAppearance.selected.iconColor = .white
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.white,
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
