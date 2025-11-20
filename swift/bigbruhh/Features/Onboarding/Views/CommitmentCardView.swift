//
//  CommitmentCardView.swift
//  bigbruhh
//
//  Shareable "I committed to my Future Self" card
//  Displayed at the end of onboarding
//

import SwiftUI
import AVKit

struct CommitmentCardView: View {
    let onContinue: () -> Void

    @EnvironmentObject var state: ConversionOnboardingState
    @State private var showShareSheet = false
    @State private var itemsToShare: [Any] = []

    // 3D Interactivity State
    @State private var dragOffset: CGSize = .zero

    // MARK: - Computed Properties

    private var userName: String {
        state.getResponse(forStepId: 4) ?? "ME"
    }

    private var userGoal: String {
        state.getResponse(forStepId: 5) ?? "CHANGE MY LIFE"
    }

    private var dailyCommitment: String {
        // "I have created my future Me, It will call me everyday and keep on track..."
        // We can make this dynamic based on user inputs if needed, but for now using the requested template.
        return "I HAVE CREATED MY FUTURE ME. IT WILL CALL ME EVERYDAY AND KEEP ME ON TRACK."
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // Scanline overlay - subtle monitor effect
            Scanlines()
            // Vignette overlay - focus attention
            Vignette(intensity: 0.5)

            VStack(spacing: 24) {
                Spacer()

                // The Card (Interactive)
                cardView
                    .rotation3DEffect(
                        .degrees(Double(dragOffset.width / 20)),
                        axis: (x: 0, y: -1, z: 0)
                    )
                    .rotation3DEffect(
                        .degrees(Double(dragOffset.height / 20)),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                    dragOffset = .zero
                                }
                            }
                    )
                    .padding(.horizontal, 24)

                Spacer()

                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: shareCard) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                            Text("SHARE COMMITMENT")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1.5)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .applyVoiceGlassEffect(prominent: false, accentColor: .white)

                    Button(action: onContinue) {
                        HStack(spacing: 12) {
                            Text("CONTINUE")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1.5)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(Color.buttonTextColor(for: .brutalRed))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .applyVoiceGlassEffect(prominent: true, accentColor: .brutalRed)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: itemsToShare)
        }
    }

    // MARK: - The Card View

    private var cardView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Row: Logo
            HStack {
                Text("You+")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black.opacity(0.9))

                Spacer()
            }
            .padding(.bottom, 40)

            // Main Content (Dynamic Commitment)
            Text("I COMMITTED TO")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black.opacity(0.5))
                .tracking(2)
                .padding(.bottom, 12)

            Text(dailyCommitment)
                .font(.system(size: 24, weight: .heavy)) // Slightly smaller for longer text
                .foregroundColor(.black)
                .lineLimit(nil) // Allow full text
                .minimumScaleFactor(0.6)
                .lineSpacing(4)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Video Player (if available)
            if let videoURL = state.generatedCommitmentVideoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 180)
                    .cornerRadius(16)
                    .padding(.bottom, 20)
            } else {
                // Placeholder or just spacing if no video
                Spacer()
                    .frame(height: 20)
            }

            // Bottom Row: Mission
            VStack(alignment: .leading, spacing: 8) {
                Text("MISSION:")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black.opacity(0.4))
                    .tracking(1)

                Text(userGoal.uppercased())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(2)
            }
        }
        .padding(32)
        .frame(width: 400, height: 320) // Square aspect ratio
        .background(
            ZStack {
                Color(hex: "#ffffff") // Zinc-900

                // Internal Scanlines (Subtle)
                Scanlines()
                    .opacity(0.15)

                // Gloss/Highlight Effect (for 3D feel)
                LinearGradient(
                    colors: [.black.opacity(0.1), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.5)
            }
        )
        .cornerRadius(32) // Super rounded corners
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        // Shadow for depth
        .shadow(
            color: Color.black.opacity(0.5),
            radius: 20,
            x: 0,
            y: 10
        )
    }

    // MARK: - Helpers

    @MainActor
    private func shareCard() {
        // If we have a generated video, share that!
        if let videoURL = state.generatedCommitmentVideoURL {
            itemsToShare = [videoURL]
            showShareSheet = true
            return
        }

        // Fallback: Render Image
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0

        if let image = renderer.uiImage {
            itemsToShare = [image]
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
