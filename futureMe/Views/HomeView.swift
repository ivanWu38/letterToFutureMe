import SwiftUI


struct HomeView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    var onSendTapped: () -> Void
    @State private var showCompose = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28).fill(NordicTheme.bg)
                            .frame(height: 240)
                            .overlay(alignment: .bottomLeading) {
                                // simple geometric landscape
                                GeometryReader { geo in
                                    Path { p in
                                        let w = geo.size.width, h = geo.size.height
                                        p.move(to: .init(x: 0, y: h*0.65))
                                        p.addLine(to: .init(x: w, y: h*0.45))
                                        p.addLine(to: .init(x: w, y: h))
                                        p.addLine(to: .init(x: 0, y: h))
                                        p.closeSubpath()
                                    }.fill(NordicTheme.slate.opacity(0.5))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                            }
                        Text(NSLocalizedString("home.title", comment: "")).font(.nordicTitle())
                    }
                    
                    
                    NordicButton(title: NSLocalizedString("home.send_letter", comment: "")) { showCompose = true }
                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("home").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCompose) { ComposeView() }
            .onReceive(NotificationCenter.default.publisher(for: .init("openCompose"))) { _ in showCompose = true }
        }
    }
}
