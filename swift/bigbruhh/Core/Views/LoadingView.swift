//
//  LoadingView.swift
//  bigbruhh
//
//  Loading screen displayed during app initialization
//

import SwiftUI

struct LoadingView: View {
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.brutalBlack
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Text("BIG BRUH")
                    .font(.headline)
                    .foregroundColor(.brutalRedLight)
                    .brutalStyle()
                    .scaleEffect(pulse)

                ProgressView()
                    .tint(.neonGreen)
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                pulse = 1.05
            }
        }
    }
}

#Preview {
    LoadingView()
}

