import SwiftUI
import SwiftData


struct InboxView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Letter.deliverAt, order: .reverse)]) private var letters: [Letter]
    @State private var selection: Letter?
    @State private var currentTime = Date()


    var deliveredLetters: [Letter] { letters.filter { $0.deliverAt <= currentTime } }
    
    
    var body: some View {
        NavigationStack {
            List {
                if !deliveredLetters.isEmpty {
                    ForEach(deliveredLetters) { letter in row(letter) }
                } else {
                    ContentUnavailableView(
                        "No Letters Yet",
                        systemImage: "envelope",
                        description: Text("Your future letters will appear here when their delivery time arrives.")
                    )
                }

            }
            .navigationTitle("Inbox")
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
            }
            .sheet(item: $selection) { letter in LetterDetailView(letter: letter) }
        }
    }
    
    
    @ViewBuilder private func row(_ letter: Letter) -> some View {
        Button { selection = letter } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(letter.title.isEmpty ? "(No Title)" : letter.title).font(.headline)
                    Text(letter.deliverAt, style: .date)
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: {
                    if letter.deliverAt > currentTime {
                        return "clock"  // 尚未到達時間
                    } else if letter.isRead {
                        return "envelope.open"  // 已讀
                    } else {
                        return "envelope"  // 未讀但已到達時間
                    }
                }())
            }
        }
    }
}
