//
//  PermissionIcons.swift
//  bigbruhh
//
//  Custom vector graphic icons for permission requests
//  Red-based color scheme for accountability context
//

import SwiftUI

// MARK: - Notification Bell Icon

struct NotificationBellIcon: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Radiating alert waves (background)
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#F7941D").opacity(0.4),
                                Color(hex: "#F7941D").opacity(0.0)
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 140 + CGFloat(index * 30), height: 140 + CGFloat(index * 30))
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 0.0 : 0.6)
                    .animation(
                        .easeOut(duration: 2.0)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.3),
                        value: isAnimating
                    )
            }
            
            // Main bell shape
            ZStack {
                // Bell body
                BellShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#F25C54"),
                                Color(hex: "#FF6B6B")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(hex: "#F25C54").opacity(0.5), radius: 15, x: 0, y: 5)
                
                // Bell clapper
                Circle()
                    .fill(Color(hex: "#FAD6DC"))
                    .frame(width: 8, height: 8)
                    .offset(y: 18)
                
                // Alert badge (top right)
                Circle()
                    .fill(Color(hex: "#F7941D"))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("!")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    )
                    .offset(x: 25, y: -25)
                    .shadow(color: Color(hex: "#F7941D").opacity(0.6), radius: 8, x: 0, y: 2)
            }
            .rotationEffect(.degrees(isAnimating ? -15 : 15))
            .animation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
        }
        .frame(width: 200, height: 200)
        .onAppear {
            isAnimating = true
        }
    }
}

// Custom bell shape
struct BellShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Bell top curve
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.3))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.3),
            control: CGPoint(x: width * 0.5, y: height * 0.05)
        )
        
        // Right side
        path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.7))
        
        // Bottom curve
        path.addQuadCurve(
            to: CGPoint(x: width * 0.15, y: height * 0.7),
            control: CGPoint(x: width * 0.5, y: height * 0.75)
        )
        
        // Left side
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.3))
        
        return path
    }
}

// MARK: - Phone Call Icon

struct PhoneCallIcon: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Sound waves (background)
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FAD6DC").opacity(0.5),
                                Color(hex: "#FAD6DC").opacity(0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 100 + CGFloat(index * 40), height: 100 + CGFloat(index * 40))
                    .rotationEffect(.degrees(-45))
                    .scaleEffect(isAnimating ? 1.3 : 0.9)
                    .opacity(isAnimating ? 0.0 : 0.7)
                    .animation(
                        .easeOut(duration: 1.8)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.25),
                        value: isAnimating
                    )
            }
            
            // Phone handset
            PhoneShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#F25C54"),
                            Color(hex: "#FF6B6B")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .shadow(color: Color(hex: "#F25C54").opacity(0.6), radius: 20, x: 0, y: 8)
                .rotationEffect(.degrees(isAnimating ? -5 : 5))
                .animation(
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Incoming indicator
            Circle()
                .fill(Color(hex: "#FAD6DC"))
                .frame(width: 16, height: 16)
                .overlay(
                    Image(systemName: "arrow.down.left")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(hex: "#F25C54"))
                )
                .offset(x: -35, y: -35)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .frame(width: 200, height: 200)
        .onAppear {
            isAnimating = true
        }
    }
}

// Custom phone shape
struct PhoneShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Phone handset curve
        path.move(to: CGPoint(x: width * 0.25, y: height * 0.15))
        
        // Top earpiece
        path.addQuadCurve(
            to: CGPoint(x: width * 0.45, y: height * 0.25),
            control: CGPoint(x: width * 0.3, y: height * 0.1)
        )
        
        // Middle section
        path.addQuadCurve(
            to: CGPoint(x: width * 0.55, y: height * 0.75),
            control: CGPoint(x: width * 0.5, y: height * 0.5)
        )
        
        // Bottom mouthpiece
        path.addQuadCurve(
            to: CGPoint(x: width * 0.75, y: height * 0.85),
            control: CGPoint(x: width * 0.7, y: height * 0.9)
        )
        
        // Return path (outer edge)
        path.addQuadCurve(
            to: CGPoint(x: width * 0.65, y: height * 0.7),
            control: CGPoint(x: width * 0.8, y: height * 0.8)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.35, y: height * 0.3),
            control: CGPoint(x: width * 0.6, y: height * 0.5)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.25, y: height * 0.15),
            control: CGPoint(x: width * 0.2, y: height * 0.2)
        )
        
        return path
    }
}

// MARK: - Microphone Icon

struct MicrophoneIcon: View {
    @State private var isAnimating = false
    @State private var audioLevel: CGFloat = 0.3
    
    var body: some View {
        ZStack {
            // Audio visualization bars (background)
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#5A7BEF").opacity(0.6),
                                    Color(hex: "#5A7BEF").opacity(0.2)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 6, height: CGFloat.random(in: 30...80))
                        .scaleEffect(y: isAnimating ? CGFloat.random(in: 0.5...1.2) : 0.5)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: isAnimating
                        )
                }
            }
            .offset(x: -80)
            
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#5A7BEF").opacity(0.6),
                                    Color(hex: "#5A7BEF").opacity(0.2)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 6, height: CGFloat.random(in: 30...80))
                        .scaleEffect(y: isAnimating ? CGFloat.random(in: 0.5...1.2) : 0.5)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: isAnimating
                        )
                }
            }
            .offset(x: 80)
            
            // Microphone body
            VStack(spacing: 0) {
                // Mic capsule (top)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#F25C54"),
                                Color(hex: "#FF6B6B")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 40, height: 60)
                    .overlay(
                        // Mic grille lines
                        VStack(spacing: 4) {
                            ForEach(0..<3) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 25, height: 2)
                            }
                        }
                    )
                    .shadow(color: Color(hex: "#F25C54").opacity(0.5), radius: 15, x: 0, y: 5)
                
                // Mic stand
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF6B6B"),
                                Color(hex: "#F25C54")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 20)
                
                // Mic base
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#F25C54"))
                    .frame(width: 50, height: 12)
            }
            
            // Recording indicator
            Circle()
                .fill(Color(hex: "#FF6B6B"))
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                )
                .offset(x: 30, y: -40)
                .scaleEffect(isAnimating ? 1.3 : 1.0)
                .opacity(isAnimating ? 0.5 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .frame(width: 200, height: 200)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview

#Preview("Notification Bell") {
    ZStack {
        Color.black.ignoresSafeArea()
        NotificationBellIcon()
    }
}

#Preview("Phone Call") {
    ZStack {
        Color.black.ignoresSafeArea()
        PhoneCallIcon()
    }
}

#Preview("Microphone") {
    ZStack {
        Color.black.ignoresSafeArea()
        MicrophoneIcon()
    }
}
