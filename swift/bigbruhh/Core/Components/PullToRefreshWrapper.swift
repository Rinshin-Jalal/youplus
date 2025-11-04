//
//  PullToRefreshWrapper.swift
//  bigbruhh
//
//  Pull-to-refresh wrapper for data fetching
//

import SwiftUI

struct PullToRefreshWrapper<Content: View>: View {
    let content: Content
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    
    init(onRefresh: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            content
                .refreshable {
                    await performRefresh()
                }
        } else {
            // Fallback for iOS 14
            content
                .onPullToRefresh(isRefreshing: $isRefreshing) {
                    await performRefresh()
                }
        }
    }
    
    private func performRefresh() async {
        await onRefresh()
    }
}

// MARK: - iOS 14 Fallback

struct PullToRefreshModifier: ViewModifier {
    @Binding var isRefreshing: Bool
    let onRefresh: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                if value > 100 && !isRefreshing {
                    Task {
                        isRefreshing = true
                        await onRefresh()
                        isRefreshing = false
                    }
                }
            }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func onPullToRefresh(isRefreshing: Binding<Bool>, onRefresh: @escaping () async -> Void) -> some View {
        modifier(PullToRefreshModifier(isRefreshing: isRefreshing, onRefresh: onRefresh))
    }
}
