import SwiftUI
import Combine

public protocol Splashable: ObservableObject {
    var showHome: () -> Void { get set }
}

struct CallScreenPlaceholder<S: Splashable>: View {
    @ObservedObject private var splashable: S

    public init(splashable: S) {
        self.splashable = splashable
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Phone Icon
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 120, height: 120)

                    Image(systemName: "phone.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("CALL SCREEN")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                    .tracking(2)

                Text("Call screen implementation\ncoming soon")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Spacer()

                Button(action: {
                    splashable.showHome()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                        Text("BACK TO HOME")
                            .font(.system(size: 16, weight: .bold))
                            .tracking(1)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.red)
                    .cornerRadius(8)
                }

                Spacer()
                    .frame(height: 100)
            }
        }
    }
}

struct CallScreenPlaceholder_Previews: PreviewProvider {
    class MockSplashable: Splashable {
        var showHome: () -> Void = {}
    }

    static var previews: some View {
        CallScreenPlaceholder(splashable: MockSplashable())
            .previewDisplayName("Call Screen Placeholder")
    }
}
