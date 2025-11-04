//
//  ProcessingView.swift
//  bigbruhh
//
//  Processing screen after onboarding completion
//  Pushes onboarding data to backend and completes setup
//  Matches React Native version with 2x2 step grid and progress bar
//

import SwiftUI

struct ProcessingStep {
    let label: String
    var status: StepStatus
    
    enum StepStatus {
        case pending
        case processing
        case completed
    }
}

struct ProcessingView: View {
    let onboardingResponse: ConversionOnboardingResponse?

    @State private var isComplete = false
    @State private var error: String?
    @State private var currentStep = 0
    @State private var hasRedirected = false
    @State private var progress: Double = 0.0
    @State private var uploadMessage: String = ""
    @State private var steps: [ProcessingStep] = [
        ProcessingStep(label: "CREATING", status: .pending),
        ProcessingStep(label: "SYNCING", status: .pending),
        ProcessingStep(label: "ENABLING", status: .pending),
        ProcessingStep(label: "READY", status: .pending)
    ]

    // Callback for navigation completion
    var onComplete: (() -> Void)?

    init(onboardingResponse: ConversionOnboardingResponse? = nil, onComplete: (() -> Void)? = nil) {
        self.onboardingResponse = onboardingResponse
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let error = error {
                errorView(error)
            } else {
                processingView
            }
        }
        .onAppear {
            processUser()
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 0) {
                Spacer()
                
                // Logo
            logoView
                
            // Processing Text
            Text(isComplete ? "READY" : "PROCESSING")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                .tracking(3)
                .padding(.bottom, 40)
            
            // Step-by-step processing grid - 2x2
            stepsGridView
            
            // Simple progress bar
            progressBarView
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
    
    private var logoView: some View {
        VStack {
            // Using text logo for now - can be replaced with actual logo image
            Text("BIGBRUH")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
                .tracking(4)
        }
        .padding(.bottom, 40)
    }
    
    private var stepsGridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                stepCard(for: step, at: index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private func stepCard(for step: ProcessingStep, at index: Int) -> some View {
        VStack(spacing: 12) {
            // Step Icon
            stepIcon(for: step.status)
            
            // Step Label
            Text(step.label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(stepTextColor(for: step.status))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(stepBackgroundColor(for: step.status))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(stepBorderColor(for: step.status), lineWidth: 3)
        )
        .cornerRadius(12)
        .opacity(step.status == .pending ? 0.4 : 1.0)
    }
    
    private func stepIcon(for status: ProcessingStep.StepStatus) -> some View {
        Group {
            switch status {
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            case .processing:
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
            case .pending:
                Image(systemName: "circle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(white: 0.4))
            }
        }
    }
    
    private func stepBackgroundColor(for status: ProcessingStep.StepStatus) -> Color {
        switch status {
        case .completed:
            return Color(red: 0.78, green: 0.9, blue: 0.78) // #C8E6C9
        case .processing:
            return Color(red: 0.86, green: 0.08, blue: 0.24) // #DC143C
        case .pending:
            return Color(white: 0.2) // #333333
        }
    }
    
    private func stepBorderColor(for status: ProcessingStep.StepStatus) -> Color {
        switch status {
        case .completed:
            return Color(red: 0.53, green: 0.66, blue: 0.54) // #88a88a
        case .processing:
            return Color(red: 0.55, green: 0, blue: 0) // #8B0000
        case .pending:
            return Color(white: 0.33) // #555555
        }
    }
    
    private func stepTextColor(for status: ProcessingStep.StepStatus) -> Color {
        switch status {
        case .completed:
            return .black
        case .processing:
            return .white
        case .pending:
            return Color(white: 0.4) // #666666
        }
    }
    
    private var progressBarView: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(white: 0.2)) // #333333
                .frame(height: 4)
                .cornerRadius(2)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.86, green: 0.08, blue: 0.24)) // #DC143C
                        .frame(maxWidth: .infinity)
                        .scaleEffect(x: progress, y: 1, anchor: .leading)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.8), value: progress),
                    alignment: .leading
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("SETUP FAILED")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
                .tracking(2)
            
            Button("RESTART") {
                restartProcess()
            }
            .font(.system(size: 16, weight: .black))
            .foregroundColor(.black)
            .tracking(2)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(Color(red: 0.86, green: 0.08, blue: 0.24)) // #DC143C
            .cornerRadius(0)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private func processUser() {
        Task {
            do {
                // Check if we have onboarding data
                guard let response = onboardingResponse else {
                    await MainActor.run {
                        self.error = "No onboarding data found. Please complete onboarding first."
                    }
                    return
                }

                // Step 1: Auth (User verification)
                await updateStepStatus(0, .processing)
                await updateProgress(0.15, duration: 0.5)

                // Verify user is authenticated
                guard AuthService.shared.isAuthenticated else {
                    throw ConversionOnboardingError.userNotAuthenticated
                }

                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await updateStepStatus(0, .completed)

                // Step 2: Data Upload (Voice recordings + onboarding data)
                await updateStepStatus(1, .processing)

                // Upload conversion onboarding data with progress tracking
                let apiResponse = try await ConversionOnboardingService.shared.uploadOnboardingData(
                    response: response,
                    progressCallback: { message, progressValue in
                        Task { @MainActor in
                            self.uploadMessage = message
                            // Map progress 0.0-1.0 to range 0.2-0.7
                            let mappedProgress = 0.2 + (progressValue * 0.5)
                            await self.updateProgress(mappedProgress, duration: 0.3)
                        }
                    }
                )

                if !apiResponse.success {
                    throw ConversionOnboardingError.networkError(
                        NSError(domain: "ConversionUpload", code: 1,
                               userInfo: [NSLocalizedDescriptionKey: apiResponse.error ?? "Upload failed"])
                    )
                }

                print("✅ Conversion onboarding uploaded successfully")
                print("📊 Voice uploads: \(apiResponse.data?.voiceUploads.whyItMatters != nil ? "✅" : "❌") whyItMatters, \(apiResponse.data?.voiceUploads.costOfQuitting != nil ? "✅" : "❌") costOfQuitting, \(apiResponse.data?.voiceUploads.commitment != nil ? "✅" : "❌") commitment")

                await updateStepStatus(1, .completed)

                // Step 3: VoIP Token (Register for push notifications)
                await updateStepStatus(2, .processing)
                await updateProgress(0.85, duration: 0.8)

                // VoIP token registration (already done in ConversionOnboardingService)
                try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

                await updateStepStatus(2, .completed)

                // Step 4: Complete (Finalization)
                await updateStepStatus(3, .processing)
                await updateProgress(1.0, duration: 0.5)

                // Finalization
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

                await updateStepStatus(3, .completed)
            
            // Complete processing
            await MainActor.run {
                    isComplete = true
                    print("✅ Processing completed successfully")
                    
                    // Navigate to home (prevent multiple redirects)
                    if !hasRedirected {
                        hasRedirected = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onComplete?()
                        }
                    }
                }
                
            } catch {
                await MainActor.run {
                    // Handle specific conversion onboarding errors
                    if let conversionError = error as? ConversionOnboardingError {
                        switch conversionError {
                        case .userNotAuthenticated:
                            self.error = "Authentication failed. Please sign in again."
                        case .invalidData:
                            self.error = "No onboarding data found. Please complete onboarding first."
                        case .networkError(let networkError):
                            self.error = "Network error: \(networkError.localizedDescription)"
                        case .voiceRecordingMissing:
                            self.error = "Voice recording missing. Please complete onboarding again."
                        case .voiceConversionFailed(let fileName):
                            self.error = "Failed to process voice recording: \(fileName)"
                        }
                    } else {
                        self.error = "Setup failed. Please try again."
                    }
                    print("❌ Processing failed: \(error)")
                }
            }
        }
    }
    
    private func updateStepStatus(_ index: Int, _ status: ProcessingStep.StepStatus) async {
            await MainActor.run {
            if index < steps.count {
                steps[index].status = status
            }
        }
    }
    
    private func updateProgress(_ value: Double, duration: Double) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: duration)) {
                progress = value
            }
        }
    }
    
    private func restartProcess() {
        error = nil
        isComplete = false
        currentStep = 0
        hasRedirected = false
        progress = 0.0
        steps = [
            ProcessingStep(label: "CREATING", status: .pending),
            ProcessingStep(label: "SYNCING", status: .pending),
            ProcessingStep(label: "ENABLING", status: .pending),
            ProcessingStep(label: "READY", status: .pending)
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            processUser()
        }
    }
}

#Preview {
    ProcessingView()
}
