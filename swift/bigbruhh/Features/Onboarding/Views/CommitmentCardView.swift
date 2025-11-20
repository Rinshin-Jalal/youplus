//
//  CommitmentCardView.swift
//  bigbruhh
//
//  Shareable "I committed to my Future Self" card
//  Displayed at the end of onboarding
//

import SwiftUI

struct CommitmentCardView: View {
    let onContinue: () -> Void

    @EnvironmentObject var state: ConversionOnboardingState
    @State private var showShareSheet = false
    @State private var renderedImage: UIImage?

    // MARK: - Computed Properties

    private var userName: String {
        state.getResponse(forStepId: 4) ?? "ME"
    }

    private var userGoal: String {
        state.getResponse(forStepId: 5) ?? "CHANGE MY LIFE"
    }

    private var commitmentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Background scanlines
            Scanlines()
                .opacity(0.3)
                .allowsHitTesting(false)

            VStack(spacing: 24) {
                Spacer()

                // The Card
                cardView
                    .padding(.horizontal, 24)
                    // Add shadow/glow
                    .shadow(color: Color.brutalRed.opacity(0.3), radius: 20, x: 0, y: 0)

                Spacer()

                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: shareCard) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("SHARE COMMITMENT")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(0) // Brutalist - sharp corners
                        .overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 1)
                        )
                    }

                    Button(action: onContinue) {
                        Text("CONTINUE")
                            .font(.headline)
                            .foregroundColor(.white)
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.brutalRed)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheet(activityItems: [image])
            }
        }
    }

    // MARK: - The Card View

    private var cardView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 24))
                    .foregroundColor(.brutalRed)

                Spacer()

                Text("OFFICIAL COMMITMENT")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
            }
            .padding(.bottom, 32)

            // Main Text
            Text("I COMMITTED TO\nMY FUTURE SELF")
                .font(.system(size: 32, weight: .black, design: .default)) // Heavy impact
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)
                .padding(.bottom, 32)

            // Details
            VStack(alignment: .leading, spacing: 16) {
                detailRow(label: "AGENT", value: userName.uppercased())
                Divider().background(Color.white.opacity(0.2))
                detailRow(label: "MISSION", value: userGoal.uppercased())
                Divider().background(Color.white.opacity(0.2))
                detailRow(label: "DATE", value: commitmentDate.uppercased())
            }
            .padding(.bottom, 40)

            // Footer
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NO EXCUSES.")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brutalRed)
                    Text("NO ESCAPE.")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.brutalRed)
                }

                Spacer()

                // "Stamp" or Brand
                VStack(alignment: .trailing, spacing: 2) {
                    Text("BIG BRUH")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                        .italic()

                    Text("VERIFIED")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white)
                        .foregroundColor(.black)
                }
            }
        }
        .padding(32)
        .background(
            ZStack {
                Color.black

                // Subtle texture/noise could go here
                Scanlines()
                    .opacity(0.2)

                // Border
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        )
        // Make it look like a physical card
        .background(Color.black) // Ensure opaque for screenshot
    }

    // MARK: - Helpers

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .tracking(1)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(2)
        }
    }

    @MainActor
    private func shareCard() {
        let renderer = ImageRenderer(content: cardView.frame(width: 350, height: 500))
        renderer.scale = UIScreen.main.scale

        if let image = renderer.uiImage {
            renderedImage = image
            showShareSheet = true
        }
    }
}

// MARK: - Share Sheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct CommitmentCardView_Previews: PreviewProvider {
    static var previews: some View {
        CommitmentCardView(onContinue: {})
            .environmentObject(ConversionOnboardingState())
    }
}
