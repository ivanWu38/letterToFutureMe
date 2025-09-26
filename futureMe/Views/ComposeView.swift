import SwiftUI
import SwiftData


struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject private var languageManager = LanguageManager.shared
    
    
    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var date: Date = Calendar.current.date(byAdding: .minute, value: 2, to: .now) ?? .now
    @State private var img1: Data? = nil
    @State private var img2: Data? = nil
    @State private var isSaving = false
    @State private var error: String?
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("compose.section.title", comment: "")) { TextField(NSLocalizedString("compose.title_placeholder", comment: ""), text: $title) }
                Section(NSLocalizedString("compose.section.message", comment: "")) { TextEditor(text: $bodyText).frame(minHeight: 160) }
                Section(NSLocalizedString("compose.section.delivery_time", comment: "")) {
                    DatePicker(NSLocalizedString("compose.deliver_at", comment: ""), selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                Section(NSLocalizedString("compose.section.photos", comment: "")) {
                    PhotoPickerView(data: $img1, label: NSLocalizedString("compose.photo1", comment: ""))
                    PhotoPickerView(data: $img2, label: NSLocalizedString("compose.photo2", comment: ""))
                }
            }
            .navigationTitle(NSLocalizedString("compose.title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button(NSLocalizedString("compose.button.cancel", comment: ""), role: .cancel) { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("compose.button.schedule", comment: "")) { Task { await save() } }.disabled(isSaving || bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert(NSLocalizedString("compose.alert.error", comment: ""), isPresented: .constant(error != nil), actions: { Button(NSLocalizedString("compose.button.ok", comment: "")) { error = nil } }, message: { Text(error ?? "") })
        }
    }
    
    
    private func save() async {
        guard date >= Date().addingTimeInterval(-60) else { self.error = NSLocalizedString("compose.error.invalid_date", comment: ""); return }
        isSaving = true
        let letter = Letter(title: title, body: bodyText, deliverAt: date, isRead: false, image1: img1, image2: img2)
        print("🐛 Creating letter with title: '\(letter.title)', body: '\(letter.body)', deliverAt: \(letter.deliverAt)")
        context.insert(letter)
        print("🐛 Letter inserted into context")
        do {
            try context.save()
            print("🐛 Context saved successfully")
            try await NotificationManager.shared.schedule(for: letter)
            print("🐛 Notification scheduled successfully")
            isSaving = false
            dismiss()
        } catch {
            print("🐛 Error saving: \(error.localizedDescription)")
            self.error = error.localizedDescription
            isSaving = false
        }
    }
}
