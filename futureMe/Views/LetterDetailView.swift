import SwiftUI


struct LetterDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject private var languageManager = LanguageManager.shared
    
    
    @State var letter: Letter
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(letter.title.isEmpty ? NSLocalizedString("letter.untitled", comment: "") : letter.title).font(.nordicHeading())
                    Text(letter.body).font(.body).fixedSize(horizontal: false, vertical: true)
                    if let data = letter.image1, let img = UIImage(data: data) { Image(uiImage: img).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 12)) }
                    if let data = letter.image2, let img = UIImage(data: data) { Image(uiImage: img).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 12)) }
                    HStack { Spacer(); Text(letter.deliverAt, style: .date); Spacer() }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("letter.title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button(NSLocalizedString("letter.button.close", comment: "")) { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) { deleteLetter() } label: { Label(NSLocalizedString("letter.button.delete", comment: ""), systemImage: "trash") }
                        Button(NSLocalizedString("letter.button.reschedule", comment: "")) { reschedule() }
                    } label: { Image(systemName: "ellipsis.circle") }
                }
            }
            .onDisappear {
                // 在用戶關閉信件時標記為已讀，提供更自然的用戶體驗
                markAsReadSilently()
            }
        }
    }


    private func markAsRead() {
        if !letter.isRead {
            print("🐛 Marking letter '\(letter.title)' as read")
            letter.isRead = true
            try? context.save()
        }
    }

    private func markAsReadSilently() {
        if !letter.isRead {
            print("🐛 Silently marking letter '\(letter.title)' as read")
            // 在一個新的任務中異步更新，避免影響當前 UI
            Task {
                await MainActor.run {
                    letter.isRead = true
                    try? context.save()
                }
            }
        }
    }
    
    
    private func deleteLetter() {
        NotificationManager.shared.removePending(id: letter.id)
        context.delete(letter)
        try? context.save()
        dismiss()
    }
    
    
    private func reschedule() {
        // simple example: push one day forward
        letter.deliverAt = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(86400)
        try? context.save()
        Task { try? await NotificationManager.shared.schedule(for: letter) }
    }
}
