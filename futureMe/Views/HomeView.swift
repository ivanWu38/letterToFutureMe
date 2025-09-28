import SwiftUI


struct HomeView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @Environment(\.colorScheme) private var colorScheme
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
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 80)

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
                        .padding(.top, 10)

                        Spacer()


                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCompose) { ComposeView() }
            .onReceive(NotificationCenter.default.publisher(for: .init("openCompose"))) { _ in showCompose = true }
        }
    }
}
