import SwiftUI
import SwiftData


struct InboxView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: [SortDescriptor(\Letter.deliverAt, order: .reverse)]) private var letters: [Letter]
    @ObservedObject private var languageManager = LanguageManager.shared
    @State private var selection: Letter?
    @State private var currentTime = Date()


    var deliveredLetters: [Letter] { letters.filter { $0.deliverAt <= currentTime } }
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background image
                    Image("inbox")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(.all)

                    VStack(spacing: 0) {
                        // Top navigation bar
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .opacity(0) // Invisible for balance

                            Spacer()

                            Text(NSLocalizedString("inbox.title", comment: ""))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)

                            Spacer()

                            // Invisible placeholder for balance
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .opacity(0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 20)

                        // Main content area - mostly empty like in design
                        if !deliveredLetters.isEmpty {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(deliveredLetters) { letter in
                                        letterCard(letter)
                                    }
                                }
                                .padding(.horizontal, 20)

                                // Bottom spacing for house
                                Spacer(minLength: 100)
                            }
                        } else {
                            VStack {
                                Spacer()

                                // Empty state - minimal like in design
                                VStack(spacing: 16) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 48))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))

                                    Text(NSLocalizedString("inbox.empty.title", comment: ""))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)

                                    Text(NSLocalizedString("inbox.empty.description", comment: ""))
                                        .font(.system(size: 14))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }

                                Spacer()
                                Spacer()
                            }
                        }
                    }

                }
            }
            .navigationBarHidden(true)
            .onAppear {
                currentTime = Date()
            }
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                currentTime = Date()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                currentTime = Date()
                // mark delivered on foreground
                for l in letters where l.deliverAt <= currentTime && !l.delivered { l.delivered = true }
                try? context.save()
            }
            .onReceive(NotificationManager.shared.$lastOpenedLetterID) { id in
                guard let id, let match = deliveredLetters.first(where: { $0.id == id }) else { return }
                selection = match
                // Update app badge when user opens letter from notification
                updateAppBadgeCount()
            }
            .sheet(item: $selection) { letter in LetterDetailView(letter: letter) }
        }
    }

    private func updateAppBadgeCount() {
        let now = currentTime
        let unreadCount = letters.filter { $0.deliverAt <= now && !$0.isRead }.count
        NotificationManager.shared.updateAppBadge(unreadCount: unreadCount)
    }

    private func letterCard(_ letter: Letter) -> some View {
        Button(action: { selection = letter }) {
            HStack(spacing: 12) {
                // Letter icon
                Image(systemName: {
                    if letter.deliverAt > currentTime {
                        return "clock"
                    } else if letter.isRead {
                        return "envelope.open"
                    } else {
                        return "envelope"
                    }
                }())
                .font(.system(size: 20))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))

                // Letter content
                VStack(alignment: .leading, spacing: 2) {
                    Text(letter.title.isEmpty ? NSLocalizedString("inbox.no_title", comment: "") : letter.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .lineLimit(1)

                    Text(letter.deliverAt, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                }

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
