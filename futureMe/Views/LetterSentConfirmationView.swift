import SwiftUI

struct LetterSentConfirmationView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
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
                        .fill(Color(red: 0.102, green: 0.125, blue: 0.184))
                        .frame(width: 120, height: 120)

                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 60))
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
                Button(action: onDismiss) {
                    Text(NSLocalizedString("confirmation.button.continue", comment: ""))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0.102, green: 0.125, blue: 0.184))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    LetterSentConfirmationView(onDismiss: {})
}