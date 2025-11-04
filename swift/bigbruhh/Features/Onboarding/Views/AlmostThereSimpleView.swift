//
//  AlmostThereSimpleView.swift
//  bigbruhh
//
//  SIMPLE VERSION - Direct navigation, no callbacks
//

import SwiftUI

struct AlmostThereSimpleView: View {
    @EnvironmentObject var navigator: AppNavigator
    @EnvironmentObject var onboardingData: OnboardingDataManager

    @State private var currentStep: Int = 0
    @State private var showChoiceScreen: Bool = false
    @State private var nextPressed = false

    // Concentricity animation state for navigation button only
    @State private var nextRipple = false

    // Personalized data from conversion onboarding
    private var userGoal: String {
        onboardingData.conversionData?.goal ?? "your goal"
    }

    private var favoriteExcuse: String {
        onboardingData.conversionData?.favoriteExcuse ?? "your excuse"
    }

    private var dailyCommitment: String {
        onboardingData.conversionData?.dailyCommitment ?? "your commitment"
    }

    private var strikeLimit: Int {
        onboardingData.conversionData?.strikeLimit ?? 3
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if showChoiceScreen {
                // LEAVE / COMMIT choice (no liquid glass here)
                VStack(spacing: 0) {
                    // Top - LEAVE
                    Button(action: {
                        print("User chose LEAVE")
                        navigator.showHome()
                    }) {
                        VStack {
                            Spacer()
                            Text("LEAVE")
                                .font(.system(size: 80, weight: .black))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)

                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 2)

                    // Bottom - COMMIT
                    Button(action: {
                        print("🔥🔥🔥 User chose COMMIT - SHOWING PAYWALL 🔥🔥🔥")
                        navigator.showPaywall()
                    }) {
                        VStack {
                            Spacer()
                            Text("COMMIT")
                                .font(.system(size: 80, weight: .black))
                                .foregroundColor(Color.brutalRed)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Steps 1-4 with enhanced navigation button
                VStack {
                    Spacer()

                    Text(confrontationSteps[currentStep].prompt)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)

                    Spacer()

                    HStack {
                        Spacer()
                        
                        ZStack {
                            // Concentricity ripple for NEXT button
                            if nextRipple {
                                ForEach(0..<3, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.green.opacity(0.4), lineWidth: 2)
                                        .frame(width: 120, height: 50)
                                        .scaleEffect(nextRipple ? 1.0 + (Double(i) * 0.5) : 1)
                                        .opacity(nextRipple ? 0 : 1)
                                        .animation(.easeOut(duration: 0.8).delay(Double(i) * 0.1), value: nextRipple)
                                }
                            }
                            
                            // Navigation button with liquid glass and concentricity
                            NavigationButton(
                                title: "NEXT →",
                                isPressed: $nextPressed,
                                step: currentStep
                            ) {
                                triggerNextRipple()
                                if currentStep < 3 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStep += 1
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showChoiceScreen = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Concentricity Animation
    
    private func triggerNextRipple() {
        withAnimation {
            nextRipple = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            nextRipple = false
        }
    }

    private let confrontationSteps: [ConfrontationStep] = [
        ConfrontationStep(
            id: 1,
            prompt: "You just told me everything.\n\nYour goal.\nYour pattern.\nYour excuses.\nYour failures.\n\nI heard it all."
        ),
        ConfrontationStep(
            id: 2,
            prompt: "You know what happens next.\n\nEvery. Single. Day.\n\nI call you.\n\nNo excuses.\nNo escape.\nNo mercy."
        ),
        ConfrontationStep(
            id: 3,
            prompt: "THIS ISN'T A GAME.\n\nTHIS IS WAR.\n\nAGAINST YOUR WEAK SELF.\n\nYOU CHOSE THIS.\n\nNOW COMMIT."
        ),
        ConfrontationStep(
            id: 4,
            prompt: "Last chance to quit.\n\nOr...\n\nCommit and never look back.\n\nNo blocking.\nNo deleting.\nNo running.\n\nOnce you pay, I own your accountability.\n\nReady?"
        )
    ]
}

// MARK: - Navigation Button with Liquid Glass and Concentricity

struct NavigationButton: View {
    let title: String
    @Binding var isPressed: Bool
    let step: Int
    let action: () -> Void

    // Color changes based on step
    private var buttonColor: Color {
        switch step {
        case 0:
            return Color(hex: "#90FD0E") // Green for step 1
        case 1:
            return Color(hex: "#FF0000") // Red for step 2
        case 2:
            return Color(hex: "#FF4444") // Lighter red for step 3
        default:
            return Color(hex: "#90FD0E") // Green for other steps
        }
    }

    var body: some View {
        Button(title) {
            action()
        }
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(.black)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .scaleEffect(isPressed ? 1.05 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .modifier(LiquidGlassNavigationModifier(tintColor: buttonColor))
    }
}

// MARK: - Liquid Glass Modifier with iOS Version Check

struct LiquidGlassNavigationModifier: ViewModifier {
    let tintColor: Color

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // iOS 26+ with liquid glass - use tintColor
            content
                .glassEffect(.regular.tint(tintColor.opacity(0.8)).interactive(), in: .rect(cornerRadius: 25))
        } else {
            // iOS 17 and below - fallback styling
            content
                .cornerRadius(25)
        }
    }
}

#Preview {
    AlmostThereSimpleView()
        .environmentObject(AppNavigator())
}
