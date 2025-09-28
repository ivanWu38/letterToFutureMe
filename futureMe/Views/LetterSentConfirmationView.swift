import SwiftUI
import UIKit

struct LetterSentConfirmationView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var isAdPresenting = false
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Background covering entire screen
            Color(red: 0.91, green: 0.84, blue: 0.89)
                .ignoresSafeArea(.all)

            VStack(spacing: 40) {
                Spacer()

                // Success icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.306, green: 0.380, blue: 0.533))
                        .frame(width: 120, height: 120)

                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 130))
                        .foregroundColor(.white)
                }

                // Success message
                VStack(spacing: 16) {
                    Text(NSLocalizedString("confirmation.title", comment: ""))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text(NSLocalizedString("confirmation.message", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Confirm button
                Button(action: handleContinueAction) {
                    Text(NSLocalizedString("confirmation.button.continue", comment: ""))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.306, green: 0.380, blue: 0.533))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isAdPresenting)
                .opacity(isAdPresenting ? 0.6 : 1.0)
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }

        }
    }

    private func handleContinueAction() {
        // Get the root view controller from the window scene
        let presentingViewController = getRootViewController()

        guard let presentingViewController = presentingViewController else {
            print("⚠️ Could not find root view controller, proceeding without ad")
            onDismiss()
            return
        }

        // First dismiss any active keyboard
        presentingViewController.view.endEditing(true)

        isAdPresenting = true

        // Wait for keyboard dismissal and view stabilization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Show interstitial ad after keyboard is dismissed
            AdManager.shared.presentInterstitialAd(from: presentingViewController) {
                // This completion handler is called when the ad is dismissed
                DispatchQueue.main.async { [self] in
                    isAdPresenting = false
                    onDismiss()
                }
            }
        }
    }

    private func getRootViewController() -> UIViewController? {
        // Get the root view controller from the active window scene
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }

        // Find the topmost presented view controller
        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }

        return topViewController
    }
}

#Preview {
    LetterSentConfirmationView(onDismiss: {})
}
