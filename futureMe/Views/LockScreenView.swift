import SwiftUI

struct LockScreenView: View {
    @ObservedObject private var appLock = AppLock.shared
    @ObservedObject private var languageManager = LanguageManager.shared

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea(.all)

            VStack(spacing: 40) {
                Spacer()

                // App icon or logo
                VStack(spacing: 20) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)

                    Text("Future Me")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }

                // Lock message
                VStack(spacing: 16) {
                    Text(NSLocalizedString("applock.title", comment: ""))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(NSLocalizedString("applock.message", comment: ""))
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Unlock button
                Button(action: {
                    Task {
                        await appLock.authenticate()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .font(.system(size: 20))

                        Text(NSLocalizedString("applock.unlock", comment: ""))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    LockScreenView()
}