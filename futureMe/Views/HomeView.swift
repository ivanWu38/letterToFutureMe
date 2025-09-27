import SwiftUI


struct HomeView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    var onSendTapped: () -> Void
    @State private var showCompose = false
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background image
                    Image("home")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(.all)

                    VStack(spacing: 0) {
                        // Title text positioned on the mountain area
                        Text(NSLocalizedString("home.title", comment: ""))
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 80)

                        Spacer()

                        // Send button positioned in the bottom area
                        Button(action: { showCompose = true }) {
                            Text(NSLocalizedString("home.send_letter", comment: ""))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color(red: 0.52, green: 0.58, blue: 0.70))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 180)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCompose) { ComposeView() }
            .onReceive(NotificationCenter.default.publisher(for: .init("openCompose"))) { _ in showCompose = true }
        }
    }
}
